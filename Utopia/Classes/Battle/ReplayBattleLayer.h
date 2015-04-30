//
//  ReplayBattleLayer.h
//  Utopia
//
//  Created by Rob Giusti on 4/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MainBattleLayer.h"
#import "Replay.pb.h"

@interface ReplayBattleLayer : MainBattleLayer {
  
  BOOL _isDownloading;
  
  CombatReplayProto *_replay;
  
  NSMutableArray *_combatSteps;
  
}

@property (readonly, getter=getCurrStep) CombatReplayStepProto* currStep;

- (id) initWithReplay:(CombatReplayProto*)replay;

- (CombatReplayStepProto*)getCurrStep;

@end
