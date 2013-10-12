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
@property (nonatomic, assign) int durability;
@property (nonatomic, assign) int enhancementPercentage;

+ (id) userMonsterWithProto:(FullUserMonsterProto *)proto;

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


typedef enum {
  kTask = 1,
  kDefeatTypeJob,
  kBuildStructJob,
  kUpgradeStructJob,
  kPossessEquipJob,
  kCoinRetrievalJob,
  kSpecialJob
} JobItemType;

typedef enum {
  WARRIOR_T,
  ARCHER_T,
  MAGE_T
} PlayerClassType;

@interface UserJob : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, assign) int numCompleted;
@property (nonatomic, assign) int total;
@property (nonatomic, assign) JobItemType jobType;
@property (nonatomic, assign) int jobId;

- (id) initWithTask:(FullTaskProto *)p;
- (id) initWithBuildStructJob:(BuildStructJobProto *)p;
- (id) initWithUpgradeStructJob:(UpgradeStructJobProto *)p;
- (id) initWithCoinRetrieval:(int)amount questId:(int)questId;
+ (NSArray *)jobsForQuest:(FullQuestProto *)fqp;

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