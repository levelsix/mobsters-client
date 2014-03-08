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
#import "PrivateChatPostProto+UnreadStatus.h"

#define ANIMATION_SPEED 800.f

@implementation ChatMainView

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  [self endEditing:YES];
  return [self.insideView pointInside:[self convertPoint:point toView:self.insideView] withEvent:event] ||
         [self.openButton pointInside:[self convertPoint:point toView:self.openButton] withEvent:event];
}

@end

@implementation ChatTopBar

- (void) clickButton:(int)button {
  self.label1.highlighted = NO;
  self.label1.shadowColor = [UIColor colorWithWhite:1.f alpha:0.5f];
  self.label2.highlighted = NO;
  self.label2.shadowColor = [UIColor colorWithWhite:1.f alpha:0.5f];
  self.label3.highlighted = NO;
  self.label3.shadowColor = [UIColor colorWithWhite:1.f alpha:0.5f];
  
  UILabel *label = nil;
  if (button == 1) {
    label = self.label1;
  } else if (button == 2) {
    label = self.label2;
  } else if (button == 3) {
    label = self.label3;
  }
  label.highlighted = YES;
  self.selectedView.center = ccp(label.center.x, self.selectedView.center.y);
  label.shadowColor = [UIColor colorWithWhite:0.f alpha:0.3f];
}

- (IBAction) buttonClicked:(id)sender {
  int tag = [(UIView *)sender tag];
  if (tag == 1) {
    [self.delegate button1Clicked];
    [self clickButton:1];
  } else if (tag == 2) {
    [self.delegate button2Clicked];
    [self clickButton:2];
  } else if (tag == 3) {
    [self.delegate button3Clicked];
    [self clickButton:3];
  }
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
  
  [self button1Clicked];
}

- (void) viewWillAppear:(BOOL)animated {
  CGRect r = self.view.frame;
  r.origin.x = -self.containerView.frame.size.width;
  self.view.frame = r;
  [self closeAnimated:NO];
  
  [self reloadTables:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTables:) name:CHAT_RECEIVED_NOTIFICATION object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
      [self open];
    }
  } else {
    if (self.isOpen) {
      [self closeAnimated:YES];
    } else {
      [self open];
    }
  }
  _passedThreshold = NO;
}

- (void) open {
  [UIView animateWithDuration:-self.view.frame.origin.x/ANIMATION_SPEED animations:^{
    CGRect r = self.view.frame;
    r.origin.x = 0;
    self.view.frame = r;
    
    self.arrow.transform = CGAffineTransformIdentity;
  }];
  
  self.isOpen = YES;
}

- (void) closeAnimated:(BOOL)animated {
  float dist = self.containerView.frame.size.width+self.view.frame.origin.x;
  
  void (^anim)(void) = ^{
    CGRect r = self.view.frame;
    r.origin.x = -self.containerView.frame.size.width-1;
    self.view.frame = r;
    
    self.arrow.transform = CGAffineTransformMakeScale(-1, 1);
  };
  
  void (^comp)(BOOL finished) = ^(BOOL finished){
    [self.privateChatView loadListViewAnimated:NO];
  };
  
  if (animated) {
    [UIView animateWithDuration:dist/ANIMATION_SPEED animations:anim completion:comp];
  } else {
    anim();
    comp(YES);
  }
  
  self.isOpen = NO;
}

- (void) openWithConversationForUserId:(int)userId {
  [self button3Clicked];
  [self.privateChatView openConversationWithUserId:userId animated:NO];
  [self open];
}

#pragma mark - ChatTopBar delegate

- (void) button1Clicked {
  self.globalChatView.hidden = NO;
  self.clanChatView.hidden = YES;
  self.privateChatView.hidden = YES;
  
  [self.topBar clickButton:1];
}

- (void) button2Clicked {
  self.globalChatView.hidden = YES;
  self.clanChatView.hidden = NO;
  self.privateChatView.hidden = YES;
  
  [self.topBar clickButton:2];
}

- (void) button3Clicked {
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
  UIViewController *gvc = (UIViewController *)self.parentViewController;
  [gvc presentViewController:m animated:YES completion:nil];
  [m pushViewController:[[ClanInfoViewController alloc] initWithClanId:clan.clanId andName:clan.name] animated:NO];
  
  [self closeAnimated:YES];
}

- (void) profileClicked:(int)userId {
  UIViewController *gvc = (UIViewController *)self.parentViewController;
  ProfileViewController *pvc = [[ProfileViewController alloc] initWithUserId:userId];
  [gvc addChildViewController:pvc];
  pvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:pvc.view];
}

- (void) dealloc {
  NSLog(@"Meep");
}

@end
