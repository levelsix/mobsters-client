//
//  CCEquipCard.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "CCEquipCard.h"
#import "GameState.h"
#import "Globals.h"

@implementation CCEquipCard

+ (id) cardWithBattleEquip:(id)equip isOnRightSide:(BOOL)isOnRightSide {
  return [[[self alloc] initWithBattleEquip:equip isOnRightSide:isOnRightSide] autorelease];
}

- (id) initWithBattleEquip:(BattleEquip *)equip isOnRightSide:(BOOL)isOnRightSide {
  if (!equip.equipId) {
    return [self initWithFile:@"puzzcommonmini.png"];
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullEquipProto *fep = [gs equipWithId:equip.equipId];
  
  NSString *base = [[[Globals stringForRarity:fep.rarity] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
  NSString *bgdFile = [NSString stringWithFormat:@"puzz%@mini.png", base];
  
  if ((self = [super initWithFile:bgdFile])) {
    CCSprite *eqIcon = [CCSprite node];
    [self addChild:eqIcon];
    eqIcon.position = ccp(self.contentSize.width/2, self.contentSize.height/2+10);
    eqIcon.scale = MIN(29/eqIcon.contentSize.width, 24/eqIcon.contentSize.height);
    [Globals imageNamed:[Globals imageNameForEquip:equip.equipId] toReplaceSprite:eqIcon];
    
    int numStars = [gl calculateEnhancementLevel:equip.enhancePercent];
    for (int i = 0; i < gl.maxEnhancementLevel; i++) {
      CCSprite *star;
      if (i < numStars) {
        star = [CCSprite spriteWithFile:@"filledstar.png"];
      } else {
        star = [CCSprite spriteWithFile:@"innerstar.png"];
      }
      
      float xPos = self.contentSize.width/2-(gl.maxEnhancementLevel/2.f-i-0.5)*(star.contentSize.width);
      star.position = ccp(xPos, 15);
      
      [self addChild:star];
    }
    
    NSString *str = [Globals shortenedStringForEquipType:fep.equipType];
    CCLabelTTF *label = [CCLabelTTF labelWithString:str fontName:@"Dirty Headline" fontSize:6.f];
    [self addChild:label];
    label.color = ccc3(0, 0, 0);
    label.opacity = 180;
    label.position = ccp(self.contentSize.width/2, 5);
    
    CCSprite *durBarBgd = [CCSprite spriteWithFile:@"itemdurabilitybg.png"];
    float x = (isOnRightSide ? self.contentSize.width : 0) + (isOnRightSide ? 1 : -1) * (durBarBgd.contentSize.width/2+1);
    durBarBgd.position = ccp(x, self.contentSize.height/2);
    [self addChild:durBarBgd];
    
    self.durabilityBar = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"itemdurabilitybar.png"]];
    [durBarBgd addChild:self.durabilityBar];
    self.durabilityBar.position = ccp(durBarBgd.contentSize.width/2, durBarBgd.contentSize.height/2);
    self.durabilityBar.type = kCCProgressTimerTypeBar;
    self.durabilityBar.percentage = 100.f*equip.durability/fep.maxDurability;
  }
  return self;
}

@end
