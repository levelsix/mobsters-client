//
//  SkillController.m
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillQuickAttack.h"
#import "SkillJelly.h"
#import "SkillCakeDrop.h"
#import "NewBattleLayer.h"
#import "GameViewController.h"
#import "GameState.h"

@implementation SkillController

+ (id) skillWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color // Factory call, can create different skill types
{
  switch( proto.type )
  {
    case SkillTypeQuickAttack: return [[SkillQuickAttack alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeJelly: return [[SkillJelly alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeCakeDrop: return [[SkillCakeDrop alloc] initWithProto:proto andMobsterColor:color];
    default: CustomAssert(NO, @"Trying to create a skill with the factory for undefined skill."); return nil;
  }
}

- (id) initWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color
{
  self = [super init];
  if ( ! self )
    return nil;
  
  _orbColor = color;
  _skillType = proto.type;
  _activationType = proto.activationType;
  _shouldExecuteInitialAction = YES;
  
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

- (SpecialOrbType) generateSpecialOrb
{
  return SpecialOrbTypeNone;
}

- (void) triggerSkill:(SkillTriggerPoint)trigger withCompletion:(SkillControllerBlock)completion;
{
  // Try to trigger the skill and use callback right away if it's not responding
  _callbackBlock = completion;
  BOOL triggered = [self skillCalledWithTrigger:trigger];
  if (! triggered)
    _callbackBlock();
}

#pragma mark - Placeholders to be overriden

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger
{
  // Cache image if needed
  if (! _characterImage)
    [self prepareCharacterImage];

  // Skip initial attack (if deserialized)
  if (! _shouldExecuteInitialAction && trigger == SkillTriggerPointEnemyAppeared)
  {
    _callbackBlock();
    _shouldExecuteInitialAction = YES;
    return YES;
  }
  
  return NO;
}

- (void) skillTriggerFinished
{
  _callbackBlock();
}

- (void) setDefaultValues
{
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
}

#pragma mark - UI

- (void) prepareCharacterImage
{
  BattlePlayer* owner = self.belongsToPlayer ? self.player : self.enemy;
  GameState *gs = [GameState sharedGameState];
  MonsterProto *proto = [gs monsterWithId:owner.monsterId];
  
  _characterImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
  NSString *fileName = [proto.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamed:fileName withView:_characterImage maskedColor:nil indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];  
}

- (void) showSkillPopupOverlayWithCompletion:(SkillControllerBlock)completion
{
  GameViewController *gvc = [GameViewController baseController];
  UIView *parentView = gvc.view;
  SkillPopupOverlay* popupOverlay = [[[NSBundle mainBundle] loadNibNamed:@"SkillPopupOverlay" owner:self options:nil] objectAtIndex:0];
  [parentView addSubview:popupOverlay];
  popupOverlay.origin = CGPointMake((parentView.width - popupOverlay.width)/2, (parentView.height - popupOverlay.height)/2);
  [popupOverlay animateForSkill:_skillType forPlayer:_belongsToPlayer withImage:_characterImage withCompletion:completion];
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
  return [NSDictionary dictionaryWithObjectsAndKeys:@(_skillType), @"skillType", nil];
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
  
  _shouldExecuteInitialAction = NO;
  
  return YES;
}

@end