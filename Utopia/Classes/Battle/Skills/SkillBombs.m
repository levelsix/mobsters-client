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

@implementation SkillBombs

#pragma mark - Initialization

- (void) setDefaultValues
{
  // Properties
  [super setDefaultValues];
  
  _minBombs = 1;
  _maxBombs = 1;
  _initialBombs = 1;
  _bombCounter = 1;
  _bombDamage = 1;
  _bombChance = 0.2;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"MIN_BOMBS"] )
    _minBombs = value;
  else if ( [property isEqualToString:@"MAX_BOMBS"] )
    _maxBombs = value;
  else if ( [property isEqualToString:@"INITIAL_BOMBS"] )
    _initialBombs = value;
  else if ( [property isEqualToString:@"BOMB_COUNTER"] )
    _bombCounter = value;
  else if ( [property isEqualToString:@"BOMB_DAMAGE"] )
    _bombDamage = value;
  else if ( [property isEqualToString:@"BOMB_CHANCE"] )
    _bombChance = value;
}

#pragma mark - Overrides

- (BOOL) generateSpecialOrb:(BattleOrb*)orb atColumn:(int)column row:(int)row
{
  if (orb.orbColor != self.orbColor)
    return NO;
  
  NSInteger bombsOnBoard = [self specialsOnBoardCount:SpecialOrbTypeBomb];
  float rand = ((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX);
  if ((rand < _bombChance && bombsOnBoard < _maxBombs) || bombsOnBoard < _minBombs)
  {
    [self makeBomb:orb];
    orb.bombCounter++;  // because it will be decreased right after the spawn by nextMove
    return YES;
  }
  
  return NO;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  // Initial bomb spawn
  if (trigger == SkillTriggerPointEnemyAppeared)
  {
    if (execute)
      [self initialSequence];
    return YES;
  }
  
  return NO;
}

#pragma mark - Skill logic

- (void) makeBomb:(BattleOrb*)orb
{
  orb.specialOrbType = SpecialOrbTypeBomb;
  orb.bombCounter = _bombCounter;
  orb.bombDamage = _bombDamage;
}

// Jumping, showing overlay and spawning initial set
- (void) initialSequence
{
  [self showSkillPopupOverlay:YES withCompletion:^{
    [self performAfterDelay:0.5 block:^{
      [self spawnBombs:_initialBombs withTarget:self andSelector:@selector(skillTriggerFinished)];
    }];
  }];
}

static const NSInteger bombsMaxSearchIterations = 1000;

// Adding bombs
- (void) spawnBombs:(NSInteger)count withTarget:(id)target andSelector:(SEL)selector
{
  [self preseedRandomization];
  
  for (NSInteger n = 0; n < count; n++)
  {
    BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
    BattleOrb* orb = nil;
    NSInteger column, row;
    NSInteger counter = 0;
    
    // Trying to find orbs of the same color first
    do {
      column = rand() % (layout.numColumns-2) + 1;  // So we'll never spawn at the edge of the board
      row = rand() % (layout.numRows-2) + 1;
      orb = [layout orbAtColumn:column row:row];
      counter++;
    }
    while ((orb.specialOrbType != SpecialOrbTypeNone || orb.powerupType != PowerupTypeNone || orb.orbColor != self.orbColor) && counter < bombsMaxSearchIterations);
    
    // Another loop if we haven't found the orb of the same color (avoiding chain)
    if (counter == bombsMaxSearchIterations)
    {
      counter = 0;
      do {
        column = rand() % (layout.numColumns-2) + 1;  // So we'll never spawn at the edge of the board
        row = rand() % (layout.numRows-2) + 1;
        orb = [layout orbAtColumn:column row:row];
        counter++;
      } while (([self.battleLayer.orbLayer.layout hasChainAtColumn:column row:row] || orb.specialOrbType != SpecialOrbTypeNone || orb.powerupType != PowerupTypeNone) &&
               counter < bombsMaxSearchIterations);
    }
    
    // Nothing found (just in case), continue and perform selector if the last bomb
    if (counter == bombsMaxSearchIterations)
    {
      if (n == count-1)
        if (target && selector)
          SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
            [target performSelector:selector withObject:nil]; );
      continue;
    }
    
    // Update data
    [self makeBomb:orb];
    
    // Update tile
    OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
    BattleTile* tile = [layout tileAtColumn:column row:row];
    [bgdLayer updateTile:tile keepLit:NO withTarget:((n==count-1)?target:nil) andCallback:selector];
    
    // Update orb
    [self performAfterDelay:0.5 block:^{
      OrbSprite* orbSprite = [self.battleLayer.orbLayer.swipeLayer spriteForOrb:orb];
      [orbSprite reloadSprite:YES];
    }];
  }
}

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
        orb.bombCounter--;
        
        // Update sprite
        OrbSprite* sprite = [layer spriteForOrb:orb];
        if (orb.bombCounter <= 0) // Blow up the bomb
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
        }
        else
          [sprite updateBombCounter:YES];
      }
    }
  
  // Dropping bombs if needed
  if (bombCount > 0)
  {
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
      
        completion(YES);
      }];
    }];
  }
  else
    completion(NO);
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
       }],
      nil]];
  }
}

@end
