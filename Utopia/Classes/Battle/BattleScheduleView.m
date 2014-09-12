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

- (void) setOrdering:(NSArray *)ordering showEnemyBands:(NSArray *)showEnemyBands playerTurns:(NSArray*)playerTurns{
  NSMutableArray *oldArr = self.monsterViews;
  
  // If it was hidden just remove all the old monster views
  if (self.hidden) {
    for (UIView *v in oldArr) {
      [v removeFromSuperview];
    }
    oldArr = nil;
  }
  
  self.monsterViews = [NSMutableArray array];
  for (int i = 0; i < ordering.count; i++) {
    NSNumber *num = ordering[i];
    NSNumber *enemyBand = showEnemyBands[i];
    NSNumber *playersTurn = playerTurns[i];
    
    int monsterId = num.intValue;
    BOOL showEnemyBand = enemyBand.boolValue;
    BOOL isPlayersTurn = playersTurn.boolValue;
    MiniMonsterView *mmv = [self monsterViewForMonsterId:monsterId showEnemyBand:showEnemyBand player:isPlayersTurn];
    [self.monsterViews addObject:mmv];
    
    if (i < oldArr.count) {
      MiniMonsterView *ommv = oldArr[i];
      
      // Mikhail: now we jumping the current element right before the actual turn from the NewBattleLayer
      // using bounceLastView. So no need for doing it here anymore. Left the code just in case
      //BOOL isLast = i == oldArr.count-1;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (self.numSlots-i-1)*0.05f*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView transitionFromView:ommv toView:mmv duration:0.3 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished) {
          //if (isLast) {
          //  [self performSelector:@selector(bounceView:) withObject:self.monsterViews[0] afterDelay:0.2f];
          //}
        }];
      });
    } else {
      // We have to put them into a superview because otherwise the whole container view flips when we transition
      UIView *v = [[UIView alloc] initWithFrame:mmv.frame];
      v.center = [self centerForIndex:i width:mmv.frame.size.width];
      [v addSubview:mmv];
      [self.containerView addSubview:v];
      
      //[self performSelector:@selector(bounceView:) withObject:self.monsterViews[0] afterDelay:0.3f];
    }
  }
}

- (void) bounceLastView
{
  if (self.monsterViews && self.monsterViews.count > 0)
    [self bounceView:self.monsterViews[0]];
}

- (void) addMonster:(int)monsterId showEnemyBand:(BOOL)showEnemyBand player:(BOOL)player{
  MiniMonsterView *first = [self.monsterViews firstObject];
  MiniMonsterView *new = [self monsterViewForMonsterId:monsterId showEnemyBand:showEnemyBand player:player];
  
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
    [self bounceLastView];
    
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

- (MiniMonsterView *) monsterViewForMonsterId:(int)monsterId showEnemyBand:(BOOL)showEnemyBand player:(BOOL)player {
  MiniMonsterView *mmv = [[NSBundle mainBundle] loadNibNamed:@"MiniMonsterView" owner:self options:nil][0];
  [mmv updateForMonsterId:monsterId];
  
  if (showEnemyBand) {
    UIImageView *iv = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"enemystripes.png"]];
    [mmv insertSubview:iv aboveSubview:mmv.bgdIcon];
    iv.alpha = 0.6;
    
    THLabel *label = [[THLabel alloc] initWithFrame:CGRectMake(1, mmv.frame.size.height-15, mmv.frame.size.width, 15)];
    label.font = [UIFont fontWithName:@"GothamNarrow-Ultra" size:8];
    label.textAlignment = NSTextAlignmentCenter;
    label.gradientStartColor = [UIColor colorWithRed:255/255.f green:182/255.f blue:0.f alpha:1.f];
    label.gradientEndColor = [UIColor colorWithRed:255/255.f green:53/255.f blue:0.f alpha:1.f];
    label.strokeColor = [UIColor whiteColor];
    label.strokeSize = 1.f;
    label.shadowColor = [UIColor colorWithWhite:0.f alpha:0.7f];
    label.shadowBlur = 0.9;
    label.shadowOffset = CGSizeMake(0, 1);
    label.text = @"ENEMY";
    [mmv addSubview:label];
  }
  
  // Button to activate mobster window
  if (self.delegate)
  {
    MaskedButton *button = [[MaskedButton alloc] initWithFrame:mmv.bgdIcon.frame];
    button.baseImage = mmv.bgdIcon;
    button.tag = player;
    [button remakeImage];
    [button addTarget:self.delegate action:@selector(mobsterViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    [mmv addSubview:button];
  }
  
  return mmv;
}

@end
