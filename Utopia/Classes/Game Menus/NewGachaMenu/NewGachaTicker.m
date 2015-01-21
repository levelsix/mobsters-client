//
//  NewGachaTicker.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/14/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "NewGachaTicker.h"
#import "UIView+Coordinates.h"
#import "SoundEngine.h"
#import "Globals.h"

@interface NewGachaTicker()

- (void)tickerUpdate:(NSTimer*)timer;
- (void)playTickerSfx;

@end

@implementation NewGachaTicker

- (instancetype)initWithImageView:(UIImageView*)imageView cellWidth:(int)cellWidth anchorPoint:(CGPoint)anchorPoint
{
  if (self = [super init])
  {
    _tickerImageView = imageView;
    _cellWidth = cellWidth;
    
    self.tickerImageView.layer.anchorPoint = anchorPoint;
    self.tickerImageView.originY += (self.tickerImageView.layer.anchorPoint.y - .5f) * self.tickerImageView.height;
    
    [self resetState];
    
    _tickerUpdateTimer = [NSTimer timerWithTimeInterval:1.f / 30.f target:self selector:@selector(tickerUpdate:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_tickerUpdateTimer forMode:NSRunLoopCommonModes];
    
    _contentStartOffset = kContentStartOffset_iPhone5;
    if      ([Globals isiPhone6Plus])     _contentStartOffset = kContentStartOffset_iPhone6Plus;
    else if ([Globals isiPhone6])         _contentStartOffset = kContentStartOffset_iPhone6;
    else if ([Globals isSmallestiPhone])  _contentStartOffset = kContentStartOffset_iPhone4;
  }
  return self;
}

- (void)performCleanUp
{
  [_tickerUpdateTimer invalidate];
}

- (void)updateWithContentOffset:(float)contentOffset
{
  static float lastContentOffset = -1.f;
  if (lastContentOffset < 0.f)
  {
    lastContentOffset = contentOffset;
    return;
  }
  
  const float movement = contentOffset - lastContentOffset;
  const bool scrollingRight = movement < 0.f;
  lastContentOffset = contentOffset;
  
  const int f = ((int)roundf(contentOffset + _contentStartOffset)) % _cellWidth;
  if (scrollingRight) // Scrolling to the right
  {
    const int rangeMax = _cellWidth - kTickerCollisionEdgeBegin;
    const int rangeMin = _cellWidth - kTickerCollisionEdgeEnd;
    if ((f > rangeMin && f < rangeMax) || // Detect right edges
        (ABS(movement) > _cellWidth && ABS(_tickerCurrentAngle) < kTickerMaxHeldInPlaceAngle)) // Faster speeds might not trigger edge collision
    {
      if (_tickerState != TickerState_HeldInPlace) [self playTickerSfx];
      
      _tickerSpeedBasedAngleMultiplier = MIN(1.f + ABS(movement) / kTickerSpeedSensitivity, 2.f);
      const float displacementAngle = (ABS(movement) > _cellWidth)
        ? (rangeMax - rangeMin) * kTickerDisplacementAnglePerPixel * _tickerSpeedBasedAngleMultiplier
        : (rangeMax - f) * kTickerDisplacementAnglePerPixel * _tickerSpeedBasedAngleMultiplier;
      _tickerTargetAngle = clampf(displacementAngle, _tickerCurrentAngle, kTickerMaxAllowedAngle);
      _tickerState = TickerState_HeldInPlace;
    }
    else if (_tickerState == TickerState_HeldInPlace)
    {
      _tickerTargetAngle = 0.f;
      _tickerState = TickerState_Falling;
    }
  }
  else // Scrolling to the left
  {
    const int rangeMax = kTickerCollisionEdgeEnd;
    const int rangeMin = kTickerCollisionEdgeBegin;
    if ((f > rangeMin && f < rangeMax) || // Detect left edges
        (ABS(movement) > _cellWidth && ABS(_tickerCurrentAngle) < kTickerMaxHeldInPlaceAngle)) // Faster speeds might not trigger edge collision
    {
      if (_tickerState != TickerState_HeldInPlace) [self playTickerSfx];
      
      _tickerSpeedBasedAngleMultiplier = MIN(1.f + ABS(movement) / kTickerSpeedSensitivity, 2.f);
      const float displacementAngle = (ABS(movement) > _cellWidth)
        ? (rangeMax - rangeMin) * -kTickerDisplacementAnglePerPixel * _tickerSpeedBasedAngleMultiplier
        : (f - rangeMin) * -kTickerDisplacementAnglePerPixel * _tickerSpeedBasedAngleMultiplier;
      _tickerTargetAngle = clampf(displacementAngle, -kTickerMaxAllowedAngle, _tickerCurrentAngle);
      _tickerState = TickerState_HeldInPlace;
    }
    else if (_tickerState == TickerState_HeldInPlace)
    {
      _tickerTargetAngle = 0.f;
      _tickerState = TickerState_Falling;
    }
  }
  
  [self tickerUpdate:_tickerUpdateTimer];
}

- (void)tickerUpdate:(NSTimer*)timer
{
  bool tickerWillFall = false;
  switch (_tickerState)
  {
    case TickerState_Falling: // Ticker will snap back to its resting position
      tickerWillFall = true;
      break;
      
    case TickerState_HeldInPlace: // Ticker is held in place against an edge
      if (ABS(_tickerTargetAngle) < ABS(_tickerCurrentAngle))
        tickerWillFall = true;
      else
        _tickerCurrentAngle = _tickerTargetAngle;
      break;
      
    case TickerState_Resting:
    default:
      break;
  }
  
  if (tickerWillFall)
  {
    const float sign = SGN(_tickerCurrentAngle);
    _tickerCurrentAngle -= sign * kTickerFallAnglePerFrame * _tickerSpeedBasedAngleMultiplier;
    if (sign != SGN(_tickerCurrentAngle)) _tickerCurrentAngle = 0.f;
    if (_tickerCurrentAngle == 0.f) _tickerState = TickerState_Resting;
  }
  
  self.tickerImageView.layer.transform = CATransform3DMakeRotation(_tickerCurrentAngle / 180.f * M_PI, 0.f, 0.f, -1.f);
}

- (void)resetState
{
  _tickerCurrentAngle = 0.f;
  _tickerTargetAngle = 0.f;
  _tickerSpeedBasedAngleMultiplier = 1.f;
  _tickerState = TickerState_Resting;
  
  self.tickerImageView.layer.transform = CATransform3DIdentity;
}

- (void)playTickerSfx
{
  [[SoundEngine sharedSoundEngine] playEffect:@"sfx_damage_click_lp.mp3"];
}

@end
