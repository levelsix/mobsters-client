//
//  OneLineNotificationViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/27/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "OneLineNotificationViewController.h"
#import "Globals.h"

#define LOWEST_LABEL_BOT_POINT 20.f

@implementation OneLineNotificationView

- (void) updateForString:(NSString *)str color:(NotificationColor)color {
  NSString *prefix = color == NotificationColorRed ? @"red" : color == NotificationColorGreen ? @"green" : @"purple";
  
  self.label.text = str;
  
  self.leftBgdIcon.image = [Globals imageNamed:[@"notendcap" stringByAppendingString:[prefix stringByAppendingString:@".png"]]];
  self.middleBgdIcon.image = [Globals imageNamed:[@"notmiddle" stringByAppendingString:[prefix stringByAppendingString:@".png"]]];
  self.rightBgdIcon.image = self.leftBgdIcon.image;
  
  CGSize size = [self.label.text getSizeWithFont:self.label.font constrainedToSize:self.label.frame.size];
  CGRect r = self.frame;
  r.size.width = (int)(size.width+self.label.frame.origin.x*2);
  self.frame = r;
  
  if (color == NotificationColorRed) {
    self.label.shadowColor = [UIColor colorWithRed:92/255.f green:6/255.f blue:8/255.f alpha:0.8];
  } else if (color == NotificationColorGreen) {
    self.label.shadowColor = [UIColor colorWithRed:81/255.f green:111/255.f blue:5/255.f alpha:0.8];
  } else if (color == NotificationColorPurple) {
    self.label.shadowColor = [UIColor colorWithWhite:0.f alpha:0.75f];
  }
}

- (void) animateIn:(dispatch_block_t)completion {
  CGPoint pt = self.center;
  self.center = ccp(self.center.x, -self.frame.size.height/2);
  [UIView animateWithDuration:0.3f animations:^{
    self.center = pt;
  } completion:^(BOOL finished) {
    if (completion) {
      completion();
    }
  }];
}

- (void) animateOut:(dispatch_block_t)completion {
  [UIView animateWithDuration:0.3f animations:^{
    self.center = ccp(self.center.x, -self.frame.size.height/2);
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
    if (completion) {
      completion();
    }
  }];
}

@end

@implementation OneLineNotificationViewController

- (id) initWithNotificationString:(NSString *)str color:(NotificationColor)color isImmediate:(BOOL)isImmediate {
  if ((self = [super init])) {
    [[NSBundle mainBundle] loadNibNamed:@"OneLineNotificationView" owner:self options:nil];
    [self.notificationView updateForString:str color:color];
    _priority = isImmediate ? NotificationPriorityImmediate : NotificationPriorityRegular;
  }
  return self;
}

- (void) viewDidLoad {
  [self.view addSubview:self.notificationView];
}

- (void) loadView {
  UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
  view.backgroundColor = [UIColor clearColor];
  view.userInteractionEnabled = NO;
  self.view = view;
}

- (void) displayView {
  [super displayView];
  self.view.frame = self.view.superview.bounds;
}

- (void) animateWithCompletionBlock:(dispatch_block_t)completion {
  [self displayView];
  
  // Have to use height because omnipresent views don't have proper orientation
  self.notificationView.center = ccp(self.relativeFrame.size.width/2, LOWEST_LABEL_BOT_POINT);
  
  _completion = completion;
  
  [self.notificationView animateIn:^{
    [self performSelector:@selector(end) withObject:nil afterDelay:3.f];
  }];
}

- (void) end {
  [self.notificationView animateOut:^{
    [self removeView];
    
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

- (NotificationPriority) priority {
  return _priority;
}

- (NotificationLocationType) locationType {
  return NotificationLocationTypeTop;
}

@end
