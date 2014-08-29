//
//  SkillBattleIndicatorView.m
//  Utopia
//
//  Created by Mikhail Larionov on 8/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillBattleIndicatorView.h"

@interface SkillBattleIndicatorView()

@property (weak, nonatomic) SkillController* skillController;

@end

@implementation SkillBattleIndicatorView

- (instancetype) initWithPlayerColor:(OrbColor)color activationType:(SkillActivationType)activationType skillType:(SkillType)skillType
{
  if ( activationType != SkillActivationTypeAutoActivated )
  {
    NSLog(@"Only auto-activating skills are supported for now");
    return nil;
  }
  
  switch (activationType)
  {
    case SkillActivationTypeAutoActivated:
      self = [self initForAutoactivatedSkill:color];
      break;
    default:
      break;
  }
  
  
  return self;
}

- (id) initForAutoactivatedSkill:(OrbColor)color
{
  NSString* bgImageName;
  NSString* orbImageName;
  switch (color)
  {
    case OrbColorEarth: bgImageName = @"earthcounterbg.png"; orbImageName = @"earthorbcounter.png"; break;
    case OrbColorFire:  bgImageName = @"firecounterbg.png"; orbImageName = @"fireorbcounter.png"; break;
    case OrbColorLight: bgImageName = @"lightcounterbg.png"; orbImageName = @"lightorbcounter.png"; break;
    case OrbColorDark:  bgImageName = @"nightcounterbg.png"; orbImageName = @"nightorbcounter.png"; break;
    case OrbColorWater: bgImageName = @"watercounterbg.png"; orbImageName = @"waterorbcounter.png"; break;
    default: return nil;
  }
  
  self = [CCSprite spriteWithImageNamed:bgImageName];
  
  CCSprite* orbIcon = [CCSprite spriteWithImageNamed:orbImageName];
  [self addChild:orbIcon];
  
  _orbsLabel = [CCLabelTTF labelWithString:@"8" fontName:@"GothamNarrow-UltraItalic" fontSize:10];
  _orbsLabel.color = [CCColor whiteColor];
  [self addChild:_orbsLabel];
  
  return self;
}

- (void) setOrbsCount:(NSInteger)orbsCount
{
  if (_orbsLabel)
    [_orbsLabel setString:[NSString stringWithFormat:@"%d", orbsCount]];
}

@end
