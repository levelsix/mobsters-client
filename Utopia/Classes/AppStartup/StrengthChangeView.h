//
//  StrengthChangeView.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/7/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NibUtils.h"
#import "HudNotificationController.h"

@interface StrengthChangeView : EmbeddedNibView <TopBarNotification> {
  dispatch_block_t _completion;
}

@property (nonatomic, retain) IBOutlet UILabel *strengthChangeLabel;

- (id) initWithStrengthChange:(int64_t)str;

@end
