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

@protocol AttackMapDelegate <NSObject>

@optional
- (void) visitCityClicked:(int)cityId;
- (void) enterDungeon:(int)taskId isEvent:(BOOL)isEvent eventId:(int)eventId useGems:(BOOL)useGems;
- (void) findPvpMatch:(BOOL)useGems;
- (void) beginPvpMatch:(PvpHistoryProto *)history;

@end

@interface AttackMapViewController : UIViewController <AttackEventViewDelegate> {
  BOOL _buttonClicked;
  
  AttackEventView *_curEventView;
}

@property (nonatomic, strong) IBOutlet UIImageView *borderView;
@property (nonatomic, strong) IBOutlet LeaguePromotionView *leaguePromotionView;

@property (nonatomic, strong) IBOutlet MultiplayerView *multiplayerView;
@property (nonatomic, strong) IBOutlet UIView *pveView;

@property (nonatomic, strong) IBOutlet UIScrollView *mapScrollView;
@property (nonatomic, strong) IBOutlet UIView *mapView;

@property (nonatomic, strong) IBOutlet AttackEventView *evoEventView;
@property (nonatomic, strong) IBOutlet AttackEventView *enhanceEventView;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, weak) id<AttackMapDelegate> delegate;

- (IBAction)cityClicked:(id)sender;
- (IBAction)enterEventClicked:(id)sender;
- (IBAction)findMatchClicked:(id)sender;
- (IBAction)close:(id)sender;

@end
