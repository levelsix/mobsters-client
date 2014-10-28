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
#import "ClanHelpUtil.h"
#import "ChatObject.h"

@interface GameState : NSObject {
  NSTimer *_evolutionTimer;
  NSTimer *_healingTimer;
  NSTimer *_combineTimer;
  NSTimer *_miniJobTimer;
}

@property (nonatomic, assign) BOOL isTutorial;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) int userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int gems;
@property (nonatomic, assign) int cash;
@property (nonatomic, assign) int oil;
@property (nonatomic, retain) NSString *referralCode;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, assign) int skillPoints;
@property (nonatomic, assign) int experience;
@property (nonatomic, assign) int tasksCompleted;
@property (nonatomic, assign) int numReferrals;
@property (nonatomic, assign) int elo;
@property (nonatomic, assign) int playerHasBoughtInAppPurchase;
@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic, retain) MSDate *createTime;
@property (nonatomic, assign) BOOL hasReceivedfbReward;
@property (nonatomic, assign) int numBeginnerSalesPurchased;
@property (nonatomic, retain) MSDate *shieldEndTime;
@property (nonatomic, retain) MSDate *lastObstacleCreateTime;
@property (nonatomic, retain) MSDate *lastMiniJobSpawnTime;
@property (nonatomic, assign) int avatarMonsterId;
@property (nonatomic, retain) MSDate *lastFreeGachaSpin;

@property (nonatomic, assign) int allowQuestSkipping;

@property (nonatomic, retain) UserPvpLeagueProto *pvpLeague;

@property (nonatomic, retain) NSString *kabamNaid;
@property (nonatomic, retain) NSString *facebookId;
@property (nonatomic, retain) NSString *gameCenterId;

@property (nonatomic, retain) NSString *deviceToken;

@property (nonatomic, retain) NSMutableDictionary *staticStructs;
@property (nonatomic, retain) NSMutableDictionary *staticMonsters;
@property (nonatomic, retain) NSMutableDictionary *staticTasks;
@property (nonatomic, retain) NSMutableDictionary *staticCities;
@property (nonatomic, retain) NSMutableDictionary *staticItems;
@property (nonatomic, retain) NSMutableDictionary *staticObstacles;
@property (nonatomic, retain) NSMutableDictionary *staticPrerequisites;
@property (nonatomic, retain) NSArray *persistentEvents;
@property (nonatomic, retain) NSMutableDictionary *eventCooldownTimes;
@property (nonatomic, retain) NSArray *staticClanIcons;
@property (nonatomic, retain) NSArray *staticLeagues;
@property (nonatomic, retain) NSMutableDictionary *staticAchievements;
@property (nonatomic, retain) NSArray *staticMapElements;

@property (nonatomic, retain) NSArray *persistentClanEvents;
@property (nonatomic, retain) PersistentClanEventClanInfoProto *curClanRaidInfo;
@property (nonatomic, retain) NSMutableArray *curClanRaidUserInfos;
@property (nonatomic, retain) NSMutableDictionary *staticRaids;

@property (nonatomic, retain) NSMutableSet *completedTasks;

@property (nonatomic, retain) NSArray *boosterPacks;

@property (nonatomic, retain) NSMutableArray *myMonsters;
@property (nonatomic, retain) NSMutableArray *myStructs;
@property (nonatomic, retain) NSMutableArray *myObstacles;
@property (nonatomic, retain) NSMutableDictionary *myQuests;
@property (nonatomic, retain) NSMutableDictionary *myAchievements;
@property (nonatomic, retain) NSMutableArray *myMiniJobs;
@property (nonatomic, retain) NSMutableArray *myItems;

@property (nonatomic, retain) NSMutableArray *monsterHealingQueue;
@property (nonatomic, retain) MSDate *monsterHealingQueueEndTime;
@property (nonatomic, retain) NSMutableSet *recentlyHealedMonsterIds;
@property (nonatomic, assign) BOOL hasShownFreeHealingQueueSpeedup;
@property (nonatomic, assign) float totalTimeForHealQueue;

@property (nonatomic, retain) NSMutableDictionary *inProgressCompleteQuests;
@property (nonatomic, retain) NSMutableDictionary *inProgressIncompleteQuests;
@property (nonatomic, retain) NSMutableDictionary *availableQuests;

@property (nonatomic, retain) NSMutableArray *battleHistory;

@property (nonatomic, retain) NSMutableArray *notifications;
@property (nonatomic, retain) NSMutableArray *globalChatMessages;
@property (nonatomic, retain) NSMutableArray *clanChatMessages;
@property (nonatomic, retain) NSMutableArray *rareBoosterPurchases;
@property (nonatomic, retain) NSMutableArray *privateChats;

@property (nonatomic, retain) NSMutableSet *fbUnacceptedRequestsFromFriends;
@property (nonatomic, retain) NSMutableSet *fbAcceptedRequestsFromMe;

@property (nonatomic, retain) NSMutableArray *unrespondedUpdates;

@property (nonatomic, retain) MSDate *lastLogoutTime;
@property (nonatomic, assign) int64_t lastLoginTimeNum;

@property (nonatomic, retain) MinimumClanProto *clan;
@property (nonatomic, retain) NSMutableArray *requestedClans;
@property (nonatomic, assign) UserClanStatus myClanStatus;
@property (nonatomic, retain) ClanHelpUtil *clanHelpUtil;

@property (nonatomic, retain) NSMutableArray *userExpansions;
@property (nonatomic, retain) NSMutableDictionary *expansionCosts;

@property (nonatomic, retain) NSMutableDictionary *staticLevelInfos;
@property (nonatomic, retain) NSMutableDictionary *battleDialogueInfo;

@property (nonatomic, retain) NSMutableDictionary *staticSkills;

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
- (ClanRaidProto *) raidWithId:(int)raidId;
- (FullTaskProto *) taskWithId:(int)taskId;
- (TaskMapElementProto *) mapElementWithId:(int)mapElementId;
- (TaskMapElementProto *) mapElementWithTaskId:(int)mapElementId;
- (AchievementProto *) achievementWithId:(int)achievementId;
- (FullTaskProto *) taskWithCityId:(int)cityId assetId:(int)assetId;
- (FullQuestProto *) questForId:(int)questId;
- (ItemProto *) itemForId:(int)itemId;
- (BoosterPackProto *) boosterPackForId:(int)packId;
- (MonsterProto *) monsterWithId:(int)monsterId;
- (ObstacleProto *) obstacleWithId:(int)obstacleId;
- (NSArray *) prerequisitesForGameType:(GameType)gt gameEntityId:(int)gameEntityId;
- (ClanIconProto *) clanIconWithId:(int)iconId;
- (PvpLeagueProto *) leagueForId:(int)leagueId;
- (PersistentEventProto *) persistentEventWithId:(int)eventId;
- (PersistentEventProto *) currentPersistentEventWithType:(PersistentEventProto_EventType)type;
- (MonsterBattleDialogueProto *) battleDialogueForMonsterId:(int)monsterId type:(MonsterBattleDialogueProto_DialogueType)type;

- (void) unlockAllTasks;
- (BOOL) isTaskUnlocked:(int)taskId;
- (BOOL) isTaskCompleted:(int)taskId;
- (BOOL) isCityUnlocked:(int)cityId;
- (NSArray *) taskIdsToUnlockMoreTasks;

- (void) addToMyStructs:(NSArray *)myStructs;
- (void) addToMyObstacles:(NSArray *)myObstacles;
- (void) addToMyMonsters:(NSArray *)myMonsters;
- (void) addToMyQuests:(NSArray *)quests;
- (void) addToMyAchievements:(NSArray *)achievements;
- (void) addToAvailableQuests:(NSArray *)quests;
- (void) addToInProgressCompleteQuests:(NSArray *)quests;
- (void) addToInProgressIncompleteQuests:(NSArray *)quests;
- (void) addNotification:(UserNotification *)un;
- (void) addToMiniJobs:(NSArray *)miniJobs isNew:(BOOL)isNew;
- (void) addToMyItems:(NSArray *)items;
- (void) addChatMessage:(MinimumUserProtoWithLevel *)sender message:(NSString *)msg scope:(GroupChatScope)scope isAdmin:(BOOL)isAdmin;
- (void) addChatMessage:(ChatMessage *)cm scope:(GroupChatScope) scope;
- (void) addPrivateChat:(PrivateChatPostProto *)post;
- (void) addBoosterPurchase:(RareBoosterPurchaseProto *)bp;
- (void) addToStaticLevelInfos:(NSArray *)lurep;
- (void) addToExpansionCosts:(NSArray *)costs;
- (void) addToEventCooldownTimes:(NSArray *)arr;

- (NSArray *) allClanChatObjects;

- (void) addInventorySlotsRequests:(NSArray *)invites;
- (NSArray *) acceptedFbRequestsForUserStructId:(int)userStructId fbStructLevel:(int)level;
- (NSSet *) facebookIdsAlreadyUsed;

- (void) addUserMonsterHealingItemToEndOfQueue:(UserMonsterHealingItem *)item;
- (void) removeUserMonsterHealingItem:(UserMonsterHealingItem *)item;
- (void) addAllMonsterHealingProtos:(NSArray *)items;
- (void) saveHealthProgressesFromIndex:(NSInteger)index;
- (void) readjustAllMonsterHealingProtos;

- (void) addClanRaidUserInfo:(PersistentClanEventUserInfoProto *)info;

- (UserMonster *) myMonsterWithUserMonsterId:(uint64_t)userMonsterId;
- (UserMonster *) myMonsterWithSlotNumber:(NSInteger)slotNum;
- (NSArray *) allMonstersOnMyTeam;
- (NSArray *) allBattleAvailableMonstersOnTeam;
- (NSArray *) allBattleAvailableAliveMonstersOnTeam;
- (UserStruct *) myStructWithId:(int)structId;
- (UserStruct *) myTownHall;
- (UserStruct *) myLaboratory;
- (UserStruct *) myEvoChamber;
- (UserStruct *) myTeamCenter;
- (UserStruct *) myMiniJobCenter;
- (UserStruct *) myClanHouse;
- (NSArray *) allHospitals;
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
- (void) addToStaticObstacles:(NSArray *)arr;

- (void) addUnrespondedUpdate:(id<GameStateUpdate>)up;
- (void) addUnrespondedUpdates:(id<GameStateUpdate>)field1, ... NS_REQUIRES_NIL_TERMINATION;
- (void) removeAndUndoAllUpdatesForTag:(int)tag;
- (void) removeFullUserUpdatesForTag:(int)tag;
- (void) removeNonFullUserUpdatesForTag:(int)tag;

- (int) maxCash;
- (int) maxOil;
- (int) maxInventorySlots;
- (int) maxTeamCost;

- (int) expNeededForLevel:(int)level;
- (int) currentExpForLevel;
- (int) expDeltaNeededForNextLevel;

- (void) beginHealingTimer;
- (void) stopHealingTimer;

- (void) beginEvolutionTimer;
- (void) stopEvolutionTimer;

- (void) beginCombineTimer;
- (void) stopCombineTimer;

- (void) beginMiniJobTimerShowFreeSpeedupImmediately:(BOOL)freeSpeedup;
- (void) stopMiniJobTimer;

- (void) addToRequestedClans:(NSArray *)arr;

- (PersistentClanEventUserInfoProto *) myClanRaidInfo;

- (BOOL) hasActiveShield;
- (BOOL) hasDailyFreeSpin;
- (int) numberOfFreeSpinsForBoosterPack:(int)boosterPackId;

- (BOOL) canAskForClanHelp;

- (int) lastLeagueShown;
- (void) currentLeagueWasShown;
- (BOOL) hasShownCurrentLeague;

@end
