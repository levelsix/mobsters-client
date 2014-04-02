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

- (void) updateForString:(NSString *)str isGreen:(BOOL)isGreen {
  self.label.text = str;
  
  for (UIImageView *img in self.imgViews) {
    img.highlighted = isGreen;
  }
  
  CGSize size = [self.label.text sizeWithFont:self.label.font constrainedToSize:self.label.frame.size];
  CGRect r = self.frame;
  r.size.width = (int)(size.width+self.label.frame.origin.x*2);
  self.frame = r;
  
  if (isGreen) {
    self.label.shadowColor = [UIColor colorWithRed:81/255.f green:111/255.f blue:5/255.f alpha:0.8];
  }
}

- (void) animateIn:(void (^)(void))completion {
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

- (void) animateOut {
  [UIView animateWithDuration:0.3f animations:^{
    self.center = ccp(self.center.x, -self.frame.size.height/2);
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
  }];
}

@end

@implementation OneLineNotificationViewController

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

- (void) addNotification:(NSString *)string isGreen:(BOOL)isGreen {
  [self animateCurrentNotificationViewOut];
  
  [[NSBundle mainBundle] loadNibNamed:@"OneLineNotificationView" owner:self options:nil];
  [self.notificationView updateForString:string isGreen:isGreen];
  [self.view addSubview:self.notificationView];
  
  // Have to use height because omnipresent views don't have proper orientation
  self.notificationView.center = ccp(self.view.frame.size.height/2, LOWEST_LABEL_BOT_POINT);
  
  [self.notificationView animateIn:^{
    [self performSelector:@selector(animateCurrentNotificationViewOut) withObject:nil afterDelay:3.f];
  }];
}

- (void) animateCurrentNotificationViewOut {
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  [self.notificationView animateOut];
  self.notificationView = nil;
}

@end
