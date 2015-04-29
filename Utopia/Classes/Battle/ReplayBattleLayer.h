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
  
  CombatReplayProto *_replay;
  
}

- (void) initWithReplay:(CombatReplayProto*)replay;


@end
