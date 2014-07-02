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

@class ForgeAttempt;
@class MSDate;

@interface MonsterProto (Name)

- (NSString *) monsterName;

@end

@interface UserMonster : NSObject

@property (nonatomic, assign) uint64_t userMonsterId;
@property (nonatomic, assign) int userId;
@property (nonatomic, assign) int monsterId;
@property (nonatomic, assign) int curHealth;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int experience;
@property (nonatomic, assign) int teamSlot;
@property (nonatomic, assign) int isComplete;
@property (nonatomic, assign) int numPieces;
@property (nonatomic, retain) MSDate *combineStartTime;

+ (id) userMonsterWithProto:(FullUserMonsterProto *)proto;
+ (id) userMonsterWithMinProto:(MinimumUserMonsterProto *)proto;
+ (id) userMonsterWithTaskStageMonsterProto:(TaskStageMonsterProto *)proto;
- (BOOL) isHealing;
- (BOOL) isEnhancing;
- (BOOL) isEvolving;
- (BOOL) isSacrificing;
- (BOOL) isOnAMiniJob;
- (BOOL) isAvailable;
- (BOOL) isAvailableForSelling;
- (int) sellPrice;

- (MonsterProto *) staticMonster;
- (NSString *) statusString;
- (NSString *) statusImageName;
- (MonsterProto *) staticEvolutionMonster;
- (MonsterProto *) staticEvolutionCatalystMonster;
- (MonsterLevelInfoProto *) levelInfo;
- (BOOL) isCombining;
- (int) timeLeftForCombining;

- (FullUserMonsterProto *) convertToProto;
- (MinimumUserMonsterProto *) convertToMinimumProto;

- (NSComparisonResult) compare:(UserMonster *)um;

@end

@interface UserMonsterHealingItem : NSObject

@property (nonatomic, assign) uint64_t userMonsterId;
@property (nonatomic, assign) int userId;
@property (nonatomic, retain) MSDate *queueTime;
@property (nonatomic, retain) MSDate *endTime;

@property (nonatomic, assign) float healthProgress;
@property (nonatomic, assign) int priority;
@property (nonatomic, assign) float totalSeconds;
@property (nonatomic, retain) NSArray *timeDistribution;

+ (id) userMonsterHealingItemWithProto:(UserMonsterHealingProto *)proto;

- (UserMonster *)userMonster;
- (UserMonsterHealingProto *) convertToProto;

- (float) totalSeconds;
- (float) currentPercentage;
- (float) currentPercentageWithUserMonster:(UserMonster *)um;

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

@interface EnhancementItem : NSObject

+ (id) itemWithUserEnhancementItemProto:(UserEnhancementItemProto *)proto;

@property (nonatomic, assign) uint64_t userMonsterId;
@property (nonatomic, assign) int enhancementCost;
@property (nonatomic, retain) MSDate *expectedStartTime;

- (UserMonster *)userMonster;
- (UserEnhancementItemProto *) convertToProto;

@end

@interface UserEnhancement : NSObject

@property (nonatomic, retain) EnhancementItem *baseMonster;
@property (nonatomic, retain) NSMutableArray *feeders;

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

- (id) clone;

@end

@interface UserEvolution : NSObject

@property (nonatomic, assign) uint64_t userMonsterId1;
@property (nonatomic, assign) uint64_t userMonsterId2;
@property (nonatomic, assign) uint64_t catalystMonsterId;
@property (nonatomic, retain) MSDate *startTime;

+ (id) evolutionWithUserEvolutionProto:(UserMonsterEvolutionProto *)proto;
+ (id) evolutionWithEvoItem:(EvoItem *)evo time:(MSDate *)time;
- (MSDate *) endTime;
- (UserMonsterEvolutionProto *) convertToProto;
- (EvoItem *) evoItem;

@end

@interface UserStruct : NSObject 

@property (nonatomic, assign) int userStructId;
@property (nonatomic, assign) int userId;
@property (nonatomic, assign) int structId;
@property (nonatomic, assign) int fbInviteStructLvl;
@property (nonatomic, retain) MSDate *lastRetrieved;
@property (nonatomic, assign) CGPoint coordinates;
@property (nonatomic, retain) MSDate *purchaseTime;
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, assign) StructOrientation orientation;

+ (id) userStructWithProto:(FullUserStructureProto *)proto;
+ (id) userStructWithTutorialStructProto:(TutorialStructProto *)proto;
- (id<StaticStructure>) staticStructForPrevLevel;
- (id<StaticStructure>) staticStruct;
- (id<StaticStructure>) staticStructForNextLevel;
- (id<StaticStructure>) maxStaticStruct;
- (NSArray *) allStaticStructs;
- (id<StaticStructure>) staticStructForFbLevel;
- (id<StaticStructure>) staticStructForNextFbLevel;
- (int) maxLevel;
- (int) baseStructId;
- (int) numBonusSlots;

- (int) numResourcesAvailable;

- (MSDate *) buildCompleteDate;
- (NSTimeInterval) timeLeftForBuildComplete;

@end

@interface UserObstacle : NSObject

@property (nonatomic, assign) int userObstacleId;
@property (nonatomic, assign) int userId;
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

@interface ChatMessage : NSObject

@property (nonatomic, retain) MinimumUserProtoWithLevel *sender;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, retain) MSDate *date;
@property (nonatomic, assign) BOOL isAdmin;

- (id) initWithProto:(GroupChatMessageProto *)p;

@end

@interface UserExpansion : NSObject

@property (nonatomic, assign) int userId;
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
  RewardTypeItem
} RewardType;

@interface Reward : NSObject

@property (nonatomic, assign) int monsterId;
@property (nonatomic, assign) int itemId;
@property (nonatomic, assign) BOOL isPuzzlePiece;
@property (nonatomic, assign) int silverAmount;
@property (nonatomic, assign) int oilAmount;
@property (nonatomic, assign) int goldAmount;
@property (nonatomic, assign) int expAmount;
@property (nonatomic, assign) RewardType type;

+ (NSArray *) createRewardsForDungeon:(BeginDungeonResponseProto *)proto;
+ (NSArray *) createRewardsForDungeon:(BeginDungeonResponseProto *)proto tillStage:(int)stageNum;
+ (NSArray *) createRewardsForQuest:(FullQuestProto *)quest;
+ (NSArray *) createRewardsForMiniJob:(MiniJobProto *)miniJob;
+ (NSArray *) createRewardsForPvpProto:(PvpProto *)pvp;

- (id) initWithMonsterId:(int)monsterId isPuzzlePiece:(BOOL)isPuzzlePiece;
- (id) initWithItemId:(int)monsterId;
- (id) initWithSilverAmount:(int)silverAmount;
- (id) initWithOilAmount:(int)oilAmount;
- (id) initWithGoldAmount:(int)goldAmount;
- (id) initWithExpAmount:(int)expAmount;

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

@property (nonatomic, assign) int userId;
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

@property (nonatomic, assign) uint64_t userMiniJobId;
@property (nonatomic, assign) int baseDmgReceived;
@property (nonatomic, assign) int durationMinutes;
@property (nonatomic, retain) MSDate *timeStarted;
@property (nonatomic, retain) NSArray *userMonsterIds;
@property (nonatomic, retain) MSDate *timeCompleted;
@property (nonatomic, retain) MiniJobProto *miniJob;

+ (id) userMiniJobWithProto:(UserMiniJobProto *)proto;

- (NSDictionary *) damageDealtPerUserMonsterId;

@end
