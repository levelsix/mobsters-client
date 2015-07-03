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

#define LOWEST_LABEL_BOT_POINT ([Globals isiPad] ? 50.f : 35.f)

@implementation MiniEventGoalNotificationView

- (void) updateForGoalString:(NSString *)goalStr pointsStr:(NSString *)pointsStr image:(NSString *)img {
  self.layer.cornerRadius = [Globals isiPad] ? 14.f : 7.f;
  
  NSString *str = [NSString stringWithFormat:@"%@: %@", goalStr, pointsStr];
  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
  [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"a4f100"] range:NSMakeRange(str.length-pointsStr.length, pointsStr.length)];
  self.label.attributedText = attr;
  
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

- (id) initWithGoalString:(NSString *)goalStr pointsStr:(NSString *)pointsStr image:(NSString *)img isImmediate:(BOOL)isImmediate {
  if ((self = [super init])) {
    [[NSBundle mainBundle] loadNibNamed:@"MiniEventGoalNotificationView" owner:self options:nil];
    [self.notificationView updateForGoalString:goalStr pointsStr:pointsStr image:img];
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
