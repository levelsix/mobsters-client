//
//  BattleScheduleView.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "BattleScheduleView.h"

#import "Globals.h"

#import "CAKeyFrameAnimation+Jumping.h"

#define VIEW_SPACING 4

@implementation BattleScheduleView

- (void) awakeFromNib {
  if ([Globals isLongiPhone]) {
    self.numSlots = 5;
  } else {
    self.numSlots = 3;
  }
  
  UIImage *dark = [Globals maskImage:self.bgdView.image withColor:[UIColor colorWithWhite:0.f alpha:1.f]];
  UIImageView *img = [[UIImageView alloc] initWithImage:dark];
  [self.bgdView.superview addSubview:img];
  img.frame = self.bgdView.frame;
  self.overlayView = img;
  img.alpha = 0.f;
}

- (void) displayOverlayView {
  [UIView animateWithDuration:0.3f animations:^{
    self.overlayView.alpha = 1.f;
  }];
}

- (void) removeOverlayView {
  [UIView animateWithDuration:0.3f animations:^{
    self.overlayView.alpha = 0.f;
  }];
}

- (void) setOrdering:(NSArray *)ordering {
  NSMutableArray *oldArr = self.monsterViews;
  
  // If it was hidden just remove all the old monster views
  if (self.hidden) {
    for (UIView *v in oldArr) {
      [v removeFromSuperview];
    }
    oldArr = nil;
  }
  
  self.monsterViews = [NSMutableArray array];
  int i = 0;
  for (NSNumber *num in ordering) {
    int monsterId = num.intValue;
    MiniMonsterView *mmv = [self monsterViewForMonsterId:monsterId];
    [self.monsterViews addObject:mmv];
    
    if (i < oldArr.count) {
      MiniMonsterView *ommv = oldArr[i];
      
      BOOL isLast = i == oldArr.count-1;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (self.numSlots-i-1)*0.05f*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView transitionFromView:ommv toView:mmv duration:0.3 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished) {
          if (isLast) {
            [self performSelector:@selector(bounceView:) withObject:self.monsterViews[0] afterDelay:0.2f];
          }
        }];
      });
    } else {
      // We have to put them into a superview because otherwise the whole container view flips when we transition
      UIView *v = [[UIView alloc] initWithFrame:mmv.frame];
      v.center = [self centerForIndex:i width:mmv.frame.size.width];
      [v addSubview:mmv];
      [self.containerView addSubview:v];
      
      [self performSelector:@selector(bounceView:) withObject:self.monsterViews[0] afterDelay:0.3f];
    }
    
    i++;
  }
}

- (void) addMonster:(int)monsterId {
  MiniMonsterView *first = [self.monsterViews firstObject];
  MiniMonsterView *new = [self monsterViewForMonsterId:monsterId];
  
  [self.monsterViews removeObject:first];
  [self.monsterViews addObject:new];
  
  UIView *v = [[UIView alloc] initWithFrame:new.frame];
  v.center = ccp(-new.frame.size.width/2, self.containerView.frame.size.height/2);
  [v addSubview:new];
  [self.containerView addSubview:v];
  
  [UIView animateWithDuration:0.3f animations:^{
    for (int i = 0; i < self.monsterViews.count; i++) {
      MiniMonsterView *mmv = self.monsterViews[i];
      mmv.superview.center = [self centerForIndex:i width:mmv.frame.size.width];
    }
    
    first.superview.center = ccp(first.superview.center.x, -first.superview.frame.size.height/2);
    first.superview.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self bounceView:self.monsterViews[0]];
    
    [first.superview removeFromSuperview];
  }];
}

- (void) bounceView:(UIView *)view {
  float iconHeight = view.frame.size.height/3;
  float duration = 0.8f;
  
  CAKeyframeAnimation *anim = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:iconHeight];
  anim.duration = duration;
  [view.layer addAnimation:anim forKey:@"bounce"];
  
  CAKeyframeAnimation *anim2 = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:iconHeight];
  anim2.duration = duration;
  [self.currentBorder.layer addAnimation:anim2 forKey:@"bounce"];
}

- (CGPoint) centerForIndex:(int)i width:(float)width {
  return ccp(self.containerView.frame.size.width-VIEW_SPACING*(i+1)-width*(i+0.5),
             self.containerView.frame.size.height/2);
}

- (MiniMonsterView *) monsterViewForMonsterId:(int)monsterId {
  MiniMonsterView *mmv = [[NSBundle mainBundle] loadNibNamed:@"MiniMonsterView" owner:self options:nil][0];
  [mmv updateForMonsterId:monsterId];
  return mmv;
}

@end
