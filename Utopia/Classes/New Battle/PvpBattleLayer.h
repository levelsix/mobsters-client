//
//  PvpBattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "NewBattleLayer.h"

@interface PvpBattleLayer : NewBattleLayer {
  BOOL _wonBattle;
  BOOL _receivedEndDungeonResponse;
  BOOL _waitingForEndDungeonResponse;
  
  BOOL _manageWasClicked;
  
  int _numTimesNotResponded;
  
  int _curQueueNum;
  BOOL _hasChosenEnemy;
  BOOL _waitingForDownload;
  BOOL _spawnedNewTeam;
  
  BOOL _useGemsForQueue;
}

@property (nonatomic, retain) QueueUpResponseProto *queueInfo;

@property (nonatomic, retain) BattleLostView *lostView;
@property (nonatomic, retain) BattleWonView *wonView;
@property (nonatomic, retain) BattleQueueNode *queueNode;

@property (nonatomic, retain) IBOutlet UIView *swapView;
@property (nonatomic, retain) IBOutlet UILabel *swapLabel;
@property (nonatomic, retain) IBOutlet BattleDeployView *deployView;
@property (nonatomic, retain) IBOutlet UIButton *forfeitButton;
@property (nonatomic, retain) IBOutlet UIButton *deployCancelButton;

@property (nonatomic, retain) IBOutlet NSMutableArray *seenUserIds;

@property (nonatomic, retain) IBOutlet NSArray *enemyTeamSprites;

@property (nonatomic, assign) BOOL useGemsForQueue;

@end
