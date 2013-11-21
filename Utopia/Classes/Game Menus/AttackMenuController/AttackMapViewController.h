//
//  AttackMapViewController.h
//  Utopia
//
//  Created by Danny on 10/8/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobstersEventProtocol.pb.h"

@interface AttackMapIconView : UIView

@property (nonatomic, strong) IBOutlet UIImageView *cityNameIcon;
@property (nonatomic, strong) IBOutlet UIButton *cityButton;
@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, strong) FullCityProto *fcp;
@property (nonatomic, assign) int cityNumber;

@end

@interface AttackMapIconViewContainer : UIView

@property (nonatomic, strong) IBOutlet AttackMapIconView *iconView;

@end

@interface MultiplayerView : UIView

@property (nonatomic, strong) IBOutlet UILabel *multiplayerUnlockLabel;

@end

@protocol AttackMapDelegate <NSObject>

- (void) visitCityClicked:(int)cityId;

@end

@interface AttackMapViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView *borderView;
@property (nonatomic, strong) IBOutlet MultiplayerView *multiplayerView;

@property (nonatomic, strong) IBOutlet UIScrollView *mapScrollView;
@property (nonatomic, strong) IBOutlet UIView *mapView;

@property (nonatomic, weak) id<AttackMapDelegate> delegate;

- (IBAction)close:(id)sender;

@end

