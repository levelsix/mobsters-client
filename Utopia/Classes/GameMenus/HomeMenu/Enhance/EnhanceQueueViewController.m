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
#import "MiniEventManager.h"

#import "DailyEventViewController.h"

#define ENHANCE_FIRST_TIME_DEFAULTS_KEY @"EnhanceFirstTime2"

@implementation EnhanceSmallCardCell

- (void) awakeFromNib {
  [super awakeFromNib];
  self.qualityLabel.superview.transform = CGAffineTransformMakeRotation(-M_PI_4);
}

- (void) updateForListObject:(UserMonster *)listObject userEnhancement:(UserEnhancement *)ue {
  MonsterProto *mp = listObject.staticMonster;
  BOOL greyscale = listObject.isProtected || ue.isActive;
  
  NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Card.png"];
  [Globals imageNamed:fileName withView:self.monsterIcon greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  NSString *bgdImgName = [Globals imageNameForElement:mp.monsterElement suffix:@"mediumsquare.png"];
  [Globals imageNamed:bgdImgName withView:self.bgdIcon greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  [self.evoBadge updateForToon:mp greyscale:greyscale];
  
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

static int listViewContentOffset = 0.f;

- (id) initWithBaseMonster:(UserMonster *)um {
  // Changed to [self init] for tutorial vc
  if ((self = [self init])) {
    EnhancementItem *ei = [[EnhancementItem alloc] init];
    ei.userMonsterUuid = um.userMonsterUuid;
    
    UserEnhancement *ue = [[UserEnhancement alloc] init];
    ue.baseMonster = ei;
    ue.feeders = [NSMutableArray array];
    
    _currentEnhancement = ue;
  }
  return self;
}

- (id) initWithCurrentEnhancement {
  if ((self = [super init])) {
    GameState *gs = [GameState sharedGameState];
    _currentEnhancement = gs.userEnhancement;
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
  [Globals imageNamed:fileName withView:self.monsterImageView maskedColor:nil greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES useiPhone6Prefix:YES useiPadSuffix:YES];
  
  self.titleImageName = @"enhancelabmenuheader.png";
  
  self.curExpLabel.superview.layer.cornerRadius = POPUP_CORNER_RADIUS;
  
  self.selectMobsterLabel.strokeSize = 0.5f;
  self.selectMobsterLabel.strokeColor = [UIColor colorWithRed:127/255.f green:168/255.f blue:39/255.f alpha:1.f];
  
  self.monsterImageView.superview.transform = CGAffineTransformMakeScale(0.8, 0.8);
  
  if ([Globals isiPhone6] || [Globals isiPhone6Plus]) {
    self.monsterImageView.transform = CGAffineTransformMakeScale(0.82, 0.82);
  }
  
  self.noMobstersLabel.text = [NSString stringWithFormat:@"You have no available %@s.", MONSTER_NAME];
  self.queueEmptyLabel.text = [NSString stringWithFormat:@"Select a %@ to sacrifice", MONSTER_NAME];
  self.costTitleLabel.text = [NSString stringWithFormat:@"%@ Cost", MONSTER_NAME];
  
  self.buttonSpinner.hidden = YES;
  
  self.monsterGlowIcon.alpha = 0.f;
  self.skipButtonView.hidden = YES;
  
  self.leftCornerView = [[NSBundle mainBundle] loadNibNamed:@"DailyEventCornerView" owner:self options:nil][0];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self reloadQueueViewAnimated:NO];
  [self reloadListViewAnimated:NO];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabels) name:RECEIVED_CLAN_HELP_NOTIFICATION object:nil];
  [self updateLabelsNonTimer];
  
  DailyEventCornerView *cv = (DailyEventCornerView *)self.leftCornerView;
  cv.delegate = self;
  [cv updateForEnhance];
  
  [[SocketCommunication sharedSocketCommunication] pauseFlushTimer];
  
  self.listView.collectionView.contentOffset = CGPointMake(listViewContentOffset, 0.f);
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self.itemSelectViewController closeClicked:nil];
  
  [[SocketCommunication sharedSocketCommunication] flush];
  [[SocketCommunication sharedSocketCommunication] resumeFlushTimer];
  
  if (!_isClosing) {
    listViewContentOffset = self.listView.collectionView.contentOffset.x;
  }
}

- (BOOL) canClose {
  listViewContentOffset = 0.f;
  _isClosing = YES;
  return YES;
}

- (int) maxQueueSize {
  GameState *gs = [GameState sharedGameState];
  LabProto *lab = (LabProto *)gs.myLaboratory.staticStructForCurrentConstructionLevel;
  
  int researchFactor = [gs.researchUtil amountBenefitForType:ResearchTypeIncreaseEnhanceQueue];
  
  return lab.queueSize+researchFactor;
}

- (UserEnhancement *) currentEnhancement {
  return _currentEnhancement;
}

- (NSAttributedString *) attributedTitle {
  // DO it based on gs's enhancement since that will dictate whether we are base vc or not
  GameState *gs = [GameState sharedGameState];
  if (gs.userEnhancement) {
    GameState *gs = [GameState sharedGameState];
    
    int cur = [gs currentlyUsedInventorySlots];
    int max = [gs maxInventorySlots];
    
    NSString *s1 = [NSString stringWithFormat:@"ENHANCE %@S ", MONSTER_NAME.uppercaseString];
    NSString *s2 = cur > max ? [NSString stringWithFormat:@"(%d/%d)", cur, max] : @"";
    NSString *str = [NSString stringWithFormat:@"%@%@", s1, s2];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:nil];
    
    if (cur > max) {
      [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:219/255.f green:1/255.f blue:0.f alpha:1.f] range:NSMakeRange(s1.length, str.length-s1.length)];
    }
    return attrStr;
  } else {
    MonsterProto *mp = self.currentEnhancement.baseMonster.userMonster.staticMonster;
    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Enhance %@", mp.displayName]];
  }
}

- (void) waitTimeComplete {
  [self reloadListViewAnimated:YES];
  [self reloadQueueViewAnimated:YES];
  [self updateLabelsNonTimer];
}

- (void) eventCornerViewClicked:(id)sender {
  if ([Globals shouldShowFatKidDungeon]) {
    DailyEventViewController *evc = [[DailyEventViewController alloc] init];
    [self.parentViewController pushViewController:evc animated:YES];
    [evc updateForEnhance];
  } else {
    GameState *gs = [GameState sharedGameState];
    UserStruct *us = gs.myLaboratory;
    [Globals addAlertNotification:[NSString stringWithFormat:@"You must upgrade your %@ to Level %d to access Cake Kid events.", us.staticStruct.structInfo.name, FAT_KID_DUNGEON_LEVEL]];
  }
}

- (void) updateLabelsNonTimer {
  if (_waitingForResponse) {
    // Do nothing
    return;
  }
  
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
    
    self.nextLevelLabel.text = [NSString stringWithFormat:@"to level %d", newLevel];
    
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
  
  [self updateStats];
  [self updateLabels];
}

- (void) updateLabels {
  if (_waitingForResponse) {
    // Do nothing
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserEnhancement *ue = self.currentEnhancement;
  
  self.oilButtonView.hidden = YES;
  self.finishButtonView.hidden = YES;
  self.helpButtonView.hidden = YES;
  self.collectButtonView.hidden = YES;
  
  self.totalTimeLabel.highlighted = NO;
  
  MSDate *date = [ue expectedEndTime];
  if (!date) {
    int totalOilCost = [gl calculateTotalOilCostForEnhancement:ue];
    // Only change it if its not 0 so that when it fades out it doesn't change to 0.
    if (totalOilCost > 0) {
      self.totalQueueCostLabel.text = [Globals commafyNumber:totalOilCost];
      [Globals adjustViewForCentering:self.totalQueueCostLabel.superview withLabel:self.totalQueueCostLabel];
    }
    
    int time = ue.totalSeconds;
    if (time > 0) {
      self.totalTimeLabel.text = [[Globals convertTimeToShortString:time] uppercaseString];
    }
    
    self.oilButtonView.hidden = NO;
  } else if (ue.isComplete) {
    self.totalTimeLabel.highlighted = YES;
    self.totalTimeLabel.text = @"Complete!";
    
    self.collectButtonView.hidden = NO;
    
    [self.itemSelectViewController closeClicked:nil];
  } else {
    // Timer
    int timeLeft = date.timeIntervalSinceNow;
    int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    
    self.totalTimeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    
    BOOL canHelp = [gs canAskForClanHelp] && [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeEnhanceTime userDataUuid:ue.baseMonster.userMonsterUuid] < 0;
    
    self.finishButtonView.hidden = NO;
    
    if (speedupCost > 0) {
      self.speedupIcon.hidden = NO;
      self.freeLabel.hidden = YES;
      
      self.helpButtonView.hidden = !canHelp;
    } else {
      self.speedupIcon.hidden = YES;
      self.freeLabel.hidden = NO;
      self.helpButtonView.hidden = YES;
    }
    
    for (MonsterQueueCell *cell in self.queueView.collectionView.visibleCells) {
      NSIndexPath *ip = [self.queueView.collectionView indexPathForCell:cell];
      [self listView:self.queueView updateCell:cell forIndexPath:ip listObject:self.currentEnhancement.feeders[ip.row]];
    }
  }
  
  DailyEventCornerView *cv = (DailyEventCornerView *)self.leftCornerView;
  [cv updateLabels];
}

- (void) updateStats {
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = self.currentEnhancement.baseMonster.userMonster;
  
  int origLevel = um.level;
  int curLevel = origLevel;
  int maxLevel = um.staticMonster.maxLevel;
  BOOL isAtMax = origLevel == maxLevel;
  
  um.level = curLevel;
  int curAttk = [gl calculateTotalDamageForMonster:um];
  int curHp = [gl calculateMaxHealthForMonster:um];
  int curSpeed = [gl calculateSpeedForMonster:um];
  int curStrength = [gl calculateStrengthForMonster:um];
  
  um.level = MIN(curLevel+1, maxLevel);
  int newAttk = [gl calculateTotalDamageForMonster:um];
  int newHp = [gl calculateMaxHealthForMonster:um];
  int newSpeed = [gl calculateSpeedForMonster:um];
  int newStrength = [gl calculateStrengthForMonster:um];
  
  um.level = origLevel;
  
  self.attackLabel.text = [NSString stringWithFormat:@"%@%@", [Globals commafyNumber:curAttk], newAttk > curAttk ? [NSString stringWithFormat:@" + %@", [Globals commafyNumber:newAttk-curAttk]] : @""];
  self.healthLabel.text = [NSString stringWithFormat:@"%@%@", [Globals commafyNumber:curHp], newHp > curHp ? [NSString stringWithFormat:@" + %@", [Globals commafyNumber:newHp-curHp]] : @""];
  self.speedLabel.text = [NSString stringWithFormat:@"%@%@", [Globals commafyNumber:curSpeed], newSpeed > curSpeed ? [NSString stringWithFormat:@" + %@", [Globals commafyNumber:newSpeed-curSpeed]] : @""];
  self.strengthLabel.text = !isAtMax ? [NSString stringWithFormat:@"+%@", [Globals commafyNumber:newStrength-curStrength]] : [NSString stringWithFormat:@"%@", [Globals commafyNumber:curStrength]];
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
    if (um.isAvailable && ![um.userMonsterUuid isEqualToString:self.currentEnhancement.baseMonster.userMonsterUuid] && ![self.currentEnhancement.feeders containsObject:um]) {
      [arr addObject:um];
    }
  }
  
  Globals *gl = [Globals sharedGlobals];
  UserEnhancement *ue = self.currentEnhancement;
  
  LabProto *lab = (LabProto *)[[gs myLaboratory] staticStruct];
  UserMonster *base = ue.baseMonster.userMonster;
  MonsterProto *baseMp = base.staticMonster;
  float researchBonus = [gs.researchUtil percentageBenefitForType:ResearchTypeXpBonus element:baseMp.monsterElement evoTier:baseMp.evolutionLevel];
  
  [arr sortUsingComparator:^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    if (obj1.isProtected != obj2.isProtected) {
      return [@(obj1.isProtected) compare:@(obj2.isProtected)];
    }
    
    float exp1 = [gl calculateUserMonsterExperienceIncrease:base feeder:obj1 lab:lab researchBonus:researchBonus];
    float exp2 = [gl calculateUserMonsterExperienceIncrease:base feeder:obj2 lab:lab researchBonus:researchBonus];
    
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
    EnhancementItem *ei = [listObject isKindOfClass:[EnhancementItem class]] ? listObject : nil;
    [cell updateForListObject:um];
    
    MonsterQueueCell *queue = (MonsterQueueCell *)cell;
    if (!ue.isActive) {
      queue.minusButton.hidden = NO;
      
      queue.botLabel.hidden = NO;
      
      int num = [ue experienceIncreaseOfNewUserMonster:um];
      queue.botLabel.text = [NSString stringWithFormat:@"%@xp", [Globals commafyNumber:num]];
    } else {
      queue.minusButton.hidden = YES;
      
      float percent = ue.isComplete ?: [ue currentPercentageForItem:ei];
      
      if (percent >= 1.f) {
        queue.checkView.hidden = NO;
      } else if (percent > 0.f) {
        int timeLeft = [ue expectedEndTimeForItem:ei].timeIntervalSinceNow;
        
        [queue updateTimeWithTimeLeft:timeLeft percent:percent];
      }
    }
  }
}

#pragma mark List

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.userMonsters[indexPath.row];
  if (!um.isProtected && !self.currentEnhancement.isActive) {
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
    // Disabled for enhance tutorial
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
  if (!_waitingForResponse && !self.currentEnhancement.isActive) {
    Globals *gl = [Globals sharedGlobals];
    UserMonster *um = _confirmUserMonster;
    UserEnhancement *ue = self.currentEnhancement;
    
    EnhancementItem *ei = [[EnhancementItem alloc] init];
    ei.userMonsterUuid = um.userMonsterUuid;
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
  if (!_waitingForResponse && !self.currentEnhancement.isActive) {
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
  _buttonSender = sender;
  
  NSMutableDictionary *qualDict = [NSMutableDictionary dictionary];
  
  for (EnhancementItem *ei in self.currentEnhancement.feeders) {
    Quality qual = ei.userMonster.staticMonster.quality;
    
    if (qual >= QualityRare) {
      NSNumber *num = qualDict[@(qual)];
      qualDict[@(qual)] = @([num intValue]+1);
    }
  }
  
  NSArray *rarities = [[qualDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
  
  NSString *rStr = @"";
  
  if (rarities.count > 0) {
    if (rarities.count == 1) {
      Quality q = [rarities[0] intValue];
      int num = [qualDict[@(q)] intValue];
      
      NSString *article = [NSString stringWithFormat:@"a%@ ", q == QualityUltra || q == QualityEpic ? @"n" : @""];
      rStr = [NSString stringWithFormat:@"%@%@ %@%@", num == 1 ? article : @"", [Globals stringForRarity:q], MONSTER_NAME, num == 1 ? @"" : @"s"];
    } else {
      NSMutableString *mut = [NSMutableString string];
      
      if (rarities.count == 2) {
        Quality q = [rarities[0] intValue];
        [mut appendFormat:@"%@ ", [Globals stringForRarity:q]];
      } else {
        for (int i = 0; i < rarities.count-1; i++) {
          Quality q = [rarities[i] intValue];
          [mut appendFormat:@"%@, ", [Globals stringForRarity:q]];
        }
      }
      
      Quality q = [rarities.lastObject intValue];
      [mut appendFormat:@"and %@ %@s", [Globals stringForRarity:q], MONSTER_NAME];
      
      rStr = mut;
    }
    
    NSString *str = [NSString stringWithFormat:@"You are about to sacrifice %@. Continue?", rStr];
    [GenericPopupController displayConfirmationWithDescription:str title:[NSString stringWithFormat:@"Sacrifice %@?", MONSTER_NAME] okayButton:@"Sacrifice" cancelButton:@"Cancel" target:self selector:@selector(enhanceConfirmed)];
  } else {
    [self enhanceConfirmed];
  }
}

- (void) enhanceConfirmed {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  int oilCost = [gl calculateTotalOilCostForEnhancement:self.currentEnhancement];
  int curAmount = gs.oil;
  if (oilCost > curAmount) {
    ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
    if (svc) {
      ResourceItemsFiller *rif = [[ResourceItemsFiller alloc] initWithResourceType:ResourceTypeOil requiredAmount:oilCost shouldAccumulate:YES];
      rif.delegate = self;
      svc.delegate = rif;
      self.itemSelectViewController = svc;
      self.resourceItemsFiller = rif;
      
      GameViewController *gvc = [GameViewController baseController];
      svc.view.frame = gvc.view.bounds;
      [gvc addChildViewController:svc];
      [gvc.view addSubview:svc.view];
      
      if (_buttonSender == nil)
      {
        [svc showCenteredOnScreen];
      }
      else
      {
        if ([_buttonSender isKindOfClass:[UIButton class]]) // Enhance mobster
        {
          UIButton* invokingButton = (UIButton*)_buttonSender;
          [svc showAnchoredToInvokingView:invokingButton withDirection:ViewAnchoringPreferLeftPlacement inkovingViewImage:invokingButton.currentImage];
        }
      }
    }
  } else {
    [self sendEnhanceWithItemsDict:nil allowGems:NO];
  }
  
  _buttonSender = nil;
}

- (void) enhanceWithItemsDict:(NSDictionary *)itemIdsToQuantity {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  BOOL allowGems = [itemIdsToQuantity[@0] boolValue];
  
  int cost = [gl calculateTotalOilCostForEnhancement:self.currentEnhancement];
  ResourceType resType = ResourceTypeOil;
  
  int curAmount = [gl calculateTotalResourcesForResourceType:resType itemIdsToQuantity:itemIdsToQuantity];
  int gemCost = [gl calculateGemConversionForResourceType:resType amount:cost-curAmount];
  
  if (allowGems && gemCost > gs.gems) {
    [GenericPopupController displayNotEnoughGemsView];
  } else if (allowGems || cost <= curAmount) {
    [self sendEnhanceWithItemsDict:itemIdsToQuantity allowGems:allowGems];
  }
}

- (void) sendEnhanceWithItemsDict:(NSDictionary *)itemIdsToQuantity allowGems:(BOOL)allowGems {
  if (!_waitingForResponse) {
    [[OutgoingEventController sharedOutgoingEventController] tradeItemIdsForResources:itemIdsToQuantity];
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] submitEnhancement:self.currentEnhancement useGems:allowGems delegate:self];
    
    if (success) {
      self.oilLabelsView.hidden = YES;
      self.buttonSpinner.hidden = NO;
      [self.buttonSpinner startAnimating];
      
      _waitingForResponse = YES;
    }
  }
}

- (void) handleSubmitMonsterEnhancementResponseProto:(FullEvent *)fe {
  self.oilLabelsView.hidden = NO;
  self.buttonSpinner.hidden = YES;
  
  _waitingForResponse = NO;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:ENHANCE_MONSTER_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
}

- (IBAction)skipCLicked:(id)sender {
  [self speedupEnhancementAnimation];
}

- (IBAction)helpClicked:(id)sender {
  
  if (!_waitingForResponse) {
    [[OutgoingEventController sharedOutgoingEventController] solicitEnhanceHelp:self.currentEnhancement];
    [self updateLabels];
  }
}

- (IBAction)finishClicked:(id)sender {
  if (!_waitingForResponse) {
    Globals *gl = [Globals sharedGlobals];
    UserEnhancement *ue = [self currentEnhancement];
    int timeLeft = ue.expectedEndTime.timeIntervalSinceNow;
    int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    
    if (goldCost <= 0) {
      [self speedupEnhancement];
    } else {
      ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
      if (svc) {
        SpeedupItemsFiller *sif = [[SpeedupItemsFiller alloc] initWithGameActionType:GameActionTypeEnhanceTime];
        sif.delegate = self;
        svc.delegate = sif;
        self.speedupItemsFiller = sif;
        self.itemSelectViewController = svc;
        
        GameViewController *gvc = [GameViewController baseController];
        svc.view.frame = gvc.view.bounds;
        [gvc addChildViewController:svc];
        [gvc.view addSubview:svc.view];
        
        if (sender == nil)
        {
          [svc showCenteredOnScreen];
        }
        else
        {
          if ([sender isKindOfClass:[TimerCell class]]) // Invoked from TimerAction
          {
            UIButton* invokingButton = ((TimerCell*)sender).speedupButton;
            const CGPoint invokingViewAbsolutePosition = [Globals convertPointToWindowCoordinates:invokingButton.frame.origin fromViewCoordinates:invokingButton.superview];
            [svc showAnchoredToInvokingView:invokingButton
                              withDirection:invokingViewAbsolutePosition.y < [Globals screenSize].height * .25f ? ViewAnchoringPreferBottomPlacement : ViewAnchoringPreferLeftPlacement
                          inkovingViewImage:[invokingButton backgroundImageForState:invokingButton.state]];
          }
          else if ([sender isKindOfClass:[UIButton class]]) // Speed up enhancing mobster
          {
            UIButton* invokingButton = (UIButton*)sender;
            [svc showAnchoredToInvokingView:invokingButton
                              withDirection:ViewAnchoringPreferLeftPlacement
                          inkovingViewImage:[invokingButton backgroundImageForState:invokingButton.state]];
          }
        }
      }
    }
  }
}

- (void) speedupEnhancement {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserEnhancement *ue = [self currentEnhancement];
  int timeLeft = ue.expectedEndTime.timeIntervalSinceNow;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  [self.itemSelectViewController closeClicked:nil];
  
  if (gs.gems < goldCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] enhanceWaitComplete:YES delegate:self];
    
    if (success) {
      self.finishLabelsView.hidden = YES;
      self.buttonSpinner.hidden = NO;
      
      _waitingForResponse = YES;
      
      [[NSNotificationCenter defaultCenter] postNotificationName:ENHANCE_MONSTER_NOTIFICATION object:nil];
    }
  }
}

#pragma mark - Speedup Items Filler

- (int) numGemsForTotalSpeedup {
  Globals *gl = [Globals sharedGlobals];
  UserEnhancement *ue = [self currentEnhancement];
  int timeLeft = ue.expectedEndTime.timeIntervalSinceNow;
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  return gemCost;
}

- (void) speedupItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController *)viewController {
  if ([itemObject isKindOfClass:[GemsItemObject class]]) {
    [self speedupEnhancement];
  } else if ([itemObject isKindOfClass:[UserItem class]]) {
    // Apply items
    GameState *gs = [GameState sharedGameState];
    UserItem *ui = (UserItem *)itemObject;
    ItemProto *ip = [gs itemForId:ui.itemId];
    UserEnhancement *ue = [self currentEnhancement];
    
    if (ip.itemType == ItemTypeSpeedUp) {
      [[OutgoingEventController sharedOutgoingEventController] tradeItemForSpeedup:ui.itemId userEnhancement:ue];
      
      [self updateLabels];
    }
    
    int timeLeft = ue.expectedEndTime.timeIntervalSinceNow;
    if (timeLeft > 0) {
      [viewController reloadDataAnimated:YES];
    }
  }
}

- (int) timeLeftForSpeedup {
  UserEnhancement *ue = [self currentEnhancement];
  int timeLeft = ue.expectedEndTime.timeIntervalSinceNow;
  return timeLeft;
}

- (int) totalSecondsRequired {
  UserEnhancement *ue = [self currentEnhancement];
  return ue.totalSeconds;
}

- (void) resourceItemsUsed:(NSDictionary *)itemUsages {
  [self enhanceWithItemsDict:itemUsages];
}

- (void) itemSelectClosed:(id)viewController {
  self.itemSelectViewController = nil;
  self.speedupItemsFiller = nil;
  self.resourceItemsFiller = nil;
}

#pragma mark - Responses

- (void) handleEnhancementWaitTimeCompleteResponseProto:(FullEvent *)fe {
  // In case its called from the timer action
  if ([self isViewLoaded]) {
    //    self.finishLabelsView.hidden = NO;
    //    self.buttonSpinner.hidden = YES;
    //
    //    _waitingForResponse = NO;
    //
    //    [self updateLabelsNonTimer];
    _waitingForResponse = NO;
    [self collectClicked:nil];
  }
}

- (IBAction)collectClicked:(id)sender {
  if (!_waitingForResponse && self.currentEnhancement.isComplete) {
    // We must set the enhancement item's user monster to fake monsters so that they can be animated
    UserEnhancement *ue = self.currentEnhancement;
    
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    int pointsEnhanced = [gl calculateExperienceIncrease:ue];
    
    UserMonster *baseUm = ue.baseMonster.userMonster.copy;
    for (EnhancementItem *ei in ue.feeders) {
      [ei setFakedUserMonster:ei.userMonster.copy];
    }
    
    int numCakeKidFeeders = 0;
    for (EnhancementItem *ei in ue.feeders) {
      UserMonster *um = [gs myMonsterWithUserMonsterUuid:ei.userMonsterUuid];
      
      BOOL isCakeKid = [um.staticMonster.monsterGroup containsString:@"CakeKid"];
      if (isCakeKid) {
        numCakeKidFeeders++;
      }
    }
    
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] collectEnhancementWithDelegate:self];
    
    if (success) {
      [AchievementUtil checkEnhancedPoints:pointsEnhanced];
      
      // Must do this after so that OutgoingEventController edits the actual user monster and not our fake one
      // For the enhancement items it doesn't matter so much since those will be removed from the array based on userMonsterId.
      [ue.baseMonster setFakedUserMonster:baseUm];
      
      self.collectLabelsView.hidden = YES;
      self.buttonSpinner.hidden = NO;
      
      _waitingForResponse = YES;
      
      
      // Mini event stuff
      [[MiniEventManager sharedInstance] checkEnhanceXp:pointsEnhanced baseMonsterRarity:baseUm.staticMonster.quality];
      
      // Calculate strength gained
      int oldStrength = [gl calculateStrengthForMonster:baseUm];
      int newStrength = [gl calculateStrengthForMonster:[gs myMonsterWithUserMonsterUuid:baseUm.userMonsterUuid]];
      int strengthGained = newStrength-oldStrength;
      
      // Cake kids use seperate mini event goal
      BOOL isCakeKid = [baseUm.staticMonster.monsterGroup containsString:@"CakeKid"];
      if (!isCakeKid) {
        [[MiniEventManager sharedInstance] checkEnhanceStrengthGained:strengthGained];
      } else {
        [[MiniEventManager sharedInstance] checkCakeKidEnhanceStrengthGained:strengthGained];
      }
      
      // Cake kid as feeder
      if (numCakeKidFeeders) {
        [[MiniEventManager sharedInstance] checkEnhanceCakeKidFeeder:numCakeKidFeeders];
      }
    }
  }
}

- (void) handleCollectMonsterEnhancementResponseProto:(FullEvent *)fe {
  self.collectLabelsView.hidden = NO;
  self.finishLabelsView.hidden = NO;
  self.buttonSpinner.hidden = YES;
  
  [self animateEnhancement];
  
  //  [self reloadListViewAnimated:YES];
  //  [self reloadQueueViewAnimated:YES];
  //  [self updateLabelsNonTimer];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:ENHANCE_MONSTER_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
}

@end
