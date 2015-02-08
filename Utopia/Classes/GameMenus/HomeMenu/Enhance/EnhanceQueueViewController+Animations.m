//
//  EnhanceQueueViewController+Animations.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/3/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "EnhanceQueueViewController+Animations.h"

#import "Globals.h"
#import "CAKeyframeAnimation+AHEasing.h"

#import "SoundEngine.h"

@interface TestView : UIView

@end

@implementation TestView

- (CGPathRef) spiralPath {
  CGMutablePathRef spiralPath = CGPathCreateMutable();
  
  float numPts = 64;
  float maxRadius = 64;
  float numRotations = 2;
  
  float prevAngle = 0;
  float prevRadius = maxRadius;
  
  CGPoint spiralStart = CGPointMake(0, prevRadius);
  CGPathMoveToPoint(spiralPath, nil, spiralStart.x, spiralStart.y);
  
  for(int i = numPts; i >= 0; i--) {
    CGFloat radius = maxRadius * i/numPts;
    CGFloat angle = M_PI*2*numRotations * i/numPts;
    CGPoint nextPoint = CGPointMake(-radius*sin(angle), radius*cos(angle));
    
    //a smooth spiral
    float midAngle = prevAngle+(angle-prevAngle)/2;
    CGPoint controlPoint = CGPointMake(-prevRadius*sin(midAngle),
                                       prevRadius*cos(midAngle));
    CGPathAddQuadCurveToPoint(spiralPath, nil, controlPoint.x, controlPoint.y, nextPoint.x, nextPoint.y);
    
    prevAngle = angle;
    prevRadius = radius;
  }
  
  CGPoint center = CGPointMake(264, 86);
  const CGAffineTransform translate = CGAffineTransformMakeTranslation(center.x, center.y);
  
  CGMutablePathRef finalPath = CGPathCreateMutable();
  CGPathMoveToPoint(finalPath, nil, 202, 140);
  CGPathAddLineToPoint(finalPath, &translate, spiralStart.x, spiralStart.y);
  CGPathAddPath(finalPath, &translate, spiralPath);
  
  CGPathRelease(spiralPath);
  
  return finalPath;
}

//- (void) drawRect:(CGRect)rect {
//  UIBezierPath *aPath = [UIBezierPath bezierPathWithCGPath:[self spiralPath]];
//
//  // Set the render colors.
//  [[UIColor blackColor] setStroke];
//  [[UIColor clearColor] setFill];
//
//  // Adjust the drawing options as needed.
//  aPath.lineWidth = 1;
//
//  // Fill the path before stroking it so that the fill
//  // color does not obscure the stroked line.
//  [aPath fill];
//  [aPath stroke];
//}

@end

@implementation EnhanceQueueViewController (Animations)

- (CGPathRef) newSpiralPathWithStartPoint:(CGPoint)pt {
  CGMutablePathRef spiralPath = CGPathCreateMutable();
  
  float numPts = 64;
  float maxRadius = 64;
  float numRotations = 2;
  
  float prevAngle = 0;
  float prevRadius = maxRadius;
  
  CGPoint spiralStart = CGPointMake(0, prevRadius);
  CGPathMoveToPoint(spiralPath, nil, spiralStart.x, spiralStart.y);
  
  for(int i = numPts; i >= 0; i--) {
    CGFloat radius = maxRadius * i/numPts;
    CGFloat angle = M_PI*2*numRotations * i/numPts;
    CGPoint nextPoint = CGPointMake(-radius*sin(angle), radius*cos(angle));
    
    //a smooth spiral
    float midAngle = prevAngle+(angle-prevAngle)/2;
    CGPoint controlPoint = CGPointMake(-prevRadius*sin(midAngle),
                                       prevRadius*cos(midAngle));
    CGPathAddQuadCurveToPoint(spiralPath, nil, controlPoint.x, controlPoint.y, nextPoint.x, nextPoint.y);
    
    prevAngle = angle;
    prevRadius = radius;
  }
  
  CGPoint center = self.monsterImageView.superview.center;
  const CGAffineTransform translate = CGAffineTransformMakeTranslation(center.x, center.y);
  
  CGMutablePathRef finalPath = CGPathCreateMutable();
  CGPathMoveToPoint(finalPath, nil, pt.x, pt.y);
  
  //Interpolate between our point and spiralStart
  CGPoint lineEnd = CGPointApplyAffineTransform(spiralStart, translate);
  numPts = 10;
  for (int i = 1; i < numPts; i++) {
    CGPathAddLineToPoint(finalPath, nil, pt.x+(lineEnd.x-pt.x)*i/numPts, pt.y+(lineEnd.y-pt.y)*i/numPts);
  }
  
  CGPathAddPath(finalPath, &translate, spiralPath);
  
  CGPathRelease(spiralPath);
  
  return finalPath;
}

static int totalLevelUps = 0;

- (void) animateEnhancement {
  self.queueView.collectionView.contentOffset = CGPointMake(0, 0);
  [self.queueView.collectionView layoutIfNeeded];
  
  self.queueView.userInteractionEnabled = NO;
  self.listView.userInteractionEnabled = NO;
  
  UserEnhancement *ue = self.currentEnhancement;
  UserMonster *base = ue.baseMonster.userMonster;
  NSString *imgName = [Globals imageNameForElement:base.staticMonster.monsterElement suffix:@"enhancebg.png"];
  self.monsterGlowIcon.image = [Globals imageNamed:imgName];
  
  totalLevelUps = (int)[ue finalPercentageFromCurrentLevel];
  
  self.skipButtonView.hidden = NO;
  self.buttonViewsContainer.hidden = YES;
  
  [self animateNextEnhancementItem];
}

- (void) animateNextEnhancementItem {
  UserEnhancement *ue = self.currentEnhancement;
  
  if (ue.feeders.count) {
    EnhancementItem *ei = ue.feeders[0];
    
    NSIndexPath *ip = [NSIndexPath indexPathForItem:0 inSection:0];
    MonsterQueueCell *queueCell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:ip];
    queueCell.alpha = 0.f;
    
    [ue.feeders removeObjectAtIndex:0];
    [self reloadQueueViewAnimated:YES];
    
    [self.queueCell updateForListObject:ei.userMonster];
    self.queueCell.minusButton.hidden = YES;
    [self.view addSubview:self.queueCell];
    
    float animDuration = 1.3f;
    
    CAKeyframeAnimation *key = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    key.path = [self newSpiralPathWithStartPoint:[self.queueCell.superview convertPoint:queueCell.center fromView:queueCell.superview]];
    // Must manually release on our own since newSpiral method does not release it
    CGPathRelease(key.path);
    key.duration = animDuration;
    key.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.queueCell.layer addAnimation:key forKey:nil];
    
    float percBeforeFading = 0.7f;
    [UIView animateWithDuration:animDuration*(1-percBeforeFading) delay:animDuration*percBeforeFading options:UIViewAnimationOptionTransitionNone animations:^{
      self.queueCell.alpha = 0.f;
    } completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:animDuration animations:^{
      self.queueCell.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    }];
    
    // Pulse the glow and time it accordingly
    // Since this is the last animation, let it call the completion block
    float appearTime = 0.3f;
    float pulseDelay = 0.1f;
    float initDelay = animDuration-appearTime;
    [UIView animateWithDuration:appearTime delay:initDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
      self.monsterGlowIcon.alpha = 1.f;
    } completion:^(BOOL finished) {
      if (finished) {
        [UIView animateWithDuration:appearTime delay:pulseDelay options:UIViewAnimationOptionCurveEaseIn animations:^{
          self.monsterGlowIcon.alpha = 0.f;
        } completion:^(BOOL finished) {
          [self spiralAnimationFinished:finished enhancementItem:ei];
        }];
      } else {
        self.monsterGlowIcon.alpha = 0.f;
        [self spiralAnimationFinished:finished enhancementItem:ei];
      }
    }];
    
    // Make the monster bounce as if he is sucking in the feeder
    appearTime = 0.1f;
    pulseDelay = 0.f;
    initDelay += 0.2f;
    float imgScale = 1.05;
    CGAffineTransform t = self.monsterImageView.superview.transform;
    [UIView animateWithDuration:appearTime delay:initDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
      self.monsterImageView.superview.transform = CGAffineTransformScale(t, imgScale, imgScale);
    } completion:^(BOOL finished) {
      if (finished) {
        [UIView animateWithDuration:appearTime delay:pulseDelay options:UIViewAnimationOptionCurveEaseIn animations:^{
          self.monsterImageView.superview.transform = t;
        } completion:nil];
      } else {
        self.monsterImageView.superview.transform = t;
      }
    }];
    
    [SoundEngine enhanceFlying];
  } else {
    [self enhancementAnimationComplete];
  }
}

- (void) spiralAnimationFinished:(BOOL)flag enhancementItem:(EnhancementItem *)ei {
  self.queueCell.alpha = 1.f;
  self.queueCell.transform = CGAffineTransformIdentity;
  [self.queueCell removeFromSuperview];
  [self.queueCell.layer removeAllAnimations];
  
  if (flag) {
    Globals *gl = [Globals sharedGlobals];
    UserMonster *baseUm = self.currentEnhancement.baseMonster.userMonster;
    float startLevel = [gl calculateLevelForMonster:baseUm.monsterId experience:baseUm.experience];
    
    // This will set baseUm at its appropriate level
    baseUm.experience += [gl calculateExperienceIncrease:self.currentEnhancement.baseMonster feeder:ei];
    [self animateProgressBarAndLevelUpsWithLevel:startLevel];
  }
}

- (void) animateProgressBarAndLevelUpsWithLevel:(float)startLevel {
  Globals *gl = [Globals sharedGlobals];
  UserMonster *baseUm = self.currentEnhancement.baseMonster.userMonster;
  float endLevel = [gl calculateLevelForMonster:baseUm.monsterId experience:baseUm.experience];
  
  int baseLevel = (int)startLevel;
  float basePerc = startLevel - baseLevel;
  float nextPerc = clampf(endLevel-baseLevel, 0.f, 1.f);
  
  if (baseLevel >= baseUm.staticMonster.maxLevel) {
    basePerc = 1.f;
    nextPerc = 1.f;
  }
  
  // Need to update hp and what not.. This is kind of hacky but works
  int origLevel = baseUm.level;
  baseUm.level = baseLevel;
  [self updateStats];
  
  // finalPerc should be calculated after setting baseLevel so that we get the value relative to baseLevel.
  float finalPerc = [self.currentEnhancement finalPercentageFromCurrentLevel];
  
  // Update the progress bars
  self.curLevelLabel.text = [NSString stringWithFormat:@"Level %d:", baseLevel];
  self.curProgressBar.percentage = basePerc;
  self.addedProgressBar.percentage = finalPerc;
  
  baseUm.level = origLevel;
  
  int nextLevel = (int)endLevel;
  float duration = (nextPerc-basePerc)*0.9f;
  [self.curProgressBar animateToPercentage:nextPerc duration:duration completion:^{
    if (baseLevel < nextLevel) {
      [self spawnLevelUp:1 completion:^{
        [self animateProgressBarAndLevelUpsWithLevel:baseLevel+1];
      }];
    } else {
      [self animateNextEnhancementItem];
    }
  }];
}

- (void) spawnLevelUp:(int)numLevelUps completion:(dispatch_block_t)completion {
  CGPoint delta = ccp(-60, 11);
  
  CGPoint levelCenter = self.levelIcon.center;
  CGPoint upCenter = self.upIcon.center;
  
  float mult = 1.1;
  float animIn = 0.2f*mult;
  float animScaleDelay = 0.06f*mult;
  float animDelay = 0.1f*mult;
  float animHold = 0.6f;
  float animOut = 0.3f;
  
  float smallScale = 0.1;
  
  self.levelIcon.center = ccpAdd(levelCenter, delta);
  self.levelIcon.alpha = 0.f;
  [UIView animateWithDuration:animIn delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.levelIcon.center = levelCenter;
    self.levelIcon.alpha = 1.f;
  } completion:nil];
  
  self.levelIcon.transform = CGAffineTransformMakeScale(smallScale, smallScale);
  CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale" function:BackEaseOut fromValue:smallScale toValue:1.f];
  anim.duration = animIn;
  anim.beginTime = CACurrentMediaTime()+animScaleDelay;
  [self.levelIcon.layer addAnimation:anim forKey:@"scale"];
  [self performSelector:@selector(resetTransform:) withObject:self.levelIcon afterDelay:animScaleDelay];
  
  self.upIcon.center = ccpAdd(upCenter, ccpMult(delta, -1));
  self.upIcon.alpha = 0.f;
  [UIView animateWithDuration:animIn delay:animDelay options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.upIcon.center = upCenter;
    self.upIcon.alpha = 1.f;
  } completion:nil];
  
  self.upIcon.transform = CGAffineTransformMakeScale(smallScale, smallScale);
  CAKeyframeAnimation *anim2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale" function:BackEaseOut fromValue:smallScale toValue:1.f];
  anim2.duration = anim.duration;
  anim2.beginTime = CACurrentMediaTime()+animDelay+animScaleDelay;
  [self.upIcon.layer addAnimation:anim2 forKey:@"scale"];
  [self performSelector:@selector(resetTransform:) withObject:self.upIcon afterDelay:animDelay+animScaleDelay];
  
  [self.view addSubview:self.levelUpView];
  self.levelUpView.alpha = 1.f;
  [UIView animateWithDuration:animOut delay:animDelay+animIn+animHold options:UIViewAnimationOptionTransitionNone animations:^{
    self.levelUpView.alpha = 0.f;
  } completion:^(BOOL finished) {
    if (finished) {
      [self.levelUpView removeFromSuperview];
      
      completion();
    }
  }];
  
  self.levelUpNumLabel.alpha = 0.f;
  if (numLevelUps > 1) {
    self.levelUpNumLabel.text = [NSString stringWithFormat:@"x%d", numLevelUps];
    
    [UIView animateWithDuration:animIn delay:animDelay*2 options:UIViewAnimationOptionTransitionNone animations:^{
      self.levelUpNumLabel.alpha = 1.f;
    } completion:nil];
  }
  
  [SoundEngine structCompleted];
}

- (void) resetTransform:(UIView *)v {
  v.transform = CGAffineTransformIdentity;
}

- (void) speedupEnhancementAnimation {
  // Stop the currently animating 
  [self.queueCell removeFromSuperview];
  [self.levelUpView removeFromSuperview];
  [self.curProgressBar stopAnimation];
  [self.monsterImageView.superview.layer removeAllAnimations];
  [self.monsterGlowIcon.layer removeAllAnimations];
  
  // Reload queue immediately so monsters disappear
  [self.currentEnhancement.feeders removeAllObjects];
  [self reloadQueueViewAnimated:YES];
  
  [self enhancementAnimationComplete];
  
  // Start new level up animation
  if (totalLevelUps) {
    // Eat up the touches
    self.levelUpView.userInteractionEnabled = YES;
    [self spawnLevelUp:totalLevelUps completion:^{
      self.levelUpView.userInteractionEnabled = NO;
    }];
  }
}

- (void) enhancementAnimationComplete {
  // Basically start with a new enhancement
  [self.currentEnhancement.baseMonster setFakedUserMonster:nil];
  self.currentEnhancement.isActive = NO;
  self.currentEnhancement.isComplete = NO;
  
  _waitingForResponse = NO;
  
  // Don't animate queue view or the enhance button will show up and fade out...
  [self reloadQueueViewAnimated:NO];
  [self reloadListViewAnimated:YES];
  [self updateLabelsNonTimer];
  
  self.queueView.userInteractionEnabled = YES;
  self.listView.userInteractionEnabled = YES;
  
  self.buttonViewsContainer.hidden = NO;
  
  [UIView animateWithDuration:0.3f animations:^{
    self.skipButtonView.alpha = 0.f;
  } completion:^(BOOL finished) {
    self.skipButtonView.hidden = YES;
    self.skipButtonView.alpha = 1.f;
  }];
}

@end
