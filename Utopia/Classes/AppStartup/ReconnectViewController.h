//
//  ReconnectViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HudNotificationController.h"
#import "OmnipresentViewController.h"

@interface ReconnectViewController : OmnipresentViewController <TopBarNotification> {
  dispatch_block_t _completion;
}

@property (nonatomic, retain) IBOutlet UIView *notificationView;
@property (nonatomic, retain) IBOutlet UILabel *reconnectLabel;
@property (nonatomic, retain) IBOutlet UIImageView *wifiIcon;

- (void) end;

@end
