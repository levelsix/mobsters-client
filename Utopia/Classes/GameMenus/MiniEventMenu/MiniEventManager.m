//
//  MiniEventManager.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MiniEventManager.h"
#import "MiniEventViewController.h"
#import "OutgoingEventController.h"
#import "GameState.h"
#import "Globals.h"

@interface MiniEventManager (Private)

- (void) updateLocalUserMiniEvent:(UserMiniEventProto*)userMiniEvent;
- (void) retrieveNewUserMiniEvent;
- (void) currentActiveMiniEventEnded;
- (void) startEventRetrievalTimer;
- (void) stopEventRetrievalTimer;
- (void) startEventScheduledEventEndTimer;
- (void) stopEventScheduledEventEndTimer;
- (void) killAllTimers;
- (void) restartAllTimers;

@end

static const NSTimeInterval kNewMiniEventRetrievalTimeInterval = 60; // Seconds

@implementation MiniEventManager

SYNTHESIZE_SINGLETON_FOR_CLASS(MiniEventManager)

- (instancetype) init
{
  self = [super init];
  if (self)
  {
    _currentUserMiniEvent = nil;
    _miniEventRetrievalTimer = nil;
    _miniEventScheduledEventEndTimer = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(killAllTimers)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
  }
  return self;
}

- (void) handleUserMiniEventReceivedOnStartup:(UserMiniEventProto*)userMiniEvent
{
  [self updateLocalUserMiniEvent:userMiniEvent];
  
  if (!_currentUserMiniEvent)
  {
    [self retrieveNewUserMiniEvent];
  }
}

- (void) updateLocalUserMiniEvent:(UserMiniEventProto*)userMiniEvent
{
  _currentUserMiniEvent = nil;
  
  if (userMiniEvent && userMiniEvent.miniEvent)
  {
    _currentUserMiniEvent = [UserMiniEvent userMiniEventWithProto:userMiniEvent];
    
    if ([_currentUserMiniEvent eventHasEnded] && [_currentUserMiniEvent allCompletedTiersHaveBeenRedeemed])
    {
      // Event has ended and all tier rewards that user has accumulated enough points for have already been redeemed
      _currentUserMiniEvent = nil;
    }
    else
    {
      [self stopEventRetrievalTimer];
      
      if (![_currentUserMiniEvent eventHasEnded])
      {
        [self startEventScheduledEventEndTimer];
      }
      
      [[NSNotificationCenter defaultCenter] postNotificationName:MINI_EVENT_IS_AVAILABLE_NOTIFICATION object:nil];
    }
  }
}

- (void) retrieveNewUserMiniEvent
{
  GameState* gs = [GameState sharedGameState];
  if (gs.connected && !gs.isTutorial && gs.userUuid && ![gs.userUuid isEqualToString:@""])
  {
    // Ask the server for a new mini event, if any
    [[OutgoingEventController sharedOutgoingEventController] retrieveUserMiniEventWithDelegate:self];
  }
  else
  {
    [self startEventRetrievalTimer];
  }
}

- (void) handleRetrieveMiniEventResponseProto:(FullEvent*)fe
{
  RetrieveMiniEventResponseProto* proto = (RetrieveMiniEventResponseProto*)fe.event;

  if (proto.status == RetrieveMiniEventResponseProto_RetrieveMiniEventStatusSuccess)
  {
    [self updateLocalUserMiniEvent:proto.userMiniEvent];
  }
  
  if (!_currentUserMiniEvent ||
      proto.status == RetrieveMiniEventResponseProto_RetrieveMiniEventStatusFailOther)
  {
    [self startEventRetrievalTimer];
  }
}

- (void) currentActiveMiniEventEnded
{
  [self stopEventScheduledEventEndTimer];

  if ([_currentUserMiniEvent allCompletedTiersHaveBeenRedeemed])
  {
    // Event has ended and all tier rewards that user has accumulated enough points for have already been redeemed
    _currentUserMiniEvent = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MINI_EVENT_IS_UAVAILABLE_NOTIFICATION object:nil];
    
    [self retrieveNewUserMiniEvent];
  }
  else
  {
    [[NSNotificationCenter defaultCenter] postNotificationName:MINI_EVENT_HAS_ENDED_NOTIFICATION object:nil];
  }
}

- (void) startEventRetrievalTimer
{
  if (_miniEventRetrievalTimer == nil)
  {
    // Retry to retrieve a new mini event on timed intervals
    _miniEventRetrievalTimer = [NSTimer timerWithTimeInterval:kNewMiniEventRetrievalTimeInterval target:self
                                                     selector:@selector(retrieveNewUserMiniEvent) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_miniEventRetrievalTimer forMode:NSRunLoopCommonModes];
  }
}

- (void) stopEventRetrievalTimer
{
  if (_miniEventRetrievalTimer)
  {
    [_miniEventRetrievalTimer invalidate];
    _miniEventRetrievalTimer = nil;
  }
}

- (void) startEventScheduledEventEndTimer
{
  if (_miniEventScheduledEventEndTimer == nil)
  {
    // Kick off a timer for the expected end time of the current active mini event
    const NSTimeInterval timeLeft = [_currentUserMiniEvent secondsTillEventEndTime];
    _miniEventScheduledEventEndTimer = [NSTimer timerWithTimeInterval:timeLeft target:self
                                                             selector:@selector(currentActiveMiniEventEnded) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_miniEventScheduledEventEndTimer forMode:NSRunLoopCommonModes];
  }
}

- (void) stopEventScheduledEventEndTimer
{
  if (_miniEventScheduledEventEndTimer)
  {
    [_miniEventScheduledEventEndTimer invalidate];
    _miniEventScheduledEventEndTimer = nil;
  }
}

- (void) killAllTimers
{
  [NSNotificationCenter.defaultCenter removeObserver:self];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(restartAllTimers)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];
  
  [self stopEventRetrievalTimer];
  [self stopEventScheduledEventEndTimer];
}

- (void) restartAllTimers
{
  [NSNotificationCenter.defaultCenter removeObserver:self];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(killAllTimers)
                                               name:UIApplicationWillResignActiveNotification
                                             object:nil];
  
  if (_currentUserMiniEvent)
  {
    if (![_currentUserMiniEvent eventHasEnded])
    {
      [self startEventScheduledEventEndTimer];
    }
  }
  else
  {
    [self startEventRetrievalTimer];
  }
}

- (void) handleUserProgressOnMiniEventGoal:(MiniEventGoalProto_MiniEventGoalType)goalType withAmount:(int32_t)amount
{
  if (_currentUserMiniEvent &&
      ![_currentUserMiniEvent eventHasEnded] &&
      MiniEventGoalProto_MiniEventGoalTypeIsValidValue(goalType) &&
      amount > 0)
  {
    for (MiniEventGoalProto* goalProto in _currentUserMiniEvent.miniEvent.goalsList)
    {
      if (goalProto.goalType == goalType)
      {
        UserMiniEventGoal* userMiniEventGoal = [_currentUserMiniEvent.miniEventGoals objectForKey:@(goalProto.miniEventGoalId)];
        userMiniEventGoal.progress += amount;
        
        const int newProgress = userMiniEventGoal.progress;
        const int oldProgress = userMiniEventGoal.progress - amount;
        const int numTimesGoalCompletedAfterProgress  = (newProgress - newProgress % userMiniEventGoal.goalAmt) / userMiniEventGoal.goalAmt;
        const int numTimesGoalCompletedBeforeProgress = (oldProgress - oldProgress % userMiniEventGoal.goalAmt) / userMiniEventGoal.goalAmt;
        
        if (numTimesGoalCompletedAfterProgress > numTimesGoalCompletedBeforeProgress)
        {
          // Current progress led to goal being completed
        
          const int numTimesGoalCompleted = numTimesGoalCompletedAfterProgress - numTimesGoalCompletedBeforeProgress;
          const int32_t pointsGained = userMiniEventGoal.pointsGained * numTimesGoalCompleted;
          _currentUserMiniEvent.pointsEarned += pointsGained;
          
          if (self.miniEventViewController)
          {
            [self.miniEventViewController miniEventUpdated:_currentUserMiniEvent];
          }
          
          [Globals addMiniEventGoalNotification:[NSString stringWithFormat:@"%@: %d Points Earned!", userMiniEventGoal.actionDescription, pointsGained]
                                          image:_currentUserMiniEvent.miniEvent.img];
          
          if ([_currentUserMiniEvent completedTiersWithUnredeemedRewards] > 0)
          {
            [[NSNotificationCenter defaultCenter] postNotificationName:MINI_EVENT_TIER_REWARD_AVAILABLE_OR_REDEEMED_NOTIFICATION object:nil];
          }
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

- (void) handleRedeemMiniEventRewards:(UserRewardProto*)rewards tierRedeemed:(RedeemMiniEventRewardRequestProto_RewardTier)tierRedeemed
{
  if (_currentUserMiniEvent &&
      RedeemMiniEventRewardRequestProto_RewardTierIsValidValue(tierRedeemed))
  {
    switch (tierRedeemed)
    {
      case RedeemMiniEventRewardRequestProto_RewardTierTierOne:   _currentUserMiniEvent.tierOneRedeemed   = YES; break;
      case RedeemMiniEventRewardRequestProto_RewardTierTierTwo:   _currentUserMiniEvent.tierTwoRedeemed   = YES; break;
      case RedeemMiniEventRewardRequestProto_RewardTierTierThree: _currentUserMiniEvent.tierThreeRedeemed = YES; break;
    }
  
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
    
    [Globals addPurpleAlertNotification:[NSString stringWithFormat:@"You collected your Tier %d reward!", (int)tierRedeemed] isImmediate:YES];
    
    if ([_currentUserMiniEvent eventHasEnded] && [_currentUserMiniEvent allCompletedTiersHaveBeenRedeemed])
    {
      // Event has ended and all tier rewards that user has accumulated enough points for have already been redeemed
      _currentUserMiniEvent = nil;
      
      [[NSNotificationCenter defaultCenter] postNotificationName:MINI_EVENT_IS_UAVAILABLE_NOTIFICATION object:nil];
      
      [self retrieveNewUserMiniEvent];
    }
    else
    {
      [[NSNotificationCenter defaultCenter] postNotificationName:MINI_EVENT_TIER_REWARD_AVAILABLE_OR_REDEEMED_NOTIFICATION object:nil];
    }
  }
}

@end
