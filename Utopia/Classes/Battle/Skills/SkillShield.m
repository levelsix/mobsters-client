//
//  SkillShield.m
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillShield.h"
#import "NewBattleLayer.h"
#import "NSObject+PerformBlockAfterDelay.h"

@implementation SkillShield

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _shieldHp = 1;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"SHIELD_HP"] )
    _shieldHp = value;
}

- (id) initWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color
{
  self = [super initWithProto:proto andMobsterColor:color];
  if ( ! self )
    return nil;
  
  _currentShieldHp = 0;
  
  return self;
}

#pragma mark - Overrides

- (BOOL) shouldSpawnRibbon
{
  return (_currentShieldHp == 0);
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  // If attacker is a shield owner
  if (player == self.belongsToPlayer)
    return damage;
  
  _tempDamageDealt = damage;
  
  // Modify damage
  damage -= _currentShieldHp;
  if (damage < 0)
    damage = 0;
  
  NSInteger damageAbsorbed = MIN(_tempDamageDealt, _currentShieldHp);
  if (damageAbsorbed > 0)
  {
    [self showSkillPopupMiniOverlay:NO
                         bottomText:[NSString stringWithFormat:@"%ld DMG BLOCKED", (long)damageAbsorbed]
                     withCompletion:^{}];
  }
  
  return damage;
}

- (void) restoreVisualsIfNeeded
{
  if (_currentShieldHp > 0)
    [self createShieldSprite];
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  // Create shield
  if (trigger == SkillTriggerPointEndOfPlayerMove)
  {
    if ([self skillIsReady])
    {
      if (execute)
      {
        [self showSkillPopupOverlay:YES withCompletion:^(){
          
          // Set shield power
          _currentShieldHp += _shieldHp;
          
          // Create sprite
          [self performAfterDelay:0.3 block:^{
            [self createShieldSprite];
            [self showShieldHp];
          }];
          
          // Finish skill
          [self resetOrbCounter];
          [self skillTriggerFinished:YES];
        }];
      }
      return YES;
    }
  }
  
  // Bounce shield upon receiving damage
  if ((trigger == SkillTriggerPointEnemyDealsDamage && self.belongsToPlayer) ||
      (trigger == SkillTriggerPointPlayerDealsDamage && !self.belongsToPlayer))
  {
    if (execute)
    {
      if (_currentShieldHp > 0)
      {
        // Modify shield
        _currentShieldHp -= _tempDamageDealt;
        if (_currentShieldHp <= 0)
        {
          _currentShieldHp = 0;
          [self removeShieldSprite];
        }
        else
          [self shieldHpChanged];
      }
      [self skillTriggerFinished];
    }
    return YES;
  }
  
  return NO;
}

#pragma mark - Animation helpers

static const NSInteger permanentActionTag = 100;

- (void) createPermanentAnimation:(CCSprite*)owner withPop:(BOOL)shouldPop
{
  
  CCAction *permanent = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                 [CCActionEaseInOut actionWithAction:[CCActionScaleTo actionWithDuration:0.7 scale:1.03]],
                                                                 [CCActionEaseInOut actionWithAction:[CCActionScaleTo actionWithDuration:0.7 scale:1.0]],
                                                                 nil]];
  permanent.tag = permanentActionTag;
  
  CCActionSequence* pop = [CCActionSequence actions:
                           [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.7 scale:1.0]],
                           [CCActionCallBlock actionWithBlock:
                            ^{
                              [owner runAction:permanent];
                            }],
                           nil];
  
  if (shouldPop)
    [owner runAction:pop];
  else
    [owner runAction:permanent];
}

- (void) startPermanentAnimationsAfterDelay:(float)delay withPop:(BOOL)shouldPop
{
  [self performAfterDelay:delay block:^{
    [self createPermanentAnimation:_backSprite withPop:shouldPop];
    [self createPermanentAnimation:_frontSprite withPop:shouldPop];
    [self createPermanentAnimation:_glowSprite withPop:shouldPop];
  }];
}

- (void) stopPermanentAnimations
{
  [_backSprite stopActionByTag:permanentActionTag];
  [_frontSprite stopActionByTag:permanentActionTag];
  [_glowSprite stopActionByTag:permanentActionTag];
}

#pragma mark - Animations

- (void) createShieldSprite
{
  // Check if the shield is here already
  if (_backSprite)
  {
    [self shieldHpChanged];
    return;
  }
  
  CGPoint position = ccp(20, 25);
  BattleSprite* owner = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
  
  _backSprite = [CCSprite spriteWithImageNamed:@"forcefieldback.png"];
  _backSprite.position = position;
  _backSprite.scale = 0.0;
  [owner addChild:_backSprite z:-5];
  
  _frontSprite = [CCSprite spriteWithImageNamed:@"forcefieldfront.png"];
  _frontSprite.position = position;
  _frontSprite.scale = 0.0;
  [owner addChild:_frontSprite z:5];
  
  _glowSprite = [CCSprite spriteWithImageNamed:@"forcefieldglow.png"];
  _glowSprite.position = position;
  _glowSprite.scale = 0.0;
  //_glowSprite.blendFunc = (ccBlendFunc){GL_ONE, GL_ONE};
  _glowSprite.blendMode = [CCBlendMode blendModeWithOptions:@{CCBlendFuncSrcColor: @(GL_ONE), CCBlendFuncDstColor: @(GL_ONE)}];
  
  [owner addChild:_glowSprite z:6];
  
  [self startPermanentAnimationsAfterDelay:0.0 withPop:YES];
}

- (void) removeShieldSprite
{
  if (! _backSprite)
    return;
  
  [self stopPermanentAnimations];
  
  CCActionSequence* popAnimation1 = [CCActionSequence actions:
                                    [CCActionSpawn actionOne:[CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:0.3 scale:10.0]]
                                                         two:[CCActionFadeOut actionWithDuration:0.3]],
                                    [CCActionRemove action],
                                    nil];
  CCActionSequence* popAnimation2 = [popAnimation1 copy];
  CCActionSequence* popAnimation3 = [popAnimation1 copy];
  
  [_backSprite runAction:popAnimation1];
  [_frontSprite runAction:popAnimation2];
  [_glowSprite runAction:popAnimation3];
  
  _backSprite = _frontSprite = _glowSprite = nil;
}

- (void) showShieldHp
{
  BattleSprite* owner = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
  NSString *str = [NSString stringWithFormat:@"%d", (int)_shieldHp];
  CCLabelBMFont *damageLabel = [CCLabelBMFont labelWithString:str fntFile:@"shieldfont.fnt"];
  [self.battleLayer.bgdContainer addChild:damageLabel z:owner.zOrder];
  damageLabel.position = ccpAdd(owner.position, ccp(0, owner.contentSize.height));
  damageLabel.scale = 0.01;
  [damageLabel runAction:[CCActionSequence actions:
                          [CCActionSpawn actions:
                           [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:1.2f scale:1]],
                           [CCActionFadeOut actionWithDuration:1.5f],
                           [CCActionMoveBy actionWithDuration:1.5f position:ccp(0,25)],nil],
                          [CCActionRemove action],
                          nil]];
}

- (void) shieldHpChanged
{
  // Changing opacity
  if (! _glowSprite)
    return;
  
  float opacity = 0.3 + 0.7*(float)_currentShieldHp/(float)_shieldHp;
  CCActionSequence* popAnimation1 = [CCActionSequence actions:
                                 [CCActionFadeTo actionWithDuration:0.4 opacity:opacity],
                                 nil];
  CCActionSequence* popAnimation2 = [popAnimation1 copy];
  CCActionSequence* popAnimation3 = [popAnimation1 copy];
  
  [_backSprite runAction:popAnimation1];
  [_frontSprite runAction:popAnimation2];
  [_glowSprite runAction:popAnimation3];
  
  // Bouncing
  if (! _backSprite)
    return;
  
  [self stopPermanentAnimations];
  
  popAnimation1 = [CCActionSequence actions:
                                     [CCActionEaseOut actionWithAction:[CCActionScaleTo actionWithDuration:0.2 scale:1.1]],
                                     [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:0.2 scale:1.0]],
                                     nil];
  popAnimation2 = [popAnimation1 copy];
  popAnimation3 = [popAnimation1 copy];
  
  [_backSprite runAction:popAnimation1];
  [_frontSprite runAction:popAnimation2];
  [_glowSprite runAction:popAnimation3];
  
  [self startPermanentAnimationsAfterDelay:0.4 withPop:NO];
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_currentShieldHp) forKey:@"currentShield"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* currentShieldHp = [dict objectForKey:@"currentShield"];
  if (currentShieldHp)
    _currentShieldHp = [currentShieldHp floatValue];
  
  return YES;
}

@end
