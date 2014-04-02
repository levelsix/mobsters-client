//
//  OneLineNotificationViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/27/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "OmnipresentViewController.h"

@interface OneLineNotificationView : UIView

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutletCollection(UIImageView) NSArray *imgViews;

@end

@interface OneLineNotificationViewController : OmnipresentViewController

@property (nonatomic, retain) IBOutlet OneLineNotificationView *notificationView;

- (void) addNotification:(NSString *)string isGreen:(BOOL)isGreen;

@end
