//
//  PvpBattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "NewBattleLayer.h"

#import "ResourceItemsFiller.h"

@interface PvpBattleLayer : NewBattleLayer <ResourceItemsFillerDelegate> {
  BOOL _receivedEndPvpResponse;
  BOOL _waitingForEndPvpResponse;
  
  int _curQueueNum;
  BOOL _hasChosenEnemy;
  BOOL _waitingForDownload;
  BOOL _spawnedNewTeam;
  
  BOOL _userAttacked;
  
  BOOL _isRevenge;
  uint64_t _prevBattleStartTime;
  
  BOOL _didRunaway;
  
  UIImage* _nextMatchButtonImage;
}

@property (nonatomic, retain) NSArray *defendersList;

@property (nonatomic, retain) BattleQueueNode *queueNode;

@property (nonatomic, retain) UIButton *closeButton;

@property (nonatomic, retain) IBOutlet NSMutableArray *seenUserUuids;

@property (nonatomic, retain) IBOutlet NSArray *enemyTeamSprites;

@property (nonatomic, retain) NSDictionary *itemUsagesForQueue;

@property (nonatomic, retain) ItemSelectViewController *itemSelectViewController;
@property (nonatomic, retain) ResourceItemsFiller *resourceItemsFiller;

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize pvpHistoryForRevenge:(PvpHistoryProto *)hist;

@end
