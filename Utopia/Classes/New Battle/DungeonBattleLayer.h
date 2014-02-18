//
//  DungeonBattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/3/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "NewBattleLayer.h"
#import "Protocols.pb.h"

#define BATTLE_MANAGE_CLICKED_KEY @"BattleManageClicked"

@interface DungeonBattleLayer : NewBattleLayer {
  BOOL _wonBattle;
  BOOL _receivedEndDungeonResponse;
  BOOL _waitingForEndDungeonResponse;
  
  BOOL _manageWasClicked;
  
  int _numTimesNotResponded;
}

@property (nonatomic, retain) BeginDungeonResponseProto *dungeonInfo;

@property (nonatomic, retain) BattleLostView *lostView;
@property (nonatomic, retain) BattleWonView *wonView;

@property (nonatomic, retain) IBOutlet UIView *swapView;
@property (nonatomic, retain) IBOutlet UILabel *swapLabel;
@property (nonatomic, retain) IBOutlet BattleDeployView *deployView;
@property (nonatomic, retain) IBOutlet UIButton *forfeitButton;
@property (nonatomic, retain) IBOutlet UIButton *deployCancelButton;

- (void) receivedDungeonInfo:(BeginDungeonResponseProto *)di;

- (IBAction)forfeitClicked:(id)sender;
- (IBAction)manageClicked:(id)sender;
- (IBAction)shareClicked:(id)sender;

@end
