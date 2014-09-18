//
//  EnhanceQueueViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/24/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "EnhanceQueueViewController.h"

#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "SocketCommunication.h"
#import "MonsterPopUpViewController.h"
#import "GameViewController.h"
#import "EnhanceQueueViewController+Animations.h"

#define ENHANCE_FIRST_TIME_DEFAULTS_KEY @"EnhanceFirstTime"

@implementation EnhanceSmallCardCell

- (void) awakeFromNib {
  [super awakeFromNib];
  self.qualityLabel.superview.transform = CGAffineTransformMakeRotation(-M_PI_4);
}

- (void) updateForListObject:(UserMonster *)listObject userEnhancement:(UserEnhancement *)ue {
  MonsterProto *mp = listObject.staticMonster;
  BOOL greyscale = listObject.isProtected;
  
  NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Card.png"];
  [Globals imageNamed:fileName withView:self.monsterIcon greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  NSString *bgdImgName = [Globals imageNameForElement:mp.monsterElement suffix:@"mediumsquare.png"];
  [Globals imageNamed:bgdImgName withView:self.bgdIcon greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  if (listObject.isProtected) {
    self.enhancePercentLabel.text = @"Locked";
  } else {
    int ptsIncrease = [ue experienceIncreaseOfNewUserMonster:listObject];
    self.enhancePercentLabel.text = [NSString stringWithFormat:@"%@xp", [Globals commafyNumber:ptsIncrease]];
  }
  
  self.lockIcon.hidden = !listObject.isProtected;
  
  self.qualityLabel.text = [[Globals shortenedStringForRarity:mp.quality] uppercaseString];
  
  NSString *tagName = [Globals imageNameForRarity:mp.quality suffix:@"band.png"];
  [Globals imageNamed:tagName withView:self.qualityBgdView greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

@end

@implementation EnhanceQueueViewController

- (id) initWithBaseMonster:(UserMonster *)um {
  if ((self = [super init])) {
    EnhancementItem *ei = [[EnhancementItem alloc] init];
    ei.userMonsterId = um.userMonsterId;
    
    UserEnhancement *ue = [[UserEnhancement alloc] init];
    ue.baseMonster = ei;
    ue.feeders = [NSMutableArray array];
    
    _currentEnhancement = ue;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.cardCell = [[NSBundle mainBundle] loadNibNamed:@"EnhanceSmallCardCell" owner:self options:nil][0];
  self.queueCell = [[NSBundle mainBundle] loadNibNamed:@"MonsterQueueCell" owner:self options:nil][0];
  
  self.queueView.isFlipped = YES;
  self.queueView.cellClassName = @"MonsterQueueCell";
  self.listView.cellClassName = @"EnhanceSmallCardCell";
  
  MonsterProto *mp = self.currentEnhancement.baseMonster.userMonster.staticMonster;
  NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamed:fileName withView:self.monsterImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.title = [NSString stringWithFormat:@"Enhance %@", mp.displayName];
  
  self.curExpLabel.superview.layer.cornerRadius = 4.f;
  
  self.selectMobsterLabel.strokeSize = 0.5f;
  self.selectMobsterLabel.strokeColor = [UIColor colorWithRed:127/255.f green:168/255.f blue:39/255.f alpha:1.f];
  
  self.monsterImageView.superview.transform = CGAffineTransformMakeScale(0.8, 0.8);
  
  self.noMobstersLabel.text = [NSString stringWithFormat:@"You have no available %@s.", MONSTER_NAME];
  self.queueEmptyLabel.text = [NSString stringWithFormat:@"Select a %@ below to sacrifice", MONSTER_NAME];
  
  self.buttonSpinner.hidden = YES;
  
  self.monsterGlowIcon.alpha = 0.f;
  self.skipButtonView.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self reloadQueueViewAnimated:NO];
  [self reloadListViewAnimated:NO];
  
  [self updateLabelsNonTimer];
}

- (UserEnhancement *) currentEnhancement {
  return _currentEnhancement;
}

- (int) maxQueueSize {
  GameState *gs = [GameState sharedGameState];
  LabProto *lab = (LabProto *)gs.myLaboratory.staticStruct;
  return lab.queueSize;
}

- (void) waitTimeComplete {
  [self reloadListViewAnimated:YES];
  [self reloadQueueViewAnimated:YES];
  [self updateLabelsNonTimer];
}

- (void) updateLabelsNonTimer {
  Globals *gl = [Globals sharedGlobals];
  
  UserEnhancement *ue = self.currentEnhancement;
  UserMonster *um = ue.baseMonster.userMonster;
  
  int curPerc = floorf([ue currentPercentageOfLevel]*100);
  int newPerc = floorf([ue finalPercentageFromCurrentLevel]*100);
  
  self.curProgressBar.percentage = um.level >= um.staticMonster.maxLevel ? 1.f : curPerc/100.f;
  self.addedProgressBar.percentage = newPerc/100.f;
  
  int additionalNewLevel = (int)(newPerc/100.f);
  int curLevel = um.level;
  int maxLevel = um.staticMonster.maxLevel;
  int afterEnhanceLevel = um.level+additionalNewLevel;
  int newLevel = MIN(curLevel+additionalNewLevel+1, maxLevel+1);
  
  self.curLevelLabel.text = [NSString stringWithFormat:@"Level %d:", curLevel];
  self.afterEnhanceLevelLabel.text = [NSString stringWithFormat:@"Level %d", afterEnhanceLevel];
  self.afterEnhanceLevelLabel.highlighted = um.level < afterEnhanceLevel;
  
  if (newLevel <= maxLevel) {
    int expToNewLevel = [gl calculateExperienceRequiredForMonster:um.monsterId level:newLevel];
    int curExp = [gl calculateExperienceIncrease:ue]+um.experience;
    self.curExpLabel.text = [NSString stringWithFormat:@"%@xp", [Globals commafyNumber:MAX(0, expToNewLevel-curExp)]];
    
    self.nextLevelLabel.text = [NSString stringWithFormat:@"Needed for\nlevel %d", newLevel];
    
    self.curExpLabel.hidden = NO;
    self.nextLevelLabel.hidden = NO;
    self.maxLevelLabel.hidden = YES;
  } else {
    self.curExpLabel.hidden = YES;
    self.nextLevelLabel.hidden = YES;
    self.maxLevelLabel.hidden = NO;
  }
  
  int baseOilCost = [gl calculateOilCostForNewMonsterWithEnhancement:ue feeder:nil];
  self.queueingCostLabel.text = [Globals commafyNumber:baseOilCost];
  [Globals adjustViewForCentering:self.queueingCostLabel.superview withLabel:self.queueingCostLabel];
  
  int totalOilCost = [gl calculateTotalOilCostForEnhancement:ue];
  // Only change it if its not 0 so that when it fades out it doesn't change to 0.
  if (totalOilCost > 0) {
    self.totalQueueCostLabel.text = [Globals commafyNumber:totalOilCost];
    [Globals adjustViewForCentering:self.totalQueueCostLabel.superview withLabel:self.totalQueueCostLabel];
  }
  
  [self updateStats];
}

- (void) updateStats {
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = self.currentEnhancement.baseMonster.userMonster;
  
  int origLevel = um.level;
  int curLevel = origLevel;
  int maxLevel = um.staticMonster.maxLevel;
  
  um.level = curLevel;
  int curAttk = [gl calculateTotalDamageForMonster:um];
  int curHp = [gl calculateMaxHealthForMonster:um];
  int curSpeed = [gl calculateSpeedForMonster:um];
  
  um.level = MIN(curLevel+1, maxLevel);
  int newAttk = [gl calculateTotalDamageForMonster:um];
  int newHp = [gl calculateMaxHealthForMonster:um];
  int newSpeed = [gl calculateSpeedForMonster:um];
  
  um.level = origLevel;
  
  self.attackLabel.text = [NSString stringWithFormat:@"%@%@", [Globals commafyNumber:curAttk], newAttk > curAttk ? [NSString stringWithFormat:@" + %@", [Globals commafyNumber:newAttk-curAttk]] : @""];
  self.healthLabel.text = [NSString stringWithFormat:@"%@%@", [Globals commafyNumber:curHp], newHp > curHp ? [NSString stringWithFormat:@" + %@", [Globals commafyNumber:newHp-curHp]] : @""];
  self.speedLabel.text = [NSString stringWithFormat:@"%@%@", [Globals commafyNumber:curSpeed], newSpeed > curSpeed ? [NSString stringWithFormat:@" + %@", [Globals commafyNumber:newSpeed-curSpeed]] : @""];
}

- (void) updateTimeWithCell:(MonsterQueueCell *)cell {
  UserEnhancement *ue = self.currentEnhancement;
  EnhancementItem *item = ue.feeders[0];
  int timeLeft = [ue expectedEndTimeForItem:item].timeIntervalSinceNow;
  float perc = [ue currentPercentageForItem:item];
  [cell updateTimeWithTimeLeft:timeLeft percent:perc];
}

#pragma mark - Refreshing collection view

- (void) reloadQueueViewAnimated:(BOOL)animated {
  [self.queueView reloadTableAnimated:animated listObjects:self.currentEnhancement.feeders];
  
  if (self.currentEnhancement.feeders.count >= self.maxQueueSize) {
    self.queueArrow.highlighted = YES;
  } else {
    self.queueArrow.highlighted = NO;
  }
}

- (void) reloadListViewAnimated:(BOOL)animated {
  [self reloadMonstersArray];
  [self.listView reloadTableAnimated:animated listObjects:self.userMonsters];
}

- (void) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [NSMutableArray array];
  
  for (UserMonster *um in gs.myMonsters) {
    if (um.isAvailable && um.userMonsterId != self.currentEnhancement.baseMonster.userMonsterId && ![self.currentEnhancement.feeders containsObject:um]) {
      [arr addObject:um];
    }
  }
  
  Globals *gl = [Globals sharedGlobals];
  UserEnhancement *ue = self.currentEnhancement;
  [arr sortUsingComparator:^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    if (obj1.isProtected != obj2.isProtected) {
      return [@(obj1.isProtected) compare:@(obj2.isProtected)];
    }
    
    EnhancementItem *ei = [[EnhancementItem alloc] init];
    ei.userMonsterId = obj1.userMonsterId;
    float exp1 = [gl calculateExperienceIncrease:ue.baseMonster feeder:ei];
    
    ei.userMonsterId = obj2.userMonsterId;
    float exp2 = [gl calculateExperienceIncrease:ue.baseMonster feeder:ei];
    if (exp1 != exp2) {
      return [@(exp2) compare:@(exp1)];
    } else {
      return [obj1 compare:obj2];
    }
  }];
  
  self.userMonsters = arr;
}

#pragma mark - MonsterListView delegate

- (void) listView:(ListCollectionView *)listView updateCell:(MonsterListCell *)cell forIndexPath:(NSIndexPath *)ip listObject:(id)listObject {
  UserEnhancement *ue = self.currentEnhancement;
  if (listView == self.listView) {
    [(EnhanceSmallCardCell *)cell updateForListObject:listObject userEnhancement:ue];
  } else {
    UserMonster *um = [listObject isKindOfClass:[EnhancementItem class]] ? [listObject userMonster] : listObject;
    [cell updateForListObject:um];
    
    MonsterQueueCell *queue = (MonsterQueueCell *)cell;
    queue.botLabel.hidden = NO;
      
    int num = [ue experienceIncreaseOfNewUserMonster:um];
    queue.botLabel.text = [NSString stringWithFormat:@"%@xp", [Globals commafyNumber:num]];
  }
}

#pragma mark List

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.userMonsters[indexPath.row];
  if (!um.isProtected) {
    if (!_waitingForResponse) {
      _confirmUserMonster = self.userMonsters[indexPath.row];
      [self checkMonsterIsNotMaxed];
    }
  } else {
    MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:um allowSell:YES];
    UIViewController *parent = [GameViewController baseController];
    mpvc.view.frame = parent.view.bounds;
    [parent.view addSubview:mpvc.view];
    [parent addChildViewController:mpvc];
  }
}

- (void) checkMonsterIsNotMaxed {
  UserEnhancement *ue = self.currentEnhancement;
  
  float percIncrease = [ue percentageIncreaseOfNewUserMonster:_confirmUserMonster roundToPercent:NO];
  
  if (percIncrease) {
    [self checkUserMonsterOnTeam];
  } else {
    UserMonster *um = ue.baseMonster.userMonster;
    if (um.level >= um.staticMonster.maxLevel) {
      [Globals addAlertNotification:[NSString stringWithFormat:@"Oops, this %@ is already at max level.", MONSTER_NAME]];
    } else {
      [Globals addAlertNotification:[NSString stringWithFormat:@"Oops, you already have enough to max this %@.", MONSTER_NAME]];
    }
  }
}

- (void) checkUserMonsterOnTeam {
  UserMonster *um = _confirmUserMonster;
  if (um.teamSlot > 0) {
    NSString *description = [NSString stringWithFormat:@"This %@ is currently on your team. Continue?", MONSTER_NAME];
    [GenericPopupController displayConfirmationWithDescription:description title:@"Continue?" okayButton:@"Continue" cancelButton:@"Cancel" target:self selector:@selector(confirmationAccepted)];
  } else {
    [self confirmationAccepted];
  }
}

- (void) confirmationAccepted {
  if (self.currentEnhancement.feeders.count >= self.maxQueueSize) {
    [Globals addAlertNotification:@"The laboratory queue is already full!"];
  } else {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if (![def boolForKey:ENHANCE_FIRST_TIME_DEFAULTS_KEY]) {
      NSString *str = [NSString stringWithFormat:@"You will lose this %@ by sacrificing it for enhancement. Continue?", MONSTER_NAME];
      [GenericPopupController displayConfirmationWithDescription:str title:[NSString stringWithFormat:@"Sacrifice %@?", MONSTER_NAME] okayButton:@"Sacrifice" cancelButton:@"Cancel" target:self selector:@selector(allowAddToQueue)];
    } else {
      [self allowAddToQueue];
    }
  }
}

- (void) allowAddToQueue {
  if (!_waitingForResponse) {
    Globals *gl = [Globals sharedGlobals];
    UserMonster *um = _confirmUserMonster;
    UserEnhancement *ue = self.currentEnhancement;
    
    EnhancementItem *ei = [[EnhancementItem alloc] init];
    ei.userMonsterId = um.userMonsterId;
    ei.enhancementCost = [gl calculateOilCostForNewMonsterWithEnhancement:ue feeder:ei];
    [ue.feeders addObject:ei];
    
    [self reloadQueueViewAnimated:YES];
    [self animateUserMonsterIntoQueue:_confirmUserMonster];
    [self reloadListViewAnimated:YES];
    
    [self updateLabelsNonTimer];
    
    _confirmUserMonster = nil;
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:YES forKey:ENHANCE_FIRST_TIME_DEFAULTS_KEY];
  } else {
    [Globals addAlertNotification:@"Hold on, we are still processing your previous request."];
  }
}

- (void) animateUserMonsterIntoQueue:(UserMonster *)um {
  int monsterIndex = (int)[self.userMonsters indexOfObject:um];
  MonsterListCell *cardCell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:monsterIndex inSection:0]];
  
  monsterIndex = (int)[self.queueView.listObjects indexOfObject:um];
  NSIndexPath *ip = [NSIndexPath indexPathForItem:monsterIndex inSection:0];
  MonsterQueueCell *queueCell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:ip];
  
  if (cardCell && queueCell) {
    // Make listView update it instead so exp shows up
    //[self.queueCell updateForListObject:um];
    [self listView:self.queueView updateCell:self.queueCell forIndexPath:ip listObject:self.currentEnhancement.feeders[ip.row]];
    [self.cardCell updateForListObject:um userEnhancement:self.currentEnhancement];
    self.cardCell.enhancePercentLabel.text = cardCell.enhancePercentLabel.text;
    
    [self.view addSubview:self.queueCell];
    [self.view insertSubview:self.cardCell belowSubview:self.queueView];
    
    [Globals animateStartView:cardCell toEndView:queueCell fakeStartView:self.cardCell fakeEndView:self.queueCell];
  } else {
    [self.queueView.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
  }
}

#pragma mark Queue

- (void) listView:(ListCollectionView *)listView minusClickedAtIndexPath:(NSIndexPath *)indexPath {
  if (!_waitingForResponse) {
    EnhancementItem *ei = self.currentEnhancement.feeders[indexPath.row];
    [self.currentEnhancement.feeders removeObjectAtIndex:indexPath.row];
    
    [self reloadListViewAnimated:YES];
    [self animateEnhancementItemOutOfQueue:ei];
    [self reloadQueueViewAnimated:YES];
    
    [self updateLabelsNonTimer];
  }
}

- (void) animateEnhancementItemOutOfQueue:(EnhancementItem *)ei {
  int monsterIndex = (int)[self.userMonsters indexOfObject:ei];
  NSIndexPath *ip = [NSIndexPath indexPathForRow:monsterIndex inSection:0];
  MonsterListCell *cardCell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:ip];
  
  monsterIndex = (int)[self.queueView.listObjects indexOfObject:ei];
  MonsterQueueCell *queueCell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:monsterIndex inSection:0]];
  
  if (cardCell && queueCell) {
    [self.queueCell updateForListObject:ei.userMonster];
    [self.cardCell updateForListObject:ei.userMonster userEnhancement:self.currentEnhancement];
    
    [self.view addSubview:self.queueCell];
    [self.view insertSubview:self.cardCell belowSubview:self.queueView];
    
    [Globals animateStartView:queueCell toEndView:cardCell fakeStartView:self.queueCell fakeEndView:self.cardCell];
  } else {
    [self.listView.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
  }
}

#pragma mark - Sending Enhancement

- (IBAction) enhanceButtonClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];

  int oilCost = [gl calculateTotalOilCostForEnhancement:self.currentEnhancement];
  int curAmount = gs.oil;
  if (oilCost > curAmount) {
    [GenericPopupController displayExchangeForGemsViewWithResourceType:ResourceTypeOil amount:oilCost-curAmount target:self selector:@selector(useGemsForEnhance)];
  } else {
    [self sendEnhanceAllowGems:NO];
  }
}

- (void) useGemsForEnhance {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];

  int cost = [gl calculateTotalOilCostForEnhancement:self.currentEnhancement];
  int curAmount = gs.oil;
  int gemCost = [gl calculateGemConversionForResourceType:ResourceTypeOil amount:cost-curAmount];

  if (gemCost > gs.gems) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [self sendEnhanceAllowGems:YES];
  }
}

- (void) sendEnhanceAllowGems:(BOOL)allowGems {
  if (!_waitingForResponse) {
    // We must set the enhancement item's user monster to fake monsters so that they can be animated
    UserEnhancement *ue = self.currentEnhancement;
    UserMonster *baseUm = ue.baseMonster.userMonster.copy;
    for (EnhancementItem *ei in ue.feeders) {
      [ei setFakedUserMonster:ei.userMonster.copy];
    }
    
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] enhanceMonster:self.currentEnhancement useGems:allowGems delegate:self];
    
    // Must do this after so that OutgoingEventController edits the actual user monster and not our fake one
    // For the enhancement items it doesn't matter so much since those will be removed from the array based on userMonsterId.
    [ue.baseMonster setFakedUserMonster:baseUm];
    
    if (success) {
      self.buttonLabelsView.hidden = YES;
      self.buttonSpinner.hidden = NO;
      [self.buttonSpinner startAnimating];
      
      // Clear the feeders list..
      // Don't clear here, it will auto clear through the process of the animation?
      //[self.currentEnhancement.feeders removeAllObjects];
      
      _waitingForResponse = YES;
    } else {
      // Set it back
      [ue.baseMonster setFakedUserMonster:nil];
      for (EnhancementItem *ei in ue.feeders) {
        [ei setFakedUserMonster:nil];
      }
    }
  }
}

- (void) handleEnhanceMonsterResponseProto:(FullEvent *)fe {
  self.buttonLabelsView.hidden = NO;
  self.buttonSpinner.hidden = YES;
  
  [self animateEnhancement];
  
//  [self reloadListViewAnimated:YES];
//  [self reloadQueueViewAnimated:YES];
//  [self updateLabelsNonTimer];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:ENHANCE_MONSTER_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  
  _waitingForResponse = NO;
}

- (IBAction)skipCLicked:(id)sender {
  [self speedupEnhancement];
}

@end
