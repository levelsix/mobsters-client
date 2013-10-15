//
//  GenViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *menuBackButton;
@property (nonatomic, retain) IBOutlet UILabel *menuBackLabel;
@property (nonatomic, retain) IBOutlet UIView *menuCloseButton;

- (void)loadCustomNavBarButtons;
- (void)setUpImageBackButton;
- (void)setUpCloseButton;
- (IBAction)popCurrentViewController:(id)sender;
- (IBAction)menuCloseClicked:(id)sender;

@end
