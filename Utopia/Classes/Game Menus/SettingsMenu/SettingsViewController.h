//
//  SettingsViewController.h
//  Utopia
//
//  Created by Danny on 9/9/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "Globals.h"
#import "SettingSwitchButton.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "NibUtils.h"  


@interface SettingsViewController : GenViewController <SettingSwitchButtonDelegate,MFMailComposeViewControllerDelegate, TabBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet FlipTabBar *menuTopBar;
@property (nonatomic, strong) IBOutlet SettingSwitchButton *musicSwitchButton;
@property (nonatomic, strong) IBOutlet SettingSwitchButton *soundSwitchButton;
@property (nonatomic, strong) IBOutlet SettingSwitchButton *shakeSwitchButton;

@property (nonatomic, strong) IBOutlet UIView *faqView;
@property (nonatomic, strong) IBOutlet UIView *settingsView;

@property (nonatomic, strong) NSArray *textStrings;

@property (nonatomic, strong) IBOutlet UITableView *faqTable;

- (IBAction)emailSupport:(id)sender;
- (IBAction)forums:(id)sender;
- (IBAction)writeAReview:(id)sender;
- (IBAction)moreGames:(id)sender;
- (IBAction)changeCharacter:(id)sender;
- (IBAction)changeName:(id)sender;

- (void)loadFAQ;

@end
