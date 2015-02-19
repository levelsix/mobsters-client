//
//  ChatViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/8/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "ChatViewController.h"
#import "cocos2d.h"
#import "OutgoingEventController.h"
#import "GameState.h"
#import "MenuNavigationController.h"
#import "ProfileViewController.h"
#import "UnreadNotifications.h"
#import "SoundEngine.h"
#import "GameViewController.h"
#import "Globals.h"
#import "GenericPopupController.h"

#define ANIMATION_SPEED 800.f

@implementation ChatMainView

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  BOOL foundPoint = NO;
  for (UIView *v in self.allowedViews) {
    if ([v pointInside:[self convertPoint:point toView:v] withEvent:event]) {
      foundPoint = YES;
    }
  }
  if (!foundPoint) [self endEditing:NO];
  return [super pointInside:point withEvent:event];
}

@end

@implementation ChatViewController

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserver:self selector:@selector(reloadTables:) name:GLOBAL_CHAT_RECEIVED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadTables:) name:PRIVATE_CHAT_RECEIVED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadTables:) name:CLAN_CHAT_RECEIVED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadTables:) name:CLAN_HELPS_CHANGED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadTables:) name:RECEIVED_CLAN_HELP_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadTables:) name:CLAN_AVENGINGS_CHANGED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadTables:) name:NEW_BATTLE_HISTORY_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadTables:) name:CLAN_TEAM_DONATIONS_CHANGED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(updateClanBadge) name:CLAN_CHAT_RECEIVED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(updateClanBadge) name:CLAN_HELPS_CHANGED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(updateClanBadge) name:CLAN_AVENGINGS_CHANGED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(updateClanBadge) name:CLAN_TEAM_DONATIONS_CHANGED_NOTIFICATION object:nil];
  
  //[center addObserver:self selector:@selector(reloadTables:) name:FB_INVITE_RESPONDED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadTables:) name:NEW_FB_INVITE_NOTIFICATION object:nil];
  
  [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  
  self.view.hidden = YES;
  
  [[CCDirector sharedDirector] pause];
  
  [Analytics openChat];
  
  // Increase
  float newHeight = self.view.height-28.f;
  self.mainView.height = newHeight;
  self.mainView.center = ccp(self.view.width/2, self.view.height/2);
  
  // Add other chat views
  self.clanChatView.frame = self.globalChatView.frame;
  [self.globalChatView.superview addSubview:self.clanChatView];
  
  // Make private chat's width 2x size
  self.privateChatView.frame = self.globalChatView.frame;
  self.privateChatView.width *= 2;
  self.privateChatView.topLiveHelpView = self.topLiveHelpView;
  [self.globalChatView.superview addSubview:self.privateChatView];
  
  // So that it doesn't mark it as viewed
  self.clanChatView.hidden = YES;
  [self updateClanBadge];
  
  [self.view addSubview:self.popoverView];
  self.popoverView.hidden = YES;
  
  [self reloadTablesAnimated:NO];
  
  
  self.updateTimer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  [self updateLabels];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  self.view.hidden = NO;
  self.mainView.center = ccp(self.view.frame.size.width/2, self.view.frame.size.height*3/2);
  self.bgdView.alpha = 0.f;
  [UIView animateWithDuration:0.18f animations:^{
    self.mainView.center = ccp(self.view.frame.size.width/2, self.view.frame.size.height/2);
    self.bgdView.alpha = 1.f;
  }];
  
  [SoundEngine chatOpened];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[CCDirector sharedDirector] resume];
  
  [self.monsterSelectViewController closeClicked:nil];
  
  [SoundEngine chatClosed];
}

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [self.updateTimer invalidate];
  self.updateTimer = nil;
}

- (void) updateLabels {
  // Go through the chat views and see if any need to update time
  BOOL reloadEverything = NO;
  
  for (ChatView *cv in @[self.clanChatView, self.privateChatView]) {
    for (ChatCell *cell in cv.chatTable.visibleCells) {
      NSIndexPath *ip = [cv.chatTable indexPathForCell:cell];
      id<ChatObject> co = cv.chats[ip.row];
      
      if ([co respondsToSelector:@selector(updateForTimeInChatCell:)]) {
        reloadEverything |= [co updateForTimeInChatCell:cell];
      }
    }
  }
  
  if (reloadEverything) {
    [self reloadTablesAnimated:YES];
  }
}

- (void) updateBadges {
  GameState *gs = [GameState sharedGameState];
  int privBadge = 0;
  for (id<ChatObject> p in gs.allPrivateChats) {
    if (!p.isRead) {
      privBadge++;
    }
  }
  self.privateBadgeIcon.badgeNum = privBadge;
}

- (void) updateClanBadge {
  GameState *gs = [GameState sharedGameState];
  if (!self.clanChatView.hidden) {
    for (id <ChatObject> cm in gs.allClanChatObjects) {
      [cm markAsRead];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_CHAT_VIEWED_NOTIFICATION object:nil];
  }
  
  int badgeNum = 0;
  for (id<ChatObject> cm in gs.allClanChatObjects) {
    badgeNum += !cm.isRead;
  }
  self.clanBadgeIcon.badgeNum = badgeNum;
  
  [self updateBadges];
}

- (void) reloadTables:(NSNotification *)notification {
  [self reloadTablesAnimated:YES];
  
  // Only add a private chat if it is from the other user
  PrivateChatPostProto *pcpp = [notification.userInfo objectForKey:[NSString stringWithFormat:PRIVATE_CHAT_DEFAULTS_KEY, self.privateChatView.curUserUuid]];
  if ([pcpp.otherUser.userUuid isEqualToString:self.privateChatView.curUserUuid]) {
    [self.privateChatView addPrivateChat:pcpp];
  } else if ([notification.name isEqualToString:NEW_FB_INVITE_NOTIFICATION] ||
             [notification.name isEqualToString:NEW_BATTLE_HISTORY_NOTIFICATION]) {
    // Reload with baseChats so that the new fb invite gets potentially added.. if possible
    [self.privateChatView updateForChats:self.privateChatView.baseChats animated:YES];
  }
}

- (void) reloadTablesAnimated:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  [self.globalChatView updateForChats:gs.globalChatMessages animated:animated];
  [self.clanChatView updateForChats:gs.allClanChatObjects andClan:gs.clan animated:animated];
  [self.privateChatView updateForPrivateChatList:gs.allPrivateChats];
  
  [self updateBadges];
  
  [self checkMonsterSelect];
}

- (void) openToViewWithBadge {
  if (self.clanBadgeIcon.badgeNum) {
    [self button2Clicked:nil];
  } else if (self.privateBadgeIcon.badgeNum) {
    [self button3Clicked:nil];
  }
  [self button1Clicked:nil];
}

- (void) openWithConversationForUserUuid:(NSString *)userUuid name:(NSString *)name {
  [self button3Clicked:nil];
  [self.privateChatView openConversationWithUserUuid:userUuid name:name animated:NO];
}

- (IBAction)topLiveHelpClicked:(id)sender {
  //click the private chat button
  [self button3Clicked:sender];
  //click the admin button
  Globals *gl = [Globals sharedGlobals];
  MinimumUserProto *mup = gl.adminChatUser;
  [self.privateChatView openConversationWithUserUuid:mup.userUuid name:mup.name animated:YES];
  [self hideTopLiveHelp];
}

- (IBAction)closeClicked:(id)sender {
  // Check if we are editing
  if (sender && _isEditing) {
    [self.view endEditing:YES];
    [self.popoverView close];
  } else if (!self.mainView.layer.animationKeys.count) {
    [self beginAppearanceTransition:NO animated:YES];
    [UIView animateWithDuration:0.18f animations:^{
      self.topLiveHelpView.center = ccp(self.view.frame.size.width/2, self.view.frame.size.height*3/2);
      self.mainView.center = ccp(self.view.frame.size.width/2, self.view.frame.size.height*3/2);
      self.bgdView.alpha = 0.f;
    } completion:^(BOOL finished) {
      [self.view removeFromSuperview];
      [self removeFromParentViewController];
      
      [self endAppearanceTransition];
    }];
    
    [self.popoverView close];
    
    [self.delegate chatViewControllerDidClose:self];
    [self.view endEditing:YES];
  }
}

#pragma mark - ChatTopBar delegate

- (void) button1Clicked:(id)sender {
  self.globalChatView.hidden = NO;
  self.clanChatView.hidden = YES;
  self.privateChatView.hidden = YES;
  [self.popoverView close];
  [self.monsterSelectViewController closeClicked:nil];
  
  // Make sure list view is shown
  [self.privateChatView loadListViewAnimated:NO];
  
  [self.topBar clickButton:1];
  
  [self.delegate chatViewControllerDidChangeScope:ChatScopeGlobal];
}

- (void) button2Clicked:(id)sender {
  self.globalChatView.hidden = YES;
  self.clanChatView.hidden = NO;
  self.privateChatView.hidden = YES;
  [self.popoverView close];
  [self.monsterSelectViewController closeClicked:nil];
  
  // Make sure list view is shown
  [self.privateChatView loadListViewAnimated:NO];
  
  [self.topBar clickButton:2];
  
  [self updateClanBadge];
  
  [self.delegate chatViewControllerDidChangeScope:ChatScopeClan];
}

- (void) button3Clicked:(id)sender {
  self.globalChatView.hidden = YES;
  self.clanChatView.hidden = YES;
  self.privateChatView.hidden = NO;
  [self.popoverView close];
  [self.monsterSelectViewController closeClicked:nil];
  
  // Make sure list view is shown
  [self.privateChatView loadListViewAnimated:NO];
  
  [self.topBar clickButton:3];
  
  [self.delegate chatViewControllerDidChangeScope:ChatScopePrivate];
}

#pragma mark - ChatViewDelegate methods
- (void) hideTopLiveHelp {
  if (self.topLiveHelpView.alpha > 0.f) {
    [UIView animateWithDuration:0.3f animations:^{
      self.topLiveHelpView.alpha = 0.f;
    }];
  }
}

- (void) clanClicked:(MinimumClanProto *)clan {
  GameViewController *gvc = [GameViewController baseController];
  [gvc openClanViewForClanUuid:clan.clanUuid];
  
  [self closeClicked:nil];
}

- (void) profileClicked:(NSString *)userUuid {
  UIViewController *gvc = [GameViewController baseController];
  ProfileViewController *pvc = [[ProfileViewController alloc] initWithUserUuid:userUuid];
  [gvc addChildViewController:pvc];
  pvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:pvc.view];
}

- (void) beginPrivateChatWithUserUuid:(NSString *)userUuid name:(NSString *)name {
  [self openWithConversationForUserUuid:userUuid name:name];
  [self hideTopLiveHelp];
}

- (void) muteClicked:(NSString *)userUuid name:(NSString *)name {
  NSString *msg = [NSString stringWithFormat:@"Would you like to hide messages from %@ for 24 hours?", name];
  [GenericPopupController displayConfirmationWithDescription:msg title:[NSString stringWithFormat:@"Mute %@", name] okayButton:@"Mute" cancelButton:@"Cancel" target:self selector:@selector(muteConfirmed)];
  
  _muteUserUuid = userUuid;
  _muteName = name;
}

- (void) muteConfirmed {
  Globals *gl = [Globals sharedGlobals];
  [gl muteUserUuid:_muteUserUuid];
  
  [Globals addGreenAlertNotification:[NSString stringWithFormat:@"%@ has just been muted.", _muteName] isImmediate:YES];
  
  _muteUserUuid = nil;
  _muteName = nil;
}

- (IBAction) findClanClicked:(id)sender {
  GameViewController *gvc = [GameViewController baseController];
  [gvc openClanView];
}

- (void) viewedPrivateChat {
  [self updateBadges];
  
  GameState *gs = [GameState sharedGameState];
  [self.privateChatView updateForPrivateChatList:[gs allPrivateChats]];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:PRIVATE_CHAT_VIEWED_NOTIFICATION object:nil];
}

#pragma mark - Keyboard Notifications

- (void) keyboardWillShow:(NSNotification *)n {
	NSDictionary *userInfo = [n userInfo];
	CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationCurve:curve];
  [UIView setAnimationDuration:animationDuration];
  
  NSArray *chatViews = @[self.globalChatView, self.clanChatView, self.privateChatView];
  for (ChatView *cv in chatViews) {
    if (!_isEditing) {
      cv.originalBottomViewRect = cv.bottomView.frame;
    }
    
    CGRect relFrame = [cv convertRect:keyboardFrame fromView:nil];
    CGFloat keyboardTop = relFrame.origin.y;
    cv.bottomView.center = ccp(cv.bottomView.center.x, MIN(CGRectGetMidY(cv.originalBottomViewRect), keyboardTop-cv.bottomView.frame.size.height/2));
    
    CGRect r = cv.chatTable.frame;
    r.origin.y = cv.bottomView.frame.origin.y-MIN(cv.chatTable.contentSize.height+cv.chatTable.contentInset.top, r.size.height);
    cv.chatTable.frame = r;
    
    int numRows = (int)[cv.chatTable numberOfRowsInSection:0];
    if (numRows > 0) {
      [cv.chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
  }
  
  [UIView commitAnimations];
  
  [self.popoverView close];
  
  _isEditing = YES;
}

- (void) keyboardWillHide:(NSNotification *)n {
	NSDictionary *userInfo = [n userInfo];
  NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationCurve:curve];
  [UIView setAnimationDuration:animationDuration];
  
  NSArray *chatViews = @[self.globalChatView, self.clanChatView, self.privateChatView];
  for (ChatView *cv in chatViews) {
    cv.bottomView.frame = cv.originalBottomViewRect;
    
    cv.chatTable.originY = cv.bottomView.frame.origin.y-cv.chatTable.height;
  }
  
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(editingStopped)];
  
  [UIView commitAnimations];
  
  [self.popoverView close];
}

- (void) editingStopped {
  _isEditing = NO;
}

#pragma mark - Clan Team Donate Delegate

- (void) displayMonsterSelect:(ClanMemberTeamDonationProto *)donation sender:(id)sender {
  if (self.clanChatView.isHidden) {
    return;
  }
  
  MonsterSelectViewController *svc = [[MonsterSelectViewController alloc] init];
  if (svc) {
    self.monsterSelectViewController = svc;
    
    TeamDonateMonstersFiller *td = [[TeamDonateMonstersFiller alloc] initWithDonation:donation];
    svc.delegate = td;
    td.delegate = self;
    self.teamDonateMonstersFiller = td;
    
    GameViewController *gvc = [GameViewController baseController];
    svc.view.frame = gvc.view.bounds;
    [gvc addChildViewController:svc];
    [gvc.view addSubview:svc.view];
    
    // Make sure whole chat is in the view
    UITableViewCell *cell = [sender getAncestorInViewHierarchyOfType:[UITableViewCell class]];
    [self.clanChatView.chatTable scrollToRowAtIndexPath:[self.clanChatView.chatTable indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    
    if (sender == nil)
    {
      [svc showCenteredOnScreen];
    }
    else
    {
      if ([sender isKindOfClass:[UIButton class]])
      {
        UIButton* invokingButton = (UIButton*)sender;
        [svc showAnchoredToInvokingView:invokingButton
                          withDirection:ViewAnchoringPreferRightPlacement
                      inkovingViewImage:[invokingButton imageForState:invokingButton.state]];
      }
    }
    
    self.clanChatView.allowAutoScroll = NO;
  }
}

- (void) checkMonsterSelect {
  if (self.teamDonateMonstersFiller) {
    // Grab the latest team donation in case it has been fulfilled..
    GameState *gs = [GameState sharedGameState];
    NSString *donationUuid = self.teamDonateMonstersFiller.donation.donationUuid;
    
    ClanMemberTeamDonationProto *newDonation = nil;
    for (ClanMemberTeamDonationProto *donation in gs.clanTeamDonateUtil.teamDonations) {
      if ([donation.donationUuid isEqualToString:donationUuid]) {
        newDonation = donation;
      }
    }
    
    if (!newDonation || newDonation.isFulfilled) {
      [self.monsterSelectViewController closeClicked:nil];
    } else {
      self.teamDonateMonstersFiller.donation = newDonation;
    }
  }
}

- (void) monsterChosen {
  ClanMemberTeamDonationProto *donation = self.teamDonateMonstersFiller.donation;
  
  // Find the donation in chat views list
  NSInteger idx = [self.clanChatView.chats indexOfObject:donation];
  if (idx != NSNotFound) {
    ChatCell *cell = (ChatCell *)[self.clanChatView.chatTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    
    if (cell) {
      if ([cell.currentChatSubview isKindOfClass:[ChatTeamDonateView class]]) {
        ChatTeamDonateView *donateView = (ChatTeamDonateView *)cell.currentChatSubview;
        
        donateView.donateSpinner.hidden = NO;
        [donateView.donateSpinner startAnimating];
        
        donateView.donateLabel.hidden = YES;
        
        donateView.donateButton.userInteractionEnabled = NO;
      }
    }
  }
}

- (void) monsterSelectClosed {
  self.clanChatView.allowAutoScroll = YES;
  self.monsterSelectViewController = nil;
  self.teamDonateMonstersFiller = nil;
}

@end
