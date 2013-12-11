//
//  OutgoingEventController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"
#import "UserData.h"
#import <CoreLocation/CoreLocation.h>
#import "StoreKit/StoreKit.h"

@interface OutgoingEventController : NSObject

+ (OutgoingEventController *) sharedOutgoingEventController;

- (void) createUser;

- (void) startupWithDelegate:(id)delegate;
- (void) logout;

- (void) inAppPurchase:(NSString *)receipt goldAmt:(int)gold silverAmt:(int)silver product:(SKProduct *)product;

- (UserStruct *) purchaseNormStruct:(int)structId atX:(int)x atY:(int)y;
- (void) moveNormStruct:(UserStruct *)userStruct atX:(int)x atY:(int)y;
- (void) retrieveFromNormStructure:(UserStruct *)userStruct;
- (void) instaUpgrade:(UserStruct *)userStruct;
- (void) normStructWaitComplete:(UserStruct *)userStruct;
- (void) upgradeNormStruct:(UserStruct *)userStruct;

- (void) loadPlayerCity:(int)userId withDelegate:(id)delegate;
- (void) loadNeutralCity:(int)cityId withDelegate:(id)delegate;

- (void) levelUp;

- (UserQuest *) acceptQuest:(int)questId;
- (void) redeemQuest:(int)questId delegate:(id)delegate;
- (void) questProgress:(int)questId;
- (UserQuest *) donateForQuest:(int)questId monsterIds:(NSArray *)monsterIds;

- (void) retrieveUsersForUserIds:(NSArray *)userIds includeCurMonsterTeam:(BOOL)includeCurMonsterTeam delegate:(id)delegate;

- (void) enableApns:(NSData *)deviceToken;

- (void) fbConnectReward;

- (void) sendGroupChat:(GroupChatScope)scope message:(NSString *)msg;

- (void) createClan:(NSString *)clanName tag:(NSString *)clanTag description:(NSString *)description requestOnly:(BOOL)requestOnly delegate:(id)delegate;
- (void) leaveClanWithDelegate:(id)delegate;
- (void) requestJoinClan:(int)clanId delegate:(id)delegate;
- (void) retractRequestToJoinClan:(int)clanId delegate:(id)delegate;
- (void) approveOrRejectRequestToJoinClan:(int)requesterId accept:(BOOL)accept delegate:(id)delegate;
- (void) transferClanOwnership:(int)newClanOwnerId delegate:(id)delegate;
- (void) changeClanDescription:(NSString *)description delegate:(id)delegate;
- (void) changeClanJoinType:(BOOL)requestRequired delegate:(id)delegate;
- (void) bootPlayerFromClan:(int)playerId delegate:(id)delegate;
- (void) retrieveClanInfo:(NSString *)clanName clanId:(int)clanId grabType:(RetrieveClanInfoRequestProto_ClanInfoGrabType)grabType isForBrowsingList:(BOOL)isForBrowsingList beforeClanId:(int)beforeClanId delegate:(id)delegate;

- (void) purchaseCityExpansionAtX:(int)x atY:(int)y;
- (void) expansionWaitComplete:(BOOL)speedUp atX:(int)x atY:(int)y;

- (void) purchaseBoosterPack:(int)boosterPackId delegate:(id)delegate;

- (void) privateChatPost:(int)recipientId content:(NSString *)content;
- (void) retrievePrivateChatPosts:(int)otherUserId delegate:(id)delegate;

- (void) beginDungeon:(int)taskId withDelegate:(id)delegate;
- (void) updateMonsterHealth:(int)userMonsterId curHealth:(int)curHealth;
- (void) endDungeon:(BeginDungeonResponseProto *)dungeonInfo userWon:(BOOL)userWon delegate:(id)delegate;

- (BOOL) removeMonsterFromTeam:(int)userMonsterId;
- (BOOL) addMonsterToTeam:(int)userMonsterId;
- (void) increaseInventorySlots:(UserStruct *)us withGems:(BOOL)gems;
- (void) combineMonsters:(NSArray *)userMonsterIds;
- (BOOL) combineMonsterWithSpeedup:(int)userMonsterId;
- (BOOL) addMonsterToHealingQueue:(int)userMonsterId;
- (BOOL) removeMonsterFromHealingQueue:(UserMonsterHealingItem *)item;
- (BOOL) speedupHealingQueue;
- (void) healQueueWaitTimeComplete:(NSArray *)healingItems;

- (BOOL) setBaseEnhanceMonster:(int)userMonsterId;
- (BOOL) removeBaseEnhanceMonster;
- (BOOL) addMonsterToEnhancingQueue:(int)userMonsterId;
- (BOOL) removeMonsterFromEnhancingQueue:(EnhancementItem *)item;
- (BOOL) speedupEnhancingQueue;
- (void) enhanceQueueWaitTimeComplete:(NSArray *)enhancingItems;

- (void) inviteAllFacebookFriends:(NSArray *)fbFriends forStruct:(UserStruct *)us;
- (void) acceptAndRejectInvitesWithAcceptIds:(NSArray *)acceptIds rejectIds:(NSArray *)rejectIds;

@end
