//
//  MiniEventManager.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "Protocols.pb.h"
#import "UserData.h"

@protocol MiniEventInfoViewProtocol <NSObject>

@required

- (void) initializeWithUserMiniEvent:(UserMiniEvent*)userMiniEvent;
- (void) updateForUserMiniEvent:(UserMiniEvent*)userMiniEvent;
- (void) updateTimeLeftForEvent:(UserMiniEvent*)userMiniEvent;

@optional

- (void) miniEventViewWillAppear;
- (void) miniEventViewWillDisappear;

@end

@class MiniEventViewController;

@interface MiniEventManager : NSObject
{
  NSTimer* _miniEventRetrievalTimer;
  NSTimer* _miniEventScheduledEventEndTimer;
}

@property (nonatomic, strong, readonly) UserMiniEvent* currentUserMiniEvent;  // Might be nil, in case of no active user mini event
@property (nonatomic, weak) MiniEventViewController* miniEventViewController; // Weak reference to mini event view controller while it's open

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(MiniEventManager)

- (void) handleUserMiniEventReceivedOnStartup:(UserMiniEventProto*)userMiniEvent;
- (void) handleUserProgressOnMiniEventGoal:(MiniEventGoalProto_MiniEventGoalType)goalType withAmount:(int32_t)amount;
- (void) handleRedeemMiniEventRewardInitiatedByUserWithDelegate:(id)delegate tierRedeemed:(RedeemMiniEventRewardRequestProto_RewardTier)tierRedeemed;
- (void) handleRedeemMiniEventRewards:(UserRewardProto*)rewards tierRedeemed:(RedeemMiniEventRewardRequestProto_RewardTier)tierRedeemed;



- (void) checkBuildStrength:(int)structId;
- (void) checkResearchStrength:(int)researchId;

- (void) checkEnhanceXp:(int)expGained baseMonsterRarity:(Quality)quality;

- (void) checkPvpCaughtMonster:(Quality)quality;
- (void) checkPvpResourceWinningsWithCash:(int)cash oil:(int)oil;
- (void) checkRevengeWin;
- (void) checkAvengeWin;
- (void) checkAvengeRequest;

- (void) checkClanHelp:(int)amount;
- (void) checkClanDonate;

- (void) checkBoosterPack:(int)boosterPackId;

@end
