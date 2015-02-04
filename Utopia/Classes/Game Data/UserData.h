//
//  UserData.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/9/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"
#import "StaticStructure.h"
#import "ItemObject.h"
#import "HospitalQueue.h"

@class ForgeAttempt;
@class MSDate;

@interface MonsterProto (Name)

- (NSString *) monsterName;

@end

@interface UserMonster : NSObject

@property (nonatomic, retain) NSString *userMonsterUuid;
@property (nonatomic, retain) NSString *userUuid;
@property (nonatomic, assign) int monsterId;
@property (nonatomic, assign) int curHealth;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int experience;
@property (nonatomic, assign) int teamSlot;
@property (nonatomic, assign) int isComplete;
@property (nonatomic, assign) int numPieces;
@property (nonatomic, retain) MSDate *combineStartTime;
@property (nonatomic, assign) int isProtected;
@property (nonatomic, assign) int offensiveSkillId;
@property (nonatomic, assign) int defensiveSkillId;

+ (id) userMonsterWithProto:(FullUserMonsterProto *)proto;
+ (id) userMonsterWithMinProto:(MinimumUserMonsterProto *)proto;
+ (id) userMonsterWithTaskStageMonsterProto:(TaskStageMonsterProto *)proto;
+ (id) userMonsterWithMonsterSnapshotProto:(UserMonsterSnapshotProto *)proto;
- (BOOL) isHealing;
- (BOOL) isEnhancing;
- (BOOL) isEvolving;
- (BOOL) isSacrificing;
- (BOOL) isOnAMiniJob;
- (BOOL) isAvailable;
- (BOOL) isAvailableForSelling;

- (int) sellPrice;
- (int) teamCost;
- (int) feederExp;
- (int) speed;

- (MonsterProto *) staticMonster;
- (NSString *) statusString;
- (NSString *) statusImageName;
- (MonsterProto *) staticEvolutionMonster;
- (MonsterProto *) staticEvolutionCatalystMonster;
- (MonsterLevelInfoProto *) minLevelInfo;
- (MonsterLevelInfoProto *) maxLevelInfo;
- (BOOL) isCombining;
- (int) timeLeftForCombining;

- (FullUserMonsterProto *) convertToProto;
- (MinimumUserMonsterProto *) convertToMinimumProto;

- (NSComparisonResult) compare:(UserMonster *)um;

@end

@interface EvoItem : NSObject

@property (nonatomic, retain) UserMonster *userMonster1;
@property (nonatomic, retain) UserMonster *userMonster2;
@property (nonatomic, assign) UserMonster *catalystMonster;
@property (nonatomic, assign) UserMonster *suggestedMonster;

- (NSArray *) userMonsters;
- (BOOL) isReadyForEvolution;

- (id) initWithUserMonster:(UserMonster *)um1 andUserMonster:(UserMonster *)um2 catalystMonster:(UserMonster *)catalystMonster suggestedMonster:(UserMonster *)suggestedMonster;

@end

@interface EnhancementItem : NSObject {
  // This is used to fake a UserEnhancement with different user monsters that the gamestate's.
  UserMonster *_fakedUserMonster;
}

+ (id) itemWithUserEnhancementItemProto:(UserEnhancementItemProto *)proto;

@property (nonatomic, retain) NSString *userMonsterUuid;
@property (nonatomic, assign) int enhancementCost;
@property (nonatomic, retain) MSDate *expectedStartTime;

- (UserMonster *)userMonster;
- (void) setFakedUserMonster:(UserMonster *)userMonster;
- (UserEnhancementItemProto *) convertToProto;

@end

@interface UserEnhancement : NSObject

@property (nonatomic, retain) EnhancementItem *baseMonster;
@property (nonatomic, retain) NSMutableArray *feeders;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, assign) BOOL hasShownFreeSpeedup;

+ (id) enhancementWithUserEnhancementProto:(UserEnhancementProto *)proto;

- (float) currentPercentageOfLevel;
- (float) finalPercentageFromCurrentLevel;

- (float) percentageIncreaseOfNewUserMonster:(UserMonster *)um roundToPercent:(BOOL)roundToPercent;
- (int) experienceIncreaseOfNewUserMonster:(UserMonster *)um;

- (int) experienceIncreaseOfItem:(EnhancementItem *)item;
- (float) currentPercentageForItem:(EnhancementItem *)item;
- (int) secondsForCompletionForItem:(EnhancementItem *)item;
- (MSDate *) expectedEndTimeForItem:(EnhancementItem *)item;

- (MSDate *) expectedEndTime;
- (int) totalSeconds;

- (id) clone;

@end

@interface UserEvolution : NSObject

@property (nonatomic, retain) NSString *userMonsterUuid1;
@property (nonatomic, retain) NSString *userMonsterUuid2;
@property (nonatomic, retain) NSString *catalystMonsterUuid;
@property (nonatomic, retain) MSDate *startTime;

+ (id) evolutionWithUserEvolutionProto:(UserMonsterEvolutionProto *)proto;
+ (id) evolutionWithEvoItem:(EvoItem *)evo time:(MSDate *)time;
- (MSDate *) endTime;
- (UserMonsterEvolutionProto *) convertToProto;
- (EvoItem *) evoItem;

@end

@interface UserStruct : NSObject 

@property (nonatomic, retain) NSString *userStructUuid;
@property (nonatomic, retain) NSString *userUuid;
@property (nonatomic, assign) int structId;
@property (nonatomic, assign) int fbInviteStructLvl;
@property (nonatomic, retain) MSDate *lastRetrieved;
@property (nonatomic, assign) CGPoint coordinates;
@property (nonatomic, retain) MSDate *purchaseTime;
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, assign) StructOrientation orientation;
@property (nonatomic, assign) BOOL hasShownFreeSpeedup;

+ (id) userStructWithProto:(FullUserStructureProto *)proto;
+ (id) userStructWithTutorialStructProto:(TutorialStructProto *)proto;
- (id<StaticStructure>) staticStructForPrevLevel;
- (id<StaticStructure>) staticStruct;
// In case it's being build right now
- (id<StaticStructure>) staticStructForCurrentConstructionLevel;
- (id<StaticStructure>) staticStructForNextLevel;
- (id<StaticStructure>) maxStaticStruct;
- (NSArray *) allStaticStructs;
- (id<StaticStructure>) staticStructForFbLevel;
- (id<StaticStructure>) staticStructForNextFbLevel;
- (int) maxLevel;
- (int) numBonusSlots;

- (int) baseStructId;
- (BOOL) isAncestorOfStructId:(int)structId;

- (NSArray *) allPrerequisites;
- (NSArray *) incompletePrerequisites;
- (BOOL) satisfiesAllPrerequisites;

- (int) numResourcesAvailable;

- (MSDate *) buildCompleteDate;
- (NSTimeInterval) timeLeftForBuildComplete;

@end

@interface UserObstacle : NSObject

@property (nonatomic, retain) NSString *userObstacleUuid;
@property (nonatomic, assign) int obstacleId;
@property (nonatomic, assign) CGPoint coordinates;
@property (nonatomic, retain) MSDate *removalTime;
@property (nonatomic, assign) StructOrientation orientation;

- (id) initWithObstacleProto:(UserObstacleProto *)obstacle;
- (ObstacleProto *) staticObstacle;
- (MSDate *) endTime;

@end

typedef enum {
  kNotificationBattle,
  kNotificationReferral,
  kNotificationGeneral,
  kNotificationPrivateChat
} NotificationType;

@interface UserNotification : NSObject

@property (nonatomic, retain) MinimumUserProto *otherPlayer;
@property (nonatomic, assign) NotificationType type;
@property (nonatomic, retain) MSDate *time;
@property (nonatomic, assign) BOOL sellerHadLicense;
@property (nonatomic, assign) BattleResult battleResult;
@property (nonatomic, assign) int coinsStolen;
@property (nonatomic, assign) BOOL hasBeenViewed;
@property (nonatomic, retain) NSString *wallPost;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) UIColor *color;

- (id) initWithReferralResponse:(ReferralCodeUsedResponseProto *)proto;
- (id) initWithPrivateChatPost:(PrivateChatPostProto *)proto;
- (id) initWithTitle:(NSString *)t subtitle:(NSString *)st color:(UIColor *)c;

@end

@interface UserExpansion : NSObject

@property (nonatomic, assign) int xPosition;
@property (nonatomic, assign) int yPosition;
@property (nonatomic, assign) BOOL isExpanding;
@property (nonatomic, retain) MSDate *lastExpandTime;

+ (id) userExpansionWithUserCityExpansionDataProto:(UserCityExpansionDataProto *)proto;

@end

typedef enum {
  RewardTypeMonster = 1,
  RewardTypeSilver,
  RewardTypeOil,
  RewardTypeGold,
  RewardTypeExperience,
  RewardTypeItem,
  RewardTypePvpLeague
} RewardType;

@interface Reward : NSObject

@property (nonatomic, assign) int monsterId;
@property (nonatomic, assign) int itemId;
@property (nonatomic, assign) int itemQuantity;
@property (nonatomic, assign) BOOL isPuzzlePiece;
@property (nonatomic, assign) int silverAmount;
@property (nonatomic, assign) int oilAmount;
@property (nonatomic, assign) int goldAmount;
@property (nonatomic, assign) int expAmount;
@property (nonatomic, assign) int rankAmount;
@property (nonatomic, assign) BOOL leagueChange;
@property (nonatomic, assign) PvpLeagueProto *league;
@property (nonatomic, assign) RewardType type;

+ (NSArray *) createRewardsForDungeon:(BeginDungeonResponseProto *)proto droplessStageNums:(NSArray *)droplessStageNums;
+ (NSArray *) createRewardsForDungeon:(BeginDungeonResponseProto *)proto tillStage:(int)stageNum droplessStageNums:(NSArray *)droplessStageNums;
+ (NSArray *) createRewardsForQuest:(FullQuestProto *)quest;
+ (NSArray *) createRewardsForMiniJob:(MiniJobProto *)miniJob;
+ (NSArray *) createRewardsForPvpProto:(PvpProto *)pvp droplessStageNums:(NSArray *)droplessStageNums;

- (id) initWithMonsterId:(int)monsterId isPuzzlePiece:(BOOL)isPuzzlePiece;
- (id) initWithItemId:(int)itemId quantity:(int)quantity;
- (id) initWithSilverAmount:(int)silverAmount;
- (id) initWithOilAmount:(int)oilAmount;
- (id) initWithGoldAmount:(int)goldAmount;
- (id) initWithExpAmount:(int)expAmount;
- (id) initWithPvpLeague:(PvpLeagueProto *)newLeague;

@end

@interface UserQuestJob : NSObject

@property (nonatomic, assign) int questId;
@property (nonatomic, assign) int questJobId;
@property (nonatomic, assign) int progress;
@property (nonatomic, assign) BOOL isComplete;

+ (id) questJobWithProto:(UserQuestJobProto *)proto;
- (UserQuestJobProto *) convertToProto;

@end

@interface UserQuest : NSObject

@property (nonatomic, retain) NSString *userUuid;
@property (nonatomic, assign) int questId;
@property (nonatomic, assign) BOOL isRedeemed;
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, retain) NSMutableDictionary *progressDict;

+ (id) questWithProto:(FullUserQuestProto *)proto;
- (id) initWithProto:(FullUserQuestProto *)proto;

- (void) setProgress:(int)progress forQuestJobId:(int)questJobId;
- (void) setIsCompleteForQuestJobId:(int)questJobId;
- (int) getProgressForQuestJobId:(int)questJobId;
- (UserQuestJob *) jobForId:(int)questJobId;

@end

@interface UserAchievement : NSObject

@property (nonatomic, assign) int achievementId;
@property (nonatomic, assign) BOOL isRedeemed;
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, assign) int progress;

+ (id) userAchievementWithProto:(UserAchievementProto *)achievement;
- (UserAchievementProto *) convertToProto;

@end

typedef enum {
  RequestFromFriendInventorySlots = 1,

} RequestFromFriendType;

@interface RequestFromFriend : NSObject

@property (nonatomic, retain) UserFacebookInviteForSlotProto *invite;
@property (nonatomic, assign) RequestFromFriendType type;

+ (id) requestForInventorySlotsWithInvite:(UserFacebookInviteForSlotProto *)invite;

@end

@interface UserMiniJob : NSObject

@property (nonatomic, retain) NSString *userMiniJobUuid;
@property (nonatomic, assign) int baseDmgReceived;
@property (nonatomic, assign) int durationSeconds;
@property (nonatomic, retain) MSDate *timeStarted;
@property (nonatomic, retain) NSArray *userMonsterUuids;
@property (nonatomic, retain) MSDate *timeCompleted;
@property (nonatomic, retain) MiniJobProto *miniJob;
@property (nonatomic, assign) BOOL hasShownFreeSpeedup;

+ (id) userMiniJobWithProto:(UserMiniJobProto *)proto;

- (MSDate *) tentativeCompletionDate;

- (NSDictionary *) damageDealtPerUserMonsterUuid;

@end
