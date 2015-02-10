//
//  SkillBombs.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/16/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillBombs.h"
#import "NewBattleLayer.h"
#import "Globals.h"
#import <CCTextureCache.h>
#import "SoundEngine.h"

@implementation SkillBombs

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  // Properties
  _bombsPerActivation = 0;
  _maxBombs = 0;
  _bombCounter = 0;
  _bombDamage = 0;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ( [property isEqualToString:@"BOMBS_PER_ACTIVATION"] )
    _bombsPerActivation = value;
  else if ( [property isEqualToString:@"MAX_BOMBS"] )
    _maxBombs = value;
  else if ( [property isEqualToString:@"BOMB_COUNTER"] )
    _bombCounter = value;
  else if ( [property isEqualToString:@"BOMB_DAMAGE"] )
    _bombDamage = value;
}

- (id) initWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color
{
  self = [super initWithProto:proto andMobsterColor:color];
  if ( ! self )
    return nil;
  
  _turnCounter = 0;
  
  return self;
}

#pragma mark - Overrides

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  // Additional bomb spawn on skill trigger
  if ((self.activationType == SkillActivationTypeUserActivated && trigger == SkillTriggerPointManualActivation) ||
       (self.activationType == SkillActivationTypeAutoActivated && trigger == SkillTriggerPointEndOfPlayerMove))
  {
    if ([self skillIsReady])
    {
      if (execute)
      {
        NSInteger bombsOnBoard = [self specialsOnBoardCount:SpecialOrbTypeBomb];
        NSInteger countToSpawn = MIN(_bombsPerActivation, _maxBombs - bombsOnBoard);
        
        if (countToSpawn > 0)
        {
          // Spawn new bombs on board
          [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
          [self.battleLayer.orbLayer disallowInput];
          [self makeSkillOwnerJumpWithTarget:nil selector:nil];
          
          [self showSkillPopupOverlay:YES withCompletion:^(){
            [self performAfterDelay:0.5 block:^{
              SkillLogStart(@"Bombs -- Skill spawned additional %ld bombs", (long)countToSpawn);
              [self spawnBombs:countToSpawn isInitialSkill:NO withTarget:self andSelector:@selector(finishSpawn)];
            }];
          }];
        }
        else
          return NO;
      }
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - Skill logic

// Adding bombs
- (void) spawnBombs:(NSInteger)count isInitialSkill:(BOOL)isInitialSkill withTarget:(id)target andSelector:(SEL)selector
{
  [self preseedRandomization];
  
  for (NSInteger n = 0; n < count; n++)
  {
    BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
    BattleOrb* orb = [layout findOrbWithColorPreference:self.orbColor isInitialSkill:isInitialSkill];
    
    // Nothing found (just in case), continue and perform selector if the last bomb
    if (!orb)
    {
      if (n == count-1)
        if (target && selector)
          SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
            [target performSelector:selector withObject:nil]; );
      continue;
    }
    
    // Update data
    if (orb.orbColor != OrbColorRock) {
      orb.orbColor = self.orbColor;
      orb.specialOrbType = SpecialOrbTypeBomb;
      orb.turnCounter = _bombCounter;
      orb.bombDamage = _bombDamage;
    }
    
    // Update tile
    OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
    BattleTile* tile = [layout tileAtColumn:orb.column row:orb.row];
    [bgdLayer updateTile:tile keepLit:NO withTarget:((n==count-1)?target:nil) andCallback:selector];
    
    // Update orb
    [self performAfterDelay:0.5 block:^{
      OrbSprite* orbSprite = [self.battleLayer.orbLayer.swipeLayer spriteForOrb:orb];
      [orbSprite reloadSprite:YES];
    }];
  }
}

- (void) finishSpawn
{
  [self resetOrbCounter];
  
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
  [self.battleLayer.orbLayer allowInput];
  
  [self skillTriggerFinished:YES];
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_turnCounter) forKey:@"turnCounter"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* turnCounter = [dict objectForKey:@"turnCounter"];
  if (turnCounter)
    _turnCounter = [turnCounter integerValue];
  
  return YES;
}

#pragma mark - Class methods

// This part is class methods because bombs can overlast the skill controller. It's called from SkillManager updateSpecials

+ (void) updateBombs:(NewBattleLayer*)battleLayer withCompletion:(SkillControllerBlock)completion
{
  BattleOrbLayout* layout = battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = battleLayer.orbLayer.swipeLayer;
  NSInteger totalDamage = 0;
  NSInteger bombCount = 0;
  for (NSInteger column = 0; column < layout.numColumns; column++)
    for (NSInteger row = 0; row < layout.numRows; row++)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypeBomb)
      {
        // Update counter
        orb.turnCounter--;
        
        // Update sprite
        OrbSprite* sprite = [layer spriteForOrb:orb];
        if (orb.turnCounter <= 0) // Blow up the bomb
        {
          // Change sprite type
          orb.specialOrbType = SpecialOrbTypeNone;
          
          // Reload sprite
          [sprite reloadSprite:YES];
          
          // Add explosion
          CCParticleSystem* blast = [CCParticleSystem particleWithFile:@"bombskillexplosion.plist"];
          blast.scale = 0.5;
          blast.autoRemoveOnFinish = YES;
          blast.position = ccp(sprite.contentSize.width/2, sprite.contentSize.height/2);
          [sprite addChild:blast];
          
          // Count damage and bombs
          totalDamage += orb.bombDamage;
          bombCount++;
          
          [SoundEngine puzzleBoardExplosion];
        }
        else
          [sprite updateTurnCounter:YES];
      }
    }
  
  // Dropping bombs if needed
  if (bombCount > 0)
  {
    [battleLayer.orbLayer.bgdLayer turnTheLightsOff];
    [battleLayer.orbLayer disallowInput];
    
    float delay = 1.5 + 0.05*bombCount; // 0.05 = 0.1/2 where 0.1 is the delay between dropping bombs. So player will flinch on the middle bomb.
    
    // Player flinches
    [battleLayer.myPlayer performFarFlinchAnimationWithDelay:delay];
    
    // Deal damage
    [battleLayer performAfterDelay:delay block:^{
      battleLayer.enemyDamageDealt = (int)totalDamage;
      [battleLayer dealDamage:(int)totalDamage enemyIsAttacker:YES usingAbility:YES withTarget:nil withSelector:nil];
    }];
    
    // Bombs are dropping
    [SkillBombs dropBombsOnPlayer:bombCount withBattleLayer:battleLayer andPosition:battleLayer.myPlayer.position andCompletion:^{
      
      [battleLayer performAfterDelay:0.5 block:^{
        
        [battleLayer.orbLayer.bgdLayer turnTheLightsOn];
        [battleLayer.orbLayer allowInput];
        
        completion(YES, nil);
      }];
    }];
  }
  else
    completion(NO, nil);
}

// Copy-paste with minor improvements from airplane animation
+ (void) dropBombsOnPlayer:(NSInteger)bombCount withBattleLayer:(NewBattleLayer*)battleLayer andPosition:(CGPoint)position andCompletion:(void(^)())completion
{
  for (int i = 0; i < bombCount; i++) {
    CCSprite *bomb = [CCSprite spriteWithImageNamed:@"bomb.png"];
    [battleLayer.bgdContainer addChild:bomb];
    bomb.scale = 0.3;
    
    CGPoint endPos = ccpAdd(position, ccp(5,10));
    endPos = ccpAdd(endPos, ccpMult(POINT_OFFSET_PER_SCENE, 0.02*(i-bombCount/2)));
    
    bomb.position = ccp(endPos.x, endPos.y+250);
    
    [bomb runAction:
     [CCActionSequence actions:
      [CCActionDelay actionWithDuration:0.75f+0.1*i],
      [CCActionEaseIn actionWithAction:[CCActionMoveTo actionWithDuration:0.9f position:endPos]],
      [CCActionCallBlock actionWithBlock:
       ^{
         [[CCTextureCache sharedTextureCache] addImage:@"bombdrop.png"];
         CCParticleSystem *q = [CCParticleSystem particleWithFile:@"bombdrop.plist"];
         q.autoRemoveOnFinish = YES;
         q.position = bomb.position;
         [battleLayer.bgdContainer addChild:q];
         
         [bomb removeFromParentAndCleanup:YES];
         
         if (i == bombCount-1) {
           completion();
         }
         
         if (i == 0) {
           [battleLayer shakeScreenWithIntensity:2.f];
         }
         
         [SoundEngine puzzleBoardExplosion];
       }],
      nil]];
  }
}

@end
