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

@implementation FriendAcceptView

- (void) awakeFromNib {
  UIImage *maskImage = [UIImage imageNamed:@"fullfriendmask.png"];
  CALayer *mask = [CALayer layer];
  mask.contents = (id)[maskImage CGImage];
  mask.frame = CGRectMake(0, 0, self.profPicView.frame.size.width, self.profPicView.frame.size.height);
  self.profPicView.layer.mask = mask;
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
}

@end

@implementation UpgradeBonusCell

- (void) loadForResidence:(ResidenceProto *)res withUserStruct:(UserStruct *)us {
  GameState *gs = [GameState sharedGameState];
  
  self.occupationLabel.text = res.occupationName;
  self.slotsLabel.text = [NSString stringWithFormat:@"%d Bonus Slots", res.numBonusMonsterSlots];
  
  self.userInteractionEnabled = NO;
  
  int resLevel = res.structInfo.level;
  int usFbLevel = us.fbInviteStructLvl;
  int usCurLevel = us.staticStruct.structInfo.level;
  if (resLevel <= usFbLevel) {
    self.claimedIcon.hidden = NO;
    self.arrowIcon.hidden = YES;
    self.requiresLabel.hidden = YES;
    self.acceptViewsContainer.hidden = NO;
  } else if (resLevel <= usCurLevel && resLevel == usFbLevel+1) {
    self.claimedIcon.hidden = YES;
    self.arrowIcon.hidden = NO;
    self.requiresLabel.hidden = YES;
    self.acceptViewsContainer.hidden = NO;
    
    self.userInteractionEnabled = YES;
  } else {
    self.claimedIcon.hidden = YES;
    self.arrowIcon.hidden = YES;
    self.requiresLabel.hidden = NO;
    self.acceptViewsContainer.hidden = YES;
    
    if (resLevel <= usCurLevel) {
      ResidenceProto *prev = (ResidenceProto *)[gs structWithId:res.structInfo.predecessorStructId];
      self.requiresLabel.text = [NSString stringWithFormat:@"Requires %@", prev.occupationName];
    } else {
      self.requiresLabel.text = [NSString stringWithFormat:@"Requires Lvl %d %@", res.structInfo.level, res.structInfo.name];
    }
  }
  
  if (!self.acceptViewsContainer.hidden) {
    NSArray *accepted = [gs acceptedFbRequestsForUserStructId:us.userStructId fbStructLevel:resLevel];
    for (int i = 0; i < self.acceptViews.count; i++) {
      FriendAcceptView *av = self.acceptViews[i];
      RequestFromFriend *req = i < accepted.count ? accepted[i] : nil;
      
      av.hidden = i >= res.numAcceptedFbInvites;
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
  self.numSlotsLabel.text = [NSString stringWithFormat:@"Add %d slot%@ to your team reserves!", res.numBonusMonsterSlots, res.numBonusMonsterSlots == 1 ? @"" : @"s"];
  
  GameState *gs = [GameState sharedGameState];
  self.chooserView.blacklistFriendIds = [gs facebookIdsAlreadyUsed];
  [self updateAcceptViewsForFbLevel:res.structInfo.level friendSlots:res.numAcceptedFbInvites];
}

- (void) updateAcceptViewsForFbLevel:(int)level friendSlots:(int)slots {
  GameState *gs = [GameState sharedGameState];
  NSArray *accepted = [gs acceptedFbRequestsForUserStructId:self.userStruct.userStructId fbStructLevel:level];
  for (int i = 0; i < self.acceptViews.count; i++) {
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

#pragma mark - UITableView methods

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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

@end

@implementation UpgradeBuildingMenu

- (void) awakeFromNib {
  self.buttonContainerView.layer.cornerRadius = 6.f;
  self.buttonContainerView.layer.borderColor = [UIColor blackColor].CGColor;
  self.buttonContainerView.layer.borderWidth = 1.f;
}

- (void) loadForUserStruct:(UserStruct *)us {
  if (us == nil) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  
  id<StaticStructure> curSS = us.staticStruct;
  id<StaticStructure> nextSS = us.staticStructForNextLevel;
  id<StaticStructure> maxSS = us.maxStaticStruct;
  
  self.nameLabel.text = [NSString stringWithFormat:@"%@ (Lvl %d)", curSS.structInfo.name, curSS.structInfo.level];
  
  self.upgradeTimeLabel.text = [Globals convertTimeToLongString:nextSS.structInfo.minutesToBuild*60];
  
  [Globals imageNamed:nextSS.structInfo.imgName withView:self.structIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  // Button view
  BOOL isOil = nextSS.structInfo.buildResourceType == ResourceTypeOil;
  self.upgradeCashLabel.text = [Globals cashStringForNumber:nextSS.structInfo.buildCost];
  self.upgradeOilLabel.text = [Globals commafyNumber:nextSS.structInfo.buildCost];
  [Globals adjustViewForCentering:self.upgradeOilLabel.superview withLabel:self.upgradeOilLabel];
  self.oilButtonView.hidden = !isOil;
  self.cashButtonView.hidden = isOil;
  
  // Town hall too low
  [self.greyscaleView removeFromSuperview];
  self.greyscaleView = nil;
  int thLevel = [[[[gs myTownHall] staticStruct] structInfo] level];
  if (nextSS.structInfo.prerequisiteTownHallLvl > thLevel) {
    UIImage *grey = [Globals greyScaleImageWithBaseImage:[Globals snapShotView:self.oilButtonView.superview]];
    self.greyscaleView = [[UIImageView alloc] initWithImage:grey];
    [self.oilButtonView.superview addSubview:self.greyscaleView];
    
    self.oilButtonView.hidden = YES;
    self.cashButtonView.hidden = YES;
    
    self.cityHallTooLowLabel.text = [NSString stringWithFormat:@"This upgrade requires City Hall Lvl %d", nextSS.structInfo.prerequisiteTownHallLvl];
    
    self.cityHallTooLowLabel.hidden = NO;
  } else {
    self.cityHallTooLowLabel.hidden = YES;
  }
  
  
  // The stat bars
  StructureInfoProto_StructType structType = nextSS.structInfo.structType;
  BOOL requiresTwoBars = NO;
  BOOL showsCashSymbol1 = NO, showsCashSymbol2 = NO;
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
    
    showsCashSymbol1 = showsCashSymbol2 = (cur.resourceType == ResourceTypeCash);
  } else if (structType == StructureInfoProto_StructTypeResourceStorage) {
    ResourceStorageProto *cur = (ResourceStorageProto *)curSS;
    ResourceStorageProto *next = (ResourceStorageProto *)nextSS;
    ResourceStorageProto *max = (ResourceStorageProto *)maxSS;
    
    curStat1 = cur.capacity;
    newStat1 = next.capacity;
    maxStat1 = max.capacity;
    statName1 = @"Capacity:";
    
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
  self.statNameLabel1.text = statName1;
  NSString *increase = newStat1 > curStat1 ? [NSString stringWithFormat:@" + %@%@", dollarSign, [Globals commafyNumber:newStat1-curStat1]] : @"";
  self.statIncreaseLabel1.text = [NSString stringWithFormat:@"%@%@%@ %@", dollarSign, [Globals commafyNumber:curStat1], increase, suffix1];
  self.statNewBar1.percentage = newStat1/maxStat1;
  self.statCurrentBar1.percentage = curStat1/maxStat1;
  
  if (requiresTwoBars) {
    dollarSign = showsCashSymbol2 ? @"$" : @"";
    self.statNameLabel2.text = statName2;
    increase = newStat2 > curStat2 ? [NSString stringWithFormat:@" + %@%@", dollarSign, [Globals commafyNumber:newStat2-curStat2]] : @"";
    self.statIncreaseLabel2.text = [NSString stringWithFormat:@"%@%@%@ %@", dollarSign, [Globals commafyNumber:curStat2], increase, suffix2];
    self.statNewBar2.percentage = newStat2/maxStat2;
    self.statCurrentBar2.percentage = curStat2/maxStat2;
  }
  
  // Adjust the views
  CGRect r = self.statContainerView.frame;
  if (requiresTwoBars) {
    r.size.height = CGRectGetMaxY(self.statBarView2.frame);
  } else {
    r.size.height = CGRectGetMaxY(self.statBarView1.frame);
  }
  self.statContainerView.frame = r;
  
  r = self.timeView.frame;
  r.origin.y = CGRectGetMaxY(self.statContainerView.frame);
  self.timeView.frame = r;
  
  r = self.rightDescriptionView.frame;
  r.size.height = CGRectGetMaxY(self.timeView.frame);
  self.rightDescriptionView.frame = r;
  
  self.rightDescriptionView.center = ccp(self.rightDescriptionView.center.x, self.structIcon.center.y);
}

@end

@implementation UpgradeViewController

- (id) initWithUserStruct:(UserStruct *)us {
  if ((self = [super init])) {
    self.userStruct = us;
  }
  return self;
}

- (void) viewDidLoad {
  [self.upgradeView loadForUserStruct:self.userStruct];
  [self loadUpgradeView];
  
  if (self.userStruct.staticStruct.structInfo.structType == StructureInfoProto_StructTypeResidence) {
    [self loadTopForResidence];
  } else {
    [self loadTopForNonResidence];
  }
  
  self.menuContainer.layer.cornerRadius = 6.f;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
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
  self.titleLabel.text = [NSString stringWithFormat:@"Upgrade to Level %d?", self.userStruct.staticStructForNextLevel.structInfo.level];
}

- (void) loadTopForResidence {
  self.titleLabel.alpha = 0.f;
  self.closeView.alpha = 1.f;
  self.backView.alpha = 0.f;
  self.sendView.alpha = 0.f;
  self.bonusTopBar.alpha = 1.f;
}

- (void) loadTopForAddSlots {
  self.titleLabel.alpha = 1.f;
  self.closeView.alpha = 1.f;
  self.backView.alpha = 1.f;
  self.sendView.alpha = 0.f;
  self.bonusTopBar.alpha = 0.f;
  
  ResidenceProto *res = (ResidenceProto *)self.userStruct.staticStructForNextFbLevel;
  self.titleLabel.text = res.occupationName;
}

- (void) loadTopForFriendFinder {
  self.titleLabel.alpha = 1.f;
  self.closeView.alpha = 0.f;
  self.backView.alpha = 1.f;
  self.sendView.alpha = 1.f;
  self.bonusTopBar.alpha = 0.f;
  self.titleLabel.text = @"Hire Friends";
  
  self.sendSpinner.hidden = YES;
  self.sendLabel.hidden = NO;
  _sendingFbInvites = NO;
}

#pragma mark - Displaying Views

- (void) loadUpgradeView {
  [self.bonusView removeFromSuperview];
  [self.menuContainer addSubview:self.upgradeView];
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
    //[RefillMenuController
  } else {
    [[OutgoingEventController sharedOutgoingEventController] increaseInventorySlots:self.userStruct withGems:YES];
    [self.bonusView updateForUserStruct:self.userStruct];
    [self loadHireView];
  }
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
      
      if (_isOnFriendFinder) {
        [self.bonusView updateForUserStruct:self.userStruct];
        [self loadHireView];
      }
    }];
  }
}

- (IBAction) backClicked:(id)sender {
  if (_isOnFriendFinder) {
    [self loadAddSlotsView];
  } else {
    [self loadHireView];
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
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
  }];
}

@end
