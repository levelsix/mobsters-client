//
//  MiniEventGoalNotificationViewController.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 4/7/15.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "MiniEventGoalNotificationViewController.h"
#import "Globals.h"
#import "SoundEngine.h"

#define LOWEST_LABEL_BOT_POINT 35.f

@implementation MiniEventGoalNotificationView

- (void) updateForString:(NSString *)str image:(NSString *)img {
  self.layer.cornerRadius = 7.f;
  
  self.label.text = str;
  
  [Globals imageNamed:img withView:self.icon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  CGSize size = [self.label.text getSizeWithFont:self.label.font constrainedToSize:self.label.frame.size];
  CGRect r = self.frame;
  r.size.width = (int)(size.width+self.label.frame.origin.x+(r.size.width - CGRectGetMaxX(self.label.frame)));
  self.frame = r;
}

- (void) animateIn:(dispatch_block_t)completion {
  CGPoint pt = self.center;
  self.center = ccp(self.center.x, -self.frame.size.height/2);
  [UIView animateWithDuration:0.2f animations:^{
    self.center = pt;
  } completion:^(BOOL finished) {
    if (completion) {
      completion();
    }
  }];
}

- (void) animateOut:(dispatch_block_t)completion {
  [UIView animateWithDuration:0.2f animations:^{
    self.center = ccp(self.center.x, -self.frame.size.height/2);
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
    if (completion) {
      completion();
    }
  }];
}

@end

@implementation MiniEventGoalNotificationViewController

- (id) initWithNotificationString:(NSString *)str image:(NSString *)img isImmediate:(BOOL)isImmediate {
  if ((self = [super init])) {
    [[NSBundle mainBundle] loadNibNamed:@"MiniEventGoalNotificationView" owner:self options:nil];
    [self.notificationView updateForString:str image:img];
    _priority = isImmediate ? NotificationPriorityImmediate : NotificationPriorityRegular;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
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
    [self performSelector:@selector(end) withObject:nil afterDelay:2.f];
  }];
  
  // TODO - Play a sound effect
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
