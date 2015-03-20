//
//  SkillPopupOverlay.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillPopupOverlay.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "Globals.h"
#import "GameState.h"
#import "SkillController.h"

#define POPUP_STAY_DURATION_SHORT .5f
#define POPUP_STAY_DURATION_LONG 1.5f
#define BIG_SHAKE_RADIUS 5.f
#define BIG_SHAKE_STARTING_SCALE 10.f
#define BIG_SHAKE_ANIM_DURATION .3f
#define SMALL_SHAKE_RADIUS 3.f
#define SMALL_SHAKE_STARTING_SCALE 4.f
#define SMALL_SHAKE_ANIM_DURATION .15f
#define SHAKE_ANIM_COMPLETION_BLOCK_KEY @"SkillPopupShakeAnimationCompletionBlock"

typedef void (^ShakeAnimCompletionBlock)(void);

@implementation SkillPopupData

+ (instancetype)initWithData:(BOOL)player characterImage:(UIImageView *)characterImage topText:(NSString *)topText bottomText:(NSString *)bottomText mini:(BOOL)mini stacks:(int)stacks completion:(SkillPopupBlock)completion
{
  SkillPopupData *data = [SkillPopupData alloc];
  data.player = player;
  data.characterImage = characterImage;
  data.topText = topText;
  data.bottomText = bottomText;
  data.miniPopup = mini;
  data.skillCompletion = completion;
  data.stacks = stacks;
  data.priority = 0;
  return data;
}

- (void)enqueue:(SkillPopupData*)other
{
  if (!self.next)
  {
    self.next = other;
  }
  else if (self.next.priority < other.priority)
  {
    other.next = self.next;
    self.next = other;
  }
  else
  {
    [self.next enqueue:other];
  }
}

@end

@implementation SkillPopupOverlay

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (! self)
    return nil;
  
  self.alpha = 0.0;
  
  return self;
}

- (void) animate:(BOOL)player withImage:(UIImage*)characterImage topText:(NSString*)topText bottomText:(NSString*)bottomtext
       miniPopup:(BOOL)mini stacks:(int)stacks withCompletion:(SkillPopupBlock)completion
{
  ////////////
  // Layout //
  ////////////
  
  const float viewShakeRadius = mini ? SMALL_SHAKE_RADIUS : BIG_SHAKE_RADIUS;
  const float viewShakeStartingScale = mini ? SMALL_SHAKE_STARTING_SCALE : BIG_SHAKE_STARTING_SCALE;
  
  [_imagePlayer setTransform:CGAffineTransformMakeScale(-1.f, 1.f)];
  [_rocksImageEnemy setTransform:CGAffineTransformMakeScale(-1.f, 1.f)];
  [_leavesImageEnemy setTransform:CGAffineTransformMakeScale(-1.f, 1.f)];
  [Globals setAnchorPoint:CGPointMake(0.f, .5f) onView:_skillPlayer];
  [Globals setAnchorPoint:CGPointMake(1.f, .5f) onView:_skillEnemy];
  [_rocksImagePlayer setOrigin:CGPointMake(_rocksImagePlayer.origin.x - viewShakeRadius, _rocksImagePlayer.origin.y + viewShakeRadius)];
  [_leavesImagePlayer setOrigin:CGPointMake(_leavesImagePlayer.origin.x - viewShakeRadius, _leavesImagePlayer.origin.y + viewShakeRadius)];
  [_rocksImageEnemy setOrigin:CGPointMake(_rocksImageEnemy.origin.x + viewShakeRadius, _rocksImageEnemy.origin.y + viewShakeRadius)];
  [_leavesImageEnemy setOrigin:CGPointMake(_leavesImageEnemy.origin.x + viewShakeRadius, _leavesImageEnemy.origin.y + viewShakeRadius)];
  
  UIView* mainView = player ? _avatarPlayer : _avatarEnemy;
  UIView* skillView = player ? _skillPlayer : _skillEnemy;
  UIImageView* playerImage = player ? _imagePlayer : _imageEnemy;
  UIImageView* rocksImage = player ? _rocksImagePlayer : _rocksImageEnemy;
  UIImageView* leavesImage = player ? _leavesImagePlayer : _leavesImageEnemy;
  THLabel* nameLabel = player ? _skillNameLabelPlayer : _skillNameLabelEnemy;
  THLabel* topLabel = player ? _skillTopLabelPlayer : _skillTopLabelEnemy;
  THLabel* bottomLabel = player ? _skillBottomLabelPlayer : _skillBottomLabelEnemy;
  
  [mainView setHidden:NO];
  [topLabel setHidden:stacks <= 1];
  
  nameLabel.gradientStartColor = [UIColor whiteColor];
  nameLabel.gradientEndColor = [UIColor colorWithHexString:@"E4E4E4"];
  nameLabel.strokeSize = 1.f;
  nameLabel.strokeColor = [UIColor colorWithWhite:0.f alpha:.5f];
  nameLabel.shadowColor = [UIColor blackColor];
  nameLabel.shadowOffset = CGSizeMake(0.f, 1.5f);
  nameLabel.shadowBlur = 1.5f;
  
  topLabel.gradientStartColor = [UIColor colorWithHexString:@"ff4927"];
  topLabel.gradientEndColor = [UIColor colorWithHexString:@"ff1e10"];
  topLabel.strokeSize = 1.f;
  topLabel.strokeColor = [UIColor colorWithWhite:0.f alpha:.5f];
  topLabel.shadowColor = [UIColor blackColor];
  topLabel.shadowOffset = CGSizeMake(0.f, 1.5f);
  topLabel.shadowBlur = 1.5f;
  
  bottomLabel.textColor = [UIColor whiteColor];
  bottomLabel.strokeSize = 0.f;
  bottomLabel.shadowColor = [UIColor blackColor];
  bottomLabel.shadowOffset = CGSizeMake(0.f, 1.5f);
  bottomLabel.shadowBlur = 1.5f;
  
  [playerImage setImage:characterImage];
  
  [nameLabel setText:[topText uppercaseString]];
  [bottomLabel setText:[bottomtext uppercaseString]];
  [topLabel setText:[NSString stringWithFormat:@"%iX", stacks]];
  
  ////////////////
  // Animations //
  ////////////////
  
  const CGPoint leavesImagePosition = leavesImage.origin;
  const CGPoint leavesTravelOffset = CGPointMake(player ? -100.f : 100.f, 100.f);
  [leavesImage setOrigin:CGPointMake(leavesImagePosition.x + leavesTravelOffset.x, leavesImagePosition.y + leavesTravelOffset.y)];
  [UIView animateWithDuration:.1f delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
    [leavesImage setOrigin:leavesImagePosition];
  } completion:nil];
  
  const CGPoint rocksImagePosition = rocksImage.origin;
  const CGPoint rocksTravelOffset = CGPointMake(player ? -100.f : 100.f, 100.f);
  [rocksImage setOrigin:CGPointMake(rocksImagePosition.x + rocksTravelOffset.x, rocksImagePosition.y + rocksTravelOffset.y)];
  [UIView animateWithDuration:.1f delay:.025f options:UIViewAnimationOptionCurveLinear animations:^{
    [rocksImage setOrigin:rocksImagePosition];
  } completion:nil];
  
  const CGPoint playerImagePosition = playerImage.origin;
  const CGPoint playerTravelOffset = CGPointMake(player ? -150.f : 150.f, 25.f);
  [playerImage setOrigin:CGPointMake(playerImagePosition.x + playerTravelOffset.x, playerImagePosition.y + playerTravelOffset.y)];
  [UIView animateWithDuration:.1f delay:.05f options:UIViewAnimationOptionCurveLinear animations:^{
    [playerImage setOrigin:playerImagePosition];
  } completion:nil];
  
  [skillView.layer setOpacity:0.f];
  [skillView.layer setTransform:CATransform3DMakeScale(viewShakeStartingScale, viewShakeStartingScale, 1.f)];
  [UIView animateWithDuration:.2f delay:.15f options:UIViewAnimationOptionCurveEaseIn animations:^{
    [skillView.layer setOpacity:1.f];
    [skillView.layer setTransform:CATransform3DIdentity];
  } completion:^(BOOL finished) {
    [self shakeView:mainView withKey:@"SkillPopupShakeAnimation" smallShake:mini completion:^{
      [self performAfterDelay:mini ? POPUP_STAY_DURATION_LONG : POPUP_STAY_DURATION_SHORT block:^{
        completion();
      }];
    }];
  }];
  
  [self setAlpha:1.f];
}

- (void) quickHide:(BOOL)player
{
  [self removeFromSuperview];
}

- (void) hideWithCompletion:(SkillPopupBlock)completion forPlayer:(BOOL)player
{
  UIView* skillView = player ? _skillPlayer : _skillEnemy;
  UIImageView* playerImage = player ? _imagePlayer : _imageEnemy;
  UIImageView* rocksImage = player ? _rocksImagePlayer : _rocksImageEnemy;
  UIImageView* leavesImage = player ? _leavesImagePlayer : _leavesImageEnemy;
  
  [UIView animateWithDuration:.1f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    [skillView setOrigin:CGPointMake(skillView.origin.x, skillView.origin.y + 150.f)];
    [skillView setAlpha:0.f];
  } completion:nil];
  
  [UIView animateWithDuration:.1f delay:.03f options:UIViewAnimationOptionCurveEaseIn animations:^{
    [playerImage setOrigin:CGPointMake(playerImage.origin.x, playerImage.origin.y + 150.f)];
    [playerImage setAlpha:0.f];
  } completion:nil];
  
  [UIView animateWithDuration:.1f delay:.06f options:UIViewAnimationOptionCurveEaseIn animations:^{
    [rocksImage setOrigin:CGPointMake(rocksImage.origin.x, rocksImage.origin.y + 150.f)];
    [rocksImage setAlpha:0.f];
  } completion:nil];
  
  [UIView animateWithDuration:.1f delay:.09f options:UIViewAnimationOptionCurveEaseIn animations:^{
    [leavesImage setOrigin:CGPointMake(leavesImage.origin.x, leavesImage.origin.y + 150.f)];
    [leavesImage setAlpha:0.f];
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
    completion();
  }];
}

- (void) shakeView:(UIView*)view withKey:(NSString*)key smallShake:(BOOL)small completion:(ShakeAnimCompletionBlock)completion
{
  const float shakeDuration = small ? SMALL_SHAKE_ANIM_DURATION : BIG_SHAKE_ANIM_DURATION;
  const float shakeRadius = small ? SMALL_SHAKE_RADIUS : BIG_SHAKE_RADIUS;
  NSMutableArray *keyTimes = [NSMutableArray array];
  NSMutableArray *values = [NSMutableArray array];
  const CGPoint pos = view.layer.position;
  const int numFrames = 60.f * shakeDuration;
  
  for (int i = 0; i < numFrames; ++i)
  {
    const float t = (float)i / (float)numFrames;
    const float theta = ((float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX) * (M_PI * 2.f);
    const float radius = 1.f + (shakeRadius - 1.f) * (1.f - t);
    [keyTimes addObject:@(t)];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(pos.x + radius * cosf(theta), pos.y + radius * sinf(theta))]];
  
  }
  CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
  [anim setDuration:shakeDuration];
  [anim setCalculationMode:kCAAnimationLinear];
  [anim setKeyTimes:keyTimes];
  [anim setValues:values];
  if (completion) {
    [anim setDelegate:self];
    [anim setValue:completion forKey:SHAKE_ANIM_COMPLETION_BLOCK_KEY];
  }
  [view.layer addAnimation:anim forKey:key];
}

- (void) animationDidStop:(CAAnimation*)anim finished:(BOOL)flag
{
  ShakeAnimCompletionBlock completionBlock = [anim valueForKey:SHAKE_ANIM_COMPLETION_BLOCK_KEY];
  if (completionBlock) completionBlock();
}

@end
