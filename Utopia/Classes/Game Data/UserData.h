//
//  UserData.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/9/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"

@class ForgeAttempt;

@interface UserMonster : NSObject

@property (nonatomic, assign) int userMonsterId;
@property (nonatomic, assign) int userId;
@property (nonatomic, assign) int monsterId;
@property (nonatomic, assign) int curHealth;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int experience;
@property (nonatomic, assign) int teamSlot;
@property (nonatomic, assign) int isComplete;
@property (nonatomic, assign) int numPieces;
@property (nonatomic, retain) NSDate *combineStartTime;

+ (id) userMonsterWithProto:(FullUserMonsterProto *)proto;
+ (id) userMonsterWithTaskStageMonsterProto:(TaskStageMonsterProto *)proto;
- (BOOL) isHealing;
- (BOOL) isEnhancing;
- (BOOL) isSacrificing;

@end

@interface UserMonsterHealingItem : NSObject

@property (nonatomic, assign) int userMonsterId;
@property (nonatomic, assign) int userId;
@property (nonatomic, retain) NSDate *expectedStartTime;

+ (id) userMonsterHealingItemWithProto:(UserMonsterHealingProto *)proto;

- (float) currentPercentageOfHealth;
- (int) secondsForCompletion;
- (NSDate *) expectedEndTime;
- (UserMonsterHealingProto *) convertToProto;

@end

@interface EnhancementItem : NSObject

+ (id) itemWithUserEnhancementItemProto:(UserEnhancementItemProto *)proto;

@property (nonatomic, assign) int userMonsterId;
@property (nonatomic, retain) NSDate *expectedStartTime;

- (float) currentPercentage;
- (int) secondsForCompletion;
- (NSDate *) expectedEndTime;
- (UserMonster *)userMonster;
- (UserEnhancementItemProto *) convertToProto;

@end

@interface UserEnhancement : NSObject

@property (nonatomic, retain) EnhancementItem *baseMonster;
@property (nonatomic, retain) NSMutableArray *feeders;

+(id) enhancementWithUserEnhancementProto:(UserEnhancementProto *)proto;

- (float) currentPercentageOfLevel;
- (float) finalPercentageFromCurrentLevel;

@end

typedef enum {
  kRetrieving = 1,
  kWaitingForIncome,
  kUpgrading,
  kBuilding
} UserStructState;

@interface UserStruct : NSObject 

@property (nonatomic, assign) int userStructId;
@property (nonatomic, assign) int userId;
@property (nonatomic, assign) int structId;
@property (nonatomic, retain) NSDate *lastRetrieved;
@property (nonatomic, assign) CGPoint coordinates;
@property (nonatomic, assign) int level;
@property (nonatomic, retain) NSDate *purchaseTime;
@property (nonatomic, retain) NSDate *lastUpgradeTime;
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, assign) StructOrientation orientation;

+ (id) userStructWithProto:(FullUserStructureProto *)proto;
- (UserStructState) state;
- (FullStructureProto *) fsp;

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
@property (nonatomic, retain) NSDate *time;
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

@property (nonatomic, retain) MinimumUserProto *sender;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, assign) BOOL isAdmin;

- (id) initWithProto:(GroupChatMessageProto *)p;

@end

@interface UserExpansion : NSObject

@property (nonatomic, assign) int userId;
@property (nonatomic, assign) int xPosition;
@property (nonatomic, assign) int yPosition;
@property (nonatomic, assign) BOOL isExpanding;
@property (nonatomic, retain) NSDate *lastExpandTime;

+ (id) userExpansionWithUserCityExpansionDataProto:(UserCityExpansionDataProto *)proto;

@end

typedef enum {
  RewardTypeMonster = 1,
  RewardTypeSilver,
  RewardTypeGold,
  RewardTypeExperience
} RewardType;

@interface Reward : NSObject

@property (nonatomic, assign) int monsterId;
@property (nonatomic, assign) BOOL isPuzzlePiece;
@property (nonatomic, assign) int silverAmount;
@property (nonatomic, assign) int goldAmount;
@property (nonatomic, assign) int expAmount;
@property (nonatomic, assign) RewardType type;

+ (NSArray *) createRewardsForDungeon:(BeginDungeonResponseProto *)proto;
+ (NSArray *) createRewardsForQuest:(FullQuestProto *)quest;

- (id) initWithMonsterId:(int)monsterId isPuzzlePiece:(BOOL)isPuzzlePiece;
- (id) initWithSilverAmount:(int)silverAmount;
- (id) initWithGoldAmount:(int)goldAmount;
- (id) initWithExpAmount:(int)expAmount;

@end

@interface UserQuest : NSObject

@property (nonatomic, assign) int userId;
@property (nonatomic, assign) int questId;
@property (nonatomic, assign) BOOL isRedeemed;
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, assign) int progress;

+ (id) questWithProto:(FullUserQuestProto *)proto;
- (id) initWithProto:(FullUserQuestProto *)proto;

@end
