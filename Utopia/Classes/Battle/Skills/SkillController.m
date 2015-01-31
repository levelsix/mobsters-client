//
//  SkillController.m
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "NewBattleLayer.h"
#import "GameViewController.h"
#import "GameState.h"
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
  _callbackBlock = completion;
  _callbackParams = nil;
  BOOL triggered = [self skillCalledWithTrigger:trigger execute:YES];
  if (! triggered)
    _callbackBlock(NO, _callbackParams);
  return triggered;
}

#pragma mark - Placeholders to be overriden

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  _currentTrigger = trigger;
  
  // Cache image if needed
  if (! _characterImage)
    [self prepareCharacterImage];
  
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

- (void) skillTriggerFinished
{
  [self skillTriggerFinished:NO];
}

- (void) skillTriggerFinished:(BOOL)skillActivated
{
  _skillActivated = skillActivated;
  
  if (_currentTrigger == SkillTriggerPointEnemyAppeared)
    _executedInitialAction = YES;
  
  // Hide popup and call block
  if (_popupOverlay)
  {
    [self hideSkillPopupOverlayInternal];
    _popupOverlay = nil;
  }
  else
  {
    _callbackBlock(YES, _callbackParams);
  
    if (_skillActivated && [self isKindOfClass:[SkillControllerActive class]])
    {
      [skillManager triggerSkills:self.belongsToPlayer ? SkillTriggerPointPlayerSkillActivated : SkillTriggerPointEnemySkillActivated
                   withCompletion:^(BOOL triggered, id params) {}];
    }
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

- (void) restoreVisualsIfNeeded
{
}

#pragma mark - UI

- (void) prepareCharacterImage
{
  BattlePlayer* owner = self.belongsToPlayer ? self.player : self.enemy;
  if (! owner)
    return;
  
  GameState *gs = [GameState sharedGameState];
  MonsterProto *proto = [gs monsterWithId:owner.monsterId];
  
  _characterImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
  NSString *fileName = [proto.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamedWithiPhone6Prefix:fileName withView:_characterImage maskedColor:nil indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
}

- (void) showSkillPopupOverlayInternal
{
  // Create overlay
  UIView *parentView = self.battleLayer.hudView;
  _popupOverlay = [[[NSBundle mainBundle] loadNibNamed:@"SkillPopupOverlay" owner:self options:nil] objectAtIndex:0];
  _popupOverlay.frame = parentView.bounds;
  [parentView addSubview:_popupOverlay];
  _popupOverlay.origin = CGPointMake((parentView.width - _popupOverlay.width)/2, (parentView.height - _popupOverlay.height)/2);
  [_popupOverlay animateForSkill:_skillId forPlayer:_belongsToPlayer withImage:_characterImage withCompletion:_callbackBlockForPopup];
  
  // Hide pieces of battle hud
  if (self.belongsToPlayer)
  {
    [UIView animateWithDuration:0.1 animations:^{
      self.battleLayer.hudView.bottomView.alpha = 0.0;
    } completion:^(BOOL finished) {
      self.battleLayer.hudView.bottomView.hidden = YES;
    }];
  }
}

- (void) hideSkillPopupOverlayInternal
{
  // Restore pieces of the battle hud in a block
  SkillPopupBlock newCompletion = ^(){
    
    if (self.belongsToPlayer)
    {
      self.battleLayer.hudView.bottomView.hidden = NO;
      self.battleLayer.hudView.bottomView.alpha = 0.0;
      [UIView animateWithDuration:0.1 animations:^{
        self.battleLayer.hudView.bottomView.alpha = 1.0;
      }];
    }
    
    _callbackBlock(YES, _callbackParams);
    
    if (_skillActivated && [self isKindOfClass:[SkillControllerActive class]])
    {
      [skillManager triggerSkills:self.belongsToPlayer ? SkillTriggerPointPlayerSkillActivated : SkillTriggerPointEnemySkillActivated
                   withCompletion:^(BOOL triggered, id params) {}];
    }
  };
  
  // Hide overlay
  [_popupOverlay hideWithCompletion:newCompletion];
}

- (void) showSkillPopupOverlay:(BOOL)jumpFirst withCompletion:(SkillPopupBlock)completion
{
  _callbackBlockForPopup = completion;
  
  if (jumpFirst)
    [self makeSkillOwnerJumpWithTarget:self selector:@selector(showSkillPopupOverlayInternal)];
  else
    [self showSkillPopupOverlayInternal];
}

- (void) makeSkillOwnerJumpWithTarget:(id)target selector:(SEL)completion
{
  if (_belongsToPlayer)
    [_playerSprite jumpNumTimes:2 completionTarget:target selector:completion];
  else
    [_enemySprite jumpNumTimes:2 completionTarget:target selector:completion];
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  return [NSDictionary dictionaryWithObjectsAndKeys:@(_skillType), @"skillType", @(_executedInitialAction), @"initialized", @(_belongsToPlayer), @"belongsToPlayer", @(_skillId), @"skillId", @(_orbColor), @"color", nil];
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

@end