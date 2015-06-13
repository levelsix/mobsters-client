
//
//  DestroyedOrb.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/24/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "DestroyedOrb.h"
#import "UIColor+HexColor.h"
#import "NSObject+PerformBlockAfterDelay.h"

@implementation DestroyedOrb

- (id) initWithColor:(CCColor *)color {
  if ((self = [super initWithImageNamed:@"orbball.png"])) {
    self.color = color;
    
    self.streak = [CCMotionStreak streakWithFade:0.5 minSeg:0.1f width:8 color:color textureFilename:@"streak.png"];
  }
  return self;
}

- (id) initWithCake {
  if ((self = [super initWithImageNamed:@"cakeorb.png"])) {
    self.color = [CCColor whiteColor];
  }
  return self;
}

- (void) setParent:(CCNode *)parent {
  [super setParent:parent];
  if (parent && self.streak && !self.streak.parent) {
    [self.parent addChild:self.streak z:self.zOrder];
  }
}

- (void) update:(CCTime)delta {
  if (self.streak)
    [self.streak setPosition:self.position];
}

- (void) dealloc {
  if (self.streak)
    [self.streak removeFromParent];
}

@end

@implementation SparklingTail

- (id) initWithColor:(OrbColor)color
{
  if ((self = [super initWithFile:@"skilltail.plist"])) {
    
    self.scale = 0.5;
    UIColor* sparkleColor;
    switch (color)
    {
      case OrbColorWater: sparkleColor = [UIColor colorWithHexString:@"3bfafd"]; break;
      case OrbColorFire: sparkleColor = [UIColor colorWithHexString:@"fe3430"]; break;
      case OrbColorEarth: sparkleColor = [UIColor colorWithHexString:@"56f63e"]; break;
      case OrbColorLight: sparkleColor = [UIColor colorWithHexString:@"fef743"]; break;
      case OrbColorDark: sparkleColor = [UIColor colorWithHexString:@"7c3dea"]; break;
      default: sparkleColor = [UIColor whiteColor];
    }
    self.startColor = [CCColor colorWithUIColor:sparkleColor];
  }
  return self;
}

- (void) removeFromParent
{
  [self stopSystem];
  [self performBlockAfterDelay:2.0 block:^{
    [super removeFromParent];
  }];
}

@end

@implementation LifeStealParticleEffect

- (id)init
{
  if (self = [super initWithFile:@"LifeSteal.plist"])
  {
    self.particlePositionType = CCParticleSystemPositionTypeFree;
  }
  return self;
}

- (void) removeFromParent
{
  [self stopSystem];
  [self performBlockAfterDelay:2.f block:^{
    [super removeFromParent];
  }];
}

@end
