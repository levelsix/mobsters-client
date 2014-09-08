//
//  SkillBattleIndicatorView.m
//  Utopia
//
//  Created by Mikhail Larionov on 8/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "CCTextureCache.h"
#import "UIDefinitions.h"
#import "Globals.h"
#import "SkillBattleIndicatorView.h"
#import "SkillControllerActive.h"
#import "SkillControllerPassive.h"

@interface SkillBattleIndicatorView()

@property (weak, nonatomic) SkillController* skillController;

@end

@implementation SkillBattleIndicatorView

#pragma mark - Initialization

- (instancetype) initWithSkillController:(SkillController*)skillController enemy:(BOOL)enemy
{
  if (! skillController)
  {
    CustomAssert(FALSE, @"Error: trying to initizalize indicator with nil skill controller");
    return nil;
  }
  
  self = [super init];
  self.contentSize = CGSizeMake(51, 51);
  if (! self)
    return nil;
  
  _skillController = skillController;
  _enemy = enemy;
  
  /*switch (skillController.activationType)
  {
    case SkillActivationTypeAutoActivated:
      [self setForAutoactivatedSkill];
      break;
    case SkillActivationTypePassive:
      [self setForPassiveSkill];
      break;
    default:
      break;
  }*/
  
  [self setSkillIcon];
  
  [self setSkillLabel];
  
  return self;
}

/*- (void) setForAutoactivatedSkill
{
  if (! [_skillController isKindOfClass:[SkillControllerActive class]])
  {
    CustomAssert(FALSE, @"Wrong skill controller passed - non-active instead of active skill");
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

- (void) setForPassiveSkill
{
  if (! [_skillController isKindOfClass:[SkillControllerPassive class]])
  {
    CustomAssert(FALSE, @"Wrong skill controller passed - non-passive instead of passive skill");
    return;
  }
  
  SkillControllerActive* activeSkill = (SkillControllerActive*)_skillController;
  
  NSString* bgImageName;
  switch (activeSkill.orbColor)
  {
    case OrbColorEarth: bgImageName = @"earthcounterbg.png"; break;
    case OrbColorFire:  bgImageName = @"firecounterbg.png"; break;
    case OrbColorLight: bgImageName = @"lightcounterbg.png"; break;
    case OrbColorDark:  bgImageName = @"nightcounterbg.png"; break;
    case OrbColorWater: bgImageName = @"watercounterbg.png"; break;
    default: return;
  }
  
  if (_bgImage)
    [_bgImage removeFromParentAndCleanup:YES];
  _bgImage = [CCSprite spriteWithImageNamed:bgImageName];
  [self addChild:_bgImage];
  
  if (! _passiveOnLabel)
  {
    _passiveOnLabel = [CCLabelTTF labelWithString:@"On" fontName:@"GothamNarrow-UltraItalic" fontSize:12];
    _passiveOnLabel.color = [CCColor whiteColor];
    _passiveOnLabel.shadowOffset = ccp(0,-1);
    _passiveOnLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:0.3f];
    _passiveOnLabel.shadowBlurRadius = 1.f;
    _passiveOnLabel.position = CGPointMake(-6, 0);
    _passiveOnLabel.horizontalAlignment = CCTextAlignmentLeft;
    [self addChild:_passiveOnLabel];
  }
  
  if (! _checkIcon)
  {
    _checkIcon = [CCSprite spriteWithImageNamed:@"orbschecked.png"];
    _checkIcon.position = CGPointMake(11, 0);
    [self addChild:_checkIcon];
  }
}*/

- (void) setSkillIcon
{
  NSString* iconName;
  switch (_skillController.skillType)
  {
    case SkillTypeQuickAttack: iconName = @"quickattackicon.png"; break;
    case SkillTypeJelly: iconName = @"goosplashicon.png"; break;
    default: return;
  }
  
  _skillIcon = [CCSprite spriteWithImageNamed:iconName];
  _skillIcon.position = ccp(0, 25);
  [self addChild:_skillIcon];
  
  if (_skillController.activationType != SkillActivationTypePassive)
  {
    // Greyscale image
    UIImage *image = [Globals imageNamed:iconName];
    image = [Globals greyScaleImageWithBaseImage:image];
    CCTexture* texture = [[CCTextureCache sharedTextureCache] addCGImage:image.CGImage forKey:[iconName stringByAppendingString:@"gs"]];
    texture.contentScale = _skillIcon.texture.contentScale;
    CCSprite* greyscaleIcon = [CCSprite spriteWithTexture:texture];
    
    // Stencil node
    _stencilNode = [CCDrawNode node];
    CGPoint rectangle[] = {{0, 0}, {_skillIcon.contentSize.width, 0}, {_skillIcon.contentSize.width, _skillIcon.contentSize.height}, {0, _skillIcon.contentSize.height}};
    _stencilNode.position = CGPointMake(-_skillIcon.contentSize.width/2, -_skillIcon.contentSize.height/2);
    _stencilNode.contentSize = CGSizeMake(_skillIcon.contentSize.width, _skillIcon.contentSize.height * 0.5);
    [_stencilNode drawPolyWithVerts:rectangle count:4 fillColor:[CCColor whiteColor] borderWidth:1 borderColor:[CCColor whiteColor]];
    
    // Clipping node
    CCClippingNode* clippingNode = [CCClippingNode clippingNodeWithStencil:_stencilNode];
    clippingNode.position = _skillIcon.position;
    [clippingNode addChild:greyscaleIcon];
    [self addChild:clippingNode];
  }
}

- (void) setSkillLabel
{
  NSString* iconName;
  switch (_skillController.orbColor)
  {
    case OrbColorEarth: iconName = @"earth"; break;
    case OrbColorFire: iconName = @"fire"; break;
    case OrbColorLight: iconName = @"light"; break;
    case OrbColorDark: iconName = @"night"; break;
    case OrbColorWater: iconName = @"water"; break;
    default: return;
  }
  
  if (_enemy)
    iconName = [iconName stringByAppendingString:@"enemyskill.png"];
  else
    iconName = [iconName stringByAppendingString:@"yourskill.png"];
  
  _skillLabel = [CCSprite spriteWithImageNamed:iconName];
  _skillLabel.position = ccp(0, 10);
  [self addChild:_skillLabel];
}

#pragma mark - Setters

/*- (void) setOrbsCount:(NSInteger)orbsCount
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
}*/

- (void) setPercentage:(float)percentage
{
  if (_percentage == percentage)
    return;
  
  _percentage = percentage;
  
  // Show greyscale progress
  if (_stencilNode)
  {
    [_stencilNode stopAllActions];
    [_stencilNode runAction:[CCActionSequence actions:
                              [CCActionMoveTo actionWithDuration:0.3 position:CGPointMake(-_skillIcon.contentSize.width/2, _skillIcon.contentSize.height*(percentage-0.5))],
                              nil]];
  }
  
  // Enable/disable charged effect
  if (_skillController.activationType != SkillActivationTypePassive)
  {
    if (_percentage == 1.0)
    {
      if (! _chargedEffect)
      {
        _chargedEffect = [CCParticleSystem particleWithFile:@"skillactive.plist"];
        _chargedEffect.contentSize = _skillIcon.contentSize;
        _chargedEffect.position = CGPointMake(_chargedEffect.contentSize.width/2, _chargedEffect.contentSize.height/2);
        _chargedEffect.scale = 0.5;
        [_skillIcon addChild:_chargedEffect];
      }
      
      [_chargedEffect resetSystem];
    }
    else
    {
      if (_chargedEffect)
        [_chargedEffect stopSystem];
    }
  }
}

- (void) update
{
  // Active skills
  if ( [_skillController isKindOfClass:[SkillControllerActive class]] )
  {
    SkillControllerActive* activeSkill = (SkillControllerActive*)_skillController;
    self.percentage = 1.0 - (float)activeSkill.orbCounter/(float)activeSkill.orbRequirement;
    //self.orbsCount = activeSkill.orbCounter;
  }
}

#pragma mark - UI Calls

- (void) appear:(BOOL)instantly
{
  if (instantly)
    self.position = CGPointMake(self.position.x - self.contentSize.width, self.position.y);
  else
    [self runAction:[CCActionSequence actions:
                                   [CCActionEaseOut actionWithAction:
                                    [CCActionSpawn actionOne:
                                     [CCActionMoveBy actionWithDuration:0.3 position:CGPointMake(-self.contentSize.width, 0.)] two:
                                     [CCActionFadeIn actionWithDuration:0.3]]],
                                   nil]];
}

- (void) disappear
{
  [self runAction:[CCActionSequence actions:
                                   [CCActionEaseIn actionWithAction:
                                    [CCActionSpawn actionOne:
                                     [CCActionMoveBy actionWithDuration:0.3 position:CGPointMake(self.contentSize.width, 0.)] two:
                                     [CCActionFadeOut actionWithDuration:0.3]]],
                                   [CCActionRemove action],
                                   nil]];
}

@end
