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
#define BATTLE_USER_MONSTERS_GAINED_KEY @"BattleMonstersGained"
#define BATTLE_SECTION_COMPLETE_KEY @"BattleSectionComplete"
#define BATTLE_SECTION_NAME_KEY @"BattleSectionName"
#define BATTLE_SECTION_ITEM_KEY @"BattleSectionItem"

@interface DungeonBattleLayer : NewBattleLayer {
  BOOL _receivedEndDungeonResponse;
  BOOL _waitingForEndDungeonResponse;
  
  BOOL _checkedQuests;
  
  BOOL _isResumingState;
  BOOL _isDownloading;
  BOOL _damageWasDealt;
  
  int _numAttemptedRunaways;
  BOOL _didRunaway;
  BOOL _numContinues;
  
  uint64_t _resumedUserMonsterId;
}

@property (nonatomic, retain) IBOutlet NSString *dungeonType;
@property (nonatomic, retain) IBOutlet UIView *runawayMiddleView;
@property (nonatomic, retain) IBOutlet UILabel *runawayPercentLabel;

@property (nonatomic, retain) NSArray *userMonstersGained;
@property (nonatomic, assign) int itemIdGained;
@property (nonatomic, retain) NSString *sectionName;

@property (nonatomic, retain) BeginDungeonResponseProto *dungeonInfo;

- (void) checkQuests;
- (void) resumeFromUserTask:(MinimumUserTaskProto *)task stages:(NSArray *)stages;
- (void) handleEndDungeonResponseProto:(FullEvent *)fe;

- (void) sendServerDungeonProgress;

@end
