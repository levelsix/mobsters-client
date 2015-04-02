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

- (void) updateForUserMiniEvent:(UserMiniEvent*)userMiniEvent;

@optional

- (void) miniEventViewWillAppear;
- (void) miniEventViewWillDisappear;

@end

@interface MiniEventManager : NSObject

@property (nonatomic, strong, readonly) UserMiniEvent* currentUserMiniEvent; // Might be nil, in case of no active user mini event

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(MiniEventManager)

- (void) handleUserMiniEventReceivedOnStartup:(UserMiniEventProto*)userMiniEvent;
- (void) handleUserProgressOnMiniEventGoal:(MiniEventGoalProto_MiniEventGoalType)goalType withAmount:(int32_t)amount;
- (void) handleRedeemMiniEventRewardInitiatedByUserWithDelegate:(id)delegate tierRedeemed:(RedeemMiniEventRewardRequestProto_RewardTier)tierRedeemed;
- (void) handleRedeemMiniEventRewards:(UserRewardProto*)rewards;

@end
