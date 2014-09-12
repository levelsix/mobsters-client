//
//  TopBarNotificationController.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "HudNotificationController.h"

@implementation HudNotificationController

- (id) init {
  if ((self = [super init])) {
    self.notifications = [NSMutableArray array];
    _currentNotifications = [NSMutableArray array];
  }
  return self;
}

- (void) displayNextNotification {
  id<TopBarNotification> notification = [self.notifications firstObject];
  
  if (notification) {
    [_currentNotifications addObject:notification];
    [self.notifications removeObject:notification];
    
    [notification animateWithCompletionBlock:^{
      [_currentNotifications removeObject:notification];
      
      if (!_isPaused && !_currentNotifications.count) {
        [self displayNextNotification];
      }
    }];
  }
}

- (void) addNotification:(id<TopBarNotification>)notification {
  // Immediate and first notifications should be added to the front of the list
  if ([notification priority] == NotificationPriorityFirst || [notification priority] == NotificationPriorityImmediate) {
    [self.notifications insertObject:notification atIndex:0];
  } else {
    [self.notifications addObject:notification];
    
    [self.notifications sortUsingComparator:^NSComparisonResult(id<TopBarNotification> obj1, id<TopBarNotification> obj2) {
      return [@([obj1 priority]) compare:@([obj2 priority])];
    }];
  }
  
  // If the priority is immediate, then we want to display it right away even if paused.
  if ([notification priority] == NotificationPriorityImmediate) {
    
    [self displayNextNotification];
    
    // We only need to end abruptly if they share the same location type
    for (id<TopBarNotification> notif in _currentNotifications) {
      if (notif != notification && [notif locationType] == [notification locationType]) {
        [notif endAbruptly];
      }
    }
  } else if (!_isPaused && !_currentNotifications.count) {
    [self displayNextNotification];
  }
}

- (void) pauseNotifications {
  _isPaused = YES;
}

- (void) resumeNotifications {
  _isPaused = NO;
  
  if (!_currentNotifications.count) {
    [self displayNextNotification];
  }
}

- (void) clearAll {
  [self.notifications removeAllObjects];
  
  for (id<TopBarNotification> notif in _currentNotifications) {
    [notif endAbruptly];
  }
  [_currentNotifications removeAllObjects];
}

@end
