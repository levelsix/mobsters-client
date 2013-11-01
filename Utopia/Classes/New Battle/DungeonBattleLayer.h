//
//  DungeonBattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/3/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "NewBattleLayer.h"
#import "Protocols.pb.h"

@interface DungeonBattleLayer : NewBattleLayer {
  BOOL _wonBattle;
  BOOL _receivedEndDungeonResponse;
  BOOL _waitingForEndDungeonResponse;
}

@property (nonatomic, retain) BeginDungeonResponseProto *dungeonInfo;

- (void) receivedDungeonInfo:(BeginDungeonResponseProto *)di;

@property (nonatomic, retain) IBOutlet BattleContinueView *continueView;
@property (nonatomic, retain) IBOutlet BattleEndView *endView;

@property (nonatomic, retain) IBOutlet UIView *swapView;
@property (nonatomic, retain) IBOutlet BattleDeployView *deployView;
@property (nonatomic, retain) IBOutlet UIButton *deployButton;

@end
