//
//  OneLineNotificationViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/27/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "OmnipresentViewController.h"
#import "HudNotificationController.h"

@interface OneLineNotificationView : UIView

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutletCollection(UIImageView) NSArray *imgViews;

@end

@interface OneLineNotificationViewController : OmnipresentViewController <TopBarNotification> {
  dispatch_block_t _completion;
  NotificationPriority _priority;
}

@property (nonatomic, retain) IBOutlet OneLineNotificationView *notificationView;

- (id) initWithNotificationString:(NSString *)str isGreen:(BOOL)isGreen isImmediate:(BOOL)isImmediate;

@end
