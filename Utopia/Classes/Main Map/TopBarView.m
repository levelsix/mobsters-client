//
//  TopBarView.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "TopBarView.h"
#import "cocos2d.h"
#import "MainMenuController.h"
#import "Globals.h"
#import "GoldShoppeViewController.h"
#import "GameViewController.h"
#import "MenuNavigationController.h"

@implementation SplitImageProgressBar

- (void) awakeFromNib {
  self.leftCap.transform = CGAffineTransformMakeScale(-1, 1);
}

- (void) setPercentage:(float)percentage {
  _percentage = clampf(percentage, 0.f, 1.f);
  
  float totalWidth = percentage*self.frame.size.width;
  
  CGRect r = self.leftCap.frame;
  r.size.width = MIN(ceilf(totalWidth/2), self.leftCap.image.size.width);
  self.leftCap.frame = r;
  
  r = self.rightCap.frame;
  r.size.width = self.leftCap.frame.size.width;
  if (totalWidth >= self.leftCap.image.size.width*2) {
    r.origin.x = totalWidth-r.size.width;
  } else {
    r.origin.x = CGRectGetMaxX(self.leftCap.frame);
  }
  self.rightCap.frame = r;
  
  r = self.middleBar.frame;
  r.origin.x = CGRectGetMaxX(self.leftCap.frame);
  if (totalWidth >= self.leftCap.image.size.width*2) {
    r.size.width = self.rightCap.frame.origin.x-r.origin.x+1;
  } else {
    r.size.width = 0;
  }
  self.middleBar.frame = r;
}

- (void) dealloc {
  self.leftCap = nil;
  self.rightCap = nil;
  self.middleBar = nil;
  [super dealloc];
}

@end

@implementation TopBarView

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  // Allow all subviews to receive touch.
  for (UIView * foundView in self.subviews) {
    if (!foundView.hidden && [foundView pointInside:[self convertPoint:point toView:foundView] withEvent:event]) {
      return YES;
    }
  }
  return NO;
}

- (void) replaceChatViewWithView:(UIView *)view {
  if (self.curViewOverChatView) {
    [self.curViewOverChatView removeFromSuperview];
  }
  self.curViewOverChatView = view;
  [self addSubview:self.curViewOverChatView];
  self.curViewOverChatView.center = ccp(self.frame.size.width/2, self.frame.size.height-10-view.frame.size.height/2);
}

- (void) removeViewOverChatView {
  [self.curViewOverChatView removeFromSuperview];
  self.curViewOverChatView = nil;
}

- (IBAction)menuClicked:(id)sender {
  MenuNavigationController *m = [[[MenuNavigationController alloc] init] autorelease];
  GameViewController *gvc = [GameViewController sharedGameViewController];
  [gvc addChildViewController:m];
  [gvc.view addSubview:m.view];
  [m pushViewController:[[MainMenuController alloc] initWithNibName:nil bundle:nil] animated:NO];
}

- (IBAction)plusClicked:(id)sender {
  [Globals popupMessage:@"Not implemented."];
}

@end
