//
//  SkillController.m
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "NewBattleLayer.h"
#import "GameViewController.h"
#import "GameState.h"
#import "SkillProtoHelper.h"
#import "SkillManager.h"
#import "SkillQuickAttack.h"
#import "SkillJelly.h"
#import "SkillCakeDrop.h"
#import "SkillBombs.h"
#import "SkillShield.h"
#import "SkillPoison.h"
#import "SkillRoidRage.h"
#import "SkillMomentum.h"
#import "SkillThickSkin.h"
#import "SkillCritAndEvade.h"
#import "SkillShuffle.h"
#import "SkillHeadshot.h"
#import "SkillMud.h"
#import "SkillCounterStrike.h"
#import "SkillLifeSteal.h"
#import "SkillFlameStrike.h"
#import "SkillConfusion.h"
#import "SkillPoisonPowder.h"
#import "SkillSkewer.h"
#import "SkillHammerTime.h"
#import "SkillBloodRage.h"
#import "SkillTakeAim.h"
#import "SkillStaticField.h"
#import "SkillBlindingLight.h"
#import "SkillKnockout.h"
#import "SkillShallowGrave.h"
#import "SkillHellFire.h"
#import "SkillEnergize.h"
#import "SkillRightHook.h"
#import "SkillInsurance.h"
#import "SkillCurse.h"
#import "SkillFlameBreak.h"
#import "SkillPoisonSkewer.h"
#import "SkillPoisonFire.h"
#import "SkillChill.h"

@implementation SkillController

+ (id) skillWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color // Factory call, can create different skill types
{
  switch( proto.type )
  {
    case SkillTypeQuickAttack: return [[SkillQuickAttack alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeJelly: return [[SkillJelly alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeCakeDrop: return [[SkillCakeDrop alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeBombs: return [[SkillBombs alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeShield: return [[SkillShield alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypePoison: return [[SkillPoison alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeRoidRage: return [[SkillRoidRage alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeMomentum: return [[SkillMomentum alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeThickSkin: return [[SkillThickSkin alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeCritAndEvade: return [[SkillCritAndEvade alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeShuffle: return [[SkillShuffle alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeHeadshot: return [[SkillHeadshot alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeMud: return [[SkillMud alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeCounterStrike: return [[SkillCounterStrike alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeLifeSteal: return [[SkillLifeSteal alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeFlameStrike: return [[SkillFlameStrike alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeConfusion: return [[SkillConfusion alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypePoisonPowder: return [[SkillPoisonPowder alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeSkewer: return [[SkillSkewer alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeHammerTime: return [[SkillHammerTime alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeBloodRage: return [[SkillBloodRage alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeTakeAim: return [[SkillTakeAim alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeStaticField: return [[SkillStaticField alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeBlindingLight: return [[SkillBlindingLight alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeKnockout: return [[SkillKnockout alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeShallowGrave: return [[SkillShallowGrave alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeHellFire: return [[SkillHellFire alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeEnergize: return [[SkillEnergize alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeRightHook: return [[SkillRightHook alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeCurse: return [[SkillCurse alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeInsurance: return [[SkillInsurance alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeFlameBreak: return [[SkillFlameBreak alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypePoisonSkewer: return [[SkillPoisonSkewer alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypePoisonFire: return [[SkillPoisonFire alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeChill: return [[SkillChill alloc] initWithProto:proto andMobsterColor:color];
    default: CustomAssert(NO, @"Trying to create a skill with the factory for undefined skill."); return nil;
  }
}

- (id) initWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color
{
  self = [super init];
  if ( ! self )
    return nil;
  
  _orbColor = color;
  _skillId = proto.skillId;
  _skillType = proto.type;
  _activationType = proto.activationType;
  _skillImageNamePrefix = proto.imgNamePrefix;
  _executedInitialAction = NO;
  
  // Properties
  [self setDefaultValues];
  for (SkillPropertyProto* property in proto.propertiesList)
  {
    NSString* name = property.name;
    float value = property.skillValue;
    [self setValue:value forProperty:name];
  }
  
  return self;
}

#pragma mark - Property definitions

- (BattlePlayer*) userPlayer
{
  return self.belongsToPlayer ? self.player : self.enemy;
}

- (BattlePlayer*) opponentPlayer
{
  return self.belongsToPlayer ? self.enemy : self.player;
}

- (BattleSprite*) userSprite
{
  return self.belongsToPlayer ? self.playerSprite : self.enemySprite;
}

- (BattleSprite*) opponentSprite
{
  return self.belongsToPlayer ? self.enemySprite : self.playerSprite;
}

#pragma mark - External calls

- (BOOL) skillIsReady
{
  CustomAssert(NO, @"Calling skillIsReady for SkillController class - should be overrided.");
  return NO;
}

- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type
{
  return;
}

- (BOOL) generateSpecialOrb:(BattleOrb*)orb atColumn:(int)column row:(int)row
{
  return NO;
}

- (BOOL) triggerSkill:(SkillTriggerPoint)trigger withCompletion:(SkillControllerBlock)completion;
{
  // Try to trigger the skill and use callback right away if it's not responding
  SkillControllerBlock tempCallbackHolder = _callbackBlock;
  _callbackBlock = completion;
  _callbackParams = nil;
  BOOL triggered = [self skillCalledWithTrigger:trigger execute:YES];
  if (triggered)
  {
    [self.battleLayer.battleStateMachine.currentBattleState addSkillStepForTriggerPoint:trigger skillId:(int)self.skillId belongsToPlayer:self.belongsToPlayer ownerMonsterId:self.userPlayer.monsterId];
  }
  else
  {
    _callbackBlock = tempCallbackHolder;
    completion(NO, _callbackParams);
  }
  return triggered;
}

#pragma mark - Placeholders to be overriden

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  _currentTrigger = trigger;
  
  // Skip initial attack (if deserialized)
  if (trigger == SkillTriggerPointEnemyAppeared && _executedInitialAction)
    return NO;
  
  return NO;
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  return damage;
}

- (BOOL) skillOwnerWillEvade
{
  return NO;
}

- (BOOL) skillOwnerWillMiss
{
  return NO;
}

- (BOOL) skillOpponentWillMiss
{
  return NO;
}

- (void) skillTriggerFinished
{
  [self skillTriggerFinished:NO];
}

- (void) skillTriggerFinishedActivated
{
  [self skillTriggerFinished:YES];
}

- (void) skillTriggerFinished:(BOOL)skillActivated
{
  _skillActivated = skillActivated;
  
  if (_currentTrigger == SkillTriggerPointEnemyAppeared)
    _executedInitialAction = YES;
  
  if (_skillActivated && [self isKindOfClass:[SkillControllerActive class]])
  {
    SkillControllerBlock completion = _callbackBlock;
    [self.battleLayer triggerSkills:self.belongsToPlayer ? SkillTriggerPointPlayerSkillActivated : SkillTriggerPointEnemySkillActivated
                 withCompletion:^(BOOL triggered, id params) {
                   completion(YES, _callbackParams);
                 }];
  }
  else
  {
    _callbackBlock(YES, _callbackParams);
  }
}

- (void) setDefaultValues
{
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
}

- (BOOL) shouldSpawnRibbon
{
  return NO;
}

- (BOOL) shouldPersist
{
  return NO;
}

- (NSSet*) sideEffects
{
  return [NSSet set];
}

- (BOOL)targetsPlayer:(BattlePlayer *)player
{
  return NO;
}

- (void) restoreVisualsIfNeeded
{
}

#pragma mark - Reusable Poison Logic

- (int) poisonDamage { return 0; }

- (void) dealPoisonDamage
{
  [self performBlockAfterDelay:self.opponentSprite.animationType == MonsterProto_AnimationTypeMelee ? .5 : 0 block:^{
    
    [self showSkillPopupAilmentOverlay:@"POISONED" bottomText:[NSString stringWithFormat:@"%i POISON DMG", [self poisonDamage]] priority:0];
    
    if (self.belongsToPlayer)
    {
      [self.opponentSprite performNearFlinchAnimationWithStrength:0 delay:0.5];
    }
    else
    {
      // Flinch
      [self.opponentSprite performFarFlinchAnimationWithDelay:0.5];
    }
    
    // Flash red
    [self.opponentSprite.sprite runAction:[CCActionSequence actions:
                                      [CCActionDelay actionWithDuration:0.3],
                                      [RecursiveTintTo actionWithDuration:0.2 color:[CCColor purpleColor]],
                                      [RecursiveTintTo actionWithDuration:0.2 color:[CCColor whiteColor]],
                                      nil]];
    
    // Skull and bones
    CCSprite* skull = [CCSprite spriteWithImageNamed:@"poisonplayer.png"];
    skull.position = ccp(20, self.opponentSprite.contentSize.height/2);
    skull.scale = 0.01;
    skull.opacity = 0.0;
    [self.opponentSprite addChild:skull z:10];
    [skull runAction:[CCActionSequence actions:
                      [CCActionSpawn actions:
                       [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:0.3f scale:1]],
                       [CCActionFadeIn actionWithDuration:0.3f],
                       nil],
                      [CCActionCallBlock actionWithBlock:^{
                        [self dealPoisonDamage2];
                      }],
                      [CCActionDelay actionWithDuration:0.5],
                      [CCActionEaseElasticIn actionWithAction:[CCActionScaleTo actionWithDuration:0.7f scale:0]],
                      [CCActionRemove action],
                      nil]];
  }];
}

- (void) dealPoisonDamage2
{
  // Deal damage
  [self.battleLayer dealDamage:(int)self.poisonDamage enemyIsAttacker:!self.belongsToPlayer usingAbility:YES withTarget:self withSelector:@selector(onFinishPoisonDamage)];
  
  if (!self.belongsToPlayer)
  {
    [self.battleLayer sendServerUpdatedValuesVerifyDamageDealt:NO];
  }
}

- (void) onFinishPoisonDamage
{
  [self skillTriggerFinished];
}

#pragma mark - Reusable Quick Attack Logic

- (int) quickAttackDamage { return 0; }

- (void) showQuickAttackMiniLogo
{
  [self showSkillPopupMiniOverlay:[NSString stringWithFormat:@"%ld DMG", (long)self.quickAttackDamage]];
}

- (void) dealQuickAttack
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
  [self.battleLayer.orbLayer disallowInput];
  
  [self showQuickAttackMiniLogo];
  
  if (self.belongsToPlayer)
    [self.playerSprite performFarAttackAnimationWithStrength:0.f shouldEvade:NO shouldMiss:NO enemy:self.enemySprite
                                                      target:self selector:@selector(quickAttackDealDamage) animCompletion:nil];
  else
    [self.enemySprite performNearAttackAnimationWithEnemy:self.playerSprite shouldReturn:YES shouldEvade:NO shouldMiss:NO shouldFlinch:YES
                                                   target:self selector:@selector(quickAttackDealDamage) animCompletion:nil];
}

- (void) quickAttackDealDamage
{
  // Deal damage
  
  [self.battleLayer dealDamage:self.quickAttackDamage enemyIsAttacker:(!self.belongsToPlayer) usingAbility:YES withTarget:self withSelector:@selector(preFinishQuickAttack)];
  
  if (!self.belongsToPlayer) {
    [self.battleLayer sendServerUpdatedValuesVerifyDamageDealt:NO];
  }
}

// Puts a delay inbetween the quick attack and releasing the skill trigger for melee toons
- (void) preFinishQuickAttack
{
  [self performBlockAfterDelay:self.userSprite.animationType == MonsterProto_AnimationTypeMelee ? 1 : 0 block:^{
    [self onFinishQuickAttack];
  }];
}

- (void) onFinishQuickAttack
{
  [self skillTriggerFinished];
}

- (BattleItemType)antidoteType
{
  return BattleItemTypeNone;
}

- (BOOL) cureStatusWithAntidote:(BattleItemProto*)antidote execute:(BOOL)execute
{
  return NO;
}

- (void)onCureStatus
{
  //Placeholder
}

- (NSString *)cureBottomText
{
  return @"";
}

#pragma mark - UI

- (int) skillStacks
{
  return _stacks;
}

- (NSString*) skillName
{
  SkillProto* skillProto = [[GameState sharedGameState].staticSkills objectForKey:[NSNumber numberWithInteger:_skillId]];
  return skillProto.name;
}

- (NSString*) processedSkillDescription
{
  SkillProto* skillProto = [[GameState sharedGameState].staticSkills objectForKey:[NSNumber numberWithInteger:_skillId]];
  
  return self.belongsToPlayer ? [SkillProtoHelper offShortDescForSkill:skillProto] : [SkillProtoHelper defShortDescForSkill:skillProto];
}

- (void) showSkillPopupOverlay:(BOOL)jumpFirst withCompletion:(SkillPopupBlock)completion
{
  SkillPopupData *data = [SkillPopupData initWithData:self.belongsToPlayer characterImageName:_ownerMonsterImageName topText:[self skillName] bottomText:[self processedSkillDescription] mini:NO stacks:[self skillStacks] completion:completion];
  _callbackBlockForPopup = completion;
  [skillManager showSkillPopupOverlay:self.belongsToPlayer jumpFirst:jumpFirst withData:data];
}

- (void) showSkillPopupMiniOverlay:(NSString *)bottomText
{
  [self showSkillPopupMiniOverlay:NO bottomText:bottomText withCompletion:^{}];
}

- (void) showSkillPopupMiniOverlay:(NSString*)bottomText withCompletion:(SkillPopupBlock)completion
{
  [self showSkillPopupMiniOverlay:NO bottomText:bottomText withCompletion:completion];
}

- (void) showSkillPopupMiniOverlay:(BOOL)jumpFirst bottomText:(NSString*)bottomText withCompletion:(SkillPopupBlock)completion
{
  SkillPopupData *data = [SkillPopupData initWithData:self.belongsToPlayer characterImageName:_ownerMonsterImageName topText:[self skillName] bottomText:bottomText mini:YES stacks:_stacks completion:completion];
  _callbackBlockForPopup = completion;
  [skillManager showSkillPopupOverlay:self.belongsToPlayer jumpFirst:jumpFirst withData:data];
}

//Only used during the modifyDamage stage. Enqueues the popup, but delays playing until ready
- (void) enqueueSkillPopupMiniOverlay:(NSString*)bottomText
{
  SkillPopupData *data = [SkillPopupData initWithData:self.belongsToPlayer characterImageName:_ownerMonsterImageName topText:[self skillName] bottomText:bottomText mini:YES stacks:_stacks completion:^{}];
  _callbackBlockForPopup = nil;
  [skillManager enqueuePopupData:data forPlayer:self.belongsToPlayer];
}

- (void) enqueueSkillPopupAilmentOverlay:(NSString*)topText bottomText:(NSString*)bottomText
{
  [self enqueueSkillPopupAilmentOverlay:topText bottomText:bottomText priority:1];
}

- (void) enqueueSkillPopupAilmentOverlay:(NSString*)topText bottomText:(NSString*)bottomText priority:(int)priority
{
  SkillPopupData *data = [SkillPopupData initWithData:!self.belongsToPlayer characterImageName:[self.opponentSprite.prefix stringByAppendingString:@"Character.png"] topText:topText bottomText:bottomText mini:YES stacks:_stacks completion:^{}];
  
  data.priority = priority;
  
  [skillManager showSkillPopupOverlay:!self.belongsToPlayer jumpFirst:NO withData:data];
}

- (void) showSkillPopupAilmentOverlay:(NSString*)topText bottomText:(NSString*)bottomText
{
  [self showSkillPopupAilmentOverlay:NO topText:topText bottomText:bottomText priority:1 withCompletion:^{}];
}

- (void) showSkillPopupAilmentOverlay:(NSString *)topText bottomText:(NSString *)bottomText priority:(int)priority
{
  [self showSkillPopupAilmentOverlay:NO topText:topText bottomText:bottomText priority:priority withCompletion:^{}];
}

- (void) showSkillPopupAilmentOverlay:(BOOL)jumpFirst topText:(NSString*)topText bottomText:(NSString*)bottomText priority:(int)priority withCompletion:(SkillPopupBlock)completion
{
  SkillPopupData *data = [SkillPopupData initWithData:!self.belongsToPlayer characterImageName:[self.opponentSprite.prefix stringByAppendingString:@"Character.png"] topText:topText bottomText:bottomText mini:YES stacks:_stacks completion:completion];
  
  data.priority = priority;
  
  [skillManager showSkillPopupOverlay:!self.belongsToPlayer jumpFirst:NO withData:data];
}

- (void) makeSkillOwnerJumpWithTarget:(id)target selector:(SEL)completion
{
  if (_belongsToPlayer)
    [_playerSprite jumpNumTimes:2 completionTarget:target selector:completion];
  else
    [_enemySprite jumpNumTimes:2 completionTarget:target selector:completion];
}

#pragma mark - Side effects

- (void) addSkillSideEffectToSkillOwner:(SideEffectType)type turnsAffected:(NSInteger)numTurns
{
  [self addSkillSideEffectToSkillOwner:type turnsAffected:numTurns turnsAreSkillOwners:YES];
}

- (void) addSkillSideEffectToOpponent:(SideEffectType)type turnsAffected:(NSInteger)numTurns
{
  [self addSkillSideEffectToOpponent:type turnsAffected:numTurns turnsAreSkillOwners:NO];
}

- (void) addSkillSideEffectToSkillOwner:(SideEffectType)type turnsAffected:(NSInteger)numTurns turnsAreSkillOwners:(BOOL)turnsAreSkillOwners
{
  [(_belongsToPlayer ? _playerSprite : _enemySprite) addSkillSideEffect:type
                                                               forSkill:_skillId
                                                          turnsAffected:numTurns
                                               turnsAreSideEffectOwners:turnsAreSkillOwners
                                                               toPlayer:_belongsToPlayer];
}

- (void) addSkillSideEffectToOpponent:(SideEffectType)type turnsAffected:(NSInteger)numTurns turnsAreSkillOwners:(BOOL)turnsAreSkillOwners
{
  [(_belongsToPlayer ? _enemySprite : _playerSprite) addSkillSideEffect:type
                                                               forSkill:_skillId
                                                          turnsAffected:numTurns
                                               turnsAreSideEffectOwners:!turnsAreSkillOwners
                                                               toPlayer:!_belongsToPlayer];
}

- (void) removeSkillSideEffectFromSkillOwner:(SideEffectType)type
{
  [(_belongsToPlayer ? _playerSprite : _enemySprite) removeSkillSideEffect:type];
}

- (void) removeSkillSideEffectFromOpponent:(SideEffectType)type
{
  [(_belongsToPlayer ? _enemySprite : _playerSprite) removeSkillSideEffect:type];
}

- (void) resetAfftectedTurnsCount:(NSInteger)numTurns forSkillSideEffectOnSkillOwner:(SideEffectType)type
{
  [(_belongsToPlayer ? _playerSprite : _enemySprite) resetAfftectedTurnsCount:numTurns forSkillSideEffect:type];
}

- (void) resetAfftectedTurnsCount:(NSInteger)numTurns forSkillSideEffectOnOpponent:(SideEffectType)type
{
  [(_belongsToPlayer ? _enemySprite : _playerSprite) resetAfftectedTurnsCount:numTurns forSkillSideEffect:type];
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  return [NSDictionary dictionaryWithObjectsAndKeys:@(_skillType), @"skillType", @(_executedInitialAction), @"initialized", @(_belongsToPlayer), @"belongsToPlayer", @(_skillId), @"skillId", @(_orbColor), @"color",  @(_stacks), @"stacks", _ownerUdid, @"ownerUdid", _ownerMonsterImageName, @"ownerImageName", nil];
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! dict)
    return NO;
  
  // Comparing stored skill id with the one from server and break serialization if differ
  // This is needed in case skill id changed on server
  if (dict[@"skillType"])
    if (_skillType != [dict[@"skillType"] integerValue])
      return NO;
  
  // Keeping track of initialization flag so we won't cast initial skill stage again if player reopens the battle
  if (dict[@"initialized"])
    if ([dict[@"initialized"] boolValue])
      _executedInitialAction = YES;
  
  if (dict[@"belongsToPlayer"])
    if ([dict[@"belongsToPlayer"] boolValue])
      _belongsToPlayer = YES;
  
  if (dict[@"stacks"])
    _stacks = [dict[@"stacks"] intValue];
  
  if (dict[@"ownerUdid"])
    _ownerUdid = dict[@"ownerUdid"];
  
  if (dict[@"ownerImageName"])
    _ownerMonsterImageName = dict[@"ownerImageName"];
  
  return YES;
}

#pragma mark - Helpers

- (void) preseedRandomization
{
  // Calculating seed for pseudo-random generation (so upon deserialization pattern will be the same)
  int seed = 0;
  for (NSInteger n = 0; n < self.battleLayer.orbLayer.layout.numColumns; n++)
    for (NSInteger m = 0; m < self.battleLayer.orbLayer.layout.numRows; m++)
      seed += [self.battleLayer.orbLayer.layout orbAtColumn:n row:m].orbColor;
  srand(seed);
}

+ (NSInteger) specialsOnBoardCount:(SpecialOrbType)type layout:(BattleOrbLayout*)layout
{
  NSInteger result = 0;
  for (NSInteger column = 0; column < layout.numColumns; column++)
    for (NSInteger row = 0; row < layout.numRows; row++)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == type)
        result++;
    }
  return result;
}

+ (NSInteger) specialTilesOnBoardCount:(TileType)type layout:(BattleOrbLayout*)layout
{
  NSInteger result = 0;
  for (NSInteger column = 0; column < layout.numColumns; column++)
    for (NSInteger row = 0; row < layout.numRows; row++)
    {
      BattleTile* tile = [layout tileAtColumn:column row:row];
      if (tile.typeBottom == type)
        result++;
    }
  return result;
}

- (NSInteger) specialsOnBoardCount:(SpecialOrbType)type
{
  return [SkillController specialsOnBoardCount:type layout:self.battleLayer.orbLayer.layout];
}

- (NSInteger) specialTilesOnBoardCount:(TileType)type
{
  return [SkillController specialTilesOnBoardCount:type layout:self.battleLayer.orbLayer.layout];
}

- (BOOL)sameAsActiveSkill
{
  SkillController *activeSkill = self.belongsToPlayer ? skillManager.playerSkillControler : skillManager.enemySkillControler;
  if (!activeSkill || self == activeSkill) return NO;
  NSLog(@"%@", [activeSkill class]);
  return [activeSkill isKindOfClass:[activeSkill class]];
}

@end