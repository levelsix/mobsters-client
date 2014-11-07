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

static NSString* const BottomGradientColor[] = {@"", @"ffdada", @"ceffe0", @"c9f7ff", @"ffffd8", @"e2dbff", @"e0e0e0"};
static NSString* const NameStrokeColor[] = {@"", @"e0181a", @"008530", @"1086de", @"d55a00", @"6a3bff", @"424242"};
static NSString* const TimeTopColor[] = {@"", @"379d0d", @"379d0d", @"066dee", @"ff8e00", @"542fff", @"565656"};
static NSString* const TimeBotColor[] = {@"", @"64c817", @"64c817", @"0aadf5", @"ffbf00", @"9956ff", @"6c6c6c"};

@protocol DailyEventCornerDelegate <NSObject>

- (void) eventCornerViewClicked:(id)sender;

@end

@interface DailyEventCornerView : UIView {
  PersistentEventProto_EventType _eventType;
  
  float _initCharCenterX;
  float _initTimeLabelX;
}

@property (nonatomic, retain) IBOutlet UIImageView *gradientView;
@property (nonatomic, retain) IBOutlet UIImageView *characterIcon;
@property (nonatomic, retain) IBOutlet UIImageView *timerIcon;
@property (nonatomic, retain) IBOutlet UIImageView *eventTagIcon;

@property (nonatomic, retain) IBOutlet THLabel *nameLabel;
@property (nonatomic, retain) IBOutlet THLabel *timeLabel;

@property (nonatomic, assign) int persistentEventId;

@property (nonatomic, assign) id<DailyEventCornerDelegate> delegate;

- (void) updateForEvo;
- (void) updateForEnhance;

- (void) updateLabels;

@end
