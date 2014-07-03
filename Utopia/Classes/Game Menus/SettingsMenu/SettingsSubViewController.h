//
//  SettingsSubViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 7/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

#import "DBFBProfilePictureView.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface SettingsSubViewController : PopupSubViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UISwitch *musicSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *soundSwitch;
@property (nonatomic, strong) IBOutlet DBFBProfilePictureView *profilePicIcon;

@property (nonatomic, strong) IBOutlet UIView *fbConnectButton;
@property (nonatomic, strong) IBOutlet UILabel *fbConnectLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *fbConnectSpinner;

- (IBAction) emailSupport:(id)sender;
- (IBAction) forums:(id)sender;
- (IBAction) writeAReview:(id)sender;

@end
