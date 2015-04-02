//
//  MiniEventManager.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MiniEventManager.h"
#import "OutgoingEventController.h"
#import "GameState.h"
#import "Globals.h"

@interface MiniEventManager (Private)

- (void) updateLocalUserMiniEvent:(UserMiniEventProto*)userMiniEvent;

@end

@implementation MiniEventManager

SYNTHESIZE_SINGLETON_FOR_CLASS(MiniEventManager)

- (instancetype) init
{
  self = [super init];
  if (self)
  {
    _currentUserMiniEvent = nil;
  }
  return self;
}

- (void) handleUserMiniEventReceivedOnStartup:(UserMiniEventProto*)userMiniEvent
{
  [self updateLocalUserMiniEvent:userMiniEvent];
  
  if (!_currentUserMiniEvent)
  {
    // Ask the server for a new mini event, if any
    [[OutgoingEventController sharedOutgoingEventController] retrieveUserMiniEventWithDelegate:self];
  }
}

- (void) updateLocalUserMiniEvent:(UserMiniEventProto*)userMiniEvent
{
  _currentUserMiniEvent = nil;
  
  if (userMiniEvent && userMiniEvent.miniEvent)
  {
    _currentUserMiniEvent = [UserMiniEvent userMiniEventWithProto:userMiniEvent];
    
    MSDate* eventEndTime = [MSDate dateWithTimeIntervalSince1970:userMiniEvent.miniEvent.miniEventEndTime / 1000.f];
    MSDate* now = [MSDate date];
    if ([now compare:eventEndTime] != NSOrderedAscending)
    {
      // Event already ended
      if ((userMiniEvent.tierOneRedeemed   || _currentUserMiniEvent.pointsEarned < userMiniEvent.miniEvent.lvlEntered.tierOneMinPts) &&
          (userMiniEvent.tierTwoRedeemed   || _currentUserMiniEvent.pointsEarned < userMiniEvent.miniEvent.lvlEntered.tierTwoMinPts) &&
          (userMiniEvent.tierThreeRedeemed || _currentUserMiniEvent.pointsEarned < userMiniEvent.miniEvent.lvlEntered.tierThreeMinPts))
      {
        // All tier rewards that user has accumulated enough points for have already been redeemed
        _currentUserMiniEvent = nil;
      }
    }
  }
}

- (void) handleRetrieveMiniEventResponseProto:(FullEvent*)fe
{
  RetrieveMiniEventResponseProto* proto = (RetrieveMiniEventResponseProto*)fe.event;

  if (proto.status == RetrieveMiniEventResponseProto_RetrieveMiniEventStatusSuccess)
  {
    [self updateLocalUserMiniEvent:proto.userMiniEvent];
  }
  else
  {
    // For now not going to retry the event. Might later decide to retry in timed intervals
  }
}

- (void) handleUserProgressOnMiniEventGoal:(MiniEventGoalProto_MiniEventGoalType)goalType withAmount:(int32_t)amount
{
  if (_currentUserMiniEvent &&
      MiniEventGoalProto_MiniEventGoalTypeIsValidValue(goalType) &&
      amount > 0)
  {
    for (MiniEventGoalProto* goalProto in _currentUserMiniEvent.miniEvent.goalsList)
    {
      if (goalProto.goalType == goalType)
      {
        UserMiniEventGoal* userMiniEventGoal = [_currentUserMiniEvent.miniEventGoals objectForKey:@(goalProto.miniEventGoalId)];
        userMiniEventGoal.progress += amount;
        
        if (userMiniEventGoal.progress >= userMiniEventGoal.goalAmt &&
            userMiniEventGoal.progress - amount < userMiniEventGoal.goalAmt)
        {
          // Current progress led to goal being completed
          _currentUserMiniEvent.pointsEarned += userMiniEventGoal.pointsGained;
        }
        
        [[OutgoingEventController sharedOutgoingEventController] updateUserMiniEvent:userMiniEventGoal shouldFlush:NO];
        
        // There will be no two goals of the same type in a mini event
        break;
      }
    }
  }
}

- (void) handleRedeemMiniEventRewardInitiatedByUserWithDelegate:(id)delegate tierRedeemed:(RedeemMiniEventRewardRequestProto_RewardTier)tierRedeemed
{
  if (_currentUserMiniEvent &&
      RedeemMiniEventRewardRequestProto_RewardTierIsValidValue(tierRedeemed))
  {
    [[OutgoingEventController sharedOutgoingEventController] redeemMiniEventRewardWithDelegate:delegate
                                                                                  tierRedeemed:tierRedeemed
                                                                     miniEventForPlayerLevelId:_currentUserMiniEvent.miniEvent.lvlEntered.mefplId];
  }
}

- (void) handleRedeemMiniEventRewards:(UserRewardProto*)rewards
{
  GameState* gs = [GameState sharedGameState];
  
  if (rewards.updatedOrNewMonstersList)
  {
    [gs addToMyMonsters:rewards.updatedOrNewMonstersList];
  }
  
  if (rewards.updatedUserItemsList)
  {
    [gs.itemUtil addToMyItems:rewards.updatedUserItemsList];
  }
  
  if (rewards.hasGems || rewards.hasCash || rewards.hasOil)
  {
    // Gems, oil, and cash are updated through UpdateUserClientResponseEvent. Don't need to do anything here
  }
}

@end
