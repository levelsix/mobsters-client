//
//  GenericPopupController.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/5/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OmnipresentViewController.h"
#import "Protocols.pb.h"

@interface GenericPopupController : OmnipresentViewController

+ (GenericPopupController *) displayNotificationViewWithText:(NSString *)string title:(NSString *)title;
+ (GenericPopupController *) displayNotificationViewWithText:(NSString *)string title:(NSString *)title okayButton:(NSString *)okay target:(id)target selector:(SEL)selector;
+ (GenericPopupController *) displayNotificationViewWithMiddleView:(UIView *)view title:(NSString *)title okayButton:(NSString *)okay target:(id)target selector:(SEL)selector;
+ (GenericPopupController *) displayConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel target:(id)target selector:(SEL)selector;
+ (GenericPopupController *) displayConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel okTarget:(id)okTarget okSelector:(SEL)okSelector cancelTarget:(id)cancelTarget cancelSelector:(SEL)cancelSelector;

+ (GenericPopupController *) displayNegativeConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel okTarget:(id)okTarget okSelector:(SEL)okSelector cancelTarget:(id)cancelTarget cancelSelector:(SEL)cancelSelector;

+ (GenericPopupController *) displayNotEnoughGemsView;
+ (GenericPopupController *) displayGemConfirmViewWithDescription:(NSString *)description title:(NSString *)title gemCost:(int)gemCost target:(id)target selector:(SEL)selector;
+ (GenericPopupController *) displayExchangeForGemsViewWithResourceType:(ResourceType)resourceType amount:(int)amount target:(id)target selector:(SEL)selector;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@property (nonatomic, retain) IBOutlet UIView *descriptionView;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

// Button views
@property (nonatomic, retain) IBOutlet UIView *notificationView;
@property (nonatomic, retain) IBOutlet UILabel *notifButtonLabel;
@property (nonatomic, retain) IBOutlet UIButton *notifButton;

@property (nonatomic, retain) IBOutlet UIView *confirmationView;
@property (nonatomic, retain) IBOutlet UILabel *confOkayButtonLabel;
@property (nonatomic, retain) IBOutlet UILabel *confCancelButtonLabel;
@property (nonatomic, retain) IBOutlet UIButton *confOkayButton;
@property (nonatomic, retain) IBOutlet UIButton *confCancelButton;

@property (nonatomic, retain) IBOutlet UIView *gemView;
@property (nonatomic, retain) IBOutlet UILabel *gemButtonLabel;
@property (nonatomic, retain) IBOutlet UIButton *gemButton;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) NSMutableArray *targets;

- (IBAction)close:(id)sender;

@end
