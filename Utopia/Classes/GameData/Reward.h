//
//  Reward.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/19/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Protocols.pb.h"

typedef enum {
  RewardTypeMonster = 1,
  RewardTypeCash,
  RewardTypeOil,
  RewardTypeGems,
  RewardTypeGachaToken,
  RewardTypeItem,
  RewardTypePvpLeague,
  RewardTypeReward
} RewardType;

@interface Reward : NSObject

@property (nonatomic, assign) int monsterId;
@property (nonatomic, assign) int monsterLvl; // Lvl 0 means its a piece

@property (nonatomic, assign) int itemId;
@property (nonatomic, assign) int itemQuantity;

@property (nonatomic, assign) int cashAmount;
@property (nonatomic, assign) int oilAmount;
@property (nonatomic, assign) int gemAmount;
@property (nonatomic, assign) int tokenAmount;
@property (nonatomic, assign) int expAmount;

@property (nonatomic, assign) int rankAmount;
@property (nonatomic, assign) BOOL leagueChange;
@property (nonatomic, assign) PvpLeagueProto *league;
@property (nonatomic, assign) RewardType type;

@property (nonatomic, retain) Reward *innerReward;
@property (nonatomic, assign) int rewardQuantity;

+ (NSArray *) createRewardsForDungeon:(BeginDungeonResponseProto *)proto droplessStageNums:(NSArray *)droplessStageNums;
+ (NSArray *) createRewardsForDungeon:(BeginDungeonResponseProto *)proto tillStage:(int)stageNum droplessStageNums:(NSArray *)droplessStageNums;
+ (NSArray *) createRewardsForQuest:(FullQuestProto *)quest;
+ (NSArray *) createRewardsForMiniJob:(MiniJobProto *)miniJob;
+ (NSArray *) createRewardsForPvpProto:(PvpProto *)pvp droplessStageNums:(NSArray *)droplessStageNums isWin:(BOOL)isWin;

- (id) initWithMonsterId:(int)monsterId monsterLvl:(int)monsterLvl;
- (id) initWithItemId:(int)itemId quantity:(int)quantity;
- (id) initWithCashAmount:(int)silverAmount;
- (id) initWithOilAmount:(int)oilAmount;
- (id) initWithGemAmount:(int)goldAmount;
- (id) initWithPvpLeague:(PvpLeagueProto *)newLeague;
- (id) initWithReward:(RewardProto *)reward;

- (NSString *) imgName;
- (NSString *) name;
- (NSString *) shortName;
- (NSString *) shorterName;
- (int) quantity;

@end