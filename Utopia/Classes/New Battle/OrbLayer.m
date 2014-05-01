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
#import "CCTextureCache.h"

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

- (id) initWithColor:(CCColor *)color {
  if ((self = [super initWithImageNamed:@"orbball.png"])) {
    self.color = color;
    
    self.streak = [CCMotionStreak streakWithFade:0.5 minSeg:0.1f width:8 color:color textureFilename:@"streak.png"];
  }
  return self;
}

- (void) setParent:(CCNode *)parent {
  [super setParent:parent];
  if (parent && !self.streak.parent) {
    [self.parent addChild:self.streak z:self.zOrder];
  }
}

- (void) update:(CCTime)delta {
	[self.streak setPosition:self.position];
}

- (void) dealloc {
  [self.streak removeFromParent];
}

@end

@implementation OrbLayer

@synthesize allowsInput = _allowInput;

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
    
    self.userInteractionEnabled = YES;
    
    [self initBoard];
	}
	
	return self;
}

- (CGSize) squareSize {
  return CGSizeMake(_contentSize.width/_gridSize.width, _contentSize.height/_gridSize.height);
}

- (NSString *) gemSpriteImageNameWithColor:(GemColorId)gemColor powerup:(PowerupId)powerupId
{
  NSString *colorPrefix = @"";
  switch (gemColor) {
    case color_purple:
    case color_white:
    case color_red:
    case color_green:
    case color_blue:
    case color_filler:
      colorPrefix = [Globals imageNameForElement:(MonsterProto_MonsterElement)gemColor suffix:@""];
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
  
  return [NSString stringWithFormat:@"%@%@.png", colorPrefix, powerupSuffix];
}

- (Gem *) createRandomGemForPosition:(CGPoint)pt {
  int gemColor = (arc4random() % _numColors) + color_red;
  return [self createGemWithColor:gemColor powerup:powerup_none];
}

- (Gem *) createGemWithColor:(GemColorId)gemColor powerup:(PowerupId)powerupId {
  CCSprite * gem = [CCSprite spriteWithImageNamed:[self gemSpriteImageNameWithColor:gemColor powerup:powerupId]];
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

- (void) initBoard {
  // Cleanup first
  for (Gem *gem in self.gems) {
    [gem.sprite removeFromParent];
  }
  
  CGSize gs = [self gridSize];
  self.gems = [[NSMutableArray alloc] init];
  for (int i = 0; i < gs.width*gs.height; i++) {
    BOOL gemOkay = NO;
    while (!gemOkay) {
      int x = i % (int)self.gridSize.width;
      int y = i / self.gridSize.width;
      [_gems addObject:[self createRandomGemForPosition:ccp(x, y)]];
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
  return [self getValidMove].count > 0;
}

- (NSSet *) getValidMove {
  // Choose random corner and direction
  BOOL flipX = arc4random() % 2 == 0;
  BOOL flipY = arc4random() % 2 == 0;
  
  for (int a = 0; a < self.gridSize.width; a++) {
    for (int b = 0; b < self.gridSize.height; b++) {
      int x = flipX ? self.gridSize.width-a-1 : a;
      int y = flipY ? self.gridSize.height-b-1 : b;
      
      int idx = x+(y*self.gridSize.width);
      Gem *gem = self.gems[idx];
      NSMutableArray *toCheck = [NSMutableArray array];
      
      // If it is a molotov, return true
      if (gem.powerup == powerup_all_of_one_color) {
        NSMutableSet *set = [NSMutableSet set];
        [set addObject:gem];
        
        if (x < self.gridSize.width) {
          [set addObject:self.gems[idx+1]];
        } else {
          [set addObject:self.gems[idx-1]];
        }
        
        return set;
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
          NSMutableSet *set = [NSMutableSet set];
          [set addObject:gem];
          [set addObject:checkGem];
          return set;
        }
        
        // Swap and see if run exists
        CGPoint checkCoord = [self coordinateOfGem:checkGem];
        int checkIndex = checkCoord.x+(checkCoord.y*self.gridSize.width);
        [self.gems replaceObjectAtIndex:checkIndex withObject:gem];
        [self.gems replaceObjectAtIndex:idx withObject:checkGem];
        
        [self createRunForCurrentBoard];
        
        NSSet *set = nil;
        if (_run.count > 0) {
          NSMutableArray *batches = [self createBatchesFromRun];
          for (NSMutableArray *batch in batches) {
            if ([batch containsObject:gem] || [batch containsObject:checkGem]) {
              set = [NSSet setWithArray:batch];
              break;
            }
          }
          
          // In case there's a match that really wasn't caused by this swap..
          if (!set) {
            set = [NSSet setWithArray:batches[0]];
          }
        }
        
        // Swap them back
        [self.gems replaceObjectAtIndex:idx withObject:gem];
        [self.gems replaceObjectAtIndex:checkIndex withObject:checkGem];
        
        if (set) {
          return set;
        }
      }
    }
  }
  
  return nil;
}

- (int) createRunForCurrentBoard {
  [_run removeAllObjects];
  for (int i = 0; i < self.gems.count; i++) {
    Gem *gem = _gems[i];
    if (gem.color != color_all) {
      [self findRunFromGem:_gems[i] index:i];
    }
  }
  return (int)_run.count;
}

- (void) reshuffle {
  LNLog(@"Reshuffling...");
  
  [self.gems shuffle];
  while (![self validMoveExists] || [self createRunForCurrentBoard] > 0) {
    [self.gems shuffle];
  }
  
  for (Gem *gem in self.gems) {
    [gem.sprite runAction:[CCActionMoveTo actionWithDuration:0.3 position:[self pointForGridPosition:[self coordinateOfGem:gem]]]];
  }
  
  [self.delegate reshuffle];
}

#pragma mark gameplay

- (void) findMatchesAboveGem:(Gem *)gem index:(NSInteger)index {
  int y = index / self.gridSize.width;
  if (y <= 0) return;
  else
  {
    [_tempRun addObject:gem];
    NSInteger newIndex = index-self.gridSize.width;
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

- (void) findMatchesBelowGem:(Gem *)gem index:(NSInteger)index {
  int y = index / self.gridSize.width;
  if (y >= self.gridSize.height-1) return;
  else
  {
    [_tempRun addObject:gem];
    NSInteger newIndex = index+self.gridSize.width;
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

- (void) findMatchesLeftGem:(Gem *)gem index:(NSInteger)index
{
  int x = index % (int)self.gridSize.width;
  if (x <= 0) return;
  else
  {
    [_tempRun addObject:gem];
    NSInteger newIndex = index-1;
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

- (void) findMatchesRightGem:(Gem *)gem index:(NSInteger)index
{
  int x = index % (int)self.gridSize.width;
  if (x >= self.gridSize.width-1) return;
  else
  {
    [_tempRun addObject:gem];
    NSInteger newIndex = index+1;
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
  for (int column = 0; column < self.gridSize.width; column ++) {
    for (int row = 0; row < self.gridSize.height; row ++) {
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
    int index = (int)[_gems indexOfObject:gem];
    int x = index % (int)self.gridSize.width;
    numToReplace[x]++;
  }
  
  // fill spaces
  for (int x = 0; x < self.gridSize.width; x ++) {
    for (int y = 0; y < self.gridSize.height; y ++) {
      int thisIndex = (y*self.gridSize.width)+x;
      Gem *gem = _gems[thisIndex];
      if ([_run containsObject:gem]) {
        int replaceVal = numToReplace[x];
        Gem *newGem = [self createRandomGemForPosition:ccp(x, y)];
        newGem.sprite.position = CGPointMake(self.squareSize.width/2+(x*self.squareSize.width), self.contentSize.height+self.squareSize.height*(y-self.gridSize.height+replaceVal+0.5f));
        [self addChild:newGem.sprite z:9];
        [_gems replaceObjectAtIndex:thisIndex withObject:newGem];
        [gem.sprite removeFromParent];
      }
    }
  }
  [self updateGemPositionsAfterSwap];
  
  [SoundEngine puzzlePiecesDrop];
}

- (CCColor *) colorForSparkle:(GemColorId)color {
  UIColor *c = [Globals colorForElementOnDarkBackground:(MonsterProto_MonsterElement)color];
  CGFloat r = 1.f, g = 1.f, b = 1.f, a = 1.f;
  [c getRed:&r green:&g blue:&b alpha:&a];
  return [CCColor colorWithCcColor3b:ccc3(r*255, g*255, b*255)];
}

// Color and powerup of gem that destroyed this gem
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
  
  CCActionCallBlock *crack = [CCActionCallBlock actionWithBlock:^{
    if (powerup == powerup_horizontal_line || powerup == powerup_vertical_line) {
      CCParticleSystem *q = [CCParticleSystem particleWithFile:@"molotov.plist"];
      [self addChild:q z:100];
      q.position = gem.sprite.position;
      q.autoRemoveOnFinish = YES;
      
      [SoundEngine puzzleBoardExplosion];
    } else if (powerup == powerup_all_of_one_color) {
      CCParticleSystem *q = [CCParticleSystem particleWithFile:@"molotov.plist"];
      [self addChild:q z:100];
      q.position = gem.sprite.position;
      q.autoRemoveOnFinish = YES;
      
      [SoundEngine puzzleBoardExplosion];
    } else {
      CCSprite *q = [CCSprite spriteWithImageNamed:@"ring.png"];
      [self addChild:q];
      q.position = gem.sprite.position;
      q.scale = 0.5;
      [q runAction:[CCActionSequence actions:
                    [CCActionSpawn actions:[CCActionFadeOut actionWithDuration:0.2], [CCActionScaleTo actionWithDuration:0.2 scale:1], nil],
                    [CCActionCallBlock actionWithBlock:
                     ^{
                       [q removeFromParentAndCleanup:YES];
                     }], nil]];
      
      CCParticleSystem *x = [CCParticleSystem particleWithFile:@"sparkle1.plist"];
      [self addChild:x z:12];
      x.position = gem.sprite.position;
      x.autoRemoveOnFinish = YES;
      x.startColor = [self colorForSparkle:gem.color];
    }
  }];
  
  CCActionScaleTo *scale = [CCActionScaleTo actionWithDuration:0.2 scale:0];
  CCActionCallBlock *completion = [CCActionCallBlock actionWithBlock:^{
    _gemsToProcess--;
    [self checkAllGemsAndPowerupsDone];
    [gem.sprite removeFromParentAndCleanup:YES];
  }];
  
  CCActionSequence *sequence = [CCActionSequence actions:crack, scale, completion, nil];
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
    
    CCActionBezierTo *move = [CCActionBezierTo actionWithDuration:0.25f+xScale/600.f bezier:bez];
    DestroyedGem *dg = [[DestroyedGem alloc] initWithColor:[self colorForSparkle:gem.color]];
    [self addChild:dg z:10];
    dg.position = gem.sprite.position;
    [dg runAction:[CCActionSequence actions:move,
                   [CCActionCallBlock actionWithBlock:
                    ^{
                      [self.delegate gemReachedFlyLocation:gem];
                    }],
                   [CCActionFadeOut actionWithDuration:0.5f],
                   [CCActionDelay actionWithDuration:0.7f],
                   [CCActionCallFunc actionWithTarget:dg selector:@selector(removeFromParent)], nil]];
  }
  
  [self.delegate gemKilled:gem];
}

- (Gem *) getPowerupGemForBatch:(NSArray *)batch {
  NSInteger maxLength = 0;
  BOOL isHorizontal = YES;
  GemColorId color = 0;
  for (Gem *gem in batch) {
    NSInteger index = [_gems indexOfObject:gem];
    
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
  
  Gem *gem = nil;
  if (batch.count == 4 && maxLength == 4) {
    gem = [self createGemWithColor:color powerup:isHorizontal ? powerup_vertical_line : powerup_horizontal_line];
  } else if (batch.count > 4) {
    if (maxLength >= 5) {
      gem = [self createGemWithColor:color_all powerup:powerup_all_of_one_color];
    } else {
      gem = [self createGemWithColor:color powerup:powerup_explosion];
    }
  }
  if (gem) [self.delegate powerupCreated:gem];
  return gem;
}

- (void) processBatches:(NSMutableArray*)batches
{
  if (batches.count == 0) return;
  
  NSMutableArray * batch = [batches lastObject];
  Gem *powerupGem = [self getPowerupGemForBatch:batch];
  
  for (Gem * gem in batch)
  {
    [self destroyGem:gem fromColor:gem.color fromPowerup:powerup_none];
  }
  
  if (powerupGem) {
    // Calculate which position it should go into
    Gem *toReplace = [batch lastObject];
    for (Gem *gem in batch) {
      NSInteger index1 = [self.gems indexOfObject:gem];
      NSInteger index2 = [self.oldGems indexOfObject:gem];
      
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
     [CCActionSequence actions:
      [CCActionEaseOut actionWithAction:[CCActionScaleTo actionWithDuration:0.2 scale:1.3]],
      [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:0.2 scale:1]], nil]];
    
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
    
    CCSprite *r = [CCSprite spriteWithImageNamed:@"rocket.png"];
    r.position = [self pointForGridPosition:p.startLocation];
    [self addChild:r z:10];
    
    CCParticleSystem *q = [CCParticleSystem particleWithFile:@"rockettail.plist"];
    q.position = ccp(0,12);
    [r addChild:q z:-1];
    
    NSMutableArray *seq = [NSMutableArray array];
    for (int i = p.startLocation.x; i < self.gridSize.width; i++) {
      CGPoint pos = ccp(i, p.startLocation.y);
      Gem *g = _gems[(int)(pos.x+pos.y*self.gridSize.width)];
      [seq addObject:[CCActionMoveTo actionWithDuration:TIME_TO_TRAVEL_PER_SQUARE position:[self pointForGridPosition:pos]]];
      [seq addObject:[CCActionCallBlock actionWithBlock:^{
        if (![self.reservedGems containsObject:g]) {
          [self destroyGem:g fromColor:color fromPowerup:powerupId];
        }
      }]];
    }
    
    float time = TIME_TO_TRAVEL_PER_SQUARE*(p.startLocation.x+ROCKET_END_LOCATION-self.gridSize.width);
    [seq addObject:[CCActionSpawn actions:[CCActionMoveTo actionWithDuration:time position:[self pointForGridPosition:ccp(p.startLocation.x+ROCKET_END_LOCATION, p.startLocation.y)]],
                    [CCActionFadeOut actionWithDuration:time],
                    [CCActionCallBlock actionWithBlock:
                     ^{
                       if (!leftSideIsLonger) {
                         [self.powerups removeObject:p];
                         [self checkAllGemsAndPowerupsDone];
                       }
                     }], nil]];
    [seq addObject:[CCActionCallBlock actionWithBlock:^{
      [r removeFromParentAndCleanup:YES];
    }]];
    
    [r runAction:[CCActionSequence actionWithArray:seq]];
    
    r = [CCSprite spriteWithImageNamed:@"rocket.png"];
    r.position = [self pointForGridPosition:p.startLocation];
    r.flipX = YES;
    [self addChild:r z:10];
    
    q = [CCParticleSystem particleWithFile:@"rockettail.plist"];
    q.position = ccp(20,12);
    [r addChild:q z:-1];
    
    seq = [NSMutableArray array];
    for (int i = p.startLocation.x; i >= 0; i--) {
      CGPoint pos = ccp(i, p.startLocation.y);
      Gem *g = _gems[(int)(pos.x+pos.y*self.gridSize.width)];
      [seq addObject:[CCActionMoveTo actionWithDuration:TIME_TO_TRAVEL_PER_SQUARE position:[self pointForGridPosition:pos]]];
      [seq addObject:[CCActionCallBlock actionWithBlock:^{
        if (![self.reservedGems containsObject:g]) {
          [self destroyGem:g fromColor:color fromPowerup:powerupId];
        }
      }]];
    }
    
    time = TIME_TO_TRAVEL_PER_SQUARE*(p.startLocation.x-ROCKET_END_LOCATION)*-1;
    [seq addObject:[CCActionSpawn actions:[CCActionMoveTo actionWithDuration:time position:[self pointForGridPosition:ccp(p.startLocation.x-ROCKET_END_LOCATION, p.startLocation.y)]],
                    [CCActionFadeOut actionWithDuration:time],
                    [CCActionCallBlock actionWithBlock:
                     ^{
                       if (leftSideIsLonger) {
                         [self.powerups removeObject:p];
                         [self checkAllGemsAndPowerupsDone];
                       }
                     }], nil]];
    [seq addObject:[CCActionCallBlock actionWithBlock:^{
      [r removeFromParentAndCleanup:YES];
    }]];
    
    [r runAction:[CCActionSequence actionWithArray:seq]];
    
    [SoundEngine puzzleRocketMatch];
  } else if (p.powerupId == powerup_vertical_line) {
    for (Powerup *p2 in self.powerups) {
      if (p2.powerupId == powerup_vertical_line && p2.startLocation.x == p.startLocation.x) {
        return;
      }
    }
    
    BOOL topSideIsLonger = location.y > self.gridSize.height-location.y-1;
    
    // Have to do this due to rotation issues
    CCSprite *r = [CCSprite spriteWithImageNamed:@"rocket.png"];
    r.opacity = 0;
    r.position = [self pointForGridPosition:p.startLocation];
    [self addChild:r z:10];
    
    CCSprite *n = [CCSprite spriteWithImageNamed:@"rocket.png"];
    n.position = ccp(r.contentSize.width/2, r.contentSize.height/2);
    n.rotation = 90;
    [r addChild:n];
    
    CCParticleSystem *q = [CCParticleSystem particleWithFile:@"rockettail.plist"];
    q.position = ccpAdd(n.position, ccp(0, 10));
    [r addChild:q z:-1];
    
    NSMutableArray *seq = [NSMutableArray array];
    for (int i = p.startLocation.y; i >= 0; i--) {
      CGPoint pos = ccp(p.startLocation.x, i);
      Gem *g = _gems[(int)(pos.x+pos.y*self.gridSize.width)];
      [seq addObject:[CCActionMoveTo actionWithDuration:TIME_TO_TRAVEL_PER_SQUARE position:[self pointForGridPosition:pos]]];
      [seq addObject:[CCActionCallBlock actionWithBlock:^{
        if (![self.reservedGems containsObject:g]) {
          [self destroyGem:g fromColor:color fromPowerup:powerupId];
        }
      }]];
    }
    
    float time = TIME_TO_TRAVEL_PER_SQUARE*(p.startLocation.y-ROCKET_END_LOCATION)*-1;
    [seq addObject:[CCActionSpawn actions:[CCActionMoveTo actionWithDuration:time position:[self pointForGridPosition:ccp(p.startLocation.x, p.startLocation.y-ROCKET_END_LOCATION)]],
                    [CCActionCallBlock actionWithBlock:
                     ^{
                       [n runAction:[CCActionFadeOut actionWithDuration:time]];
                       if (topSideIsLonger) {
                         [self.powerups removeObject:p];
                         [self checkAllGemsAndPowerupsDone];
                       }
                     }], nil]];
    [seq addObject:[CCActionCallBlock actionWithBlock:^{
      [r removeFromParentAndCleanup:YES];
    }]];
    
    [r runAction:[CCActionSequence actionWithArray:seq]];
    
    
    r = [CCSprite spriteWithImageNamed:@"rocket.png"];
    r.opacity = 0;
    r.position = [self pointForGridPosition:p.startLocation];
    [self addChild:r z:10];
    
    n = [CCSprite spriteWithImageNamed:@"rocket.png"];
    n.position = ccp(r.contentSize.width/2, r.contentSize.height/2);
    n.rotation = -90;
    [r addChild:n];
    
    q = [CCParticleSystem particleWithFile:@"rockettail.plist"];
    q.position = ccpAdd(n.position, ccp(0, -10));
    [r addChild:q z:-1];
    
    seq = [NSMutableArray array];
    for (int i = p.startLocation.y; i < self.gridSize.height; i++) {
      CGPoint pos = ccp(p.startLocation.x, i);
      Gem *g = _gems[(int)(pos.x+pos.y*self.gridSize.width)];
      [seq addObject:[CCActionMoveTo actionWithDuration:TIME_TO_TRAVEL_PER_SQUARE position:[self pointForGridPosition:pos]]];
      [seq addObject:[CCActionCallBlock actionWithBlock:^{
        [self destroyGem:g fromColor:color fromPowerup:powerupId];
      }]];
    }
    
    time = TIME_TO_TRAVEL_PER_SQUARE*(p.startLocation.y+ROCKET_END_LOCATION-self.gridSize.height);
    [seq addObject:[CCActionSpawn actions:[CCActionMoveTo actionWithDuration:time position:[self pointForGridPosition:ccp(p.startLocation.x, p.startLocation.y+ROCKET_END_LOCATION)]],
                    [CCActionCallBlock actionWithBlock:
                     ^{
                       [n runAction:[CCActionFadeOut actionWithDuration:time]];
                       if (!topSideIsLonger) {
                         [self.powerups removeObject:p];
                         [self checkAllGemsAndPowerupsDone];
                       }
                     }], nil]];
    [seq addObject:[CCActionCallBlock actionWithBlock:^{
      [r removeFromParentAndCleanup:YES];
    }]];
    
    [r runAction:[CCActionSequence actionWithArray:seq]];
    
    [SoundEngine puzzleRocketMatch];
  } else if (p.powerupId == powerup_explosion) {
    NSMutableArray *blowup = [NSMutableArray array];
    for (Gem *gem in _gems) {
      if ([self gem:gem isInExplosionRangeOfLocation:p.startLocation] && ![self.reservedGems containsObject:gem]) {
        [blowup addObject:gem];
        [self.reservedGems addObject:gem];
      }
    }
    [self runAction:[CCActionSequence actions:
                     [CCActionDelay actionWithDuration:0.05],
                     [CCActionCallBlock actionWithBlock:
                      ^{
                        [self.powerups removeObject:p];
                        for (Gem *gem in blowup) {
                          [self destroyGem:gem fromColor:color fromPowerup:powerupId];
                        }
                        [self checkAllGemsAndPowerupsDone];
                        
                        CCParticleSystem *x = [CCParticleSystem particleWithFile:@"grenade1.plist"];
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
        CCParticleSystem *q = [CCParticleSystem particleWithFile:@"rockettail.plist"];
        q.particlePositionType = CCParticleSystemPositionTypeFree;
        [self addChild:q z:10];
        q.position = [self pointForGridPosition:p.startLocation];
        
        BOOL last = i == blowup.count-1;
        [q runAction:
         [CCActionSequence actions:
          [CCActionDelay actionWithDuration:i*0.1],
          [CCActionMoveTo actionWithDuration:MOLOTOV_PARTICLE_DURATION position:gem.sprite.position],
          [CCActionCallBlock actionWithBlock:
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
  NSInteger index = [_gems indexOfObject:gem];
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
      
      NSMutableArray *toDestroy = [NSMutableArray array];
      for (Gem *gem in _gems) {
        if (gem.color == color && gem != _realDragGem && gem != _swapGem) {
          CCParticleSystem *q = [CCParticleSystem particleWithFile:@"rockettail.plist"];
          [self addChild:q z:10];
          q.position = _realDragGem.sprite.position;
          [q runAction:[CCActionMoveTo actionWithDuration:MOLOTOV_PARTICLE_DURATION position:gem.sprite.position]];
          q.duration = MOLOTOV_PARTICLE_DURATION;
          q.autoRemoveOnFinish = YES;
          
          [toDestroy addObject:gem];
          [self.reservedGems addObject:toDestroy];
        }
      }
      [toDestroy shuffle];
      
      // First action just delays everything, then we replace and fire off rockets
      NSMutableArray *seq = [NSMutableArray array];
      [seq addObject:[CCActionDelay actionWithDuration:MOLOTOV_PARTICLE_DURATION-0.1]];
      [seq addObject:[CCActionCallBlock actionWithBlock:^{
        NSMutableArray *seq = [NSMutableArray array];
        [seq addObject:[CCActionDelay actionWithDuration:0.2]];
        for (Gem *gem in toDestroy) {
          Gem *newGem = [self createGemWithColor:color powerup:arc4random() % 2 == 0 ? powerup_horizontal_line : powerup_vertical_line];
          [self.gems replaceObjectAtIndex:[self.gems indexOfObject:gem] withObject:newGem];
          newGem.sprite.position = [self pointForGridPosition:[self coordinateOfGem:newGem]];
          [gem.sprite removeFromParentAndCleanup:YES];
          [self addChild:newGem.sprite z:9];
          
          [seq addObject:[CCActionDelay actionWithDuration:0.2]];
          [seq addObject:[CCActionCallBlock actionWithBlock:^{
            [self destroyGem:newGem fromColor:gem.color fromPowerup:powerup_none];
          }]];
        }
        [seq addObject:[CCActionCallBlock actionWithBlock:^{
          [self.powerups removeObject:p];
          [self checkAllGemsAndPowerupsDone];
        }]];
        [self runAction:[CCActionSequence actionWithArray:seq]];
      }]];
      [self runAction:[CCActionSequence actionWithArray:seq]];
      
      _realDragGem.powerup = powerup_none;
      _swapGem.powerup = powerup_none;
      [self destroyGem:_realDragGem fromColor:color_all fromPowerup:powerup_none];
      [self destroyGem:_swapGem fromColor:color_all fromPowerup:powerup_none];
    }
    // bomb and cocktail
    else if ((_realDragGem.powerup == powerup_explosion && _swapGem.powerup == powerup_all_of_one_color) ||
             (_swapGem.powerup == powerup_explosion && _realDragGem.powerup == powerup_all_of_one_color)) {
      GemColorId color = _realDragGem.powerup == powerup_all_of_one_color ? _swapGem.color : _realDragGem.color;
      
      Powerup *p = [[Powerup alloc] init];
      [self.powerups addObject:p];
      
      NSMutableArray *toDestroy = [NSMutableArray array];
      for (Gem *gem in _gems) {
        if (gem.color == color && gem != _realDragGem && gem != _swapGem) {
          CCParticleSystem *q = [CCParticleSystem particleWithFile:@"rockettail.plist"];
          [self addChild:q z:10];
          q.position = _realDragGem.sprite.position;
          [q runAction:[CCActionMoveTo actionWithDuration:MOLOTOV_PARTICLE_DURATION position:gem.sprite.position]];
          q.duration = MOLOTOV_PARTICLE_DURATION;
          q.autoRemoveOnFinish = YES;
          
          [toDestroy addObject:gem];
          [self.reservedGems addObject:toDestroy];
        }
      }
      [toDestroy shuffle];
      
      // First action just delays everything, then we replace and fire off rockets
      NSMutableArray *seq = [NSMutableArray array];
      [seq addObject:[CCActionDelay actionWithDuration:MOLOTOV_PARTICLE_DURATION-0.1]];
      [seq addObject:[CCActionCallBlock actionWithBlock:^{
        NSMutableArray *seq = [NSMutableArray array];
        [seq addObject:[CCActionDelay actionWithDuration:0.2]];
        for (Gem *gem in toDestroy) {
          Gem *newGem = [self createGemWithColor:color powerup:powerup_explosion];
          [self.gems replaceObjectAtIndex:[self.gems indexOfObject:gem] withObject:newGem];
          newGem.sprite.position = [self pointForGridPosition:[self coordinateOfGem:newGem]];
          [gem.sprite removeFromParentAndCleanup:YES];
          [self addChild:newGem.sprite z:9];
          
          [seq addObject:[CCActionDelay actionWithDuration:0.2]];
          [seq addObject:[CCActionCallBlock actionWithBlock:^{
            [self destroyGem:newGem fromColor:gem.color fromPowerup:powerup_none];
          }]];
        }
        [seq addObject:[CCActionCallBlock actionWithBlock:^{
          [self.powerups removeObject:p];
          [self checkAllGemsAndPowerupsDone];
        }]];
        [self runAction:[CCActionSequence actionWithArray:seq]];
      }]];
      [self runAction:[CCActionSequence actionWithArray:seq]];
      
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
          [seq addObject:[CCActionCallBlock actionWithBlock:^{
            Gem *g = _gems[(int)(i+j*self.gridSize.width)];
            g.powerup = powerup_none;
            [self destroyGem:g fromColor:g.color fromPowerup:powerup_all_of_one_color];
          }]];
          [seq addObject:[CCActionDelay actionWithDuration:0.08]];
        }
      }
      Powerup *p = [[Powerup alloc] init];
      [self.powerups addObject:p];
      [seq addObject:[CCActionCallBlock actionWithBlock:^{
        [self.powerups removeObject:p];
        [self checkAllGemsAndPowerupsDone];
      }]];
      [self runAction:[CCActionSequence actionWithArray:seq]];
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

- (NSMutableArray *) createBatchesFromRun {
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
  
  return batches;
}

- (void) turnEnd
{
  _allowInput = NO;
  
  [_run removeAllObjects];
  BOOL foundPowerup = [self checkForPowerupMatch];
  
  if (!foundPowerup) {
    [self createRunForCurrentBoard];
    if ( _run.count > 0) {
      _foundMatch = YES;
      
      // Delegate method refers to orbs beginning to combo
      [self.delegate moveBegan];
      
      NSMutableArray *batches = [self createBatchesFromRun];
      [self processBatches:batches];
    } else {
      if (!_foundMatch && _swapGem) {
        Gem *realDragGem = _realDragGem;
        Gem *swapGem = _swapGem;
        
        [self doGemSwapAnimationWithGem:realDragGem andGem:swapGem];
        NSInteger idxA = [_gems indexOfObject:swapGem];
        NSInteger idxB = [_gems indexOfObject:realDragGem];
        [_gems replaceObjectAtIndex:idxA withObject:realDragGem];
        [_gems replaceObjectAtIndex:idxB withObject:swapGem];
        
//        [[SoundEngine sharedSoundEngine] puzzleWrongMove];
        
        [self runAction:
         [CCActionSequence actions:
          [CCActionDelay actionWithDuration:ORB_ANIMATION_TIME],
          [CCActionCallFunc actionWithTarget:self.delegate selector:@selector(moveComplete)], nil]];
      } else {
        // Do this so that it doesn't get immediately unscheduled a couple lines later
        [self runAction:
         [CCActionCallFunc actionWithTarget:self.delegate selector:@selector(moveComplete)]];
      }
    }
  } else {
    // Delegate method refers to orbs beginning to combo
    [self.delegate moveBegan];
    
    _foundMatch = YES;
    [self checkAllGemsAndPowerupsDone];
  }
  
  if (_foundMatch) {
    [self unschedule:@selector(pulseValidMove)];
    [self stopValidMovePulsing];
  }
}

- (void) updateGemPositionsAfterSwap
{
  CGSize squareSize = self.squareSize;
  
  float startY = squareSize.height/2;
  float startX = squareSize.width/2;
  
  for (int y = 0; y < self.gridSize.height; y++) {
    for (int x = 0; x < self.gridSize.width; x++) {
      int idx = x+(y*self.gridSize.width);
      Gem *container = _gems[idx];
      if (container.sprite.position.x != startX || container.sprite.position.y != startY) {
        _gemsBouncing++;
        int numSquares = (container.sprite.position.y - startY) / squareSize.height;
        CCActionMoveTo * moveTo = [CCActionMoveTo actionWithDuration:0.4+0.1*numSquares position:CGPointMake(startX, startY)];
        [container.sprite runAction:[CCActionSequence actions:
                                     [CCActionEaseBounceOut actionWithAction:moveTo],
                                     [CCActionCallBlock actionWithBlock:
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
  NSInteger index1 = [_gems indexOfObject:gem1];
  NSInteger index2 = [_gems indexOfObject:gem2];
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
  id move1 = [CCActionMoveTo actionWithDuration:ORB_ANIMATION_TIME position:gem2.sprite.position];
  [gem1.sprite runAction:move1];
  
  bezier2.endPosition = gem1Pos;
  id move2 = [CCActionMoveTo actionWithDuration:ORB_ANIMATION_TIME position:gem1.sprite.position];
  [gem2.sprite runAction:move2];
}

- (void) allowInput {
  if (![self validMoveExists]) {
    [self reshuffle];
  }
  
  [self scheduleOnce:@selector(pulseValidMove) delay:3.f];
  
  _allowInput = YES;
}

- (void) disallowInput {
  _allowInput = NO;
}

#define PULSING_ANIMATION_TAG 82930

- (void) pulseValidMove {
  if (_isPulsing) return;
  _isPulsing = YES;
  
  NSSet *move = [self getValidMove];
  for (Gem *gem in move) {
    NSString *key = [NSString stringWithFormat:@"%d%dOverlay", gem.color, gem.powerup];
    CCTexture *texture = [[CCTextureCache sharedTextureCache] textureForKey:key];
    if (!texture) {
      UIImage *img = [Globals imageNamed:[self gemSpriteImageNameWithColor:gem.color powerup:gem.powerup]];
      img = [Globals maskImage:img withColor:[UIColor whiteColor]];
      texture = [[CCTextureCache sharedTextureCache] addCGImage:img.CGImage forKey:key];
      texture.contentScale = gem.sprite.texture.contentScale;
    }
    CCSprite *spr = [CCSprite spriteWithTexture:texture];
    spr.position = ccp(gem.sprite.contentSize.width/2, gem.sprite.contentSize.height/2);
    [gem.sprite addChild:spr z:0 name:@"Overlay"];
    spr.opacity = 0.f;
    spr.blendFunc = (ccBlendFunc) {GL_DST_COLOR, GL_ONE};
    
    float pulseDur = 0.4f;
    float numTimes = 4;
    float delay = 1.3f;
    CCAction *action =
    [CCActionRepeatForever actionWithAction:
     [CCActionSequence actions:
      [CCActionRepeat actionWithAction:
       [CCActionSequence actions:
        [CCActionScaleTo actionWithDuration:pulseDur scale:1.15f],
        [CCActionScaleTo actionWithDuration:pulseDur scale:1.f], nil] times:numTimes],
      [CCActionDelay actionWithDuration:delay], nil]];
    action.tag = PULSING_ANIMATION_TAG;
    [gem.sprite runAction:action];
    
    [spr runAction:
     [CCActionRepeatForever actionWithAction:
      [CCActionSequence actions:
       [CCActionRepeat actionWithAction:
        [CCActionSequence actions:
         [CCActionFadeTo actionWithDuration:pulseDur opacity:0.4f],
         [CCActionFadeTo actionWithDuration:pulseDur opacity:0.f], nil] times:numTimes],
       [CCActionDelay actionWithDuration:delay], nil]]];
  }
}

- (void) stopValidMovePulsing {
  // Stop the pulsing gems
  for (Gem *gem in self.gems) {
    [gem.sprite stopActionByTag:PULSING_ANIMATION_TAG];
    gem.sprite.scale = 1.f;
    
    CCNode *n = [gem.sprite getChildByName:@"Overlay" recursively:NO];
    [n removeFromParent];
  }
  _isPulsing = NO;
}

#pragma mark touch handling

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  if (!_allowInput) return;
  
  CGPoint location = [touch locationInNode:self];
  CGPoint square = ccp((int)(location.x/self.squareSize.width), (int)(location.y/self.squareSize.height));
  
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
      container.sprite.opacity = 0.5f;
      _dragGem.sprite.zOrder = 10;
      
      _beganTimer = NO;
      
      self.oldGems = [self.gems copy];
      
      self.isTrackingTouch = YES;
    }
  }
}

- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
  if (!_allowInput) return;
  
  if (_dragGem) {
    CGPoint location = [touch locationInNode:self];
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
      [SoundEngine puzzleSwapPiece];
      
      if (_realDragGem && _swapGem) {
        NSInteger idxA = [_gems indexOfObject:_swapGem];
        NSInteger idxB = [_gems indexOfObject:_realDragGem];
        [_gems replaceObjectAtIndex:idxA withObject:_realDragGem];
        [_gems replaceObjectAtIndex:idxB withObject:_swapGem];
        
        [self timedOut];
      }
    }
  }
}

- (void) timedOut {
  [self touchEnded:nil withEvent:nil];
}

- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  if (!_allowInput) return;
  
  if (_realDragGem) {
    [self unschedule:@selector(timedOut)];
    [_dragGem.sprite removeFromParent];
    
    _allowInput = NO;
    _realDragGem.sprite.opacity = 1.f;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ORB_ANIMATION_TIME * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      if (_realDragGem) {
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

- (void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
  [self touchEnded:touch withEvent:event];
}

#pragma mark - Serialization

#define POSITION_X_KEY @"PositionXKey"
#define POSITION_Y_KEY @"PositionYKey"
#define POWERUP_KEY @"PowerupKey"
#define GEM_COLOR_KEY @"GemColorKey"

- (id) serialize {
  NSMutableArray *arr = [NSMutableArray array];
  for (Gem *gem in self.gems) {
    NSMutableDictionary *gemInfo = [NSMutableDictionary dictionary];
    [gemInfo setObject:@(gem.powerup) forKey:POWERUP_KEY];
    [gemInfo setObject:@(gem.color) forKey:GEM_COLOR_KEY];
    
    CGPoint pt = [self coordinateOfGem:gem];
    [gemInfo setObject:@((int)pt.x) forKey:POSITION_X_KEY];
    [gemInfo setObject:@((int)pt.y) forKey:POSITION_Y_KEY];
    
    [arr addObject:gemInfo];
  }
  return arr;
}

- (void) deserialize:(NSArray *)arr {
  for (NSDictionary *gemInfo in arr) {
    PowerupId powerup = (int)[[gemInfo objectForKey:POWERUP_KEY] integerValue];
    GemColorId color = (int)[[gemInfo objectForKey:GEM_COLOR_KEY] integerValue];
    Gem *gem = [self createGemWithColor:color powerup:powerup];
    
    int x = (int)[[gemInfo objectForKey:POSITION_X_KEY] integerValue];
    int y = (int)[[gemInfo objectForKey:POSITION_Y_KEY] integerValue];
    if (x < self.gridSize.width && y < self.gridSize.height) {
      int idx = x+(y*self.gridSize.width);
      
      Gem *oldGem = [self.gems objectAtIndex:idx];
      [self.gems replaceObjectAtIndex:idx withObject:gem];
      [oldGem.sprite removeFromParent];
      
      [self addChild:gem.sprite z:9];
      gem.sprite.position = [self pointForGridPosition:[self coordinateOfGem:gem]];
    }
  }
}

@end
