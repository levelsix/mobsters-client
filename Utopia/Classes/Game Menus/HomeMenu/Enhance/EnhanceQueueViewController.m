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

@implementation EnhanceSmallCardCell

- (void) awakeFromNib {
  // Do this so that it looks like a regular list cell
  self.cardContainer = [[MonsterCardContainerView alloc] init];
  self.cardContainer.monsterCardView = self.cardView;
}

- (void) updateForListObject:(UserMonster *)listObject userEnhancement:(UserEnhancement *)ue {
  MonsterProto *mp = listObject.staticMonster;
  
  NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Thumbnail.png"];
  [Globals imageNamed:fileName withView:self.monsterIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  NSString *bgdImgName = [Globals imageNameForElement:mp.monsterElement suffix:@"mediumsquare.png"];
  [Globals imageNamed:bgdImgName withView:self.bgdIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  NSString *tagName = [Globals imageNameForRarity:mp.quality suffix:@"dot.png"];
  [Globals imageNamed:tagName withView:self.rarityDot maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  int ptsIncrease = [ue experienceIncreaseOfNewUserMonster:listObject];
  self.enhancePercentLabel.text = [NSString stringWithFormat:@"%@xp", [Globals commafyNumber:ptsIncrease]];
}

@end

@implementation EnhanceQueueViewController

- (id) initWithBaseMonster:(UserMonster *)um allowAddingToQueue:(BOOL)allowAddingToQueue {
  if ((self = [super init])) {
    self.baseMonster = um;
    _allowAddingToQueue = allowAddingToQueue;
    
    GameState *gs = [GameState sharedGameState];
    if (_allowAddingToQueue && !gs.userEnhancement) {
      [[OutgoingEventController sharedOutgoingEventController] setBaseEnhanceMonster:um.userMonsterId];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:ENHANCE_QUEUE_CHANGED_NOTIFICATION object:nil];
      [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
    }
  }
  return self;
}

- (id) initWithCurrentEnhancement {
  GameState *gs = [GameState sharedGameState];
  return [self initWithBaseMonster:gs.userEnhancement.baseMonster.userMonster allowAddingToQueue:YES];
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.cardCell = [[NSBundle mainBundle] loadNibNamed:@"EnhanceSmallCardCell" owner:self options:nil][0];
  self.queueCell = [[NSBundle mainBundle] loadNibNamed:@"MonsterQueueCell" owner:self options:nil][0];
  
  self.queueView.isFlipped = YES;
  self.queueView.cellClassName = @"MonsterQueueCell";
  self.listView.cellClassName = @"EnhanceSmallCardCell";
  
  MonsterProto *mp = self.baseMonster.staticMonster;
  NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamed:fileName withView:self.monsterImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.title = [NSString stringWithFormat:@"Enhance %@", mp.displayName];
  
  self.curExpLabel.superview.layer.cornerRadius = 4.f;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self reloadQueueViewAnimated:NO];
  [self reloadListViewAnimated:NO];
  
  [self updateLabels];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  UserEnhancement *ue = self.currentEnhancement;
  if (_allowAddingToQueue && ue.baseMonster && ue.feeders.count == 0) {
    [[OutgoingEventController sharedOutgoingEventController] removeBaseEnhanceMonster];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ENHANCE_QUEUE_CHANGED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  }
  
  [[SocketCommunication sharedSocketCommunication] flush];
}

- (UserEnhancement *) currentEnhancement {
  UserEnhancement *ue = nil;
  if (_allowAddingToQueue) {
    GameState *gs = [GameState sharedGameState];
    ue = gs.userEnhancement;
  } else {
    EnhancementItem *ei = [[EnhancementItem alloc] init];
    ei.userMonsterId = self.baseMonster.userMonsterId;
    
    ue = [[UserEnhancement alloc] init];
    ue.baseMonster = ei;
    ue.feeders = [NSMutableArray array];
  }
  
  return ue;
}

- (int) maxQueueSize {
  GameState *gs = [GameState sharedGameState];
  LabProto *lab = (LabProto *)gs.myLaboratory.staticStruct;
  return lab.queueSize;
}

- (void) waitTimeComplete {
  [self reloadListViewAnimated:YES];
  [self reloadQueueViewAnimated:YES];
  [self updateLabels];
  
  GameState *gs = [GameState sharedGameState];
  if (!gs.userEnhancement) {
    [[OutgoingEventController sharedOutgoingEventController] setBaseEnhanceMonster:self.baseMonster.userMonsterId];
    _allowAddingToQueue = YES;
  }
}

- (void) updateLabels {
  Globals *gl = [Globals sharedGlobals];
  
  UserEnhancement *ue = self.currentEnhancement;
  UserMonster *um = ue.baseMonster.userMonster;
  
  int curPerc = floorf([ue currentPercentageOfLevel]*100);
  int newPerc = floorf([ue finalPercentageFromCurrentLevel]*100);
  int delta = newPerc-curPerc;
  
  int additionalLevel = (int)(curPerc/100.f);
  curPerc = curPerc-additionalLevel*100;
  newPerc = newPerc-additionalLevel*100;
  
  self.curPercentLabel.text = [NSString stringWithFormat:@"%d%%", curPerc];
  self.addedPercentLabel.text = [NSString stringWithFormat:@"%@%%", [Globals commafyNumber:delta]];
  
  self.curProgressBar.percentage = curPerc/100.f;
  self.addedProgressBar.percentage = newPerc/100.f;
  
  int additionalNewLevel = (int)(newPerc/100.f);
  int curLevel = um.level+additionalLevel;
  int newLevel = MIN(curLevel+additionalNewLevel+1, um.staticMonster.maxLevel);
  self.nextLevelLabel.text = [NSString stringWithFormat:@"Needed for\nlevel %d", newLevel];
  self.curLevelLabel.text = [NSString stringWithFormat:@"Level %d:", curLevel];
  
  int expToNewLevel = [gl calculateExperienceRequiredForMonster:um.monsterId level:newLevel];
  int curExp = [gl calculateExperienceIncrease:ue];
  self.curExpLabel.text = [NSString stringWithFormat:@"%@xp", [Globals commafyNumber:MAX(0, expToNewLevel-curExp)]];
  
  int timeLeft = [gl calculateTimeLeftForEnhancement:ue];
  int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (timeLeft || speedupCost) {
    self.timeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    
    self.speedupCostLabel.text = [Globals commafyNumber:speedupCost];
    [Globals adjustViewForCentering:self.speedupCostLabel.superview withLabel:self.speedupCostLabel];
  }
  
  int oilCost = [gl calculateOilCostForEnhancement:ue feeder:nil];
  self.queueingCostLabel.text = [Globals commafyNumber:oilCost];
  [Globals adjustViewForCentering:self.queueingCostLabel.superview withLabel:self.queueingCostLabel];
  
  int origLevel = um.level;
  
  um.level = curLevel;
  int curAttk = [gl calculateTotalDamageForMonster:um];
  int curHp = [gl calculateMaxHealthForMonster:um];
  int curSpeed = [gl calculateSpeedForMonster:um];
  
  um.level = MIN(curLevel+1, um.staticMonster.maxLevel);
  int newAttk = [gl calculateTotalDamageForMonster:um];
  int newHp = [gl calculateMaxHealthForMonster:um];
  int newSpeed = [gl calculateSpeedForMonster:um];
  
  um.level = origLevel;
  
  self.attackLabel.text = [NSString stringWithFormat:@"%@%@", [Globals commafyNumber:curAttk], newAttk > curAttk ? [NSString stringWithFormat:@" + %@", [Globals commafyNumber:newAttk-curAttk]] : @""];
  self.healthLabel.text = [NSString stringWithFormat:@"%@%@", [Globals commafyNumber:curHp], newHp > curHp ? [NSString stringWithFormat:@" + %@", [Globals commafyNumber:newHp-curHp]] : @""];
  self.speedLabel.text = [NSString stringWithFormat:@"%@%@", [Globals commafyNumber:curSpeed], newSpeed > curSpeed ? [NSString stringWithFormat:@" + %@", [Globals commafyNumber:newSpeed-curSpeed]] : @""];
  
  if (ue.feeders.count > 0) {
    MonsterQueueCell *cell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self updateTimeWithCell:cell];
  }
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
    if (um.isAvailable && um.userMonsterId != self.baseMonster.userMonsterId) {
      [arr addObject:um];
    }
  }
  
  Globals *gl = [Globals sharedGlobals];
  UserEnhancement *ue = self.currentEnhancement;
  [arr sortUsingComparator:^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
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
    if (ip.row == 0) {
      [self updateTimeWithCell:queue];
    } else {
      queue.botLabel.hidden = NO;
      
      int num = [ue experienceIncreaseOfNewUserMonster:um];
      queue.botLabel.text = [NSString stringWithFormat:@"%@xp", [Globals commafyNumber:num]];
    }
  }
}

#pragma mark List

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  if (_allowAddingToQueue) {
    _confirmUserMonster = self.userMonsters[indexPath.row];
    [self checkMonsterIsNotMaxed];
  } else {
    [Globals addAlertNotification:@"Oops, you are already enhancing a different mobster."];
  }
}

- (void) checkMonsterIsNotMaxed {
  UserEnhancement *ue = self.currentEnhancement;
  
  float percIncrease = [ue percentageIncreaseOfNewUserMonster:_confirmUserMonster roundToPercent:NO];
  _percentIncrease = [ue percentageIncreaseOfNewUserMonster:_confirmUserMonster roundToPercent:YES];
  
  if (percIncrease) {
    [self checkUserMonsterOnTeam];
  } else {
    [Globals addAlertNotification:@"Oops, you already have enough to max out this mobster."];
  }
}

- (void) checkUserMonsterOnTeam {
  UserMonster *um = _confirmUserMonster;
  if (um.teamSlot > 0) {
    NSString *description = @"This mobster is currently on your team. Continue?";
    [GenericPopupController displayConfirmationWithDescription:description title:@"Continue?" okayButton:@"Continue" cancelButton:@"Cancel" target:self selector:@selector(confirmationAccepted)];
  } else {
    [self confirmationAccepted];
  }
}

- (void) confirmationAccepted {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  if (self.currentEnhancement.feeders.count >= self.maxQueueSize) {
    [Globals addAlertNotification:@"The laboratory queue is already full!"];
  } else {
    EnhancementItem *newItem = [[EnhancementItem alloc] init];
    newItem.userMonsterId = _confirmUserMonster.userMonsterId;
    int oilCost = [gl calculateOilCostForEnhancement:self.currentEnhancement feeder:newItem];
    int curAmount = gs.oil;
    if (oilCost > curAmount) {
      [GenericPopupController displayExchangeForGemsViewWithResourceType:ResourceTypeOil amount:oilCost-curAmount target:self selector:@selector(useGemsForEnhance)];
    } else {
      [self sendEnhanceAllowGems:NO];
    }
  }
}

- (void) useGemsForEnhance {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  EnhancementItem *newItem = [[EnhancementItem alloc] init];
  newItem.userMonsterId = _confirmUserMonster.userMonsterId;
  int cost = [gl calculateOilCostForEnhancement:self.currentEnhancement feeder:newItem];
  int curAmount = gs.oil;
  int gemCost = [gl calculateGemConversionForResourceType:ResourceTypeOil amount:cost-curAmount];
  
  if (gemCost > gs.gold) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [self sendEnhanceAllowGems:YES];
  }
}

- (void) sendEnhanceAllowGems:(BOOL)allowGems {
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] addMonsterToEnhancingQueue:_confirmUserMonster.userMonsterId useGems:allowGems];
  
  if (success) {
    [self reloadQueueViewAnimated:YES];
    [self animateUserMonsterIntoQueue:_confirmUserMonster];
    [self reloadListViewAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ENHANCE_QUEUE_CHANGED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
    
    [self updateLabels];
  }
}

- (void) animateUserMonsterIntoQueue:(UserMonster *)um {
  int monsterIndex = (int)[self.userMonsters indexOfObject:um];
  MonsterListCell *cardCell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:monsterIndex inSection:0]];
  
  monsterIndex = (int)[self.queueView.listObjects indexOfObject:um];
  NSIndexPath *ip = [NSIndexPath indexPathForItem:monsterIndex inSection:0];
  MonsterQueueCell *queueCell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:ip];
  
  if (cardCell && queueCell) {
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
  
  //[self spawnChangeLabels];
}

- (void) spawnChangeLabels {
  if (_percentIncrease) {
    NSString *str = [NSString stringWithFormat:@"+%@%%", [Globals commafyNumber:_percentIncrease]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = str;
    label.font = [UIFont fontWithName:@"Gotham-Ultra" size:12.f];
    label.textColor = [UIColor colorWithRed:0.f green:121/255.f blue:1.f alpha:1.f];
    CGSize s = [label.text sizeWithFont:label.font];
    label.frame = CGRectMake(0, 0, s.width, s.height);
    
    [self.view addSubview:label];
    CGPoint pt = [self.view convertPoint:self.addedPercentLabel.frame.origin fromView:self.addedPercentLabel.superview];
    // Account for the fact that we are choosing point relative to origin and not center because it is left aligned
    int x = (arc4random()%50)-25+5;
    label.center = ccpAdd(pt, ccp(x, 30+arc4random()%10));
    
    [UIView animateWithDuration:1.3f animations:^{
      label.center = ccpAdd(label.center, ccp(0, -65));
    }];
    
    [UIView animateWithDuration:0.5f delay:0.8f options:UIViewAnimationOptionCurveLinear animations:^{
      label.alpha = 0.f;
    } completion:^(BOOL finished) {
      [label removeFromSuperview];
    }];
  }
}

#pragma mark Queue

- (void) listView:(ListCollectionView *)listView minusClickedAtIndexPath:(NSIndexPath *)indexPath {
  EnhancementItem *ei = self.currentEnhancement.feeders[indexPath.row];
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] removeMonsterFromEnhancingQueue:ei];
  
  if (success) {
    [self reloadListViewAnimated:YES];
    [self animateEnhancementItemOutOfQueue:ei];
    [self reloadQueueViewAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ENHANCE_QUEUE_CHANGED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
    
    [self updateLabels];
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

- (IBAction) speedupClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserEnhancement *ue = [self currentEnhancement];
  int timeLeft = [gl calculateTimeLeftForEnhancement:ue];
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (gs.gold < goldCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] speedupEnhancingQueue];
    
    if (success) {
      [self reloadListViewAnimated:YES];
      [self reloadQueueViewAnimated:YES];
      [self updateLabels];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:ENHANCE_QUEUE_CHANGED_NOTIFICATION object:nil];
      [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
    }
  }
}

@end
