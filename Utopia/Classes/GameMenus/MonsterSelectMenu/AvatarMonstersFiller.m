//
//  AvatarMonstersFiller.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "AvatarMonstersFiller.h"

#import "GameState.h"

#import "OutgoingEventController.h"
#import "MiniEventManager.h"

@implementation AvatarMonsterSelectCell

- (void) updateForListObject:(UserMonster *)um {
  [self.monsterView updateForMonsterId:um.monsterId];
}

@end

@implementation AvatarMonstersFiller

- (NSString *) titleName {
  return [NSString stringWithFormat:@"CHOOSE %@", MONSTER_NAME.uppercaseString];
}

- (NSString *) cellClassName {
  return @"AvatarMonsterSelectCell";
}

//- (NSString *) footerTitle {
//  return [NSString stringWithFormat:@"Tap a %@ to Set Avatar", MONSTER_NAME];
//}
//
//- (NSString *) footerDescription {
//  return [NSString stringWithFormat:@"Donated %@s lose their HP and need to be healed.", MONSTER_NAME];
//}

- (void) updateCell:(AvatarMonsterSelectCell *)cell monster:(UserMonster *)monster {
  [cell updateForListObject:monster];
}

- (NSArray *) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [NSMutableArray array];
  
  for (UserMonster *um in gs.myMonsters) {
    if (um.isComplete) {
      // Make sure there's no other toon visible
      BOOL duplicate = NO;
      for (UserMonster *um2 in arr) {
        if (um2.monsterId == um.monsterId) {
          duplicate = YES;
          break;
        }
      }
      
      if (!duplicate) {
        [arr addObject:um];
      }
    }
  }
  
  [arr sortUsingSelector:@selector(compare:)];
  
  return arr;
}

- (void) monsterSelected:(UserMonster *)um viewController:(MonsterSelectViewController *)viewController {
  [[OutgoingEventController sharedOutgoingEventController] setAvatarMonster:um.monsterId];
  [viewController closeClicked:nil];
  
  [self.delegate avatarMonsterChosen];
}

- (void) monsterSelectClosed {
  [self.delegate monsterSelectClosed];
}

@end
