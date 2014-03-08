//
//  AttackMapViewController.h
//  Utopia
//
//  Created by Danny on 10/8/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "NibUtils.h"

@interface AttackMapIconView : UIView

@property (nonatomic, strong) IBOutlet UIImageView *cityNameIcon;
@property (nonatomic, strong) IBOutlet UIButton *cityButton;
@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, strong) FullCityProto *fcp;
@property (nonatomic, assign) int cityNumber;

@end

@interface AttackEventView : TouchableSubviewsView <TabBarDelegate> {
  int _persistentEventId;
  PersistentEventProto_EventType _eventType;
}

@property (nonatomic, retain) IBOutlet UIImageView *bgdImage;
@property (nonatomic, retain) IBOutlet UIImageView *ribbonImage;
@property (nonatomic, retain) IBOutlet UIImageView *monsterImage;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLeftLabel;
@property (nonatomic, retain) IBOutlet UILabel *cooldownLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedupGemsLabel;
@property (nonatomic, retain) IBOutlet UILabel *topRibbonLabel;
@property (nonatomic, retain) IBOutlet UILabel *botRibbonLabel;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;

@property (nonatomic, retain) IBOutlet FlipTabBar *tabBar;

@property (nonatomic, retain) IBOutlet UIView *enterView;
@property (nonatomic, retain) IBOutlet UIView *cooldownView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *noEventView;

@property (nonatomic, assign) int taskId;
@property (nonatomic, assign) int persistentEventId;

@end

@interface AttackMapIconViewContainer : UIView

@property (nonatomic, strong) IBOutlet AttackMapIconView *iconView;

@end

@interface MultiplayerView : UIView

@property (nonatomic, strong) IBOutlet UILabel *multiplayerUnlockLabel;
@property (nonatomic, strong) IBOutlet UILabel *cashCostLabel;

@end

@protocol AttackMapDelegate <NSObject>

@optional
- (void) visitCityClicked:(int)cityId;
- (void) enterDungeon:(int)taskId isEvent:(BOOL)isEvent eventId:(int)eventId useGems:(BOOL)useGems;
- (void) findPvpMatch:(BOOL)useGems;

@end

@interface AttackMapViewController : UIViewController {
  BOOL _buttonClicked;
}

@property (nonatomic, strong) IBOutlet UIImageView *borderView;
@property (nonatomic, strong) IBOutlet MultiplayerView *multiplayerView;

@property (nonatomic, strong) IBOutlet UIScrollView *mapScrollView;
@property (nonatomic, strong) IBOutlet UIView *mapView;

@property (nonatomic, strong) IBOutlet AttackEventView *eventView;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, weak) id<AttackMapDelegate> delegate;

- (IBAction)cityClicked:(id)sender;
- (IBAction)enterEventClicked:(id)sender;
- (IBAction)findMatchClicked:(id)sender;
- (IBAction)close:(id)sender;

@end
