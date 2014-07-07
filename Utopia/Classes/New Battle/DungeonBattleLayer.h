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
  
  BOOL _isResumingState;
  BOOL _isDownloading;
  BOOL _damageWasDealt;
}

@property (nonatomic, retain) BeginDungeonResponseProto *dungeonInfo;

- (void) checkQuests;
- (void) resumeFromUserTask:(MinimumUserTaskProto *)task stages:(NSArray *)stages;
- (void) handleEndDungeonResponseProto:(FullEvent *)fe;

- (void) sendServerDungeonProgress;

@end
