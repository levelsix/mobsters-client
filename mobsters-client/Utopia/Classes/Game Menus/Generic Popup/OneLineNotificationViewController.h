//
//  OneLineNotificationViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/27/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "OmnipresentViewController.h"
#import "HudNotificationController.h"

typedef enum {
  NotificationColorRed,
  NotificationColorGreen,
  NotificationColorPurple,
  NotificationColorOrange,
  NotificationColorBlue,
} NotificationColor;

@interface OneLineNotificationView : UIView

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIImageView *leftBgdIcon;
@property (nonatomic, retain) IBOutlet UIImageView *middleBgdIcon;
@property (nonatomic, retain) IBOutlet UIImageView *rightBgdIcon;

@end

@interface OneLineNotificationViewController : OmnipresentViewController <TopBarNotification> {
  dispatch_block_t _completion;
  NotificationPriority _priority;
}

@property (nonatomic, retain) IBOutlet OneLineNotificationView *notificationView;

- (id) initWithNotificationString:(NSString *)str color:(NotificationColor)color isImmediate:(BOOL)isImmediate;

@end
