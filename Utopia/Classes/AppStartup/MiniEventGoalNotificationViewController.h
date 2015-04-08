//
//  MiniEventGoalNotificationViewController.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 4/7/15.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "OmnipresentViewController.h"
#import "HudNotificationController.h"

@interface MiniEventGoalNotificationView : UIView

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIImageView *icon;

@end

@interface MiniEventGoalNotificationViewController : OmnipresentViewController <TopBarNotification> {
  dispatch_block_t _completion;
  NotificationPriority _priority;
}

@property (nonatomic, retain) IBOutlet MiniEventGoalNotificationView *notificationView;

- (id) initWithNotificationString:(NSString *)str image:(NSString *)img isImmediate:(BOOL)isImmediate;

@end
