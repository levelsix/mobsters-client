//
//  DailyEventViewController.h
//  Utopia
//
//  Created by Ashwin on 11/5/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"
#import "DailyEventScheduleViewController.h"

@interface DailyEventView : UIView

@property (nonatomic, retain) IBOutlet UIView *bgdView;

@end

@interface DailyEventViewController : PopupSubViewController {
  PersistentEventProto_EventType _eventType;
  
  PersistentEventProto *_nextEvent;
  
  BOOL _buttonClicked;
  
  float _initCharCenterX;
}

@property (nonatomic, retain) IBOutlet UIImageView *leftBgdCap;
@property (nonatomic, retain) IBOutlet UIImageView *middleBgd;
@property (nonatomic, retain) IBOutlet UIImageView *rightBgdCap;

@property (nonatomic, retain) IBOutlet UIImageView *characterIcon;
@property (nonatomic, retain) IBOutlet UIImageView *eventTagIcon;

@property (nonatomic, retain) IBOutlet THLabel *dateLabel;
@property (nonatomic, retain) IBOutlet THLabel *nameLabel;
@property (nonatomic, retain) IBOutlet THLabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *endsInLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, retain) IBOutlet UILabel *speedupGemsLabel;
@property (nonatomic, retain) IBOutlet UILabel *freeLabel;

@property (nonatomic, retain) IBOutlet UIView *enterView;
@property (nonatomic, retain) IBOutlet UIView *cooldownView;

@property (nonatomic, assign) int persistentEventId;

@property (nonatomic, retain) IBOutlet UIView *secondaryButtonView;
@property (nonatomic, retain) IBOutlet UIView *defaultButtonView;
@property (nonatomic, retain) IBOutlet THLabel *timeLabelB;

- (void) updateForEvo;
- (void) updateForEnhance;

@end
