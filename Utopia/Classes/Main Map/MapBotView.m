//
//  MapBotView.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/29/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "MapBotView.h"
#import "cocos2d.h"

@implementation MapBotView

#define ANIMATION_SPEED 0.175f
#define ANIMATION_DELAY 0.085f

- (void) awakeFromNib {
  self.animateViews = [self.animateViews sortedArrayUsingComparator:^NSComparisonResult(UIView *obj1, UIView *obj2) {
    if (obj1.frame.origin.x < obj2.frame.origin.x) {
      return NSOrderedAscending;
    } else if (obj1.frame.origin.x > obj2.frame.origin.x) {
      return NSOrderedDescending;
    }
    return NSOrderedSame;
  }];
}

- (void) update {
  if ([self.delegate respondsToSelector:@selector(updateMapBotView:)]) {
    [self.delegate updateMapBotView:self];
  }
}

- (void) animateIn:(void (^)())block {
  [self update];
  
  self.bgdView.alpha = 0.f;
  [UIView animateWithDuration:ANIMATION_SPEED+ANIMATION_DELAY*self.animateViews.count delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.bgdView.alpha = 0.83f;
  } completion:nil];
  
  for (int i = 0; i < self.animateViews.count; i++) {
    UIView *v = [self.animateViews objectAtIndex:i];
    v.alpha = 0.f;
    v.center = ccp(v.center.x, v.superview.frame.size.height);
    
    BOOL isLast = self.animateViews.count-1 == i;
    [UIView animateWithDuration:ANIMATION_SPEED delay:ANIMATION_DELAY*i options:UIViewAnimationOptionCurveEaseInOut animations:^{
      v.alpha = 1.f;
      v.center = ccp(v.center.x, v.superview.frame.size.height-v.frame.size.height/2);
    } completion:^(BOOL finished) {
      if (block && isLast && finished) {
        block();
      }
    }];
  }
}

- (void) animateOut:(void (^)())block {
  [UIView animateWithDuration:ANIMATION_SPEED+ANIMATION_DELAY*self.animateViews.count delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.bgdView.alpha = 0.f;
  } completion:nil];
  
  for (int i = 0; i < self.animateViews.count; i++) {
    UIView *v = [self.animateViews objectAtIndex:i];
    BOOL isLast = self.animateViews.count-1 == i;
    [UIView animateWithDuration:ANIMATION_SPEED delay:ANIMATION_DELAY*i options:UIViewAnimationOptionCurveEaseInOut animations:^{
      v.alpha = 0.f;
      v.center = ccp(v.center.x, v.superview.frame.size.height);
    } completion:^(BOOL finished) {
      if (block && isLast && finished) {
        block();
      }
    }];
  }
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  if ([super pointInside:point withEvent:event]) {
    for (UIView *v in self.animateViews) {
      if (!v.hidden && v.userInteractionEnabled && [v pointInside:[self convertPoint:point toView:v] withEvent:event]) {
        return YES;
      }
    }
  }
  return NO;
}

@end