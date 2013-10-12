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

- (void) startup;
- (void) logout;

- (void) inAppPurchase:(NSString *)receipt goldAmt:(int)gold silverAmt:(int)silver product:(SKProduct *)product;

- (UserStruct *) purchaseNormStruct:(int)structId atX:(int)x atY:(int)y;
- (void) moveNormStruct:(UserStruct *)userStruct atX:(int)x atY:(int)y;
- (void) rotateNormStruct:(UserStruct *)userStruct to:(StructOrientation)orientation;
- (void) retrieveFromNormStructure:(UserStruct *)userStruct;
- (void) sellNormStruct:(UserStruct *)userStruct;
- (void) instaUpgrade:(UserStruct *)userStruct;
- (void) normStructWaitComplete:(UserStruct *)userStruct;
- (void) upgradeNormStruct:(UserStruct *)userStruct;

- (void) retrieveAllStaticData;
- (void) retrieveBoosterPacks;

- (void) loadPlayerCity:(int)userId;
- (void) loadNeutralCity:(int)cityId;
- (void) loadNeutralCity:(int)cityId asset:(int)assetId;

- (void) levelUp;

- (void) acceptQuest:(int)questId;
- (void) redeemQuest:(int)questId;
- (void) retrieveQuestLog;
- (void) retrieveQuestDetails:(int)questId;

- (void) retrieveUsersForUserIds:(NSArray *)userIds;

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

- (void) submitMonsterEnhancement:(int)enhancingId feeders:(NSArray *)feeders;

- (void) purchaseBoosterPack:(int)boosterPackId;

- (void) privateChatPost:(int)recipientId content:(NSString *)content;
- (void) retrievePrivateChatPosts:(int)otherUserId;

- (void) beginDungeon:(int)taskId;

@end
