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
#import "GameState.h"
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
  _skillButtonEnabled = NO;
  
  GameState* gs = [GameState sharedGameState];
  SkillProto* playerSkillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:skillController.skillId]];
  
  [self setSkillIcon:playerSkillProto.iconImgName];
  
  [self setSkillLabel];
  
  return self;
}

- (void) setSkillIcon:(NSString*)iconName
{
  _skillIcon = [CCSprite node];
  [Globals imageNamed:iconName toReplaceSprite:_skillIcon completion:^{
    
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
    
    [self setSkillButton];
  }];
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

- (void) setSkillButton
{
  _skillButton = [CCButton buttonWithTitle:@"" spriteFrame:_skillIcon.spriteFrame];
  [_skillButton setBackgroundSpriteFrame:nil forState:CCControlStateNormal];
  [_skillButton setBackgroundSpriteFrame:nil forState:CCControlStateDisabled];
  _skillButton.position = _skillIcon.position;
  _skillButton.contentSize = _skillIcon.contentSize;
  [_skillButton setTarget:self selector:@selector(skillButtonTapped)];
  [self addChild:_skillButton];
}

- (void) skillButtonTapped
{
  if (_skillButtonEnabled && [_skillController skillIsReady])
  {
    [_skillController triggerSkill:SkillTriggerPointManualActivation withCompletion:^(BOOL triggered) {
      [self update];
    }];
  }
  else
    [self popupOrbCounter];
}

#pragma mark - Update logic

- (void) update
{
  // Active skills
  if (_skillController.activationType != SkillActivationTypePassive)
  {
    SkillControllerActive* activeSkill = (SkillControllerActive*)_skillController;
    [self setPercentage:1.0 - (float)activeSkill.orbCounter/(float)activeSkill.orbRequirement];
  }
  
  // Manually enabled skills
  if (_skillController.activationType == SkillActivationTypeUserActivated)
    [self updateButtonAnimations];
  
  // Hide if owner died
  BattlePlayer* owner = _skillController.belongsToPlayer ? _skillController.player : _skillController.enemy;
  if (owner.curHealth <= 0.0)
    [self disappear];
}

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

- (void) enableSkillButton:(BOOL)active
{
  if (_skillController.activationType != SkillActivationTypeUserActivated)
    return;
  
  _skillButtonEnabled = active;
  [self updateButtonAnimations];
}

#pragma mark - UI Calls

- (void) updateButtonAnimations
{
  if ( !_skillButton)
    return;
  
  if ([self.skillController skillIsReady] && _skillButtonEnabled)
  {
    if (![_skillIcon getActionByTag:2015])
    {
      CCActionRepeatForever* bump = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                             [CCActionEaseInOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.1]],
                                                                             [CCActionEaseInOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]],
                                                                             nil]];
      bump.tag = 2015;
      [_skillIcon runAction:bump];
      if (_chargedEffect)
        [_chargedEffect resetSystem];
    }
  }
  else
  {
    [_skillIcon stopActionByTag:2015];
    if (_skillIcon.scale != 1.0)
      [_skillIcon runAction:[CCActionScaleTo actionWithDuration:0.3 scale:1.0]];
    if (_chargedEffect)
      [_chargedEffect stopSystem];
  }
}

- (void) popupOrbCounter
{
  if (_orbCounter && _orbCounter.parent)
    return;
  
  // BG
  NSString* bgName = [NSString stringWithFormat:@"%@.png", [Globals imageNameForElement:(Element)_skillController.orbColor suffix:@"counter"] ];
  _orbCounter = [CCSprite spriteWithImageNamed:bgName];
  _orbCounter.position = ccpAdd(self.position, ccp(0, self.contentSize.height + 5));
  _orbCounter.opacity = 0.0;
  
  // Counter label
  CCLabelTTF* orbsCountLabel = [CCLabelTTF labelWithString:@"0" fontName:@"GothamNarrow-Ultra" fontSize:12];
  orbsCountLabel.color = [CCColor whiteColor];
  orbsCountLabel.shadowOffset = ccp(0,-1);
  orbsCountLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:0.3f];
  orbsCountLabel.shadowBlurRadius = 1.f;
  orbsCountLabel.horizontalAlignment = CCTextAlignmentCenter;
  orbsCountLabel.position = CGPointMake(_orbCounter.contentSize.width/2, _orbCounter.contentSize.height/2 + 4);
  [_orbCounter addChild:orbsCountLabel];
  
  if ([_skillController isKindOfClass:[SkillControllerActive class]])
  {
    SkillControllerActive* activeController = (SkillControllerActive*)_skillController;
    
    // Orb icon
    NSString* orbName = [NSString stringWithFormat:@"%@.png", [Globals imageNameForElement:(Element)_skillController.orbColor suffix:@"orb"] ];
    CCSprite* orb = [CCSprite spriteWithImageNamed:orbName];
    orb.position = CGPointMake(orbsCountLabel.position.x - 12, orbsCountLabel.position.y);
    orb.scale = 0.5;
    [_orbCounter addChild:orb];
    
    // Text
    [orbsCountLabel setString:[NSString stringWithFormat:@"%d/%d", activeController.orbRequirement-activeController.orbCounter, activeController.orbRequirement]];
    orbsCountLabel.position = CGPointMake(orbsCountLabel.position.x + 10, orbsCountLabel.position.y);
  }
  else
  {
    // Text
    [orbsCountLabel setString:[NSString stringWithFormat:@"Passive"]];
  }
  
  [self.parent addChild:_orbCounter];
  [_orbCounter runAction:[CCActionSequence actions:[RecursiveFadeTo actionWithDuration:0.3 opacity:1.0],
                 [CCActionDelay actionWithDuration:2.0],
                 [RecursiveFadeTo actionWithDuration:0.3 opacity:0.0],
                 [CCActionRemove action],
                 nil]];
}

@end
