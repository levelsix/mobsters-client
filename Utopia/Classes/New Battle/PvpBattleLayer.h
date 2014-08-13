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
  
  BOOL _didRunaway;
}

@property (nonatomic, retain) NSArray *defendersList;

@property (nonatomic, retain) BattleQueueNode *queueNode;

@property (nonatomic, retain) UIButton *closeButton;

@property (nonatomic, retain) IBOutlet NSMutableArray *seenUserIds;

@property (nonatomic, retain) IBOutlet NSArray *enemyTeamSprites;

@property (nonatomic, assign) BOOL useGemsForQueue;

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize pvpHistoryForRevenge:(PvpHistoryProto *)hist;

@end
