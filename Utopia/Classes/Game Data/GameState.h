//
//  GameState.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/2/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Protocols.pb.h"
#import "UserData.h"
#import <CoreLocation/CoreLocation.h>
#import "FullUserUpdates.h"
#import "StaticStructure.h"

@interface GameState : NSObject {
  NSTimer *_enhanceTimer;
  NSTimer *_expansionTimer;
  NSTimer *_evolutionTimer;
  NSTimer *_healingTimer;
  NSTimer *_combineTimer;
}

@property (nonatomic, assign) BOOL isTutorial;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) int userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int gold;
@property (nonatomic, assign) int silver;
@property (nonatomic, assign) int oil;
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
@property (nonatomic, retain) NSString *facebookId;

@property (nonatomic, retain) NSString *deviceToken;

@property (nonatomic, retain) NSMutableDictionary *staticStructs;
@property (nonatomic, retain) NSMutableDictionary *staticMonsters;
@property (nonatomic, retain) NSMutableDictionary *staticTasks;
@property (nonatomic, retain) NSMutableDictionary *staticCities;
@property (nonatomic, retain) NSArray *persistentEvents;
@property (nonatomic, retain) NSMutableDictionary *eventCooldownTimes;

@property (nonatomic, retain) NSMutableSet *completedTasks;

@property (nonatomic, retain) NSArray *boosterPacks;

@property (nonatomic, retain) NSMutableArray *myMonsters;
@property (nonatomic, retain) NSMutableArray *myStructs;
@property (nonatomic, retain) NSMutableDictionary *myQuests;

@property (nonatomic, retain) NSMutableArray *monsterHealingQueue;
@property (nonatomic, retain) NSDate *monsterHealingQueueEndTime;
@property (nonatomic, retain) NSMutableSet *recentlyHealedMonsterIds;

@property (nonatomic, retain) NSMutableDictionary *inProgressCompleteQuests;
@property (nonatomic, retain) NSMutableDictionary *inProgressIncompleteQuests;
@property (nonatomic, retain) NSMutableDictionary *availableQuests;

@property (nonatomic, retain) NSMutableArray *notifications;
@property (nonatomic, retain) NSMutableArray *globalChatMessages;
@property (nonatomic, retain) NSMutableArray *clanChatMessages;
@property (nonatomic, retain) NSMutableArray *rareBoosterPurchases;
@property (nonatomic, retain) NSMutableArray *privateChats;

@property (nonatomic, retain) NSMutableSet *fbUnacceptedRequestsFromFriends;
@property (nonatomic, retain) NSMutableSet *fbAcceptedRequestsFromMe;

@property (nonatomic, retain) NSMutableArray *unrespondedUpdates;

@property (nonatomic, retain) NSDate *lastLogoutTime;

@property (nonatomic, retain) MinimumClanProto *clan;
@property (nonatomic, retain) NSMutableArray *requestedClans;

@property (nonatomic, retain) NSMutableArray *userExpansions;
@property (nonatomic, retain) NSMutableDictionary *expansionCosts;

@property (nonatomic, retain) NSMutableDictionary *staticLevelInfos;

@property (nonatomic, retain) UserEnhancement *userEnhancement;
@property (nonatomic, retain) UserEvolution *userEvolution;

+ (GameState *) sharedGameState;
+ (void) purgeSingleton;

- (MinimumUserProto *) minUser;
- (MinimumUserProtoWithLevel *) minUserWithLevel;
- (FullUserProto *) convertToFullUserProto;
- (void) updateUser:(FullUserProto *)user timestamp:(uint64_t)time;

- (id) getStaticDataFrom:(NSDictionary *)dict withId:(int)itemId;
- (id<StaticStructure>) structWithId:(int)structId;
- (FullCityProto *)cityWithId:(int)cityId;
- (FullTaskProto *) taskWithId:(int)taskId;
- (FullQuestProto *) questForId:(int)questId;
- (BoosterPackProto *) boosterPackForId:(int)packId;
- (MonsterProto *) monsterWithId:(int)monsterId;
- (PersistentEventProto *) persistentEventWithId:(int)eventId;
- (PersistentEventProto *) currentPersistentEventWithType:(PersistentEventProto_EventType)type;

- (BOOL) isTaskUnlocked:(int)taskId;
- (BOOL) isCityUnlocked:(int)cityId;
- (NSArray *) taskIdsToUnlockMoreTasks;

- (void) addToMyStructs:(NSArray *)myStructs;
- (void) addToMyMonsters:(NSArray *)myMonsters;
- (void) addToMyQuests:(NSArray *)quests;
- (void) addToAvailableQuests:(NSArray *)quests;
- (void) addToInProgressCompleteQuests:(NSArray *)quests;
- (void) addToInProgressIncompleteQuests:(NSArray *)quests;
- (void) addNotification:(UserNotification *)un;
- (void) addChatMessage:(MinimumUserProtoWithLevel *)sender message:(NSString *)msg scope:(GroupChatScope)scope isAdmin:(BOOL)isAdmin;
- (void) addChatMessage:(ChatMessage *)cm scope:(GroupChatScope) scope;
- (void) addPrivateChat:(PrivateChatPostProto *)post;
- (void) addBoosterPurchase:(RareBoosterPurchaseProto *)bp;
- (void) addToStaticLevelInfos:(NSArray *)lurep;
- (void) addToExpansionCosts:(NSArray *)costs;
- (void) addToEventCooldownTimes:(NSArray *)arr;

- (void) addInventorySlotsRequests:(NSArray *)invites;
- (NSArray *) acceptedFbRequestsForUserStructId:(int)userStructId fbStructLevel:(int)level;
- (NSSet *) facebookIdsAlreadyUsed;

- (void) addUserMonsterHealingItemToEndOfQueue:(UserMonsterHealingItem *)item;
- (void) removeUserMonsterHealingItem:(UserMonsterHealingItem *)item;
- (void) addAllMonsterHealingProtos:(NSArray *)items;
- (void) saveHealthProgressesFromIndex:(int)index;
- (void) readjustAllMonsterHealingProtos;

- (void) addEnhancingItemToEndOfQueue:(EnhancementItem *)item;
- (void) removeEnhancingItem:(EnhancementItem *)item;
- (void) addEnhancementProto:(UserEnhancementProto *)proto;

- (UserMonster *) myMonsterWithUserMonsterId:(int)userMonsterId;
- (UserMonster *) myMonsterWithSlotNumber:(int)slotNum;
- (NSArray *) allMonstersOnMyTeam;
- (NSArray *) allBattleAvailableMonstersOnTeam;
- (UserStruct *) myStructWithId:(int)structId;
- (UserStruct *) myTownHall;
- (UserStruct *) myLaboratory;
- (NSArray *) myValidHospitals;
- (int) maxHospitalQueueSize;
- (UserQuest *) myQuestWithId:(int)questId;
- (NSArray *) allCurrentQuests;

- (void) updateStaticData:(StaticDataProto *)proto;
- (void) addToStaticStructs:(NSArray *)arr;
- (void) addToStaticMonsters:(NSArray *)arr;
- (void) addToStaticTasks:(NSArray *)arr;
- (void) addToStaticCities:(NSArray *)arr;
- (void) addStaticBoosterPacks:(NSArray *)bpps;

- (void) addUnrespondedUpdate:(id<GameStateUpdate>)up;
- (void) addUnrespondedUpdates:(id<GameStateUpdate>)field1, ... NS_REQUIRES_NIL_TERMINATION;
- (void) removeAndUndoAllUpdatesForTag:(int)tag;
- (void) removeFullUserUpdatesForTag:(int)tag;
- (void) removeNonFullUserUpdatesForTag:(int)tag;

- (int) maxCash;
- (int) maxOil;
- (int) maxInventorySlots;

- (int) expNeededForLevel:(int)level;
- (int) currentExpForLevel;
- (int) expDeltaNeededForNextLevel;

- (void) beginHealingTimer;
- (void) stopHealingTimer;

- (void) beginEnhanceTimer;
- (void) stopEnhanceTimer;

- (void) beginEvolutionTimer;
- (void) stopEvolutionTimer;

- (void) beginCombineTimer;
- (void) stopCombineTimer;

- (UserExpansion *) getExpansionForX:(int)x y:(int)y;
- (int) numCompletedExpansions;
- (BOOL) isExpanding;
- (UserExpansion *) currentExpansion;
- (void) beginExpansionTimer;
- (void) stopExpansionTimer;

- (void) addToRequestedClans:(NSArray *)arr;

- (BOOL) hasBeginnerShield;

@end
