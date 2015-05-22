//
//  LeaderBoardBuilding.m
//  Utopia
//
//  Created by Kenneth Cox on 5/7/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "LeaderBoardBuilding.h"
#import "CCAnimation+SpriteLoading.h"
#import "Globals.h"
#import "GameState.h"

@implementation LeaderBoardBuilding

- (void) reloadCharacterSprites {
  GameState *gs = [GameState sharedGameState];
  
  NSArray *leaderList = gs.leaderBoardPlacement;

  for (StrengthLeaderBoardProto *slbp in leaderList) {
    [self setPodiumWithMonster:[gs monsterWithId:slbp.mup.avatarMonsterId] placement:slbp.rank];
  }
}

- (void) setPodiumWithMonster:(MonsterProto *)monster placement:(int)placement {
  NSString *spritesheetName = [NSString stringWithFormat:@"%@AttackNF.plist", monster.imagePrefix];
  [Globals checkAndLoadSpriteSheet:spritesheetName completion:^(BOOL success) {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spritesheetName];
    NSString *file = [NSString stringWithFormat:@"%@AttackN00.png", monster.imagePrefix];
    if ([[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:file]) {
      
      CCSprite *monsterSprite = nil;
      CGPoint placementPosition;
      
      placementPosition = ccpAdd(ccp(self.buildingSprite.contentSize.width/2, -5), ccp(0, monster.verticalPixelOffset));
      
      switch (placement) {
        case 1:
          monsterSprite = self.firstMonsterSprite;
          placementPosition = ccpAdd(placementPosition, ccp(4, 56));
          break;
        case 2:
          monsterSprite = self.secondMonsterSprite;
          placementPosition = ccpAdd(placementPosition, ccp(32, 20));
          break;
        case 3:
          monsterSprite = self.thirdMonsterSprite;
          placementPosition = ccpAdd(placementPosition, ccp(-35, 63));
          break;
          
        default:
          [Globals popupMessage:@"Tried to place a monster lower than 3rd place on the podium"];
          return;
      }
      
      // Re-remove monster sprite just in case
      [monsterSprite removeFromParent];
      
      monsterSprite = [CCSprite spriteWithImageNamed:file];
      monsterSprite.anchorPoint = ccp(0.5, 0);
      monsterSprite.scale = 0.8;
      monsterSprite.position = placementPosition;
      [self.buildingSprite addChild:monsterSprite z:1];
    }
  }];
}

@end
