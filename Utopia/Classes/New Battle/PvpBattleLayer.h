//
//  PvpBattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "NewBattleLayer.h"

@interface PvpBattleLayer : NewBattleLayer {
  BOOL _receivedEndPvpResponse;
  BOOL _waitingForEndPvpResponse;
  
  int _curQueueNum;
  BOOL _hasChosenEnemy;
  BOOL _waitingForDownload;
  BOOL _spawnedNewTeam;
  
  BOOL _userAttacked;
  
  BOOL _useGemsForQueue;
  
  BOOL _isRevenge;
  uint64_t _prevBattleStartTime;
}

@property (nonatomic, retain) NSArray *defendersList;

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

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft pvpHistoryForRevenge:(PvpHistoryProto *)hist;

@end
