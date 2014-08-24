//
//  ClanRaidHealthBar.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/26/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanRaidHealthBar.h"

#import "GameState.h"
#import "Globals.h"

@implementation ClanMemberAttack

- (id) initWithMonsterId:(int)monsterId attackDmg:(int)dmg name:(NSString *)name {
  if ((self = [super init])) {
    self.monsterId = monsterId;
    self.attackDamage = dmg;
    self.name = name;
  }
  return self;
}

@end

#define HEALTH_BAR_BUBBLE_OFFSET 5

@implementation ClanRaidHealthBar

- (id) initWithStage:(ClanRaidStageProto *)stage width:(float)width {
  if ((self = [super init])) {
    GameState *gs = [GameState sharedGameState];
    
    CCSprite *rightCap = [CCSprite spriteWithImageNamed:@"timerbgrightcap.png"];
    [self addChild:rightCap];
    rightCap.anchorPoint = ccp(0, 0.5);
    rightCap.position = ccp(width-rightCap.contentSize.width, rightCap.contentSize.height/2);
    
    self.contentSize = CGSizeMake(width, rightCap.contentSize.height);
    
    CCSprite *bgdLeftCap = [CCSprite spriteWithImageNamed:@"timerbgcapleft.png"];
    [self addChild:bgdLeftCap];
    bgdLeftCap.position = ccp(bgdLeftCap.contentSize.width/2, self.contentSize.height/2);
    
    // Create the middle bubbles
    int totalHealth = stage.totalHealth;
    float leftPos = bgdLeftCap.contentSize.width;
    int curHealth = 0;
    
    NSMutableArray *bubbles = [NSMutableArray array];
    
    // Middle area of each bubble won't be considered part of the bar
    NSInteger numBubbles = stage.monstersList.count;
    float effectiveWidth = width-rightCap.contentSize.width*numBubbles+HEALTH_BAR_BUBBLE_OFFSET*(2*numBubbles-1);
    // Last bubble has already been placed so subtract 1
    for (int i = 0; i < numBubbles; i++) {
      CCSprite *bubble;
      float bubbleLeft;
      
      ClanRaidStageMonsterProto *mon = stage.monstersList[i];
      curHealth += mon.monsterHp;
      float perc = curHealth/(float)totalHealth;
      
      if (i < numBubbles-1) {
        bubble = [CCSprite spriteWithImageNamed:@"timerbgmiddlemobster.png"];
        [self addChild:bubble];
        bubble.anchorPoint = ccp(0, 0.5);
        bubbleLeft = perc*effectiveWidth-HEALTH_BAR_BUBBLE_OFFSET+(bubble.contentSize.width-HEALTH_BAR_BUBBLE_OFFSET*2)*i;
        bubbleLeft = MAX(leftPos, bubbleLeft);
        bubble.position = ccp(bubbleLeft, self.contentSize.height/2);
      } else {
        bubbleLeft = rightCap.position.x;
        bubble = rightCap;
      }
      [bubbles addObject:bubble];
      
      if (bubbleLeft > leftPos) {
        CCSprite *line = [CCSprite spriteWithImageNamed:@"timerbgmiddle.png"];
        [self addChild:line];
        line.anchorPoint = ccp(0, 0.5);
        line.position = ccp(leftPos, self.contentSize.height/2);
        line.scaleX = bubbleLeft-leftPos;
      }
      
      leftPos = bubbleLeft + bubble.contentSize.width;
      
      // Add the head images
      MonsterProto *mp = [gs monsterWithId:mon.monsterId];
      NSString *circle = [Globals imageNameForElement:mp.monsterElement suffix:@"timermobster.png"];
      CCSprite *bgd = [CCSprite spriteWithImageNamed:circle];
      bgd.position = ccp(bubbleLeft+bubble.contentSize.width/2, bubble.position.y);
      [self addChild:bgd z:1];
      
      CCSprite *stencil = [CCSprite spriteWithImageNamed:circle];
      CCClippingNode *clip = [CCClippingNode clippingNodeWithStencil:stencil];
      clip.position = bgd.position;
      clip.alphaThreshold = 0;
      [self addChild:clip z:2];
      
      NSString *headStr = [mp.imagePrefix stringByAppendingString:@"Thumbnail.png"];
      CCSprite *head = [CCSprite spriteWithImageNamed:headStr];
      head.scale = 0.5f;
      head.position = ccp(0.f, -3.f);
      [clip addChild:head z:1];
    }
    
    self.bubbles = bubbles;
    
    // Initialize Bar
    CCSprite *left = [CCSprite spriteWithImageNamed:@"timercapleft.png"];
    left.anchorPoint = ccp(0, 0.5);
    left.position = ccp(0, left.contentSize.height/2);
    
    CCNodeColor *stencil = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.f green:0.f blue:0.f] width:left.contentSize.width height:left.contentSize.height];
    self.leftCap = [CCClippingNode clippingNodeWithStencil:stencil];
    [self addChild:self.leftCap];
    self.leftCap.contentSize = left.contentSize;
    self.leftCap.anchorPoint = ccp(0, 0.5);
    self.leftCap.position = ccp(0, self.contentSize.height/2);
    [self.leftCap addChild:left];
    
    
    CCSprite *right = [CCSprite spriteWithImageNamed:@"timercapleft.png"];
    right.anchorPoint = ccp(0, 0.5);
    right.position = ccp(0, right.contentSize.height/2);
    right.flipX = YES;
    self.rightCapSprite = right;
    
    stencil = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.f green:0.f blue:0.f] width:right.contentSize.width height:right.contentSize.height];
    self.rightCap = [CCClippingNode clippingNodeWithStencil:stencil];
    [self addChild:self.rightCap];
    self.rightCap.contentSize = right.contentSize;
    self.rightCap.anchorPoint = ccp(1, 0.5);
    self.rightCap.position = ccp(self.contentSize.width, self.contentSize.height/2);
    [self.rightCap addChild:right z:1];
    
    
    self.middleBar = [CCSprite spriteWithImageNamed:@"timermiddle.png"];
    [self addChild:self.middleBar];
    self.middleBar.anchorPoint = ccp(0, 0.5);
    self.middleBar.position = ccp(self.leftCap.contentSize.width, self.contentSize.height/2);
  }
  return self;
}

- (void) setPercentage:(float)percentage {
  // Used for progress timer
  [self updateForPercentage:percentage];
}

- (void) updateForPercentage:(float)percent {
  NSInteger numBubbles = self.bubbles.count;
  float bubbleWidth = [self.bubbles[0] contentSize].width;
  float effectiveWidth = self.contentSize.width-bubbleWidth*numBubbles+HEALTH_BAR_BUBBLE_OFFSET*(2*numBubbles-1);
  
  float effectiveX = percent*effectiveWidth;
  
  for (CCSprite *bub in self.bubbles) {
    float left = bub.position.x+HEALTH_BAR_BUBBLE_OFFSET;
    if (left < effectiveX) {
      effectiveX += bub.contentSize.width-HEALTH_BAR_BUBBLE_OFFSET*2;
    }
  }
  
  if (effectiveX > self.leftCap.contentSize.width*2) {
    self.rightCap.position = ccp(effectiveX, self.contentSize.height/2);
    self.rightCapSprite.position = ccp(0, self.rightCapSprite.position.y);
    self.middleBar.scaleX = MAX(0, effectiveX-self.leftCap.contentSize.width*2);
    
    self.middleBar.visible = YES;
    
    if (!_leftCapIsFull) {
      CCNodeColor *nc = (CCNodeColor *)self.leftCap.stencil;
      nc.contentSize = CGSizeMake(self.leftCap.contentSize.width, self.leftCap.contentSize.height);
      
      _leftCapIsFull = YES;
    }
  } else {
    CCNodeColor *nc = (CCNodeColor *)self.leftCap.stencil;
    nc.contentSize = CGSizeMake(effectiveX/2, self.leftCap.contentSize.height);
    
    // Just shift the right cap to the left so it gets masked out
    self.rightCapSprite.position = ccp(effectiveX/2-self.rightCapSprite.contentSize.width, self.rightCapSprite.position.y);
    self.rightCap.position = ccp(effectiveX/2+self.rightCap.contentSize.width, self.contentSize.height/2);
    
    self.middleBar.visible = NO;
    
    _leftCapIsFull = NO;
  }
}

@end