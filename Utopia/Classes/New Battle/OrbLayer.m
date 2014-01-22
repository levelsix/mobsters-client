//
//  OrbLayer.m
//  PadClone
//
//  Created by Ashwin Kamath on 8/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "OrbLayer.h"
#import "SoundEngine.h"
#import "Globals.h"

#define ORB_ANIMATION_OFFSET 10
#define ORB_ANIMATION_TIME 0.15
#define ORB_CORNER_LEEWAY 0.07
#define NUMBER_OF_ORBS_FOR_MATCH 3
#define TIME_TO_TRAVEL_PER_SQUARE 0.1
#define TIME_FOR_ORB_BOUNCE 0.3
#define ROCKET_END_LOCATION 15
#define MOLOTOV_PARTICLE_DURATION 0.75

@implementation Powerup


@end

@implementation Gem

@end

@implementation DestroyedGem

- (id) initWithColor:(ccColor3B)color {
  if ((self = [super initWithFile:@"orbball.png"])) {
    self.color = color;
    
    self.streak = [CCMotionStreak streakWithFade:0.5 minSeg:0.1f width:8 color:ccWHITE textureFilename:@"streak.png"];
    self.streak.color = color;
    
    // schedule an update on each frame so we can syncronize the streak with the target
    [self schedule:@selector(onUpdate:)];
  }
  return self;
}

- (void) setParent:(CCNode *)parent {
  [super setParent:parent];
  if (parent && !self.streak.parent) {
    [self.parent addChild:self.streak z:self.zOrder];
  }
}

- (void) onUpdate:(ccTime)delta {
	[self.streak setPosition:self.position];
}

- (void) dealloc {
  [self.streak removeFromParent];
}

@end

@implementation OrbLayer

- (id) initWithContentSize:(CGSize)size gridSize:(CGSize)gridSize numColors:(int)numColors
{
  if((self=[super init])) {
		_gridSize = gridSize;
    _numColors = numColors;
    
    _run = [[NSMutableSet alloc] init];
    _tempRun = [[NSMutableSet alloc] init];
    _powerups = [[NSMutableArray alloc] init];
    _dragGem = nil;
    self.comboLabels = [NSMutableArray array];
    self.destroyedGems = [NSMutableSet set];
    self.reservedGems = [NSMutableSet set];
    self.contentSize = size;
    
    self.isTouchEnabled = YES;
    
    [self initBoard];
	}
	
	return self;
}

- (void)registerWithTouchDispatcher {
  [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (CGSize) squareSize {
  return CGSizeMake(_contentSize.width/_gridSize.width, _contentSize.height/_gridSize.height);
}

- (CCSprite *) createGemSpriteWithColor:(GemColorId)gemColor powerup:(PowerupId)powerupId
{
  NSString *colorPrefix = @"";
  switch (gemColor) {
    case color_purple:
    case color_white:
    case color_red:
    case color_green:
    case color_blue:
      colorPrefix = [Globals imageNameForElement:(MonsterProto_MonsterElement)gemColor suffix:@""];
      break;
    case color_filler:
      colorPrefix = @"rock";
      powerupId = powerup_none;
      break;
    case color_all:
      colorPrefix = @"all";
      break;
    default: return nil; break;
  }
  
  NSString *powerupSuffix = @"";
  switch (powerupId) {
    case powerup_none: powerupSuffix = @"orb"; break;
    case powerup_horizontal_line: powerupSuffix = @"sideways"; break;
    case powerup_vertical_line: powerupSuffix = @"updown"; break;
    case powerup_explosion: powerupSuffix = @"grenade"; break;
    case powerup_all_of_one_color: powerupSuffix = @"cocktail"; break;
    default: return nil; break;
  }
  
  return [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@%@.png", colorPrefix, powerupSuffix]];
}

- (Gem *) createRandomGem
{
  int gemColor = (arc4random() % _numColors) + color_red;
  return [self createGemWithColor:gemColor powerup:powerup_none];
}

- (Gem *) createGemWithColor:(GemColorId)gemColor powerup:(PowerupId)powerupId {
  CCSprite * gem = [self createGemSpriteWithColor:gemColor powerup:powerupId];
  if (!gem) {
    NSString *s = [NSString stringWithFormat:@"%d%@", gemColor, powerupId == powerup_explosion ? @"g" : powerupId != powerup_none ? @"r" : @""];
    gem = [CCLabelTTF labelWithString:s fontName:[Globals font] fontSize:20.f];
  }
  Gem *container = [[Gem alloc] init];
  container.sprite = gem;
  container.color = gemColor;
  container.powerup = powerupId;
  return container;
}

- (void) initBoard
{
  CGSize gs = [self gridSize];
  self.gems = [[NSMutableArray alloc] init];
  for (int i = 0; i < gs.width*gs.height; i++) {
    BOOL gemOkay = NO;
    while (!gemOkay) {
      [_gems addObject:[self createRandomGem]];
      [_run removeAllObjects];
      for (int j = 0; j <= i; j++) {
        [self findRunFromGem:_gems[j] index:j];
      }
      
      if (_run.count > 0) {
        [_gems removeLastObject];
      } else {
        gemOkay = YES;
      }
    }
  }
  
  // Make sure there is atleast one move
  if (![self validMoveExists]) {
    [self initBoard];
    return;
  }
  
  for (Gem *gem in self.gems) {
    [self addChild:gem.sprite z:9];
    gem.sprite.position = [self pointForGridPosition:[self coordinateOfGem:gem]];
  }
}

- (BOOL) validMoveExists {
  for (int x = 0; x < self.gridSize.width; x++) {
    for (int y = 0; y < self.gridSize.height; y++) {
      int idx = x+(y*self.gridSize.width);
      Gem *gem = self.gems[idx];
      NSMutableArray *toCheck = [NSMutableArray array];
      
      // If it is a molotov, return true
      if (gem.powerup == powerup_all_of_one_color) {
        return YES;
      }
      
      // Check right gem and up gem if they exist
      if (x < self.gridSize.width-1) {
        Gem *rightGem = self.gems[idx+1];
        [toCheck addObject:rightGem];
      }
      if (y < self.gridSize.height-1) {
        Gem *rightGem = self.gems[idx+(int)self.gridSize.width];
        [toCheck addObject:rightGem];
      }
      
      for (Gem *checkGem in toCheck) {
        // Check if both are powerups
        if (gem.powerup != powerup_none && checkGem.powerup != powerup_none) {
          return YES;
        }
        
        // Swap and see if run exists
        CGPoint checkCoord = [self coordinateOfGem:checkGem];
        int checkIndex = checkCoord.x+(checkCoord.y*self.gridSize.width);
        [self.gems replaceObjectAtIndex:checkIndex withObject:gem];
        [self.gems replaceObjectAtIndex:idx withObject:checkGem];
        
        [self createRunForCurrentBoard];
        
        // Swap them back
        [self.gems replaceObjectAtIndex:idx withObject:gem];
        [self.gems replaceObjectAtIndex:checkIndex withObject:checkGem];
        
        if (_run.count > 0) {
          return YES;
        }
      }
    }
  }
  
  return NO;
}

- (int) createRunForCurrentBoard {
  [_run removeAllObjects];
  for (int i = 0; i < self.gems.count; i++) {
    Gem *gem = _gems[i];
    if (gem.color != color_all) {
      [self findRunFromGem:_gems[i] index:i];
    }
  }
  return _run.count;
}

- (void) reshuffle {
  LNLog(@"Reshuffling...");
  
  [self.gems shuffle];
  while (![self validMoveExists] || [self createRunForCurrentBoard] > 0) {
    [self.gems shuffle];
  }
  
  for (Gem *gem in self.gems) {
    [gem.sprite runAction:[CCMoveTo actionWithDuration:0.3 position:[self pointForGridPosition:[self coordinateOfGem:gem]]]];
  }
  
  [self.delegate reshuffle];
}

#pragma mark gameplay

-(void)findMatchesAboveGem:(Gem*)gem index:(int)index
{
  int y = index / self.gridSize.width;
  if (y <= 0) return;
  else
  {
    [_tempRun addObject:gem];
    int newIndex = index-self.gridSize.width;
    if (newIndex < _gems.count) {
      Gem * newGem = _gems[newIndex];
      if (newGem.color == gem.color)
      {
        [_tempRun addObject:newGem];
        [self findMatchesAboveGem:newGem index:newIndex];
      }
    }
  }
}

-(void)findMatchesBelowGem:(Gem*)gem index:(int)index
{
  int y = index / self.gridSize.width;
  if (y >= self.gridSize.height-1) return;
  else
  {
    [_tempRun addObject:gem];
    int newIndex = index+self.gridSize.width;
    if (newIndex < _gems.count) {
      Gem * newGem = _gems[newIndex];
      if (newGem.color == gem.color)
      {
        [_tempRun addObject:newGem];
        [self findMatchesBelowGem:newGem index:newIndex];
      }
    }
  }
}

-(void)findMatchesLeftGem:(Gem*)gem index:(int)index
{
  int x = index % (int)self.gridSize.width;
  if (x <= 0) return;
  else
  {
    [_tempRun addObject:gem];
    int newIndex = index-1;
    if (newIndex < _gems.count) {
      Gem * newGem = _gems[newIndex];
      if (newGem.color == gem.color)
      {
        [_tempRun addObject:newGem];
        [self findMatchesLeftGem:newGem index:newIndex];
      }
    }
  }
}

-(void)findMatchesRightGem:(Gem*)gem index:(int)index
{
  int x = index % (int)self.gridSize.width;
  if (x >= self.gridSize.width-1) return;
  else
  {
    [_tempRun addObject:gem];
    int newIndex = index+1;
    if (newIndex < _gems.count) {
      Gem * newGem = _gems[newIndex];
      if (newGem.color == gem.color)
      {
        [_tempRun addObject:newGem];
        [self findMatchesRightGem:newGem index:newIndex];
      }
    }
  }
}

- (void) addRun:(NSMutableSet*)newRun
{
  [_run addObjectsFromArray:newRun.allObjects];
}

- (void) findRunFromGem:(Gem*)gem index:(int)index
{
  [_tempRun removeAllObjects];
  
  [self findMatchesAboveGem:gem index:index];
  if (_tempRun.count > NUMBER_OF_ORBS_FOR_MATCH-1) [self addRun:_tempRun];
  
  [_tempRun removeAllObjects];
  [self findMatchesBelowGem:gem index:index];
  if (_tempRun.count > NUMBER_OF_ORBS_FOR_MATCH-1) [self addRun:_tempRun];
  
  [_tempRun removeAllObjects];
  [self findMatchesLeftGem:gem index:index];
  if (_tempRun.count > NUMBER_OF_ORBS_FOR_MATCH-1) [self addRun:_tempRun];
  
  [_tempRun removeAllObjects];
  [self findMatchesRightGem:gem index:index];
  if (_tempRun.count > NUMBER_OF_ORBS_FOR_MATCH-1) [self addRun:_tempRun];
}

- (void) clearAndFillBoard
{
  self.oldGems = [self.gems mutableCopy];
  
  // slide down
  NSMutableSet * used = [NSMutableSet set];
  for (int column = 0; column < self.gridSize.width; column ++)
  {
    for (int row = 0; row < self.gridSize.height; row ++)
    {
      int thisIndex = (row*self.gridSize.width)+column;
      Gem * thisGem = _gems[thisIndex];
      for (int newRow = row; newRow < self.gridSize.height; newRow++)
      {
        int newIndex = (newRow*self.gridSize.width)+column;
        Gem * newGem = _gems[newIndex];
        // will swap with itself if not part of the run and nothing below was affected
        if (![_run containsObject:newGem] && ![used containsObject:newGem])
        {
          [used addObject:newGem];
          [_gems replaceObjectAtIndex:thisIndex withObject:newGem];
          [_gems replaceObjectAtIndex:newIndex withObject:thisGem];
          [_oldGems replaceObjectAtIndex:thisIndex withObject:newGem];
          [_oldGems replaceObjectAtIndex:newIndex withObject:thisGem];
          break;
        }
      }
    }
  }
  
  // create array of how many need to be replenished per column
  int numToReplace[(int)self.gridSize.width];
  for (int i = 0; i < self.gridSize.width; i++) numToReplace[i] = 0;
  for (Gem *gem in _run) {
    int index = [_gems indexOfObject:gem];
    int x = index % (int)self.gridSize.width;
    numToReplace[x]++;
  }
  
  // fill spaces
  for (Gem *gem in _run)
  {
    int index = [_gems indexOfObject:gem];
    if (index != NSNotFound) {
      int x = index % (int)self.gridSize.width;
      int y = index / self.gridSize.width;
      int replaceVal = numToReplace[x];
      Gem *newGem = [self createRandomGem];
      newGem.sprite.position = CGPointMake(self.squareSize.width/2+(x*self.squareSize.width), self.contentSize.height+self.squareSize.height*(y-self.gridSize.height+replaceVal+0.5f));
      [self addChild:newGem.sprite z:9];
      [_gems replaceObjectAtIndex:index withObject:newGem];
      [self removeChild:gem.sprite cleanup:YES];
    }
  }
  [self updateGemPositionsAfterSwap];
}

- (ccColor3B) colorForSparkle:(GemColorId)color {
  UIColor *c = [Globals colorForElement:(MonsterProto_MonsterElement)color];
  float r = 1.f, g = 1.f, b = 1.f, a = 1.f;
  [c getRed:&r green:&g blue:&b alpha:&a];
  return ccc3(r*255, g*255, b*255);
}

// Color of gem that destroyed this gem
- (void) destroyGem:(Gem *)gem fromColor:(GemColorId)color fromPowerup:(PowerupId)powerup {
  if (![self.gems containsObject:gem] || [self.destroyedGems containsObject:gem]) {
    return;
  }
  
  _gemsToProcess++;
  CGPoint pt = [self coordinateOfGem:gem];
  // Run is a set so repeats are fine
  [_run addObject:gem];
  [self.destroyedGems addObject:gem];
  [self.reservedGems addObject:gem];
  if (gem.powerup != powerup_none) {
    if (gem.powerup == powerup_horizontal_line || gem.powerup == powerup_vertical_line) {
      if (powerup == powerup_horizontal_line) {
        gem.powerup = powerup_vertical_line;
      } else if (powerup == powerup_vertical_line) {
        gem.powerup = powerup_horizontal_line;
      }
    }
    [self initiatePowerup:gem.powerup atLocation:pt withColor:color];
  }
  
  CCCallBlock *crack = [CCCallBlock actionWithBlock:^{
    if (powerup == powerup_horizontal_line || powerup == powerup_vertical_line) {
      CCParticleSystemQuad *q = [CCParticleSystemQuad particleWithFile:@"molotov.plist"];
      [self addChild:q z:100];
      q.position = gem.sprite.position;
      q.autoRemoveOnFinish = YES;
      
      [[SoundEngine sharedSoundEngine] puzzleBoardExplosion];
    } else if (powerup == powerup_all_of_one_color) {
      CCParticleSystemQuad *q = [CCParticleSystemQuad particleWithFile:@"molotov.plist"];
      [self addChild:q z:100];
      q.position = gem.sprite.position;
      q.autoRemoveOnFinish = YES;
      
      [[SoundEngine sharedSoundEngine] puzzleBoardExplosion];
    } else {
      CCSprite *q = [CCSprite spriteWithFile:@"ring.png"];
      [self addChild:q];
      q.position = gem.sprite.position;
      q.scale = 0.5;
      [q runAction:[CCSequence actions:
                    [CCSpawn actions:[CCFadeOut actionWithDuration:0.2], [CCScaleTo actionWithDuration:0.2 scale:1], nil],
                    [CCCallBlock actionWithBlock:
                     ^{
                       [q removeFromParentAndCleanup:YES];
                     }], nil]];
      
      CCParticleSystemQuad *x = [CCParticleSystemQuad particleWithFile:@"sparkle1.plist"];
      [self addChild:x z:12];
      x.position = gem.sprite.position;
      x.autoRemoveOnFinish = YES;
      x.startColor = ccc4FFromccc3B([self colorForSparkle:gem.color]);
    }
  }];
  
  CCScaleTo *scale = [CCScaleTo actionWithDuration:0.2 scale:0];
  CCCallBlock *completion = [CCCallBlock actionWithBlock:^{
    _gemsToProcess--;
    [self checkAllGemsAndPowerupsDone];
    [gem.sprite removeFromParentAndCleanup:YES];
  }];
  
  CCSequence *sequence = [CCSequence actions:crack, scale, completion, nil];
  [gem.sprite runAction:sequence];
  
  // Create random bezier
  if (gem.color != color_all) {
    ccBezierConfig bez;
    bez.endPosition = self.orbFlyToLocation;
    CGPoint initPoint = gem.sprite.position;
    
    // basePt1 is chosen with any y and x is between some neg num and approx .5
    // basePt2 is chosen with any y and x is anywhere between basePt1's x and .85
    BOOL chooseRight = arc4random()%2;
    CGPoint basePt1 = ccp(drand48()-0.8, drand48());
    CGPoint basePt2 = ccp(basePt1.x+drand48()*(0.7-basePt1.x), drand48());
    
    // outward potential increases based on distance between orbs
    float xScale = ccpDistance(gem.sprite.position, bez.endPosition);
    float yScale = (50+xScale/5)*(chooseRight?-1:1);
    float angle = ccpToAngle(ccpSub(bez.endPosition, initPoint));
    
    // Transforms are applied in reverse order!! So rotate, then scale
    CGAffineTransform t = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), xScale, yScale);
    bez.controlPoint_1 = ccpAdd(initPoint, CGPointApplyAffineTransform(basePt1, t));
    bez.controlPoint_2 = ccpAdd(initPoint, CGPointApplyAffineTransform(basePt2, t));
    
    CCBezierTo *move = [CCBezierTo actionWithDuration:0.25f+xScale/600.f bezier:bez];
    DestroyedGem *dg = [[DestroyedGem alloc] initWithColor:[self colorForSparkle:gem.color]];
    [self addChild:dg z:10];
    dg.position = gem.sprite.position;
    [dg runAction:[CCSequence actions:move,
                   [CCCallBlock actionWithBlock:
                    ^{
                      [self.delegate gemReachedFlyLocation:gem];
                    }],
                   [CCFadeOut actionWithDuration:0.5f],
                   [CCDelayTime actionWithDuration:0.7f],
                   [CCCallFunc actionWithTarget:dg selector:@selector(removeFromParent)], nil]];
  }
  
  [self.delegate gemKilled:gem];
}

- (Gem *) getPowerupGemForBatch:(NSArray *)batch {
  int maxLength = 0;
  BOOL isHorizontal = YES;
  GemColorId color = 0;
  for (Gem *gem in batch) {
    int index = [_gems indexOfObject:gem];
    
    [_tempRun removeAllObjects];
    [self findMatchesBelowGem:gem index:index];
    if (_tempRun.count > maxLength) {
      maxLength = _tempRun.count;
      isHorizontal = NO;
    }
    
    [_tempRun removeAllObjects];
    [self findMatchesRightGem:gem index:index];
    if (_tempRun.count > maxLength) {
      maxLength = _tempRun.count;
      isHorizontal = YES;
    }
    
    if (gem.color != color_all) {
      color = gem.color;
    }
  }
  
  if (batch.count == 4 && maxLength == 4) {
    return [self createGemWithColor:color powerup:isHorizontal ? powerup_vertical_line : powerup_horizontal_line];
  } else if (batch.count > 4) {
    if (maxLength >= 5) {
      return [self createGemWithColor:color_all powerup:powerup_all_of_one_color];
    } else {
      return [self createGemWithColor:color powerup:powerup_explosion];
    }
  }
  return nil;
}

- (void) processBatches:(NSMutableArray*)batches
{
  if (batches.count == 0) return;
  
  NSMutableArray * batch = [batches lastObject];
  Gem *powerupGem = [self getPowerupGemForBatch:batch];
  
  _currentComboCount++;
  int minX = self.gridSize.width, minY = self.gridSize.height, maxX = 0, maxY = 0;
  for (Gem * gem in batch)
  {
    [self destroyGem:gem fromColor:gem.color fromPowerup:powerup_none];
    
    CGPoint coord = [self coordinateOfGem:gem];
    minX = MIN(minX, coord.x);
    minY = MIN(minY, coord.y);
    maxX = MAX(maxX, coord.x+1);
    maxY = MAX(maxY, coord.y+1);
  }
  
  if (powerupGem) {
    // Calculate which position it should go into
    Gem *toReplace = [batch lastObject];
    for (Gem *gem in batch) {
      int index1 = [self.gems indexOfObject:gem];
      int index2 = [self.oldGems indexOfObject:gem];
      
      if (index1 != index2) {
        toReplace = gem;
      }
    }
    
    [_gems replaceObjectAtIndex:[self.gems indexOfObject:toReplace] withObject:powerupGem];
    [self addChild:powerupGem.sprite z:9];
    CGPoint pt = [self coordinateOfGem:powerupGem];
    powerupGem.sprite.position = ccp(self.squareSize.width*(pt.x+0.5), self.squareSize.height*(pt.y+0.5));
    
    [toReplace.sprite removeFromParentAndCleanup:YES];
    
    [powerupGem.sprite runAction:
     [CCSequence actions:
      [CCEaseSineOut actionWithAction:[CCScaleTo actionWithDuration:0.2 scale:1.3]],
      [CCEaseSineIn actionWithAction:[CCScaleTo actionWithDuration:0.2 scale:1]], nil]];
    
    _gemsToProcess--;
  }
  
  [batches removeObject:batch];
  
  [self.delegate newComboFound];
  
  [self processBatches:batches];
}

- (void) checkAllGemsAndPowerupsDone {
  if (_gemsToProcess == 0 && self.powerups.count == 0) {
    [self.destroyedGems removeAllObjects];
    [self.reservedGems removeAllObjects];
    [self clearAndFillBoard];
  }
}

- (void) initiatePowerup:(PowerupId)powerupId atLocation:(CGPoint)location withColor:(GemColorId)color {
  Powerup *p = [[Powerup alloc] init];
  p.powerupId = powerupId;
  p.startLocation = location;
  p.color = color;
  
  if (p.powerupId == powerup_horizontal_line) {
    for (Powerup *p2 in self.powerups) {
      if (p2.powerupId == powerup_horizontal_line && p2.startLocation.y == p.startLocation.y) {
        return;
      }
    }
    
    BOOL leftSideIsLonger = location.x > self.gridSize.width-location.x-1;
    
    CCSprite *r = [CCSprite spriteWithFile:@"rocket.png"];
    r.position = [self pointForGridPosition:p.startLocation];
    [self addChild:r z:10];
    
    CCParticleSystemQuad *q = [CCParticleSystemQuad particleWithFile:@"rockettail.plist"];
    q.position = ccp(0,12);
    [r addChild:q z:-1];
    
    NSMutableArray *seq = [NSMutableArray array];
    for (int i = p.startLocation.x; i < self.gridSize.width; i++) {
      CGPoint pos = ccp(i, p.startLocation.y);
      [seq addObject:[CCMoveTo actionWithDuration:TIME_TO_TRAVEL_PER_SQUARE position:[self pointForGridPosition:pos]]];
      [seq addObject:[CCCallBlock actionWithBlock:^{
        Gem *g = _gems[(int)(pos.x+pos.y*self.gridSize.width)];
        if (![self.reservedGems containsObject:g]) {
          [self destroyGem:g fromColor:color fromPowerup:powerupId];
        }
      }]];
    }
    
    float time = TIME_TO_TRAVEL_PER_SQUARE*(p.startLocation.x+ROCKET_END_LOCATION-self.gridSize.width);
    [seq addObject:[CCSpawn actions:[CCMoveTo actionWithDuration:time position:[self pointForGridPosition:ccp(p.startLocation.x+ROCKET_END_LOCATION, p.startLocation.y)]],
                    [CCFadeOut actionWithDuration:time],
                    [CCCallBlock actionWithBlock:
                     ^{
                       if (!leftSideIsLonger) {
                         [self.powerups removeObject:p];
                         [self checkAllGemsAndPowerupsDone];
                       }
                     }], nil]];
    [seq addObject:[CCCallBlock actionWithBlock:^{
      [r removeFromParentAndCleanup:YES];
    }]];
    
    [r runAction:[CCSequence actionWithArray:seq]];
    
    r = [CCSprite spriteWithFile:@"rocket.png"];
    r.position = [self pointForGridPosition:p.startLocation];
    r.flipX = YES;
    [self addChild:r z:10];
    
    q = [CCParticleSystemQuad particleWithFile:@"rockettail.plist"];
    q.position = ccp(20,12);
    [r addChild:q z:-1];
    
    seq = [NSMutableArray array];
    for (int i = p.startLocation.x; i >= 0; i--) {
      CGPoint pos = ccp(i, p.startLocation.y);
      [seq addObject:[CCMoveTo actionWithDuration:TIME_TO_TRAVEL_PER_SQUARE position:[self pointForGridPosition:pos]]];
      [seq addObject:[CCCallBlock actionWithBlock:^{
        Gem *g = _gems[(int)(pos.x+pos.y*self.gridSize.width)];
        [self destroyGem:g fromColor:color fromPowerup:powerupId];
      }]];
    }
    
    time = TIME_TO_TRAVEL_PER_SQUARE*(p.startLocation.x-ROCKET_END_LOCATION)*-1;
    [seq addObject:[CCSpawn actions:[CCMoveTo actionWithDuration:time position:[self pointForGridPosition:ccp(p.startLocation.x-ROCKET_END_LOCATION, p.startLocation.y)]],
                    [CCFadeOut actionWithDuration:time],
                    [CCCallBlock actionWithBlock:
                     ^{
                       if (leftSideIsLonger) {
                         [self.powerups removeObject:p];
                         [self checkAllGemsAndPowerupsDone];
                       }
                     }], nil]];
    [seq addObject:[CCCallBlock actionWithBlock:^{
      [r removeFromParentAndCleanup:YES];
    }]];
    
    [r runAction:[CCSequence actionWithArray:seq]];
    
    [[SoundEngine sharedSoundEngine] puzzleRocket];
  } else if (p.powerupId == powerup_vertical_line) {
    for (Powerup *p2 in self.powerups) {
      if (p2.powerupId == powerup_vertical_line && p2.startLocation.x == p.startLocation.x) {
        return;
      }
    }
    
    BOOL topSideIsLonger = location.y > self.gridSize.height-location.y-1;
    
    // Have to do this due to rotation issues
    CCSprite *r = [CCSprite spriteWithFile:@"rocket.png"];
    r.opacity = 0;
    r.position = [self pointForGridPosition:p.startLocation];
    [self addChild:r z:10];
    
    CCSprite *n = [CCSprite spriteWithFile:@"rocket.png"];
    n.position = ccp(r.contentSize.width/2, r.contentSize.height/2);
    n.rotation = 90;
    [r addChild:n];
    
    CCParticleSystemQuad *q = [CCParticleSystemQuad particleWithFile:@"rockettail.plist"];
    q.position = ccpAdd(n.position, ccp(0, 10));
    [r addChild:q z:-1];
    
    NSMutableArray *seq = [NSMutableArray array];
    for (int i = p.startLocation.y; i >= 0; i--) {
      CGPoint pos = ccp(p.startLocation.x, i);
      [seq addObject:[CCMoveTo actionWithDuration:TIME_TO_TRAVEL_PER_SQUARE position:[self pointForGridPosition:pos]]];
      [seq addObject:[CCCallBlock actionWithBlock:^{
        Gem *g = _gems[(int)(pos.x+pos.y*self.gridSize.width)];
        if (![self.reservedGems containsObject:g]) {
          [self destroyGem:g fromColor:color fromPowerup:powerupId];
        }
      }]];
    }
    
    float time = TIME_TO_TRAVEL_PER_SQUARE*(p.startLocation.y-ROCKET_END_LOCATION)*-1;
    [seq addObject:[CCSpawn actions:[CCMoveTo actionWithDuration:time position:[self pointForGridPosition:ccp(p.startLocation.x, p.startLocation.y-ROCKET_END_LOCATION)]],
                    [CCCallBlock actionWithBlock:
                     ^{
                       [n runAction:[CCFadeOut actionWithDuration:time]];
                       if (topSideIsLonger) {
                         [self.powerups removeObject:p];
                         [self checkAllGemsAndPowerupsDone];
                       }
                     }], nil]];
    [seq addObject:[CCCallBlock actionWithBlock:^{
      [r removeFromParentAndCleanup:YES];
    }]];
    
    [r runAction:[CCSequence actionWithArray:seq]];
    
    
    r = [CCSprite spriteWithFile:@"rocket.png"];
    r.opacity = 0;
    r.position = [self pointForGridPosition:p.startLocation];
    [self addChild:r z:10];
    
    n = [CCSprite spriteWithFile:@"rocket.png"];
    n.position = ccp(r.contentSize.width/2, r.contentSize.height/2);
    n.rotation = -90;
    [r addChild:n];
    
    q = [CCParticleSystemQuad particleWithFile:@"rockettail.plist"];
    q.position = ccpAdd(n.position, ccp(0, -10));
    [r addChild:q z:-1];
    
    seq = [NSMutableArray array];
    for (int i = p.startLocation.y; i < self.gridSize.height; i++) {
      CGPoint pos = ccp(p.startLocation.x, i);
      [seq addObject:[CCMoveTo actionWithDuration:TIME_TO_TRAVEL_PER_SQUARE position:[self pointForGridPosition:pos]]];
      [seq addObject:[CCCallBlock actionWithBlock:^{
        Gem *g = _gems[(int)(pos.x+pos.y*self.gridSize.width)];
        [self destroyGem:g fromColor:color fromPowerup:powerupId];
      }]];
    }
    
    time = TIME_TO_TRAVEL_PER_SQUARE*(p.startLocation.y+ROCKET_END_LOCATION-self.gridSize.height);
    [seq addObject:[CCSpawn actions:[CCMoveTo actionWithDuration:time position:[self pointForGridPosition:ccp(p.startLocation.x, p.startLocation.y+ROCKET_END_LOCATION)]],
                    [CCCallBlock actionWithBlock:
                     ^{
                       [n runAction:[CCFadeOut actionWithDuration:time]];
                       if (!topSideIsLonger) {
                         [self.powerups removeObject:p];
                         [self checkAllGemsAndPowerupsDone];
                       }
                     }], nil]];
    [seq addObject:[CCCallBlock actionWithBlock:^{
      [r removeFromParentAndCleanup:YES];
    }]];
    
    [r runAction:[CCSequence actionWithArray:seq]];
    
    [[SoundEngine sharedSoundEngine] puzzleRocket];
  } else if (p.powerupId == powerup_explosion) {
    NSMutableArray *blowup = [NSMutableArray array];
    for (Gem *gem in _gems) {
      if ([self gem:gem isInExplosionRangeOfLocation:p.startLocation] && ![self.reservedGems containsObject:gem]) {
        [blowup addObject:gem];
        [self.reservedGems addObject:gem];
      }
    }
    [self runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:0.05],
                     [CCCallBlock actionWithBlock:
                      ^{
                        [self.powerups removeObject:p];
                        for (Gem *gem in blowup) {
                          [self destroyGem:gem fromColor:color fromPowerup:powerupId];
                        }
                        [self checkAllGemsAndPowerupsDone];
                        
                        CCParticleSystemQuad *x = [CCParticleSystemQuad particleWithFile:@"grenade1.plist"];
                        [self addChild:x z:12];
                        x.position = [self pointForGridPosition:p.startLocation];
                        x.autoRemoveOnFinish = YES;
                      }],
                     nil]];
  } else if (p.powerupId == powerup_all_of_one_color) {
    if (p.color == color_all) {
      return;
    }
    
    NSMutableArray *blowup = [NSMutableArray array];
    for (Gem *gem in _gems) {
      if (gem.color == p.color && ![self.reservedGems containsObject:gem]) {
        [blowup addObject:gem];
        [self.reservedGems addObject:gem];
      }
    }
    
    [blowup shuffle];
    
    if (blowup.count > 0) {
      for (int i = 0; i < blowup.count; i++) {
        Gem *gem = [blowup objectAtIndex:i];
        CCParticleSystemQuad *q = [CCParticleSystemQuad particleWithFile:@"rockettail.plist"];
        [self addChild:q z:10];
        q.position = [self pointForGridPosition:p.startLocation];
        
        BOOL last = i == blowup.count-1;
        [q runAction:
         [CCSequence actions:
          [CCDelayTime actionWithDuration:i*0.1],
          [CCMoveTo actionWithDuration:MOLOTOV_PARTICLE_DURATION position:gem.sprite.position],
          [CCCallBlock actionWithBlock:
           ^{
             [q removeFromParentAndCleanup:YES];
             
             [self destroyGem:gem fromColor:color fromPowerup:powerupId];
             
             if (last) {
               [self.powerups removeObject:p];
             }
             
             [self checkAllGemsAndPowerupsDone];
           }],
          nil]];
      }
    } else {
      return;
    }
  }
  
  [self.powerups addObject:p];
  
  [self.delegate newComboFound];
}

- (CGPoint) pointForGridPosition:(CGPoint)pt {
  return ccp(self.squareSize.width*(pt.x+0.5), self.squareSize.height*(pt.y+0.5));
}

- (CGPoint) coordinateOfGem:(Gem *)gem {
  int index = [_gems indexOfObject:gem];
  int x = index % (int)self.gridSize.width;
  int y = index / self.gridSize.width;
  return ccp(x, y);
}

- (BOOL) gem:(Gem *)gem1 isTouchingGem:(Gem *)gem2 {
  CGPoint c1 = [self coordinateOfGem:gem1];
  CGPoint c2 = [self coordinateOfGem:gem2];
  float f = ccpLength(ccpSub(c1, c2));
  return f <= 1;
}

- (BOOL) gem:(Gem *)gem1 isInExplosionRangeOfLocation:(CGPoint)c2 {
  CGPoint c1 = [self coordinateOfGem:gem1];
  float f = ccpLength(ccpSub(c1, c2));
  return f <= 1.5;
}

- (BOOL) checkForPowerupMatch {
  // Check if both were powerups or 1 was a cocktail
  if (_swapGem && _realDragGem.powerup != powerup_none && _swapGem.powerup != powerup_none) {
    // 2 stripes
    if ((_realDragGem.powerup == powerup_horizontal_line || _realDragGem.powerup == powerup_vertical_line) &&
        (_swapGem.powerup == powerup_horizontal_line || _swapGem.powerup == powerup_vertical_line)) {
      _realDragGem.powerup = powerup_none;
      _swapGem.powerup = powerup_none;
      
      [self destroyGem:_realDragGem fromColor:_realDragGem.color fromPowerup:powerup_none];
      [self destroyGem:_swapGem fromColor:_swapGem.color fromPowerup:powerup_none];
      
      CGPoint pt = [self coordinateOfGem:_realDragGem];
      [self initiatePowerup:powerup_horizontal_line atLocation:pt withColor:_realDragGem.color];
      [self initiatePowerup:powerup_vertical_line atLocation:pt withColor:_swapGem.color];
    }
    // stripe and explosion
    else if (((_realDragGem.powerup == powerup_horizontal_line || _realDragGem.powerup == powerup_vertical_line) && _swapGem.powerup == powerup_explosion) ||
             ((_swapGem.powerup == powerup_horizontal_line || _swapGem.powerup == powerup_vertical_line)&& _realDragGem.powerup == powerup_explosion)) {
      PowerupId direction = _realDragGem.powerup == powerup_explosion ? _swapGem.powerup : _realDragGem.powerup;
      
      _realDragGem.powerup = powerup_none;
      _swapGem.powerup = powerup_none;
      
      [self destroyGem:_realDragGem fromColor:_realDragGem.color fromPowerup:powerup_none];
      [self destroyGem:_swapGem fromColor:_swapGem.color fromPowerup:powerup_none];
      
      CGPoint pt = [self coordinateOfGem:_realDragGem];
      CGPoint pt2;
      if (direction == powerup_horizontal_line) {
        [self initiatePowerup:powerup_horizontal_line atLocation:pt withColor:_realDragGem.color];
        
        pt2 = ccp(pt.x, pt.y-1);
        if (CGRectContainsPoint(CGRectMake(0, 0, self.gridSize.width, self.gridSize.height), pt2)) {
          [self initiatePowerup:powerup_horizontal_line atLocation:pt2 withColor:_swapGem.color];
        }
        
        pt2 = ccp(pt.x, pt.y+1);
        if (CGRectContainsPoint(CGRectMake(0, 0, self.gridSize.width, self.gridSize.height), pt2)) {
          [self initiatePowerup:powerup_horizontal_line atLocation:pt2 withColor:_swapGem.color];
        }
      } else {
        [self initiatePowerup:powerup_vertical_line atLocation:pt withColor:_swapGem.color];
        
        pt2 = ccp(pt.x-1, pt.y);
        if (CGRectContainsPoint(CGRectMake(0, 0, self.gridSize.width, self.gridSize.height), pt2)) {
          [self initiatePowerup:powerup_vertical_line atLocation:pt2 withColor:_swapGem.color];
        }
        
        pt2 = ccp(pt.x+1, pt.y);
        if (CGRectContainsPoint(CGRectMake(0, 0, self.gridSize.width, self.gridSize.height), pt2)) {
          [self initiatePowerup:powerup_vertical_line atLocation:pt2 withColor:_swapGem.color];
        }
      }
    }
    // stripe and cocktail
    else if (((_realDragGem.powerup == powerup_horizontal_line || _realDragGem.powerup == powerup_vertical_line) && _swapGem.powerup == powerup_all_of_one_color) ||
             ((_swapGem.powerup == powerup_horizontal_line || _swapGem.powerup == powerup_vertical_line)&& _realDragGem.powerup == powerup_all_of_one_color)) {
      GemColorId color = _realDragGem.powerup == powerup_all_of_one_color ? _swapGem.color : _realDragGem.color;
      
      Powerup *p = [[Powerup alloc] init];
      [self.powerups addObject:p];
      
      for (Gem *gem in _gems) {
        if (gem.color == color) {
          CCParticleSystemQuad *q = [CCParticleSystemQuad particleWithFile:@"rockettail.plist"];
          [self addChild:q z:10];
          q.position = _realDragGem.sprite.position;
          [q runAction:[CCMoveTo actionWithDuration:MOLOTOV_PARTICLE_DURATION position:gem.sprite.position]];
          q.duration = MOLOTOV_PARTICLE_DURATION;
          q.autoRemoveOnFinish = YES;
        }
      }
      
      // First action just delays everything, then we replace and fire off rockets
      NSMutableArray *seq = [NSMutableArray array];
      [seq addObject:[CCDelayTime actionWithDuration:MOLOTOV_PARTICLE_DURATION-0.1]];
      [seq addObject:[CCCallBlock actionWithBlock:^{
        NSMutableSet *colorGems = [NSMutableSet set];
        for (int i = 0; i < self.gems.count; i++) {
          Gem *gem = [self.gems objectAtIndex:i];
          if (gem.color == color) {
            Gem *newGem = [self createGemWithColor:color powerup:arc4random() % 2 == 0 ? powerup_horizontal_line : powerup_vertical_line];
            [self.gems replaceObjectAtIndex:[self.gems indexOfObject:gem] withObject:newGem];
            newGem.sprite.position = [self pointForGridPosition:[self coordinateOfGem:newGem]];
            [gem.sprite removeFromParentAndCleanup:YES];
            [self addChild:newGem.sprite z:9];
            
            [colorGems addObject:newGem];
          }
        }
        
        NSMutableArray *seq = [NSMutableArray array];
        [seq addObject:[CCDelayTime actionWithDuration:0.2]];
        for (Gem *gem in colorGems) {
          [seq addObject:[CCDelayTime actionWithDuration:0.2]];
          [seq addObject:[CCCallBlock actionWithBlock:^{
            [self destroyGem:gem fromColor:gem.color fromPowerup:powerup_none];
          }]];
        }
        [seq addObject:[CCCallBlock actionWithBlock:^{
          [self.powerups removeObject:p];
          [self checkAllGemsAndPowerupsDone];
        }]];
        [self runAction:[CCSequence actionWithArray:seq]];
      }]];
      [self runAction:[CCSequence actionWithArray:seq]];
      
      _realDragGem.powerup = powerup_none;
      _swapGem.powerup = powerup_none;
      [self destroyGem:_realDragGem fromColor:color_all fromPowerup:powerup_none];
      [self destroyGem:_swapGem fromColor:color_all fromPowerup:powerup_none];
    }
    // 2 explosions
    else if (_realDragGem.powerup == powerup_explosion && _swapGem.powerup == powerup_explosion) {
      _realDragGem.powerup = powerup_none;
      _swapGem.powerup = powerup_none;
      
      [self destroyGem:_realDragGem fromColor:_realDragGem.color fromPowerup:powerup_explosion];
      [self destroyGem:_swapGem fromColor:_swapGem.color fromPowerup:powerup_explosion];
      
      CGPoint pt = [self coordinateOfGem:_realDragGem];
      CGPoint pt2;
      
      pt2 = ccp(pt.x, pt.y-1);
      [self initiatePowerup:powerup_explosion atLocation:pt2 withColor:_realDragGem.color];
      
      pt2 = ccp(pt.x, pt.y+1);
      [self initiatePowerup:powerup_explosion atLocation:pt2 withColor:_realDragGem.color];
      
      pt2 = ccp(pt.x-1, pt.y);
      [self initiatePowerup:powerup_explosion atLocation:pt2 withColor:_realDragGem.color];
      
      pt2 = ccp(pt.x+1, pt.y);
      [self initiatePowerup:powerup_explosion atLocation:pt2 withColor:_realDragGem.color];
    }
    // 2 cocktails
    else if (_realDragGem.powerup == powerup_all_of_one_color && _swapGem.powerup == powerup_all_of_one_color) {
      NSMutableArray *seq = [NSMutableArray array];
      for (int i = 0; i < self.gridSize.width; i++) {
        for (int j = 0; j < self.gridSize.height; j++) {
          [seq addObject:[CCCallBlock actionWithBlock:^{
            Gem *g = _gems[(int)(i+j*self.gridSize.width)];
            g.powerup = powerup_none;
            [self destroyGem:g fromColor:g.color fromPowerup:powerup_all_of_one_color];
          }]];
          [seq addObject:[CCDelayTime actionWithDuration:0.08]];
        }
      }
      Powerup *p = [[Powerup alloc] init];
      [self.powerups addObject:p];
      [seq addObject:[CCCallBlock actionWithBlock:^{
        [self.powerups removeObject:p];
        [self checkAllGemsAndPowerupsDone];
      }]];
      [self runAction:[CCSequence actionWithArray:seq]];
    }
    _foundMatch = YES;
    return YES;
  } else if (_swapGem && (_realDragGem.powerup == powerup_all_of_one_color || _swapGem.powerup == powerup_all_of_one_color)) {
    Gem *powerupGem = nil;
    Gem *colorGem = nil;
    if (_realDragGem.powerup == powerup_all_of_one_color) {
      powerupGem = _realDragGem;
      colorGem = _swapGem;
    } else {
      powerupGem = _swapGem;
      colorGem = _realDragGem;
    }
    
    powerupGem.color = colorGem.color;
    [self destroyGem:powerupGem fromColor:colorGem.color fromPowerup:powerup_none];
    _foundMatch = YES;
    return YES;
  }
  return NO;
}

- (void) turnEnd
{
  _allowInput = NO;
  
  BOOL foundPowerup = [self checkForPowerupMatch];
  
  if (!foundPowerup) {
    [self createRunForCurrentBoard];
    if ( _run.count > 0) {
      _foundMatch = YES;
      
      // Delegate method refers to orbs beginning to combo
      [self.delegate moveBegan];
      
      NSMutableSet *s = [_run mutableCopy];
      
      NSMutableArray * batches = [NSMutableArray array];
      while (s.count > 0)
      {
        Gem *gem = [s anyObject];
        NSMutableArray * batch = [NSMutableArray array];
        [batch addObject:gem];
        [s removeObject:gem];
        
        BOOL foundGem = YES;
        while (foundGem) {
          foundGem = NO;
          for (Gem * g in [s copy])
          {
            for (Gem *g2 in [batch copy]) {
              if (g.color == g2.color && [self gem:g isTouchingGem:g2])
              {
                [batch addObject:g];
                [s removeObject:g];
                foundGem = YES;
              }
            }
          }
        }
        
        if (batch.count > NUMBER_OF_ORBS_FOR_MATCH-1)
          [batches addObject:batch];
        else {
          NSLog(@"ERROR: found run with no batch..");
          break;
        }
      }
      
      [self processBatches:batches];
    } else {
      if (!_foundMatch && _swapGem) {
        Gem *realDragGem = _realDragGem;
        Gem *swapGem = _swapGem;
        
        [self doGemSwapAnimationWithGem:realDragGem andGem:swapGem];
        int idxA = [_gems indexOfObject:swapGem];
        int idxB = [_gems indexOfObject:realDragGem];
        [_gems replaceObjectAtIndex:idxA withObject:realDragGem];
        [_gems replaceObjectAtIndex:idxB withObject:swapGem];
        
        [[SoundEngine sharedSoundEngine] puzzleWrongMove];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ORB_ANIMATION_TIME * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
          [self.delegate moveComplete];
        });
      } else {
        [self.delegate moveComplete];
      }
    }
  } else {
    // Delegate method refers to orbs beginning to combo
    [self.delegate moveBegan];
    
    [self checkAllGemsAndPowerupsDone];
  }
}

- (void) updateGemPositionsAfterSwap
{
  CGSize squareSize = self.squareSize;
  
  float startY = squareSize.height/2;
  float startX = squareSize.width/2;
  
  for (int y = 0; y < self.gridSize.height; y++)
  {
    for (int x = 0; x < self.gridSize.width; x++)
    {
      int idx = x+(y*self.gridSize.width);
      Gem *container = _gems[idx];
      if (container.sprite.position.x != startX || container.sprite.position.y != startY)
      {
        _gemsBouncing++;
        int numSquares = (container.sprite.position.y - startY) / squareSize.height;
        //        [container.sprite stopAllActions];
        CCMoveTo * moveTo = [CCMoveTo actionWithDuration:0.4+0.1*numSquares position:CGPointMake(startX, startY)];
        [container.sprite runAction:[CCSequence actions:
                                     [CCEaseBounceOut actionWithAction:moveTo],
                                     [CCCallBlock actionWithBlock:
                                      ^{
                                        _gemsBouncing--;
                                        if (_gemsBouncing == 0) {
                                          [self turnEnd];
                                        }
                                      }], nil]];
      }
      startX += squareSize.width;
    }
    startY += squareSize.height;
    startX = squareSize.width/2;
  }
  
  if (_gemsBouncing == 0) {
    _allowInput = YES;
  }
}

- (void) doGemSwapAnimationWithGem:(Gem *)gem1 andGem:(Gem *)gem2 {
  // Make sure it starts in correct place
  int index1 = [_gems indexOfObject:gem1];
  int index2 = [_gems indexOfObject:gem2];
  CGPoint sq1 = ccp(0.5+(index1 % (int)self.gridSize.width), 0.5+(index1 / (int)self.gridSize.width));
  CGPoint sq2 = ccp(0.5+(index2 % (int)self.gridSize.width), 0.5+(index2 / (int)self.gridSize.width));
  CGPoint gem1Pos = ccp(sq1.x*self.squareSize.width, sq1.y*self.squareSize.height);
  CGPoint gem2Pos = ccp(sq2.x*self.squareSize.width, sq2.y*self.squareSize.height);
  [gem1.sprite stopAllActions];
  [gem2.sprite stopAllActions];
  gem1.sprite.position = gem1Pos;
  gem2.sprite.position = gem2Pos;
  
  ccBezierConfig bezier1;
  ccBezierConfig bezier2;
  
  float yDiff = gem1Pos.y-gem2Pos.y;
  
  if (yDiff == 0) {
    bezier1.controlPoint_1 = ccp(gem1Pos.x + (gem2Pos.x-gem1Pos.x)/3, gem1Pos.y+ORB_ANIMATION_OFFSET);
    bezier1.controlPoint_2 = ccp(gem1Pos.x + (gem2Pos.x-gem1Pos.x)*2/3, gem1Pos.y+ORB_ANIMATION_OFFSET);
    
    bezier2.controlPoint_1 = ccp(gem2Pos.x + (gem1Pos.x-gem2Pos.x)/3, gem2Pos.y-ORB_ANIMATION_OFFSET);
    bezier2.controlPoint_2 = ccp(gem2Pos.x + (gem1Pos.x-gem2Pos.x)*2/3, gem2Pos.y-ORB_ANIMATION_OFFSET);
  } else {
    bezier1.controlPoint_1 = ccp(gem1Pos.x+ORB_ANIMATION_OFFSET, gem1Pos.y + (gem2Pos.y-gem1Pos.y)/3);
    bezier1.controlPoint_2 = ccp(gem1Pos.x+ORB_ANIMATION_OFFSET, gem1Pos.y + (gem2Pos.y-gem1Pos.y)*2/3);
    
    bezier2.controlPoint_1 = ccp(gem2Pos.x-ORB_ANIMATION_OFFSET, gem2Pos.y + (gem1Pos.y-gem2Pos.y)/3);
    bezier2.controlPoint_2 = ccp(gem2Pos.x-ORB_ANIMATION_OFFSET, gem2Pos.y + (gem1Pos.y-gem2Pos.y)*2/3);
  }
  
  
  // Not using bezier but keep for future use?
  bezier1.endPosition = gem2Pos;
  id move1 = [CCMoveTo actionWithDuration:ORB_ANIMATION_TIME position:gem2.sprite.position];
  [gem1.sprite runAction:move1];
  
  bezier2.endPosition = gem1Pos;
  id move2 = [CCMoveTo actionWithDuration:ORB_ANIMATION_TIME position:gem1.sprite.position];
  [gem2.sprite runAction:move2];
}

- (void) allowInput {
  if (![self validMoveExists]) {
    [self reshuffle];
  }
  
  _allowInput = YES;
}

- (void) disallowInput {
  _allowInput = NO;
}

#pragma mark touch handling

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  if (!_allowInput) return NO;
  
  CGPoint location = [self convertTouchToNodeSpace: touch];
  if (![self isPointInArea:[self convertToWorldSpace:location]]) return NO;
  CGPoint square = ccp((int)(location.x/self.squareSize.width), (int)(location.y/self.squareSize.height));
  if (square.x > self.gridSize.width-1 || square.y > self.gridSize.height-1) {
    return NO;
  }
  
  _lastGridPt = square;
  
  int index = square.x+square.y*self.gridSize.width;
  if (_gems.count > index && index >= 0) {
    Gem *container = _gems[index];
    
    if (!_dragGem) {
      _dragGem = [self createGemWithColor:container.color powerup:container.powerup];
      if (_dragGem.sprite) {
        _dragGem.sprite.opacity = 0;
        [_dragGem.sprite setPosition:location];
        [self addChild:_dragGem.sprite z:10];
      }
      
      _realDragGem = container;
      container.sprite.opacity = 128;
      [_dragGem.sprite.parent reorderChild:_dragGem.sprite z:10];
      
      _beganTimer = NO;
      
      self.oldGems = [self.gems copy];
      
      self.isTrackingTouch = YES;
      
      return YES;
    }
  }
  
  return NO;
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
  if (!_allowInput) return;
  
  if (_dragGem) {
    CGPoint location = [self convertTouchToNodeSpace: touch];
    [_dragGem.sprite setPosition:location];
    _swapGem = nil;
    
    CGPoint pt1 = ccp(location.x/self.squareSize.width, location.y/self.squareSize.height);
    CGPoint pt = ccp(clampf(floorf(pt1.x), 0, self.gridSize.width-1), clampf(floorf(pt1.y), 0, self.gridSize.height-1));
    
    pt = ccp(clampf(pt.x, _lastGridPt.x-1, _lastGridPt.x+1), clampf(pt.y, _lastGridPt.y-1, _lastGridPt.y+1));
    
    // Don't allow diagonals
    CGPoint origPt = [self coordinateOfGem:_realDragGem];
    if (pt.x != origPt.x && pt.y != origPt.y) {
      float xDist = abs(pt1.x-origPt.x);
      float yDist = abs(pt1.y-origPt.y);
      if (xDist > yDist) {
        pt = ccp(pt.x, origPt.y);
      } else {
        pt = ccp(origPt.x, pt.y);
      }
    }
    
    _lastGridPt = pt;
    
    int idx = pt.x+pt.y*self.gridSize.width;
    
    if (_gems.count > idx) {
      Gem *potential = _gems[idx];
      
      if (potential != _realDragGem) {
        _swapGem = potential;
      }
    }
    
    if (_swapGem) {
      [self doGemSwapAnimationWithGem:_realDragGem andGem:_swapGem];
      int idxA = [_gems indexOfObject:_swapGem];
      int idxB = [_gems indexOfObject:_realDragGem];
      [_gems replaceObjectAtIndex:idxA withObject:_realDragGem];
      [_gems replaceObjectAtIndex:idxB withObject:_swapGem];
      
      //      if (!_beganTimer) {
      //        _beganTimer = YES;
      //        [self schedule:@selector(timedOut) interval:TIME_LIMIT];
      //      }
      
      [self timedOut];
    }
  }
}

- (void) timedOut {
  [self ccTouchEnded:nil withEvent:nil];
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  if (_realDragGem) {
    [self unschedule:@selector(timedOut)];
    [self removeChild:_dragGem.sprite cleanup:YES];
    
    _allowInput = NO;
    _realDragGem.sprite.opacity = 255.0;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ORB_ANIMATION_TIME * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      if (_realDragGem) {
        _currentComboCount = 0;
        _foundMatch = NO;
        
        [self turnEnd];
        
        _realDragGem = nil;
        _dragGem = nil;
        _swapGem = nil;
        
        self.isTrackingTouch = NO;
      }
    });
  }
}

- (void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
  [self ccTouchEnded:touch withEvent:event];
}

@end
