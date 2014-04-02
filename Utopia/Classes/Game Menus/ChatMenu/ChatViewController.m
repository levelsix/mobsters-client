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
#import "ClanViewController.h"
#import "ProfileViewController.h"
#import "UnreadNotifications.h"
#import "SoundEngine.h"
#import "GameViewController.h"

#define ANIMATION_SPEED 800.f

@implementation ChatMainView

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  [self endEditing:NO];
  return [self.insideView pointInside:[self convertPoint:point toView:self.insideView] withEvent:event] ||
         [self.openButton pointInside:[self convertPoint:point toView:self.openButton] withEvent:event];
}

@end

@implementation ChatTopBar

- (void) awakeFromNib {
  self.inactiveTextColor = [UIColor colorWithWhite:1.f alpha:1.f];
  self.inactiveShadowColor = [UIColor colorWithWhite:0.f alpha:0.5f];
  self.activeTextColor = [UIColor colorWithRed:8/255.f green:70/255.f blue:107/255.f alpha:1.f];
  self.activeShadowColor = [UIColor colorWithWhite:1.f alpha:0.75f];
  [super awakeFromNib];
}

@end

@implementation ChatViewController

- (void) viewDidLoad {
  [self.topBar clickButton:1];
  
  self.clanChatView.frame = self.globalChatView.frame;
  [self.globalChatView.superview addSubview:self.clanChatView];
  
  // Align top left corner
  CGRect r = self.privateChatView.frame;
  r.origin = self.globalChatView.frame.origin;
  self.privateChatView.frame = r;
  [self.globalChatView.superview addSubview:self.privateChatView];
  
  [self button1Clicked:nil];
}

- (void) viewWillAppear:(BOOL)animated {
  CGRect r = self.view.frame;
  r.origin.x = -self.containerView.frame.size.width;
  self.view.frame = r;
  [self closeAnimated:NO];
  
  [self reloadTables:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTables:) name:GLOBAL_CHAT_RECEIVED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTables:) name:PRIVATE_CHAT_RECEIVED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTables:) name:CLAN_CHAT_RECEIVED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementClanBadge) name:CLAN_CHAT_RECEIVED_NOTIFICATION object:nil];
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
  
  if (!self.isOpen) {
    self.overallBadgeIcon.badgeNum = self.clanBadgeIcon.badgeNum+self.privateBadgeIcon.badgeNum;
  }
}

- (void) incrementClanBadge {
  if (!self.isOpen || self.clanChatView.hidden) {
    self.clanBadgeIcon.badgeNum++;
  }
  [self updateBadges];
}

- (void) reloadTables:(NSNotification *)notification {
  GameState *gs = [GameState sharedGameState];
  [self.globalChatView updateForChats:[gs.globalChatMessages reversedArray] animated:YES];
  [self.clanChatView updateForChats:[gs.clanChatMessages reversedArray] andClan:gs.clan];
  [self.privateChatView updateForPrivateChatList:gs.privateChats];
  
  // Only add a private chat if it is from the other user
  PrivateChatPostProto *pcpp = [notification.userInfo objectForKey:[NSString stringWithFormat:PRIVATE_CHAT_DEFAULTS_KEY, self.privateChatView.curUserId]];
  if (pcpp.recipient.minUserProto.userId == gs.userId && pcpp.poster.minUserProto.userId == self.privateChatView.curUserId) {
    [self.privateChatView addPrivateChat:pcpp];
  }
  
  [self updateBadges];
}

- (IBAction)buttonDragged:(id)sender forEvent:(UIEvent*)event {
  UITouch *touch = [[event touchesForView:sender] anyObject];
  UIButton *slider = (UIButton *)sender;
  CGPoint p = [self.view.superview convertPoint:[touch locationInView:slider] fromView:slider];
  float potentialX = p.x-slider.center.x;
  float finalX = clampf(potentialX, -self.containerView.frame.size.width, 0);
  
  if (self.isOpen && finalX > self.view.frame.origin.x) {
    _passedThreshold = YES;
  } else if (!self.isOpen && finalX < self.view.frame.origin.x) {
    _passedThreshold = YES;
  }
  
  CGRect r = self.view.frame;
  r.origin.x = finalX;
  self.view.frame = r;
}

- (IBAction)buttonLetGo:(id)sender {
  if (_passedThreshold) {
    int posX = self.view.frame.origin.x;
    
    if (posX < -self.containerView.frame.size.width/2) {
      [self closeAnimated:YES];
    } else {
      [self openToViewWithBadge];
    }
  } else {
    if (self.isOpen) {
      [self closeAnimated:YES];
    } else {
      [self openToViewWithBadge];
    }
  }
  _passedThreshold = NO;
}

- (void) openToViewWithBadge {
  if (self.clanBadgeIcon.badgeNum) {
    [self button2Clicked:nil];
  } else if (self.privateBadgeIcon.badgeNum) {
    [self button3Clicked:nil];
  }
  [self open];
}

- (void) open {
  [self reloadTables:nil];
  [UIView animateWithDuration:-self.view.frame.origin.x/ANIMATION_SPEED animations:^{
    CGRect r = self.view.frame;
    r.origin.x = 0;
    self.view.frame = r;
    
    self.arrow.transform = CGAffineTransformIdentity;
  }];
  
  self.overallBadgeIcon.badgeNum = 0;
  
  [SoundEngine chatOpened];
  
  self.isOpen = YES;
}

- (void) closeAnimated:(BOOL)animated {
  float dist = self.containerView.frame.size.width+self.view.frame.origin.x;
  
  void (^anim)(void) = ^{
    CGRect r = self.view.frame;
    r.origin.x = -self.containerView.frame.size.width-2;
    self.view.frame = r;
    
    self.arrow.transform = CGAffineTransformMakeScale(-1, 1);
  };
  
  self.isOpen = NO;
  [self updateBadges];
  
  void (^comp)(BOOL finished) = ^(BOOL finished){
    [self.privateChatView loadListViewAnimated:NO];
  };
  
  if (animated) {
    [UIView animateWithDuration:dist/ANIMATION_SPEED animations:anim completion:comp];
    [SoundEngine chatClosed];
  } else {
    anim();
    comp(YES);
  }
  
  
}

- (void) openWithConversationForUserId:(int)userId {
  [self button3Clicked:nil];
  [self.privateChatView openConversationWithUserId:userId animated:NO];
  [self open];
}

#pragma mark - ChatTopBar delegate

- (void) button1Clicked:(id)sender {
  self.globalChatView.hidden = NO;
  self.clanChatView.hidden = YES;
  self.privateChatView.hidden = YES;
  
  [self.topBar clickButton:1];
}

- (void) button2Clicked:(id)sender {
  self.globalChatView.hidden = YES;
  self.clanChatView.hidden = NO;
  self.privateChatView.hidden = YES;
  
  [self.topBar clickButton:2];
  
  self.clanBadgeIcon.badgeNum = 0;
}

- (void) button3Clicked:(id)sender {
  self.globalChatView.hidden = YES;
  self.clanChatView.hidden = YES;
  self.privateChatView.hidden = NO;
  
  // Make sure list view is shown
  [self.privateChatView loadListViewAnimated:NO];
  
  [self.topBar clickButton:3];
}

#pragma mark - ChatViewDelegate methods

- (void) clanClicked:(MinimumClanProto *)clan {
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  UIViewController *gvc = [GameViewController baseController];
  [gvc presentViewController:m animated:YES completion:nil];
  
  GameState *gs = [GameState sharedGameState];
  ClanInfoViewController *cvc = nil;
  if (gs.clan.clanId == clan.clanId) {
    cvc = [[ClanInfoViewController alloc] init];
    [cvc loadForMyClan];
  } else {
    cvc = [[ClanInfoViewController alloc] initWithClanId:clan.clanId andName:clan.name];
  }
  [m pushViewController:cvc animated:NO];
  
  [self closeAnimated:YES];
}

- (void) profileClicked:(int)userId {
  UIViewController *gvc = [GameViewController baseController];
  ProfileViewController *pvc = [[ProfileViewController alloc] initWithUserId:userId];
  [gvc addChildViewController:pvc];
  pvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:pvc.view];
}

- (IBAction)findClanClicked:(id)sender {
  UIViewController *gvc = [GameViewController baseController];
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  [gvc presentViewController:m animated:YES completion:nil];
  ClanViewController *cvc = [[ClanViewController alloc] init];
  [m pushViewController:cvc animated:NO];
  
  [self closeAnimated:YES];
}

- (void) viewedPrivateChat {
  [self updateBadges];
}

@end
