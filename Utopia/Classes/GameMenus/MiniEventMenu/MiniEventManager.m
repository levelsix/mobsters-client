//
//  MiniEventManager.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MiniEventManager.h"
#import "OutgoingEventController.h"
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
    _currentUserMiniEvent = userMiniEvent;
    
    MSDate* eventEndTime = [MSDate dateWithTimeIntervalSince1970:userMiniEvent.miniEvent.miniEventEndTime / 1000.f];
    MSDate* now = [MSDate date];
    if ([now compare:eventEndTime] != NSOrderedAscending)
    {
      // Event already ended
      if (userMiniEvent.tierOneRedeemed &&
          userMiniEvent.tierTwoRedeemed &&
          userMiniEvent.tierThreeRedeemed)
      {
        // All tier rewards have been redeemed
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

@end
