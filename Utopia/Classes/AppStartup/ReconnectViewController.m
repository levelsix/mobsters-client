//
//  ReconnectViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ReconnectViewController.h"
#import "NibUtils.h"
#import <cocos2d.h>
#import "Globals.h"
#import "NSObject+PerformBlockAfterDelay.h"

@implementation ReconnectViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  NSMutableArray *arr = [NSMutableArray array];
  for (int i = 1; i <= 4; i++) {
    [arr addObject:[Globals imageNamed:[NSString stringWithFormat:@"%dbars.png", i]]];
  }
  self.wifiIcon.animationImages = arr;
  self.wifiIcon.animationRepeatCount = 0;
  self.wifiIcon.animationDuration = 3;
  [self.wifiIcon startAnimating];
}

- (void) animateWithCompletionBlock:(dispatch_block_t)completion {
  [self displayView];
  
  _completion = completion;
  
  UIView *v = self.notificationView;
  CGPoint pt = v.center;
  v.center = ccp(v.centerX, -v.height/2);
  [UIView animateWithDuration:0.3f animations:^{
    v.center = pt;
  }];
}

- (void) end {
  self.reconnectLabel.highlighted = YES;
  self.reconnectLabel.text = @"Connected";
  
  [self.wifiIcon stopAnimating];
  
  [self performBlockAfterDelay:1.f block:^{
    UIView *v = self.notificationView;
    [UIView animateWithDuration:0.3f animations:^{
      v.center = ccp(v.centerX, -v.height/2);
    } completion:^(BOOL finished) {
      [self removeView];
      
      if (_completion) {
        _completion();
        _completion = nil;
      }
    }];
  }];
}

- (void) endAbruptly {
  // Don't allow this to end abruptly
}

- (NotificationPriority) priority {
  return NotificationPriorityImmediate;
}

- (NotificationLocationType) locationType {
  return NotificationLocationTypeTop;
}

@end
