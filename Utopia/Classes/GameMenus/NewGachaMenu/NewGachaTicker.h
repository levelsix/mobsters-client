//
//  NewGachaTicker.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/14/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

enum TickerState
{
  TickerState_Resting = 0,
  TickerState_HeldInPlace,
  TickerState_Falling
};

static const float kContentStartOffset_iPhone6 = -7.5f;     // Magic number; do not touch unless scroll bar width changes
static const float kContentStartOffset_iPhone6Plus = 28.5f; // Magic number; do not touch unless scroll bar width changes
static const float kContentStartOffset_iPhone5 = 2.f;       // Magic number; do not touch unless scroll bar width changes
static const float kContentStartOffset_iPhone4 = 14.5f;     // Magic number; do not touch unless scroll bar width changes

static const int   kTickerCollisionEdgeBegin = 3;           // Pixels
static const int   kTickerCollisionEdgeEnd = 24;            // Pixels
static const float kTickerDisplacementAnglePerPixel = 2.5f; // Degrees
static const float kTickerFallAnglePerFrame = 2.5f;         // Degrees
static const float kTickerMaxAllowedAngle = 75.f;           // Degrees
static const float kTickerMaxHeldInPlaceAngle = 20.f;       // Degrees
static const float kTickerSpeedSensitivity = 40.f;          // Lower value means more sensitivity to higher scrolling speeds

@interface NewGachaTicker : NSObject
{
  NSTimer* _tickerUpdateTimer;
  
  float _contentStartOffset;
  
  float _tickerTargetAngle;
  float _tickerCurrentAngle;
  float _tickerSpeedBasedAngleMultiplier;
  
  int _cellWidth;
  
  enum TickerState _tickerState;
}

@property (nonatomic, assign, readonly) UIImageView* tickerImageView;

- (instancetype)initWithImageView:(UIImageView*)imageView cellWidth:(int)cellWidth anchorPoint:(CGPoint)anchorPoint;
- (void)updateWithContentOffset:(float)contentOffset;
- (void)resetState;
- (void)performCleanUp;

@end
