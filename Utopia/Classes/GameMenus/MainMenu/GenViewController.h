//
//  GenViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoinBar.h"
#import "NibUtils.h"

@interface GenViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *menuBackButton;
@property (nonatomic, retain) IBOutlet MaskedButton *menuBackMaskedButton;
@property (nonatomic, retain) IBOutlet UILabel *menuBackLabel;
@property (nonatomic, retain) IBOutlet UIView *menuCloseButton;

@property (nonatomic, strong) IBOutlet CoinBar *topBar;

@property (nonatomic, retain) NSString *shortTitle;

- (void)loadCustomNavBarButtons;
- (void)setUpImageBackButton;
- (void)setUpCloseButton:(BOOL)right;
- (IBAction)menuBackClicked:(id)sender;
- (IBAction)menuCloseClicked:(id)sender;

@end
