//
//  StrengthChangeView.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/7/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "StrengthChangeView.h"
#import "Globals.h"
#import "GameViewController.h"

@implementation StrengthChangeView

- (id) initWithStrengthChange:(int64_t)str {
  if ((self = [super init])) {
    self.strengthChangeLabel.text = [(str > 0 ? @"+" : @"") stringByAppendingString:[Globals commafyNumber:str]];
    self.strengthChangeLabel.highlighted = str < 0;
    
    CGSize size = [self.strengthChangeLabel.text getSizeWithFont:self.strengthChangeLabel.font];
    float oldDiff = self.width-CGRectGetMaxX(self.strengthChangeLabel.frame);
    self.strengthChangeLabel.width = ceilf(size.width);
    self.width = CGRectGetMaxX(self.strengthChangeLabel.frame)+oldDiff;
  }
  return self;
}

- (NotificationLocationType) locationType {
  return NotificationLocationTypeTop;
}

- (NotificationPriority) priority {
  return NotificationPriorityRegular;
}

- (void) animateWithCompletionBlock:(dispatch_block_t)completion {
  _completion = completion;
  
  TopBarViewController *tvc = [[GameViewController baseController] topBarViewController];
  [tvc.view insertSubview:self aboveSubview:tvc.expView];
  if (self.width > tvc.expView.width)
    self.originX = tvc.expView.originX;
  else
    self.centerX = tvc.expView.centerX;
  self.originY = CGRectGetMaxY(tvc.expView.frame)-([Globals isiPad]?3.f:8.f);
  
  [Globals bounceView:self fadeInBgdView:nil anchorPoint:ccp((61.f/self.width), 0.f) completion:^(BOOL success) {
    [self performSelector:@selector(end) withObject:nil afterDelay:3.f];
  }];
}

- (void) end {
  [Globals shrinkView:self fadeOutBgdView:nil completion:^{
    [self removeFromSuperview];
    
    if (_completion) {
      _completion();
      _completion = nil;
    }
  }];
}

- (void) endAbruptly {
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  [self end];
}

@end
