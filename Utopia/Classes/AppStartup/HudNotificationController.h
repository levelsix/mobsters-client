//
//  TopBarNotificationController.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  NotificationLocationTypeTop = 1,
  NotificationLocationTypeBot,
  NotificationLocationTypeFullScreen
} NotificationLocationType;

typedef enum {
  // This priority will always be displayed even if controller is paused
  NotificationPriorityImmediate = 1,
  
  // Added to the front of the list
  NotificationPriorityFirst,
  
  // Added to the back of the list
  NotificationPriorityRegular
} NotificationPriority;

@protocol TopBarNotification <NSObject>

- (NotificationLocationType) locationType;
- (NotificationPriority) priority;
- (void) animateWithCompletionBlock:(dispatch_block_t)completion;
- (void) endAbruptly;

@end

@interface HudNotificationController : NSObject {
  BOOL _isPaused;
}

@property (nonatomic, retain) NSMutableArray *notifications;
@property (nonatomic, retain) NSMutableArray *currentNotifications;

- (void) addNotification:(id<TopBarNotification>)notification;

- (void) pauseNotifications;
- (void) resumeNotifications;

- (void) clearAll;

@end
