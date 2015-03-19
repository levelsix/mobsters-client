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
#import "SkillManager.h"

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
  _skillActive = NO;
  _cursed = NO;
  
  GameState* gs = [GameState sharedGameState];
  _skillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:skillController.skillId]];
  
  [self setSkillIcon:[_skillProto.imgNamePrefix stringByAppendingString:kSkillIconImageNameSuffix]];
  
//[self setSkillLabel];
  
  [self setSkillCounter];
  
  return self;
}

- (void) setSkillIcon:(NSString*)iconName
{
  _skillIcon = [CCSprite node];
  [Globals imageNamed:iconName toReplaceSprite:_skillIcon completion:^(BOOL success) {
    if (success) {
      _skillIcon.position = ccp(0, 28);
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
    }
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

- (void) setSkillCounter
{
  const Element element = (Element)_skillController.orbColor;
  
  NSString* bgName = [NSString stringWithFormat:@"%@.png", [Globals imageNameForElement:element suffix:@"counterbg"]];
  _skillCounterBg = [CCSprite spriteWithImageNamed:bgName];
  [_skillCounterBg setPosition:ccp(0, 5)];
  [self addChild:_skillCounterBg z:10];

  NSString* orbImg = [NSString stringWithFormat:@"mini%@.png", [Globals imageNameForElement:element suffix:@""]];
  _skillOrbIcon = [CCSprite spriteWithImageNamed:orbImg];
  [_skillOrbIcon setPosition:ccp(13, _skillCounterBg.contentSize.height * .5f)];
  [_skillCounterBg addChild:_skillOrbIcon];
  
  _skillCounterLabel = [CCLabelTTF labelWithString:@"" fontName:@"Gotham-Ultra" fontSize:8.f];
  [_skillCounterLabel setHorizontalAlignment:CCTextAlignmentLeft];
  [_skillCounterLabel setColor:[CCColor whiteColor]];
  [_skillCounterLabel setPosition:ccp(27, _skillCounterBg.contentSize.height * .5f)];
  [_skillCounterLabel setShadowBlurRadius:1.f];
  [_skillCounterLabel setShadowOffset:ccp(0.f, -1.f)];
  switch (element)
  {
    case ElementFire:   [_skillCounterLabel setShadowColor:[CCColor colorWithUIColor:[UIColor colorWithHexString:@"891000"]]]; break;
    case ElementEarth:  [_skillCounterLabel setShadowColor:[CCColor colorWithUIColor:[UIColor colorWithHexString:@"385700"]]]; break;
    case ElementWater:  [_skillCounterLabel setShadowColor:[CCColor colorWithUIColor:[UIColor colorWithHexString:@"004473"]]]; break;
    case ElementLight:  [_skillCounterLabel setShadowColor:[CCColor colorWithUIColor:[UIColor colorWithHexString:@"bc5000"]]]; break;
    case ElementDark:   [_skillCounterLabel setShadowColor:[CCColor colorWithUIColor:[UIColor colorWithHexString:@"150044"]]]; break;
    default: break;
  }
  [_skillCounterBg addChild:_skillCounterLabel];
  
  _skillActiveIcon = [CCSprite spriteWithImageNamed:@"maptaskdonecheck.png"];
  [_skillActiveIcon setPosition:ccp(34, _skillCounterBg.contentSize.height * .5f)];
  [_skillActiveIcon setScale:.7f * .1f];
  [_skillActiveIcon setOpacity:0.f];
  [_skillCounterBg addChild:_skillActiveIcon];
  
  if ([_skillController isKindOfClass:[SkillControllerActive class]])
  {
    SkillControllerActive* activeController = (SkillControllerActive*)_skillController;
    [_skillCounterLabel setString:[NSString stringWithFormat:@"%d/%d",
                                   (int)(activeController.orbRequirement - activeController.orbCounter),
                                   (int)(activeController.orbRequirement)]];
    [_skillCounterLabel setFontSize:9.f];
    [_skillCounterLabel setPosition:ccpAdd(_skillCounterLabel.position, ccp(5.f, 0.f))];
  }
  else
  {
    [_skillCounterLabel setString:@"PASSIVE"];
    [_skillOrbIcon setVisible:NO];
  }
}

#define CURSE_SCALE_TIME 0.2f

- (void) setCurse:(BOOL)curse
{
  _cursed = curse;
  if (curse)
  {
    [_skillCounterLabel runAction:[CCActionSequence actions:
                                   [CCActionScaleTo actionWithDuration:CURSE_SCALE_TIME scale:0],
                                   [CCActionCallBlock actionWithBlock:^{
                                      [_skillCounterLabel setPosition:ccp(27, _skillCounterBg.contentSize.height * .5f)];
                                      [_skillCounterLabel setString:@"CURSED"];
                                    }],
                                   [CCActionScaleTo actionWithDuration:CURSE_SCALE_TIME scale:1],
                                   nil]];
    
    if (!_skillActive)
      [_skillOrbIcon runAction:[CCActionScaleTo actionWithDuration:CURSE_SCALE_TIME scale:0]];
    
  }
  else
  {
    
    [_skillCounterLabel runAction:[CCActionSequence actions:
                                   [CCActionScaleTo actionWithDuration:CURSE_SCALE_TIME scale:0],
                                   [CCActionCallBlock actionWithBlock:^{
                                      [_skillCounterLabel setPosition:ccp([_skillController isKindOfClass:[SkillControllerActive class]] ? 32 : 27, _skillCounterBg.contentSize.height * .5f)];
                                      [self update];
                                    }],
                                   [CCActionScaleTo actionWithDuration:CURSE_SCALE_TIME scale:1],
                                   nil]];
    [_skillOrbIcon runAction:[CCActionSequence actions:
                              [CCActionDelay actionWithDuration:CURSE_SCALE_TIME],
                              [CCActionScaleTo actionWithDuration:CURSE_SCALE_TIME scale:1],
                              nil]];
  }
}

- (void) setSkillButton
{
  _skillButton = [CCButton buttonWithTitle:@"" spriteFrame:_skillIcon.spriteFrame];
  [_skillButton setBackgroundSpriteFrame:nil forState:CCControlStateNormal];
  [_skillButton setBackgroundSpriteFrame:nil forState:CCControlStateDisabled];
  [_skillButton setPosition:ccpAdd(_skillIcon.position, ccp(0.f, -10.f))];
  [_skillButton setContentSize:_skillIcon.contentSize];
  [_skillButton setHitAreaExpansion:10.f];
  [_skillButton setTarget:self selector:@selector(skillButtonTapped)];
  [self addChild:_skillButton];
}

- (void) skillButtonTapped
{
  if (_skillButtonEnabled && [_skillController skillIsReady])
  {
    [_skillController triggerSkill:SkillTriggerPointManualActivation withCompletion:^(BOOL triggered, id params) {
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
  if ([_skillController isKindOfClass:[SkillControllerActive class]])
  {
    SkillControllerActive* activeSkill = (SkillControllerActive*)_skillController;
    [self setPercentage:1.0 - (float)activeSkill.orbCounter/(float)activeSkill.orbRequirement];
    
    if (!_skillController.userPlayer.isCursed)
      [_skillCounterLabel setString:[NSString stringWithFormat:@"%d/%d",
                                   (int)(activeSkill.orbRequirement - activeSkill.orbCounter),
                                   (int)(activeSkill.orbRequirement)]];
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
                             [CCActionMoveTo actionWithDuration:0.3 position:CGPointMake(-_skillIcon.contentSize.width/2, _skillIcon.contentSize.height*(percentage-.5))],
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
      
      if (!_skillActive)
      {
        [_skillCounterLabel runAction:[CCActionSpawn actions:
                                       [CCActionScaleTo actionWithDuration:.5f scale:.1f],
                                       [CCActionFadeOut actionWithDuration:.5f], nil]];
        [_skillActiveIcon runAction:[CCActionSpawn actions:
                                     [CCActionScaleTo actionWithDuration:.5f scale:.7f],
                                     [CCActionFadeIn actionWithDuration:.5f], nil]];
        _skillActive = YES;
      }
    }
    else
    {
      if (_chargedEffect)
        [_chargedEffect stopSystem];
      
      if (_skillActive)
      {
        [_skillCounterLabel runAction:[CCActionSpawn actions:
                                       [CCActionScaleTo actionWithDuration:.5f scale:1.f],
                                       [CCActionFadeIn actionWithDuration:.5f], nil]];
        [_skillActiveIcon runAction:[CCActionSpawn actions:
                                     [CCActionScaleTo actionWithDuration:.5f scale:.7f * .1f],
                                     [CCActionFadeOut actionWithDuration:.5f], nil]];
        
        if (_cursed)
          [_skillOrbIcon runAction:[CCActionSpawn actions:
                                    [CCActionScaleTo actionWithDuration:.5f scale:.1f],
                                    [CCActionFadeIn actionWithDuration:.5f], nil]];
        
        _skillActive = NO;
      }
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
  CGPoint orbCounterPosition = [self.parent convertToWorldSpace:ccpAdd(self.position, ccp(0.f, self.contentSize.height - 5.f))];
  orbCounterPosition = ccp(orbCounterPosition.x, [Globals screenSize].height - orbCounterPosition.y);
  
  [skillManager displaySkillCounterPopupForController:_skillController withProto:_skillProto atPosition:orbCounterPosition];
  
}

@end
