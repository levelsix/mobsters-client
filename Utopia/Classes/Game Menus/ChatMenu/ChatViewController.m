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

@implementation ChatTopBar

- (void) clickButton:(int)button {
  [super clickButton:button];
  
  for (int i = 1; i <= 3; i++) {
    UIButton *b = (UIButton *)[self viewWithTag:i];
    b.enabled = i != button;
  }
}

@end

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

- (void) viewDidLoad {
  self.clanChatView.frame = self.globalChatView.frame;
  [self.globalChatView.superview addSubview:self.clanChatView];
  
  // Align top left corner
  CGRect r = self.privateChatView.frame;
  r.origin = self.globalChatView.frame.origin;
  self.privateChatView.frame = r;
  [self.globalChatView.superview addSubview:self.privateChatView];
  
  [self button1Clicked:nil];
  
  [self.view addSubview:self.popoverView];
  self.popoverView.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated {
  [self reloadTablesAnimated:NO];
  
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserver:self selector:@selector(reloadTables:) name:GLOBAL_CHAT_RECEIVED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadTables:) name:PRIVATE_CHAT_RECEIVED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadTables:) name:CLAN_CHAT_RECEIVED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(incrementClanBadge) name:CLAN_CHAT_RECEIVED_NOTIFICATION object:nil];
  
  [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  
  self.view.hidden = YES;
}

- (void) viewDidAppear:(BOOL)animated {
  self.view.hidden = NO;
  self.mainView.center = ccp(self.view.frame.size.width/2, self.view.frame.size.height*3/2);
  self.bgdView.alpha = 0.f;
  [UIView animateWithDuration:0.18f animations:^{
    self.mainView.center = ccp(self.view.frame.size.width/2, self.view.frame.size.height/2);
    self.bgdView.alpha = 1.f;
  }];
}

- (void) viewDidDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateBadges {
  GameState *gs = [GameState sharedGameState];
  int privBadge = 0;
  for (PrivateChatPostProto *p in gs.privateChats) {
    if (p.isUnread) {
      privBadge++;
    }
  }
  self.privateBadgeIcon.badgeNum = privBadge;
}

- (void) incrementClanBadge {
  if (self.clanChatView.hidden) {
    self.clanBadgeIcon.badgeNum++;
  } else {
    [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_CHAT_VIEWED_NOTIFICATION object:nil];
  }
  [self updateBadges];
}

- (void) reloadTables:(NSNotification *)notification {
  GameState *gs = [GameState sharedGameState];
  [self reloadTablesAnimated:YES];
  
  // Only add a private chat if it is from the other user
  PrivateChatPostProto *pcpp = [notification.userInfo objectForKey:[NSString stringWithFormat:PRIVATE_CHAT_DEFAULTS_KEY, self.privateChatView.curUserId]];
  if (pcpp.recipient.minUserProto.userId == gs.userId && pcpp.poster.minUserProto.userId == self.privateChatView.curUserId) {
    [self.privateChatView addPrivateChat:pcpp];
  }
}

- (void) reloadTablesAnimated:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  [self.globalChatView updateForChats:gs.globalChatMessages animated:animated];
  [self.clanChatView updateForChats:gs.clanChatMessages andClan:gs.clan animated:animated];
  [self.privateChatView updateForPrivateChatList:gs.privateChats];
  
  [self updateBadges];
}

- (void) openToViewWithBadge {
  if (self.clanBadgeIcon.badgeNum) {
    [self button2Clicked:nil];
  } else if (self.privateBadgeIcon.badgeNum) {
    [self button3Clicked:nil];
  }
  [self button1Clicked:nil];
}

- (void) openWithConversationForUserId:(int)userId name:(NSString *)name {
  [self button3Clicked:nil];
  [self.privateChatView openConversationWithUserId:userId name:name animated:NO];
}

- (IBAction)closeClicked:(id)sender {
  if (!self.mainView.layer.animationKeys.count) {
    [UIView animateWithDuration:0.18f animations:^{
      self.mainView.center = ccp(self.view.frame.size.width/2, self.view.frame.size.height*3/2);
      self.bgdView.alpha = 0.f;
    } completion:^(BOOL finished) {
      [self.view removeFromSuperview];
      [self removeFromParentViewController];
    }];
    
    [self.popoverView close];
    
    [self.delegate chatViewControllerDidClose:self];
  }
}

#pragma mark - ChatTopBar delegate

- (void) button1Clicked:(id)sender {
  self.globalChatView.hidden = NO;
  self.clanChatView.hidden = YES;
  self.privateChatView.hidden = YES;
  [self.popoverView close];
  
  // Make sure list view is shown
  [self.privateChatView loadListViewAnimated:NO];
  
  [self.topBar clickButton:1];
}

- (void) button2Clicked:(id)sender {
  self.globalChatView.hidden = YES;
  self.clanChatView.hidden = NO;
  self.privateChatView.hidden = YES;
  [self.popoverView close];
  
  // Make sure list view is shown
  [self.privateChatView loadListViewAnimated:NO];
  
  [self.topBar clickButton:2];
  
  self.clanBadgeIcon.badgeNum = 0;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_CHAT_VIEWED_NOTIFICATION object:nil];
}

- (void) button3Clicked:(id)sender {
  self.globalChatView.hidden = YES;
  self.clanChatView.hidden = YES;
  self.privateChatView.hidden = NO;
  [self.popoverView close];
  
  // Make sure list view is shown
  [self.privateChatView loadListViewAnimated:NO];
  
  [self.topBar clickButton:3];
}

#pragma mark - ChatViewDelegate methods

- (void) clanClicked:(MinimumClanProto *)clan {
  GameViewController *gvc = [GameViewController baseController];
  [gvc openClanViewForClanId:clan.clanId];
  
  [self closeClicked:nil];
}

- (void) profileClicked:(int)userId {
  UIViewController *gvc = [GameViewController baseController];
  ProfileViewController *pvc = [[ProfileViewController alloc] initWithUserId:userId];
  [gvc addChildViewController:pvc];
  pvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:pvc.view];
}

- (void) beginPrivateChatWithUserId:(int)userId name:(NSString *)name {
  [self openWithConversationForUserId:userId name:name];
}

- (void) muteClicked:(int)userId name:(NSString *)name {
  NSString *msg = [NSString stringWithFormat:@"Would you like to hide messages from %@ for 24 hours?", name];
  [GenericPopupController displayConfirmationWithDescription:msg title:[NSString stringWithFormat:@"Mute %@", name] okayButton:@"Mute" cancelButton:@"Cancel" target:self selector:@selector(muteConfirmed)];
  
  _muteUserId = userId;
  _muteName = name;
}

- (void) muteConfirmed {
  Globals *gl = [Globals sharedGlobals];
  [gl muteUserId:_muteUserId];
  
  [Globals addGreenAlertNotification:[NSString stringWithFormat:@"%@ has just been muted.", _muteName]];
  
  _muteUserId = 0;
  _muteName = nil;
}

- (IBAction)findClanClicked:(id)sender {
  GameViewController *gvc = [GameViewController baseController];
  [gvc openClanView];
}

- (void) viewedPrivateChat {
  [self updateBadges];
  
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
    CGRect relFrame = [cv convertRect:keyboardFrame fromView:nil];
    CGFloat keyboardTop = relFrame.origin.y;
    cv.bottomView.center = ccp(cv.bottomView.center.x, keyboardTop-cv.bottomView.frame.size.height/2);
    
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
    
    CGRect r = cv.chatTable.frame;
    r.origin.y = cv.bottomView.frame.origin.y-r.size.height;
    cv.chatTable.frame = r;
  }
  
  [UIView commitAnimations];
  
  [self.popoverView close];
}

@end
