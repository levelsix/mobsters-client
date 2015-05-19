//
//  SettingsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 7/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupNavViewController.h"

#import "NibUtils.h"

#import "SettingsSubViewController.h"
#import "FAQViewController.h"
#import "CreditsViewController.h"

@interface SettingsViewController : PopupNavViewController <TabBarDelegate>

@property (nonatomic, retain) SettingsSubViewController *settingsSubViewController;
@property (nonatomic, retain) FAQViewController *faqViewController;
@property (nonatomic, retain) CreditsViewController *creditsViewController;

@property (nonatomic, retain) IBOutlet ButtonTabBar *tabBar;

@end
