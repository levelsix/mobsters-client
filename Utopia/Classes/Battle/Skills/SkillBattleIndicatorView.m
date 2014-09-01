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

#pragma mark - Initialization

- (instancetype) initWithSkillController:(SkillController*)skillController
{
  if (! skillController)
  {
    CustomAssert(FALSE, @"Error: trying to initizalize indicator with nil skill controller");
    return nil;
  }
  
  
  if (skillController.activationType != SkillActivationTypeAutoActivated)
  {
    CustomAssert(FALSE, @"Only auto-activating skills are supported for now");
    return nil;
  }
  
  self = [super init];
  self.contentSize = CGSizeMake(51, 51);
  if (! self)
    return nil;
  
  _skillController = skillController;
  
  switch (skillController.activationType)
  {
    case SkillActivationTypeAutoActivated:
      [self setForAutoactivatedSkill];
      break;
    default:
      break;
  }
  
  [self setSkillIcon:skillController.skillType];
  
  return self;
}

- (void) setForAutoactivatedSkill
{
  if (! [_skillController isKindOfClass:[SkillControllerActive class]])
  {
    CustomAssert(FALSE, @"Wrong skill controller passed - not active instead of active skill");
    return;
  }
  
  SkillControllerActive* activeSkill = (SkillControllerActive*)_skillController;
  
  NSString* bgImageName;
  NSString* orbImageName;
  switch (activeSkill.orbColor)
  {
    case OrbColorEarth: bgImageName = @"earthcounterbg.png"; orbImageName = @"earthorbcounter.png"; break;
    case OrbColorFire:  bgImageName = @"firecounterbg.png"; orbImageName = @"fireorbcounter.png"; break;
    case OrbColorLight: bgImageName = @"lightcounterbg.png"; orbImageName = @"lightorbcounter.png"; break;
    case OrbColorDark:  bgImageName = @"nightcounterbg.png"; orbImageName = @"nightorbcounter.png"; break;
    case OrbColorWater: bgImageName = @"watercounterbg.png"; orbImageName = @"waterorbcounter.png"; break;
    default: return;
  }
  
  if (_bgImage)
    [_bgImage removeFromParentAndCleanup:YES];
  _bgImage = [CCSprite spriteWithImageNamed:bgImageName];
  [self addChild:_bgImage];
  
  if (_orbIcon)
    [_orbIcon removeFromParentAndCleanup:YES];
  _orbIcon = [CCSprite spriteWithImageNamed:orbImageName];
  _orbIcon.position = CGPointMake(-5, 0);
  [self addChild:_orbIcon];
  
  if (! _orbsCountLabel)
  {
    _orbsCountLabel = [CCLabelTTF labelWithString:@"0" fontName:@"GothamNarrow-UltraItalic" fontSize:12];
    _orbsCountLabel.color = [CCColor whiteColor];
    _orbsCountLabel.shadowOffset = ccp(0,-1);
    _orbsCountLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:0.3f];
    _orbsCountLabel.shadowBlurRadius = 1.f;
    _orbsCountLabel.position = CGPointMake(11, 0);
    _orbsCountLabel.horizontalAlignment = CCTextAlignmentLeft;
    [self addChild:_orbsCountLabel];
  }
  
  if (! _checkIcon)
  {
    _checkIcon = [CCSprite spriteWithImageNamed:@"orbschecked.png"];
    _checkIcon.position = CGPointMake(11, 0);
    [self addChild:_checkIcon];
  }
}

- (void) setSkillIcon:(SkillType)skillType
{
  NSString* iconName;
  switch (skillType)
  {
    case SkillTypeQuickAttack: iconName = @"quickattackicon.png"; break;
    default: return;
  }
  
  _skillIcon = [CCSprite spriteWithImageNamed:iconName];
  _skillIcon.position = ccp(2, 25);
  [self addChild:_skillIcon];
}

#pragma mark - Setters

- (void) setOrbsCount:(NSInteger)orbsCount
{
  if (!_orbsCountLabel || !_checkIcon)
    return;
  
  if (orbsCount == 0)
  {
    _orbsCountLabel.visible = NO;
    _checkIcon.visible = YES;
  }
  else
  {
    [_orbsCountLabel setString:[NSString stringWithFormat:@"%d", orbsCount]];
    _orbsCountLabel.visible = YES;
    _checkIcon.visible = NO;
  }
}

- (void) update
{
  // Active skills
  if ( [_skillController isKindOfClass:[SkillControllerActive class]] )
  {
    SkillControllerActive* activeSkill = (SkillControllerActive*)_skillController;
    self.orbsCount = activeSkill.orbCounter;
  }
}

@end
