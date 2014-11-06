//
//  DailyEventCornerView.h
//  Utopia
//
//  Created by Ashwin on 11/5/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NibUtils.h"
#import "Protocols.pb.h"

@interface DailyEventCornerView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *gradientView;
@property (nonatomic, retain) IBOutlet UIImageView *characterIcon;
@property (nonatomic, retain) IBOutlet UIImageView *timerIcon;
@property (nonatomic, retain) IBOutlet UIImageView *eventTagIcon;

@property (nonatomic, retain) IBOutlet THLabel *nameLabel;
@property (nonatomic, retain) IBOutlet THLabel *timeLabel;

@end
