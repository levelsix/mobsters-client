//
//  AttackMapViewController.h
//  Utopia
//
//  Created by Danny on 10/8/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"

@interface AttackMapIconView : UIView

@property (nonatomic, strong) IBOutlet UIView *visitView;
@property (nonatomic, strong) IBOutlet UILabel *cityNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *cityNumberLabel;
@property (nonatomic, strong) IBOutlet UIButton *cityButton;
@property (nonatomic, strong) IBOutlet UIButton *visitButton;
@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, strong) FullCityProto *fcp;
@property (nonatomic, assign) int cityNumber;
@property (nonatomic, assign) BOOL selected;

@end

@interface AttackMapIconViewContainer : UIView

@property (nonatomic, strong) IBOutlet AttackMapIconView *iconView;
@end

@interface MultiplayerView : UIView

@property (nonatomic, strong) IBOutlet UILabel *multiplayerUnlockLabel;
@property (nonatomic, strong) IBOutlet UIImageView *currentLeague;
@property (nonatomic, strong) IBOutlet UILabel *matchCost;
@property (nonatomic, strong) IBOutlet UIView *needToUnlockView;
@property (nonatomic, strong) IBOutlet UILabel *yourInfoLabel;

- (IBAction)findMatch:(id)sender;

@end

@protocol AttackMapDelegate <NSObject>

- (void) visitCityClicked:(int)cityId;

@end

@interface AttackMapViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView *bgdView;
@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet MultiplayerView *multiplayerView;

@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) IBOutlet UIView *loadingLabel;

@property (nonatomic, weak) id<AttackMapDelegate> delegate;

- (IBAction)close:(id)sender;

@end

