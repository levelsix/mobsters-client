//
//  HireViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/17/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "HireViewController.h"
#import "GameState.h"
#import "Globals.h"
#import "GenericPopupController.h"
#import "OutgoingEventController.h"
#import "Analytics.h"

@implementation FriendAcceptView

- (void) awakeFromNib {
  UIImage *maskImage = [UIImage imageNamed:@"teamslotmask.png"];
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
    
    self.profPicView.startHandler = ^(DBFBProfilePictureView *profilePictureView) {
      UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
      [profilePictureView addSubview:spinner];
      spinner.center = ccp(profilePictureView.width/2, profilePictureView.height/2);
      [spinner startAnimating];
      spinner.tag = 1234;
    };
    
    self.profPicView.completionHandler = ^(DBFBProfilePictureView *profilePictureView, NSError *error) {
      [[profilePictureView viewWithTag:1234] removeFromSuperview];
    };
    
    // add the stuff at the end so it knows where to save it
    self.profPicView.profileID = uid;
    
    // Delete all the empty guys
    self.bgdView.hidden = YES;
    self.slotNumLabel.hidden = YES;
  } else {
    self.bgdView.highlighted = NO;
    self.slotNumLabel.hidden = NO;
    self.profPicView.hidden = YES;
    
    self.bgdView.hidden = NO;
    self.slotNumLabel.hidden = NO;
  }
}

@end

@implementation UpgradeBonusCell

- (void) loadForResidence:(ResidenceProto *)res withUserStruct:(UserStruct *)us {
  GameState *gs = [GameState sharedGameState];
  
  self.occupationLabel.text = res.occupationName;
  self.slotsLabel.text = [NSString stringWithFormat:@"Adds %d slots to your %@", res.numBonusMonsterSlots, res.structInfo.name];
  
  self.occupationLabel.textColor = [UIColor colorWithRed:0.f green:127/255.f blue:235/255.f alpha:1.f];
  self.slotsLabel.textColor = [UIColor colorWithWhite:51/255.f alpha:1.f];
  
  self.selectionStyle = UITableViewCellSelectionStyleDefault;
  
  NSString *iconName = [@"onjobicon" stringByAppendingString:res.imgSuffix];
  
  int resLevel = res.structInfo.level;
  int usFbLevel = us.fbInviteStructLvl;
  int usCurLevel = us.staticStruct.structInfo.level;
  if (resLevel <= usFbLevel) {
    self.claimedIcon.hidden = NO;
    self.arrowIcon.hidden = NO;
    self.lockIcon.hidden = YES;
  } else if (resLevel <= usCurLevel && resLevel == usFbLevel+1) {
    self.claimedIcon.hidden = YES;
    self.arrowIcon.hidden = NO;
    self.lockIcon.hidden = YES;
  } else {
    self.claimedIcon.hidden = YES;
    self.arrowIcon.hidden = YES;
    self.lockIcon.hidden = NO;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    iconName = [@"jobicon" stringByAppendingString:res.imgSuffix];
    
    self.occupationLabel.textColor = [UIColor colorWithWhite:153/255.f alpha:1.f];
    self.slotsLabel.textColor = [UIColor colorWithWhite:153/255.f alpha:1.f];
    
    if (resLevel <= usCurLevel) {
      ResidenceProto *prev = (ResidenceProto *)[gs structWithId:res.structInfo.predecessorStructId];
      self.slotsLabel.text = [NSString stringWithFormat:@"Hire a %@ to unlock", prev.occupationName];
    } else {
      self.slotsLabel.text = [NSString stringWithFormat:@"Requires a level %d %@", res.structInfo.level, res.structInfo.name];
    }
  }
  [Globals imageNamed:iconName withView:self.occupationIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
}

@end

@implementation UpgradeBonusView

- (void) awakeFromNib {
  self.alreadyHiredView.frame = self.addSlotsView.frame;
  [self.addSlotsView.superview addSubview:self.alreadyHiredView];
}

- (void) updateForUserStruct:(UserStruct *)us {
  NSMutableArray *arr = [NSMutableArray array];
  for (ResidenceProto *rp in [us allStaticStructs]) {
    if (rp.numBonusMonsterSlots) {
      [arr addObject:rp];
    }
  }
  self.staticStructs = arr;
  
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
  NSArray *accepted = [gs acceptedFbRequestsForUserStructUuid:self.userStruct.userStructUuid fbStructLevel:level];
  
  FriendAcceptView *lastAv = nil;
  for (int i = 0; i < self.acceptViews.count; i++) {
    FriendAcceptView *av = self.acceptViews[i];
    RequestFromFriend *req = i < accepted.count ? accepted[i] : nil;
    
    if (i < slots) {
      av.hidden = NO;
      [av updateForFacebookId:req.invite.recipientFacebookId];
      
      lastAv = av;
    } else {
      av.hidden = YES;
    }
  }
  
  if (lastAv) {
    UIView *v = lastAv.superview;
    CGPoint center = v.center;
    v.width = CGRectGetMaxX(lastAv.frame);
    v.center = center;
  }
}

- (void) updateAlreadyHiredViewForResidence:(ResidenceProto *)res {
  GameState *gs = [GameState sharedGameState];
  NSArray *accepted = [gs acceptedFbRequestsForUserStructUuid:self.userStruct.userStructUuid fbStructLevel:res.structInfo.level];
  
  self.alreadyHiredLabel.text = [NSString stringWithFormat:@"You have hired a %@.", res.occupationName];
  
  UIView *bottomView = self.alreadyHiredBottomView;
  if (accepted.count) {
    FriendAcceptView *lastAv = nil;
    for (int i = 0; i < self.hiredFriendViews.count; i++) {
      FriendAcceptView *av = self.hiredFriendViews[i];
      RequestFromFriend *req = i < accepted.count ? accepted[i] : nil;
      
      if (i >= res.numAcceptedFbInvites || i >= accepted.count) {
        av.hidden = YES;
      } else {
        av.hidden = NO;
        [av updateForFacebookId:req.invite.recipientFacebookId];
        lastAv = av;
      }
    }
    
    if (lastAv) {
      UIView *v = lastAv.superview;
      CGPoint center = v.center;
      v.width = CGRectGetMaxX(lastAv.frame);
      v.center = center;
    }
    
    bottomView.hidden = NO;
    self.alreadyHiredLabel.center = ccp(self.alreadyHiredLabel.center.x, bottomView.frame.origin.y/2);
  } else {
    bottomView.hidden = YES;
    self.alreadyHiredLabel.center = ccp(self.alreadyHiredLabel.center.x, self.alreadyHiredView.frame.size.height/2);
  }
}

#pragma mark - Moving to views

- (void) moveToView:(UIView *)view {
  self.center = ccp(self.frame.size.width/2-view.center.x+self.superview.frame.size.width/2, self.center.y);
}

- (void) moveToHireView {
  [self moveToView:self.hireView];
}

- (void) moveToAddSlotsView {
  self.alreadyHiredView.hidden = YES;
  self.addSlotsView.hidden = NO;
  [self moveToView:self.addSlotsView];
}

- (void) moveToAlreadyHiredView {
  self.alreadyHiredView.hidden = NO;
  self.addSlotsView.hidden = YES;
  [self moveToView:self.alreadyHiredView];
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

#pragma mark - TabBar delegate methods

- (void) button1Clicked:(id)sender {
  self.chooserView.state = FBChooserStateAllFriends;
  [sender clickButton:1];
}

- (void) button2Clicked:(id)sender {
  self.chooserView.state = FBChooserStateGameFriends;
  [sender clickButton:2];
}

@end

@implementation HireViewController

- (id) initWithUserStruct:(UserStruct *)us {
  if ((self = [super init])) {
    self.userStruct = us;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  [self.menuContainer addSubview:self.bonusView];
  
  self.bonusTopBar.alpha = 0.f;
  self.backView.alpha = 0.f;
  [self.bonusView updateForUserStruct:self.userStruct];
  [self loadHireView];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  _canClick = YES;
  
  NSString *gn = [GAME_NAME.uppercaseString substringToIndex:[GAME_NAME rangeOfString:@" "].location];
  self.bonusTopBar.label2.text = [NSString stringWithFormat:@"%@ FRIENDS", gn];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbInviteAccepted) name:FB_INVITE_ACCEPTED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbIncreasedSlots:) name:FB_INCREASE_SLOTS_NOTIFICATION object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
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
  NSString *userStructUuid = dict[@"UserStructId"];
  
  if ([userStructUuid isEqualToString:self.userStruct.userStructUuid] && self.bonusView.superview) {
    [self.bonusView updateForUserStruct:self.userStruct];
    [self loadHireView];
  }
}

#pragma mark - Top bar

- (void) loadTopForSlotsList {
  self.titleLabel.alpha = 1.f;
  self.backView.alpha = 0.f;
  self.bonusTopBar.alpha = 0.f;
  self.titleLabel.text = @"Bonus Slots";
}

- (void) loadTopForAddSlots:(ResidenceProto *)res {
  self.titleLabel.alpha = 1.f;
  self.backView.alpha = 1.f;
  self.bonusTopBar.alpha = 0.f;
  
  self.titleLabel.text = res.occupationName;
}

- (void) loadTopForFriendFinder {
  self.titleLabel.alpha = 0.f;
  self.backView.alpha = 1.f;
  self.bonusTopBar.alpha = 1.f;
  
  self.bonusView.sendSpinner.hidden = YES;
  self.bonusView.sendLabel.hidden = NO;
  _sendingFbInvites = NO;
}

- (IBAction) hireWithGemsClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  ResidenceProto *res = (ResidenceProto *)self.userStruct.staticStructForNextFbLevel;
  if (gs.gems < res.numGemsRequired) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] increaseInventorySlots:self.userStruct withGems:YES delegate:self];
    [self.bonusView spinnerOnGems];
    _canClick = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FB_INCREASE_SLOTS_NOTIFICATION object:self userInfo:nil];
  }
}

- (void) handleIncreaseMonsterInventorySlotResponseProto:(FullEvent *)fe {
  [self.bonusView updateForUserStruct:self.userStruct];
  [self.bonusView removeSpinner];
  _canClick = YES;
  
  [self loadHireView];
}

#pragma mark - Displaying Views

- (void) loadHireView {
  _isOnFriendFinder = NO;
  [UIView animateWithDuration:0.3f animations:^{
    [self.bonusView moveToHireView];
    [self loadTopForSlotsList];
  }];
}

- (void) loadAddSlotsView {
  ResidenceProto *res = (ResidenceProto *)self.userStruct.staticStructForNextFbLevel;
  [self.bonusView updateAddSlotsViewForResidence:res];
  
  _isOnFriendFinder = NO;
  [UIView animateWithDuration:0.3f animations:^{
    [self.bonusView moveToAddSlotsView];
    [self loadTopForAddSlots:res];
  }];
}

- (void) loadAlreadyHiredViewForResidence:(ResidenceProto *)rp {
  _isOnFriendFinder = NO;
  [self.bonusView updateAlreadyHiredViewForResidence:rp];
  
  [UIView animateWithDuration:0.3f animations:^{
    [self.bonusView moveToAlreadyHiredView];
    [self loadTopForAddSlots:rp];
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
  
  ResidenceProto *rp = self.bonusView.staticStructs[indexPath.row];
  if (rp.structInfo.level == self.userStruct.fbInviteStructLvl+1 && rp.structInfo.level <= self.userStruct.staticStruct.structInfo.level) {
    [self loadAddSlotsView];
  } else if (rp.structInfo.level < self.userStruct.fbInviteStructLvl+1) {
    [self loadAlreadyHiredViewForResidence:rp];
  }
}

#pragma mark - IBActions

- (IBAction) viewFriendsClicked:(id)sender {
  [self loadFriendFinderView];
}

- (IBAction) sendClicked:(id)sender {
  if (_sendingFbInvites) return;
  if (self.bonusView.chooserView.selectedIds.count > 0) {
    self.bonusView.sendSpinner.hidden = NO;
    self.bonusView.sendLabel.hidden = YES;
    _sendingFbInvites = YES;
    NSString *req = [NSString stringWithFormat:@"Please help me add slots!"];
    [self.bonusView.chooserView sendRequestWithString:req completionBlock:^(BOOL success, NSArray *friendIds) {
      if (success && friendIds.count > 0) {
        [[OutgoingEventController sharedOutgoingEventController] inviteAllFacebookFriends:friendIds forStruct:self.userStruct];
        
        [Analytics inviteFacebook];
      }
      
      if (success && _isOnFriendFinder) {
        [self.bonusView updateForUserStruct:self.userStruct];
        [self loadHireView];
      }
      
      self.bonusView.sendSpinner.hidden = YES;
      self.bonusView.sendLabel.hidden = NO;
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

- (IBAction) closeClicked:(id)sender {
  if (_canClick) {
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
      [self.view removeFromSuperview];
      [self removeFromParentViewController];
    }];
    
    [self.delegate hireViewControllerClosed];
  }
}

@end
