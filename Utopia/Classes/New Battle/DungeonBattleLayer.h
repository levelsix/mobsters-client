//
//  DungeonBattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/3/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "NewBattleLayer.h"
#import "Protocols.pb.h"
#import "FullEvent.h"

#define BATTLE_MANAGE_CLICKED_KEY @"BattleManageClicked"

@interface DungeonBattleLayer : NewBattleLayer {
  BOOL _receivedEndDungeonResponse;
  BOOL _waitingForEndDungeonResponse;
  
  BOOL _checkedQuests;
}

@property (nonatomic, retain) BeginDungeonResponseProto *dungeonInfo;

- (void) checkQuests;
- (void) handleEndDungeonResponseProto:(FullEvent *)fe;

@end
