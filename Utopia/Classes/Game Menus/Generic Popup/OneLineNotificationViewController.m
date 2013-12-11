//
//  OneLineNotificationViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/27/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "OneLineNotificationViewController.h"
#import "Globals.h"

#define LOWEST_LABEL_BOT_POINT 100.f

@implementation OneLineNotificationViewController

- (void) loadView {
  UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
  view.backgroundColor = [UIColor clearColor];
  view.userInteractionEnabled = NO;
  self.view = view;
}

- (void) viewDidLoad {
  self.labels = [NSMutableArray array];
}

- (void) displayView {
  [super displayView];
  self.view.frame = self.view.superview.bounds;
}

- (void) addNotification:(NSString *)string color:(UIColor *)color {
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
  label.font = [UIFont fontWithName:[Globals font] size:20.f];
  label.text = string;
  label.textColor = color;
  label.backgroundColor = [UIColor clearColor];
  label.textAlignment = NSTextAlignmentCenter;
  label.shadowColor = [UIColor colorWithWhite:0.f alpha:0.6f];
  label.shadowOffset = CGSizeMake(0, 1);
  label.numberOfLines = 0;
  label.lineBreakMode = NSLineBreakByWordWrapping;
  
  CGSize size = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(self.view.frame.size.height*5/6, 9999) lineBreakMode:NSLineBreakByWordWrapping];
  label.frame = CGRectMake(0, 0, size.width, size.height);
  
  [self.view addSubview:label];
  [self.labels addObject:label];
  
  [self animateLabelsIntoPosition];
  
  [UIView animateWithDuration:2.f delay:2.f options:UIViewAnimationOptionTransitionNone animations:^{
    label.alpha = 0.f;
  } completion:^(BOOL finished) {
    [label removeFromSuperview];
    [self.labels removeObject:label];
  }];
}

- (void) animateLabelsIntoPosition {
  float curBotPoint = LOWEST_LABEL_BOT_POINT;
  for (int i = self.labels.count-1; i >= 0; i--) {
    UILabel *l = self.labels[i];
    [self setPointForLabel:l botPoint:curBotPoint];
    curBotPoint = l.frame.origin.y;
  }
}

- (void) setPointForLabel:(UILabel *)l botPoint:(float)botPoint {
  CGRect r = l.frame;
  r.origin.y = botPoint-l.frame.size.height;
  r.origin.x = self.view.frame.size.height/2-l.frame.size.width/2;
  l.frame = r;
}

@end
