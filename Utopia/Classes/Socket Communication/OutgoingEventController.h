//
//  OutgoingEventController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobstersEventProtocol.pb.h"
#import "UserData.h"
#import <CoreLocation/CoreLocation.h>
#import "StoreKit/StoreKit.h"

@interface OutgoingEventController : NSObject

+ (OutgoingEventController *) sharedOutgoingEventController;

- (void) createUser;

- (void) startupWithDelegate:(id)delegate;
- (void) logout;

- (void) inAppPurchase:(NSString *)receipt goldAmt:(int)gold cashAmt:(int)cash product:(SKProduct *)product;

- (UserStruct *) purchaseNormStruct:(int)structId atX:(int)x atY:(int)y;
- (void) moveNormStruct:(UserStruct *)userStruct atX:(int)x atY:(int)y;
- (void) rotateNormStruct:(UserStruct *)userStruct to:(StructOrientation)orientation;
- (void) retrieveFromNormStructure:(UserStruct *)userStruct;
- (void) sellNormStruct:(UserStruct *)userStruct;
- (void) instaUpgrade:(UserStruct *)userStruct;
- (void) normStructWaitComplete:(UserStruct *)userStruct;
- (void) upgradeNormStruct:(UserStruct *)userStruct;

- (void) loadPlayerCity:(NSString *)userUuid withDelegate:(id)delegate;
- (void) loadNeutralCity:(int)cityId withDelegate:(id)delegate;

- (void) levelUp;

- (UserQuest *) acceptQuest:(int)questId;
- (void) redeemQuest:(int)questId delegate:(id)delegate;
- (void) questProgress:(int)questId;
- (UserQuest *) donateForQuest:(int)questId monsterUuids:(NSArray *)monsterUuids;

- (void) retrieveUsersForUserUuids:(NSArray *)userUuids includeCurMonsterTeam:(BOOL)includeCurMonsterTeam delegate:(id)delegate;

- (void) enableApns:(NSData *)deviceToken;

- (void) fbConnectReward;

- (void) sendGroupChat:(GroupChatScope)scope message:(NSString *)msg;

- (void) createClan:(NSString *)clanName tag:(NSString *)clanTag description:(NSString *)description requestOnly:(BOOL)requestOnly delegate:(id)delegate;
- (void) leaveClanWithDelegate:(id)delegate;
- (void) requestJoinClan:(NSString *)clanUuid delegate:(id)delegate;
- (void) retractRequestToJoinClan:(NSString *)clanUuid delegate:(id)delegate;
- (void) approveOrRejectRequestToJoinClan:(NSString *)requesterUuid accept:(BOOL)accept delegate:(id)delegate;
- (void) transferClanOwnership:(NSString *)newClanOwnerUuid delegate:(id)delegate;
- (void) changeClanDescription:(NSString *)description delegate:(id)delegate;
- (void) changeClanJoinType:(BOOL)requestRequired delegate:(id)delegate;
- (void) bootPlayerFromClan:(NSString *)playerUuid delegate:(id)delegate;
- (void) retrieveClanInfo:(NSString *)clanName clanUuid:(NSString *)clanUuid grabType:(RetrieveClanInfoRequestProto_ClanInfoGrabType)grabType isForBrowsingList:(BOOL)isForBrowsingList delegate:(id)delegate;

- (void) purchaseCityExpansionAtX:(int)x atY:(int)y;
- (void) expansionWaitComplete:(BOOL)speedUp atX:(int)x atY:(int)y;

- (void) purchaseBoosterPack:(int)boosterPackId delegate:(id)delegate;

- (void) privateChatPost:(NSString *)recipientUuid content:(NSString *)content;
- (void) retrievePrivateChatPosts:(NSString *)otherUserUuid delegate:(id)delegate;

- (void) beginDungeon:(int)taskId withDelegate:(id)delegate;
- (void) updateMonsterHealth:(NSString *)userMonsterUuid curHealth:(int)curHealth;
- (void) endDungeon:(BeginDungeonResponseProto *)dungeonInfo userWon:(BOOL)userWon delegate:(id)delegate;

- (BOOL) removeMonsterFromTeam:(NSString *)userMonsterUuid;
- (BOOL) addMonsterToTeam:(NSString *)userMonsterUuid;
- (void) buyInventorySlots;
- (void) combineMonsters:(NSArray *)userMonsterUuids;
- (BOOL) combineMonsterWithSpeedup:(NSString *)userMonsterUuid;
- (BOOL) addMonsterToHealingQueue:(NSString *)userMonsterUuid;
- (BOOL) removeMonsterFromHealingQueue:(UserMonsterHealingItem *)item;
- (BOOL) speedupHealingQueue;
- (void) healQueueWaitTimeComplete:(NSArray *)healingItems;

- (BOOL) setBaseEnhanceMonster:(NSString *)userMonsterUuid;
- (BOOL) removeBaseEnhanceMonster;
- (BOOL) addMonsterToEnhancingQueue:(NSString *)userMonsterUuid;
- (BOOL) removeMonsterFromEnhancingQueue:(EnhancementItem *)item;
- (BOOL) speedupEnhancingQueue;
- (void) enhanceQueueWaitTimeComplete:(NSArray *)enhancingItems;

- (void) inviteAllFacebookFriends:(NSArray *)fbFriends;
- (void) acceptAndRejectInvitesWithAcceptUuids:(NSArray *)acceptUuids rejectUuids:(NSArray *)rejectUuids;

@end
