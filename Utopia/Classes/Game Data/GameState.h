//
//  GameState.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/2/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Info.pb.h"
#import "UserData.h"
#import <CoreLocation/CoreLocation.h>
#import "FullUserUpdates.h"

@interface GameState : NSObject {
  NSTimer *_enhanceTimer;
  NSTimer *_expansionTimer;
  NSTimer *_goldmineTimer;
}

@property (nonatomic, assign) BOOL isTutorial;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) int userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int gold;
@property (nonatomic, assign) int silver;
@property (nonatomic, retain) NSString *referralCode;
@property (nonatomic, assign) int battlesWon;
@property (nonatomic, assign) int battlesLost;
@property (nonatomic, assign) int flees;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, assign) int skillPoints;
@property (nonatomic, assign) int experience;
@property (nonatomic, assign) int tasksCompleted;
@property (nonatomic, assign) int numReferrals;
@property (nonatomic, assign) int playerHasBoughtInAppPurchase;
@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic, retain) NSDate *createTime;
@property (nonatomic, assign) BOOL hasReceivedfbReward;
@property (nonatomic, assign) int numBeginnerSalesPurchased;
@property (nonatomic, assign) BOOL hasActiveShield;

@property (nonatomic, retain) NSString *kabamNaid;

@property (nonatomic, retain) NSString *deviceToken;

@property (nonatomic, assign) int expRequiredForCurrentLevel;
@property (nonatomic, assign) int expRequiredForNextLevel;

@property (nonatomic, retain) NSMutableDictionary *staticStructs;
@property (nonatomic, retain) NSMutableDictionary *staticMonsters;
@property (nonatomic, retain) NSMutableDictionary *staticTasks;
@property (nonatomic, retain) NSMutableDictionary *staticBosses;
@property (nonatomic, retain) NSMutableDictionary *staticQuests;
@property (nonatomic, retain) NSMutableDictionary *staticCities;
@property (nonatomic, retain) NSMutableDictionary *staticBuildStructJobs;
@property (nonatomic, retain) NSMutableDictionary *staticDefeatTypeJobs;
@property (nonatomic, retain) NSMutableDictionary *staticUpgradeStructJobs;

@property (nonatomic, retain) NSArray *carpenterStructs;
@property (nonatomic, retain) NSArray *boosterPacks;

@property (nonatomic, retain) NSMutableArray *myMonsters;
@property (nonatomic, retain) NSMutableArray *myStructs;
@property (nonatomic, retain) NSMutableDictionary *myCities;

@property (nonatomic, retain) NSMutableDictionary *inProgressCompleteQuests;
@property (nonatomic, retain) NSMutableDictionary *inProgressIncompleteQuests;
@property (nonatomic, retain) NSMutableDictionary *availableQuests;

@property (nonatomic, retain) NSMutableArray *notifications;
@property (nonatomic, retain) NSMutableArray *globalChatMessages;
@property (nonatomic, retain) NSMutableArray *clanChatMessages;
@property (nonatomic, retain) NSMutableArray *rareBoosterPurchases;
@property (nonatomic, retain) NSMutableArray *privateChats;

@property (nonatomic, retain) NSMutableArray *unrespondedUpdates;

@property (nonatomic, retain) NSDate *lastLogoutTime;

@property (nonatomic, retain) MinimumClanProto *clan;
@property (nonatomic, retain) NSMutableArray *requestedClans;

@property (nonatomic, retain) NSMutableArray *userExpansions;

+ (GameState *) sharedGameState;
+ (void) purgeSingleton;

- (MinimumUserProto *) minUser;
- (void) updateUser:(FullUserProto *)user timestamp:(uint64_t)time;

- (id) getStaticDataFrom:(NSDictionary *)dict withId:(int)itemId;
- (FullStructureProto *) structWithId:(int)structId;
- (FullCityProto *)cityWithId:(int)cityId;
- (FullTaskProto *) taskWithId:(int)taskId;
- (FullBossProto *) bossWithId:(int)taskId;
- (FullQuestProto *) questForQuestId:(int)questId;
- (BoosterPackProto *) boosterPackForId:(int)packId;

- (void) addToMyStructs:(NSArray *)myStructs;
- (void) addToMyMonsters:(NSArray *)myMonsters;
- (void) addToAvailableQuests:(NSArray *)quests;
- (void) addToInProgressCompleteQuests:(NSArray *)quests;
- (void) addToInProgressIncompleteQuests:(NSArray *)quests;
- (void) addNotification:(UserNotification *)un;
- (void) addChatMessage:(MinimumUserProto *)sender message:(NSString *)msg scope:(GroupChatScope)scope isAdmin:(BOOL)isAdmin;
- (void) addChatMessage:(ChatMessage *)cm scope:(GroupChatScope) scope;
- (void) addBoosterPurchase:(RareBoosterPurchaseProto *)bp;

- (UserMonster *) myMonsterWithUserMonsterId:(int)userMonsterId;
- (UserStruct *) myStructWithId:(int)structId;

- (void) addToStaticStructs:(NSArray *)arr;
- (void) addToStaticMonsters:(NSArray *)arr;
- (void) addToStaticTasks:(NSArray *)arr;
- (void) addToStaticBosses:(NSArray *)arr;
- (void) addToStaticQuests:(NSArray *)arr;
- (void) addToStaticCities:(NSArray *)arr;
- (void) addToStaticBuildStructJobs:(NSArray *)arr;
- (void) addToStaticUpgradeStructJobs:(NSArray *)arr;
- (void) addStaticBoosterPacks:(NSArray *)bpps;

- (void) addUnrespondedUpdate:(id<GameStateUpdate>)up;
- (void) addUnrespondedUpdates:(id<GameStateUpdate>)field1, ... NS_REQUIRES_NIL_TERMINATION;
- (void) removeAndUndoAllUpdatesForTag:(int)tag;
- (void) removeFullUserUpdatesForTag:(int)tag;
- (void) removeNonFullUserUpdatesForTag:(int)tag;

- (UserExpansion *) getExpansionForX:(int)x y:(int)y;
- (int) numCompletedExpansions;
- (BOOL) isExpanding;
- (UserExpansion *) currentExpansion;
- (void) beginExpansionTimer;
- (void) stopExpansionTimer;

- (void) addToRequestedClans:(NSArray *)arr;

- (BOOL) hasBeginnerShield;

- (void) purgeStaticData;
- (void) reretrieveStaticData;
- (void) clearAllData;

@end
