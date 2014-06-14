//
//  ClanViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "NibUtils.h"
#import "Globals.h"

@class ClanBrowseViewController;
@class ClanCreateViewController;
@class ClanInfoViewController;
@class ClanRaidListViewController;
@class ClanSubViewController;

@protocol ClanViewControllerDelegate <NSObject>

- (void) clanViewControllerDidClose:(id)cvc;

@end

@interface ClanViewController : UIViewController {
  ClanSubViewController *_controller1;
  ClanSubViewController *_controller2;
  
  BOOL _isEditing;
}

@property (nonatomic, retain) ClanBrowseViewController *clanBrowseViewController;
@property (nonatomic, retain) ClanCreateViewController *clanCreateViewController;
@property (nonatomic, retain) ClanInfoViewController *clanInfoViewController;
@property (nonatomic, retain) ClanRaidListViewController *clanRaidViewController;

@property (nonatomic, retain) IBOutlet ButtonTopBar *topBar;
@property (nonatomic, retain) IBOutlet UIView *containerView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet UILabel *backLabel;
@property (nonatomic, retain) IBOutlet MaskedButton *backMaskedButton;

@property (nonatomic, retain) NSArray *myClanMembersList;
@property (nonatomic, assign) int canStartRaidStage;

// Navigation controller stack
@property (nonatomic, retain) NSMutableArray *viewControllers;

@property (nonatomic, assign) id<ClanViewControllerDelegate> delegate;

- (void) loadForClanId:(int)clanId;
- (void) pushViewController:(ClanSubViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (void) goBack;
- (void) close;

@end
