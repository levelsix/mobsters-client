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
#import "AttackMapViews.h"

#import "ResourceItemsFiller.h"

@protocol AttackMapDelegate <NSObject>

@optional
- (void) visitCityClicked:(int)cityId attackMapViewController:(id)vc;
- (void) enterDungeon:(int)taskId isEvent:(BOOL)isEvent eventId:(int)eventId useGems:(BOOL)useGems;
- (void) findPvpMatchWithItemsDict:(NSDictionary *)itemsDict;
- (void) beginPvpMatch:(PvpHistoryProto *)history;

@end

@interface AttackMapViewController : UIViewController <AttackEventViewDelegate, UIScrollViewDelegate, ResourceItemsFillerDelegate> {
  BOOL _buttonClicked;
  
  AttackMapIconView *_selectedIcon;
  AttackEventView *_curEventView;
}

@property (nonatomic, strong) IBOutlet UIImageView *borderView;

@property (nonatomic, strong) IBOutlet MultiplayerView *multiplayerView;
@property (nonatomic, strong) IBOutlet UIView *pveView;

@property (nonatomic, strong) IBOutlet UIScrollView *mapScrollView;
@property (nonatomic, strong) IBOutlet UIView *mapSegmentContainer;

@property (nonatomic, strong) IBOutlet AttackEventView *evoEventView;
@property (nonatomic, strong) IBOutlet AttackEventView *enhanceEventView;
@property (nonatomic, strong) IBOutlet AttackMapStatusView *taskStatusView;

@property (nonatomic, strong) IBOutlet UIView *myPositionView;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, retain) ItemSelectViewController *itemSelectViewController;
@property (nonatomic, retain) ResourceItemsFiller *resourceItemsFiller;

@property (nonatomic, weak) id<AttackMapDelegate> delegate;

- (void) showTaskStatusForMapElement:(int)mapElementId;

- (IBAction) cityClicked:(id)sender;
- (IBAction) enterEventClicked:(id)sender;
- (IBAction) findMatchClicked:(id)sender;
- (IBAction) openLeagueListClicked:(id)sender;
- (IBAction) close:(id)sender;
- (IBAction) close;

@end
