//
//  TutorialDropBattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialDropBattleLayer.h"

@implementation TutorialDropBattleLayer

- (void) beginFirstMove {
  _allowTurnBegin = YES;
  [self beginMyTurn];
}

- (void) finishBattle {
  _allowLootPickup = YES;
  [self pickUpLoot:(CCSprite *)[self getChildByName:LOOT_TAG recursively:YES]];
  [self moveToNextEnemy];
}

- (void) pickUpLoot:(CCSprite *)ed {
  if (_allowLootPickup) {
    [super pickUpLoot:ed];
  } else {
    // So it can display dialogue
    [self.delegate turnFinished];
  }
}

- (void) moveToNextEnemy {
  if (_lootDropped) {
    if (_allowLootPickup) {
      [super moveToNextEnemy];
    }
  } else {
    [super moveToNextEnemy];
  }
}

- (BOOL) canSkipResponseWait {
  return NO;
}

- (void) handleEndDungeonResponseProto:(FullEvent *)fe {
  [super handleEndDungeonResponseProto:fe];
  EndDungeonResponseProto *proto = (EndDungeonResponseProto *)fe.event;
  if (proto.updatedOrNewList.count > 0) {
    FullUserMonsterProto *um = proto.updatedOrNewList[0];
    self.newUserMonsterId = um.userMonsterId;
  }
}

- (NSString *) presetLayoutFile {
  return @"TutorialDropLayout.txt";
}

@end
