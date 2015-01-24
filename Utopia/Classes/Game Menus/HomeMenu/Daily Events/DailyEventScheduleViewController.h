//
//  DailyEventScheduleViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 1/22/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

@interface EventScheduleDayView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *background;
@property (nonatomic, retain) IBOutlet UILabel *date;
@property (nonatomic, retain) IBOutlet UILabel *day;
@property (nonatomic, retain) IBOutlet UILabel *detailA;
@property (nonatomic, retain) IBOutlet UILabel *detailB;
@property (nonatomic, retain) IBOutlet UILabel *detailC;
@property (nonatomic, retain) IBOutlet UIImageView *characterImage;

- (void) initWithEvent:(PersistentEventProto*)event;

@end

@interface DailyEventScheduleView : UIView

@property (weak, nonatomic) IBOutlet UIView *weekView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@interface DailyEventScheduleViewController : PopupSubViewController {
  NSMutableArray *_dayViews;
}

@property (nonatomic, retain) IBOutlet DailyEventScheduleView *dailyEventScheduleView;

- (void) initWithEventType:(PersistentEventProto_EventType)eventType;

@end
