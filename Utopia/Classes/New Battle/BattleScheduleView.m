//
//  BattleScheduleView.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "BattleScheduleView.h"

#import "Globals.h"

#define VIEW_SPACING 4

@implementation BattleScheduleView

- (void) awakeFromNib {
  if ([Globals isLongiPhone]) {
    self.numSlots = 5;
  } else {
    self.numSlots = 3;
  }
}

- (void) setOrdering:(NSArray *)ordering {
  NSMutableArray *oldArr = self.monsterViews;
  
  self.monsterViews = [NSMutableArray array];
  int i = 0;
  for (NSNumber *num in ordering) {
    int monsterId = num.intValue;
    MiniMonsterView *mmv = [self monsterViewForMonsterId:monsterId];
    [self.monsterViews addObject:mmv];
    
    if (i < oldArr.count) {
      MiniMonsterView *ommv = oldArr[i];
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (self.numSlots-i-1)*0.05f*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView transitionFromView:ommv toView:mmv duration:0.3 options:UIViewAnimationOptionTransitionFlipFromTop completion:nil];
      });
    } else {
      // We have to put them into a superview because otherwise the whole container view flips when we transition
      UIView *v = [[UIView alloc] initWithFrame:mmv.frame];
      v.center = [self centerForIndex:i width:mmv.frame.size.width];
      [v addSubview:mmv];
      [self.containerView addSubview:v];
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
    [first.superview removeFromSuperview];
  }];
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
