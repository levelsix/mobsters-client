//
//  UpgradeViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "UpgradeViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"

@implementation FriendAcceptView

- (void) awakeFromNib {
//  UIImage *maskImage = [UIImage imageNamed:@"fullfriendmask.png"];
//  CALayer *mask = [CALayer layer];
//  mask.contents = (id)[maskImage CGImage];
//  mask.frame = CGRectMake(0, 0, self.profPicView.frame.size.width, self.profPicView.frame.size.height);
//  self.profPicView.layer.mask = mask;
  
  self.profPicView.layer.cornerRadius = self.profPicView.frame.size.width/2.f;
}

- (void) updateForFacebookId:(NSString *)uid {
  if (uid) {
    self.bgdView.highlighted = YES;
    self.slotNumLabel.hidden = YES;
    self.profPicView.hidden = NO;
    
    // add the stuff at the end so it knows where to save it
    self.profPicView.profileID = uid;
  } else {
    self.bgdView.highlighted = NO;
    self.slotNumLabel.hidden = NO;
    self.profPicView.hidden = YES;
  }
  
  // Delete all the empty guys
  self.bgdView.hidden = YES;
  self.slotNumLabel.hidden = YES;
}

@end

@implementation UpgradeBonusCell

- (void) loadForResidence:(ResidenceProto *)res withUserStruct:(UserStruct *)us {
  GameState *gs = [GameState sharedGameState];
  
  self.occupationLabel.text = res.occupationName;
  self.slotsLabel.text = [NSString stringWithFormat:@"Adds %d Slots", res.numBonusMonsterSlots];
  
  self.userInteractionEnabled = NO;
  self.bgdImage.highlighted = YES;
  
  int resLevel = res.structInfo.level;
  int usFbLevel = us.fbInviteStructLvl;
  int usCurLevel = us.staticStruct.structInfo.level;
  if (resLevel <= usFbLevel) {
    self.claimedIcon.hidden = NO;
    self.arrowIcon.hidden = YES;
    self.acceptViewsContainer.hidden = NO;
    
    self.bgdImage.highlighted = NO;
  } else if (resLevel <= usCurLevel && resLevel == usFbLevel+1) {
    self.claimedIcon.hidden = YES;
    self.arrowIcon.hidden = NO;
    self.acceptViewsContainer.hidden = NO;
    
    self.bgdImage.highlighted = NO;
    self.userInteractionEnabled = YES;
  } else {
    self.claimedIcon.hidden = YES;
    self.arrowIcon.hidden = YES;
    self.acceptViewsContainer.hidden = YES;
    
    if (resLevel <= usCurLevel) {
      ResidenceProto *prev = (ResidenceProto *)[gs structWithId:res.structInfo.predecessorStructId];
      self.slotsLabel.text = [NSString stringWithFormat:@"Requires %@ to unlock", prev.occupationName];
    } else {
      self.slotsLabel.text = [NSString stringWithFormat:@"Requires Lvl %d %@ to unlock", res.structInfo.level, res.structInfo.name];
    }
  }
  
  if (!self.acceptViewsContainer.hidden) {
    NSArray *accepted = [gs acceptedFbRequestsForUserStructId:us.userStructId fbStructLevel:resLevel];
    for (int i = 0; i < self.acceptViews.count; i++) {
      FriendAcceptView *av = self.acceptViews[i];
      RequestFromFriend *req = i < accepted.count ? accepted[i] : nil;
      
      av.hidden = i >= res.numAcceptedFbInvites || i >= accepted.count;
      [av updateForFacebookId:req.invite.recipientFacebookId];
    }
  }
}

@end

@implementation UpgradeBonusView

- (void) updateForUserStruct:(UserStruct *)us {
  self.staticStructs = [us allStaticStructs];
  self.userStruct = us;
  [self.hireTable reloadData];
}

- (void) updateAddSlotsViewForResidence:(ResidenceProto *)res {
  self.gemCostLabel.text = [Globals commafyNumber:res.numGemsRequired];
  self.numSlotsLabel.text = [NSString stringWithFormat:@"Add %d slot%@ to your team reserves by hiring %@!", res.numBonusMonsterSlots, res.numBonusMonsterSlots == 1 ? @"" : @"s", res.occupationName];
  
  GameState *gs = [GameState sharedGameState];
  self.chooserView.blacklistFriendIds = [gs facebookIdsAlreadyUsed];
  [self updateAcceptViewsForFbLevel:res.structInfo.level friendSlots:res.numAcceptedFbInvites];
}

- (void) updateAcceptViewsForFbLevel:(int)level friendSlots:(int)slots {
  GameState *gs = [GameState sharedGameState];
  NSArray *accepted = [gs acceptedFbRequestsForUserStructId:self.userStruct.userStructId fbStructLevel:level];
  for (int i = 0; i < accepted.count && i < self.acceptViews.count; i++) {
    FriendAcceptView *av = self.acceptViews[i];
    RequestFromFriend *req = i < accepted.count ? accepted[i] : nil;
    
    [av updateForFacebookId:req.invite.recipientFacebookId];
  }
  
  FriendAcceptView *last = self.acceptViews[MIN(self.acceptViews.count, slots)-1];
  CGRect r = self.acceptViewsContainer.frame;
  r.size.width = CGRectGetMaxX(last.frame);
  self.acceptViewsContainer.frame = r;
  self.acceptViewsContainer.center = ccp(self.acceptViewsContainer.superview.frame.size.width/2, self.acceptViewsContainer.center.y);
}

#pragma mark - Moving to views

- (void) moveToView:(UIView *)view {
  self.center = ccp(self.frame.size.width/2-view.center.x+self.superview.frame.size.width/2, self.center.y);
}

- (void) moveToHireView {
  [self moveToView:self.hireView];
}

- (void) moveToAddSlotsView {
  [self moveToView:self.addSlotsView];
}

- (void) moveToFriendFinderView {
  [self moveToView:self.friendFinderView];
  
  [self.chooserView retrieveFacebookFriends:YES];
}

- (void) spinnerOnGems {
  self.gemSpinner.hidden = NO;
  self.gemView.hidden = YES;
}

- (void) removeSpinner {
  self.gemSpinner.hidden = YES;
  self.gemView.hidden = NO;
}

#pragma mark - UITableView methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.staticStructs.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UpgradeBonusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UpgradeBonusCell"];
  
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"UpgradeBonusCell" owner:self options:nil];
    cell = self.bonusCell;
  }
  
  [cell loadForResidence:self.staticStructs[indexPath.row] withUserStruct:self.userStruct];
  
  return cell;
}

- (IBAction) rowSelected:(UITableViewCell *)sender {
  while (sender && ![sender isKindOfClass:[UITableViewCell class]]) {
    sender = (UITableViewCell *)[sender superview];
  }
  
  [self.hireTable.delegate tableView:self.hireTable didSelectRowAtIndexPath:[self.hireTable indexPathForCell:sender]];
}

@end

@implementation UpgradeBuildingMenu

- (void) loadForUserStruct:(UserStruct *)us {
  if (us == nil) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  
  id<StaticStructure> curSS = us.staticStruct;
  id<StaticStructure> nextSS = us.staticStructForNextLevel;
  id<StaticStructure> maxSS = us.maxStaticStruct;
  if (curSS == maxSS) {
    nextSS = maxSS;
  }
  
  self.nameLabel.text = curSS.structInfo.name;
  self.upgradeTimeLabel.text = curSS != nextSS ? [Globals convertTimeToLongString:nextSS.structInfo.minutesToBuild*60] : @"N/A";
  
  [Globals imageNamed:nextSS.structInfo.imgName withView:self.structIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  // Button view
  BOOL isOil = nextSS.structInfo.buildResourceType == ResourceTypeOil;
  self.upgradeCashLabel.text = curSS != nextSS ? [Globals cashStringForNumber:nextSS.structInfo.buildCost] : @"N/A";
  self.upgradeOilLabel.text = curSS != nextSS ? [Globals commafyNumber:nextSS.structInfo.buildCost] : @"N/A";
  [Globals adjustViewForCentering:self.upgradeOilLabel.superview withLabel:self.upgradeOilLabel];
  self.oilButtonView.hidden = !isOil;
  self.cashButtonView.hidden = isOil;
  
  // Town hall too low
  [self.greyscaleView removeFromSuperview];
  self.greyscaleView = nil;
  TownHallProto *thp = (TownHallProto *)[[gs myTownHall] staticStruct];
  int thLevel = thp.structInfo.level;
  if (nextSS.structInfo.prerequisiteTownHallLvl > thLevel) {
    UIImage *grey = [Globals greyScaleImageWithBaseImage:[Globals snapShotView:self.oilButtonView.superview]];
    self.greyscaleView = [[UIImageView alloc] initWithImage:grey];
    [self.oilButtonView.superview addSubview:self.greyscaleView];
    
    self.oilButtonView.hidden = YES;
    self.cashButtonView.hidden = YES;
    
    self.tooLowLevelLabel.text = [NSString stringWithFormat:@"Requires Lvl %d %@", nextSS.structInfo.prerequisiteTownHallLvl, thp.structInfo.name];
    
    self.tooLowLevelView.hidden = NO;
  } else {
    self.tooLowLevelView.hidden = YES;
  }
  
  if (nextSS.structInfo.structType != StructureInfoProto_StructTypeTownHall) {
    [self loadStatBarsForUserStruct:us];
    self.cityHallUnlocksView.hidden = YES;
  } else {
    [self loadCityHallUnlocksViewForUserStruct:us];
    [self.statBarView1 removeFromSuperview];
    [self.statBarView2 removeFromSuperview];
  }
}

- (NSArray *) buildingsThatChangedInQuantityWithCurTH:(TownHallProto *)curTh nextTh:(TownHallProto *)nextTh {
  NSMutableArray *arr = [NSMutableArray array];
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  for (id<StaticStructure> ss in gs.staticStructs.allValues) {
    StructureInfoProto *sip = ss.structInfo;
    if (sip.level == 1) {
      int before = [gl calculateMaxQuantityOfStructId:sip.structId withTownHall:curTh];
      int after = [gl calculateMaxQuantityOfStructId:sip.structId withTownHall:nextTh];
      
      if (before < after) {
        [arr addObject:sip];
      }
    } else {
      if (sip.prerequisiteTownHallLvl != curTh.structInfo.level && sip.prerequisiteTownHallLvl == nextTh.structInfo.level) {
        // Make sure a lower lvl one isn't in the array already
        
        [arr addObject:sip];
      }
    }
  }
  
  NSMutableArray *toRemove = [NSMutableArray array];
  for (StructureInfoProto *sip in arr) {
    StructureInfoProto *check = sip;
    while (check.predecessorStructId) {
      check = [[gs structWithId:check.predecessorStructId] structInfo];
      if ([arr containsObject:check]) {
        [toRemove addObject:check];
      }
    }
  }
  [arr removeObjectsInArray:toRemove];
  
  return arr;
}

#define UNLOCK_VIEW_SPACING 7
#define NUM_PER_ROW 4

- (void) loadCityHallUnlocksViewForUserStruct:(UserStruct *)us {
  Globals *gl = [Globals sharedGlobals];
  TownHallProto *curSS = (TownHallProto *)us.staticStruct;
  TownHallProto *nextSS = (TownHallProto *)us.staticStructForNextLevel;
  
  self.cityHallUnlocksLabel.text = [NSString stringWithFormat:@"%@ Level %d Unlocks", curSS.structInfo.name, curSS.structInfo.level+1];
  
  // Find new buildings, then find buildings that increase in quantity, then level
  NSMutableArray *unlockViews = [NSMutableArray array];
  
  NSArray *changedQuant = [self buildingsThatChangedInQuantityWithCurTH:curSS nextTh:nextSS];
  for (StructureInfoProto *sip in changedQuant) {
    int before = [gl calculateMaxQuantityOfStructId:sip.structId withTownHall:curSS];
    if (sip.level == 1 && before == 0) {
      [unlockViews addObject:[self unlockViewWithImageName:sip.imgName text:@"NEW!" useBigTextBgd:YES]];
    }
  }
  for (StructureInfoProto *sip in changedQuant) {
    int before = [gl calculateMaxQuantityOfStructId:sip.structId withTownHall:curSS];
    int after = [gl calculateMaxQuantityOfStructId:sip.structId withTownHall:nextSS];
    if (sip.level == 1 && before != 0) {
      [unlockViews addObject:[self unlockViewWithImageName:sip.imgName text:[NSString stringWithFormat:@"x%d", after-before] useBigTextBgd:NO]];
    }
  }
  for (StructureInfoProto *sip in changedQuant) {
    if (sip.level > 1) {
      [unlockViews addObject:[self unlockViewWithImageName:sip.imgName text:[NSString stringWithFormat:@"LVL %d", sip.level] useBigTextBgd:YES]];
    }
  }
  
  int maxY = 0;
  for (int i = 0; i < unlockViews.count; i++) {
    UIView *v = unlockViews[i];
    float x = self.cityHallUnlocksScrollView.frame.size.width/2+((i%NUM_PER_ROW)-NUM_PER_ROW/2.f+0.5)*(v.frame.size.width+UNLOCK_VIEW_SPACING);
    float y = (i/NUM_PER_ROW+0.5)*v.frame.size.height+(i/NUM_PER_ROW+1)*UNLOCK_VIEW_SPACING;
    v.center = ccp(x, y);
    
    [self.cityHallUnlocksScrollView addSubview:v];
    
    maxY = y+v.frame.size.height/2+UNLOCK_VIEW_SPACING;
  }
  
  self.cityHallUnlocksScrollView.contentSize = CGSizeMake(self.cityHallUnlocksScrollView.frame.size.width, maxY);
}

- (UIView *) unlockViewWithImageName:(NSString *)imgName text:(NSString *)text useBigTextBgd:(BOOL)bigTextBgd {
  [[NSBundle mainBundle] loadNibNamed:@"UpgradeUnlockView" owner:self options:nil];
  
  self.nibUnlocksLabelBgd.highlighted = !bigTextBgd;
  [Globals imageNamed:imgName withView:self.nibUnlocksStructIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.nibUnlocksLabel.text = text;
  
  UIImage *img = bigTextBgd ? self.nibUnlocksLabelBgd.image : self.nibUnlocksLabelBgd.highlightedImage;
  self.nibUnlocksLabel.center = ccp(self.nibUnlocksLabelBgd.frame.origin.x+img.size.width/2, self.nibUnlocksLabel.center.y);
  
  return self.nibUnlocksView;
}

- (void) loadStatBarsForUserStruct:(UserStruct *)us {
  id<StaticStructure> curSS = us.staticStruct;
  id<StaticStructure> nextSS = us.staticStructForNextLevel;
  id<StaticStructure> maxSS = us.maxStaticStruct;
  if (curSS == maxSS) {
    nextSS = maxSS;
  }
  
  // The stat bars
  StructureInfoProto_StructType structType = nextSS.structInfo.structType;
  BOOL requiresTwoBars = NO;
  BOOL showsCashSymbol1 = NO, showsCashSymbol2 = NO;
  BOOL useSqrt1 = NO, useSqrt2 = NO;
  float curStat1 = 0, newStat1 = 0, maxStat1 = 0;
  float curStat2 = 0, newStat2 = 0, maxStat2 = 0;
  NSString *statName1 = nil, *statName2 = nil;
  NSString *suffix1 = @"", *suffix2 = @"";
  if (structType == StructureInfoProto_StructTypeResourceGenerator) {
    ResourceGeneratorProto *cur = (ResourceGeneratorProto *)curSS;
    ResourceGeneratorProto *next = (ResourceGeneratorProto *)nextSS;
    ResourceGeneratorProto *max = (ResourceGeneratorProto *)maxSS;
    
    requiresTwoBars = YES;
    
    curStat1 = cur.productionRate;
    newStat1 = next.productionRate;
    maxStat1 = max.productionRate;
    statName1 = @"Rate:";
    suffix1 = @"Per Hour";
    
    curStat2 = cur.capacity;
    newStat2 = next.capacity;
    maxStat2 = max.capacity;
    statName2 = @"Capacity:";
    
    useSqrt2 = YES;
    showsCashSymbol1 = showsCashSymbol2 = (cur.resourceType == ResourceTypeCash);
  } else if (structType == StructureInfoProto_StructTypeResourceStorage) {
    ResourceStorageProto *cur = (ResourceStorageProto *)curSS;
    ResourceStorageProto *next = (ResourceStorageProto *)nextSS;
    ResourceStorageProto *max = (ResourceStorageProto *)maxSS;
    
    curStat1 = cur.capacity;
    newStat1 = next.capacity;
    maxStat1 = max.capacity;
    statName1 = @"Capacity:";
    
    useSqrt1 = YES;
    showsCashSymbol1 = (cur.resourceType == ResourceTypeCash);
  } else if (structType == StructureInfoProto_StructTypeHospital) {
    HospitalProto *cur = (HospitalProto *)curSS;
    HospitalProto *next = (HospitalProto *)nextSS;
    HospitalProto *max = (HospitalProto *)maxSS;
    
    requiresTwoBars = YES;
    
    curStat1 = cur.queueSize;
    newStat1 = next.queueSize;
    maxStat1 = max.queueSize;
    statName1 = @"Queue Size:";
    
    curStat2 = cur.healthPerSecond;
    newStat2 = next.healthPerSecond;
    maxStat2 = max.healthPerSecond;
    statName2 = @"Rate:";
    suffix2 = @"Health Per Sec";
  } else if (structType == StructureInfoProto_StructTypeLab) {
    LabProto *cur = (LabProto *)curSS;
    LabProto *next = (LabProto *)nextSS;
    LabProto *max = (LabProto *)maxSS;
    
    requiresTwoBars = YES;
    
    curStat1 = cur.queueSize;
    newStat1 = next.queueSize;
    maxStat1 = max.queueSize;
    statName1 = @"Queue Size:";
    
    curStat2 = cur.pointsPerSecond;
    newStat2 = next.pointsPerSecond;
    maxStat2 = max.pointsPerSecond;
    statName2 = @"Rate:";
    suffix2 = @"Points Per Sec";
  } else if (structType == StructureInfoProto_StructTypeResidence) {
    ResidenceProto *cur = (ResidenceProto *)curSS;
    ResidenceProto *next = (ResidenceProto *)nextSS;
    ResidenceProto *max = (ResidenceProto *)maxSS;
    
    curStat1 = cur.numMonsterSlots;
    newStat1 = next.numMonsterSlots;
    maxStat1 = max.numMonsterSlots;
    statName1 = @"Slots:";
  }
  
  NSString *dollarSign = showsCashSymbol1 ? @"$" : @"";
  NSString *increase = newStat1 > curStat1 ? [NSString stringWithFormat:@" + %@%@", dollarSign, [Globals commafyNumber:newStat1-curStat1]] : @"";
  self.statNameLabel1.text = [NSString stringWithFormat:@"%@ %@%@%@ %@", statName1, dollarSign, [Globals commafyNumber:curStat1], increase, suffix1];
  
  float powVal = 0.75;
  if (useSqrt1) {
    self.statNewBar1.percentage = powf(newStat1/maxStat1, powVal);
    self.statCurrentBar1.percentage = powf(curStat1/maxStat1, powVal);
  } else {
    self.statNewBar1.percentage = newStat1/maxStat1;
    self.statCurrentBar1.percentage = curStat1/maxStat1;
  }
  
  if (requiresTwoBars) {
    dollarSign = showsCashSymbol2 ? @"$" : @"";
    increase = newStat2 > curStat2 ? [NSString stringWithFormat:@" + %@%@", dollarSign, [Globals commafyNumber:newStat2-curStat2]] : @"";
    self.statNameLabel2.text = [NSString stringWithFormat:@"%@ %@%@%@ %@", statName2, dollarSign, [Globals commafyNumber:curStat2], increase, suffix2];
    
    if (useSqrt2) {
      self.statNewBar2.percentage = powf(newStat2/maxStat2, powVal);
      self.statCurrentBar2.percentage = powf(curStat2/maxStat2, powVal);
    } else {
      self.statNewBar2.percentage = newStat2/maxStat2;
      self.statCurrentBar2.percentage = curStat2/maxStat2;
    }
    
    self.statBarView2.hidden = NO;
  } else {
    self.statBarView2.hidden = YES;
  }
}

@end

@implementation UpgradeViewController

- (id) initWithUserStruct:(UserStruct *)us {
  if ((self = [super init])) {
    self.userStruct = us;
  }
  return self;
}

- (id) initHireViewWithUserStruct:(UserStruct *)us {
  if ((self = [super init])) {
    self.userStruct = us;
    _isHire = YES;
  }
  return self;
}

- (void) viewDidLoad {
  
  if (_isHire) {
    [self.bonusView updateForUserStruct:self.userStruct];
    [self loadHireView];
  } else {
    [self.upgradeView loadForUserStruct:self.userStruct];
    [self loadUpgradeView];
  }
  
  self.menuContainer.layer.cornerRadius = 4.f;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  _canClick = YES;
}

- (void) viewDidAppear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbInviteAccepted) name:FB_INVITE_ACCEPTED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbIncreasedSlots:) name:FB_INCREASE_SLOTS_NOTIFICATION object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) fbInviteAccepted {
  if (self.userStruct.staticStruct.structInfo.structType == StructureInfoProto_StructTypeResidence) {
    [self.bonusView updateForUserStruct:self.userStruct];
    [self.bonusView updateAddSlotsViewForResidence:(ResidenceProto *)self.userStruct.staticStructForNextFbLevel];
  }
}

- (void) fbIncreasedSlots:(NSNotification *)notif {
  NSDictionary *dict = notif.userInfo;
  NSNumber *userStructId = dict[@"UserStructId"];
  
  if (userStructId.intValue == self.userStruct.userStructId && self.bonusView.superview) {
    [self.bonusView updateForUserStruct:self.userStruct];
    [self loadHireView];
  }
}

#pragma mark - Top bar

- (void) loadTopForNonResidence {
  self.titleLabel.alpha = 1.f;
  self.closeView.alpha = 1.f;
  self.backView.alpha = 0.f;
  self.sendView.alpha = 0.f;
  self.bonusTopBar.alpha = 0.f;
  
  int level = self.userStruct.staticStruct.structInfo.level;
  int maxLevel = self.userStruct.maxLevel;
  self.titleLabel.text = level != maxLevel ? [NSString stringWithFormat:@"Upgrade to Level %d?", level+1] : @"Building at Max";
}

- (void) loadTopForResidence {
  self.titleLabel.alpha = 1.f;
  self.closeView.alpha = 1.f;
  self.backView.alpha = 0.f;
  self.sendView.alpha = 0.f;
  self.bonusTopBar.alpha = 0.f;
  self.titleLabel.text = @"Hire Workers";
}

- (void) loadTopForAddSlots {
  self.titleLabel.alpha = 1.f;
  self.closeView.alpha = 1.f;
  self.backView.alpha = 1.f;
  self.sendView.alpha = 0.f;
  self.bonusTopBar.alpha = 0.f;
  
  ResidenceProto *res = (ResidenceProto *)self.userStruct.staticStructForNextFbLevel;
  self.titleLabel.text = [NSString stringWithFormat:@"Hire %@", res.occupationName];
}

- (void) loadTopForFriendFinder {
  self.titleLabel.alpha = 0.f;
  self.closeView.alpha = 0.f;
  self.backView.alpha = 1.f;
  self.sendView.alpha = 1.f;
  self.bonusTopBar.alpha = 1.f;
  
  self.sendSpinner.hidden = YES;
  self.sendLabel.hidden = NO;
  _sendingFbInvites = NO;
}

#pragma mark - Displaying Views

- (void) loadUpgradeView {
  [self.bonusView removeFromSuperview];
  [self.menuContainer addSubview:self.upgradeView];
  
  [self loadTopForNonResidence];
}

- (void) loadHireView {
  [self.upgradeView removeFromSuperview];
  [self.menuContainer addSubview:self.bonusView];
  
  [UIView animateWithDuration:0.3f animations:^{
    [self.bonusView moveToHireView];
    [self loadTopForResidence];
  }];
}

- (void) loadAddSlotsView {
  [self.bonusView updateAddSlotsViewForResidence:(ResidenceProto *)self.userStruct.staticStructForNextFbLevel];
  
  _isOnFriendFinder = NO;
  [UIView animateWithDuration:0.3f animations:^{
    [self.bonusView moveToAddSlotsView];
    [self loadTopForAddSlots];
  }];
}

- (void) loadFriendFinderView {
  _isOnFriendFinder = YES;
  [UIView animateWithDuration:0.3f animations:^{
    [self.bonusView moveToFriendFinderView];
    [self loadTopForFriendFinder];
  }];
}

#pragma mark - Residence Table delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  [self loadAddSlotsView];
}

#pragma mark - IBActions

- (IBAction) upgradeClicked:(id)sender {
  [self.delegate bigUpgradeClicked];
  [self closeClicked:nil];
}

- (IBAction) hireWithGemsClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  ResidenceProto *res = (ResidenceProto *)self.userStruct.staticStructForNextFbLevel;
  if (gs.gold < res.numGemsRequired) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] increaseInventorySlots:self.userStruct withGems:YES delegate:self];
    [self.bonusView spinnerOnGems];
    _canClick = NO;
  }
}

- (void) handleIncreaseMonsterInventorySlotResponseProto:(FullEvent *)fe {
  [self.bonusView updateForUserStruct:self.userStruct];
  [self.bonusView removeSpinner];
  _canClick = YES;
  
  [self loadHireView];
}

- (IBAction) viewFriendsClicked:(id)sender {
  [self loadFriendFinderView];
}

- (IBAction) sendClicked:(id)sender {
  if (_sendingFbInvites) return;
  if (self.bonusView.chooserView.selectedIds.count > 0) {
    self.sendSpinner.hidden = NO;
    self.sendLabel.hidden = YES;
    _sendingFbInvites = YES;
    NSString *req = [NSString stringWithFormat:@"Please help me add slots!"];
    [self.bonusView.chooserView sendRequestWithString:req completionBlock:^(BOOL success, NSArray *friendIds) {
      if (success && friendIds.count > 0) {
        [[OutgoingEventController sharedOutgoingEventController] inviteAllFacebookFriends:friendIds forStruct:self.userStruct];
      }
      
      if (success && _isOnFriendFinder) {
        [self.bonusView updateForUserStruct:self.userStruct];
        [self loadHireView];
      }
      
      self.sendSpinner.hidden = YES;
      self.sendLabel.hidden = NO;
      _sendingFbInvites = NO;
    }];
  }
}

- (IBAction) backClicked:(id)sender {
  if (_canClick) {
    if (_isOnFriendFinder) {
      [self loadAddSlotsView];
    } else {
      [self loadHireView];
    }
  }
}

- (void) button1Clicked:(id)sender {
  [self loadUpgradeView];
}

- (void) button2Clicked:(id)sender {
  [self.bonusView updateForUserStruct:self.userStruct];
  [self loadHireView];
}

- (IBAction) closeClicked:(id)sender {
  if (_canClick) {
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
      [self.view removeFromSuperview];
      [self removeFromParentViewController];
    }];
  }
}

@end
