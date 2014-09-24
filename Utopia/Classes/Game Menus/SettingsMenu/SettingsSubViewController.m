//
//  SettingsSubViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 7/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SettingsSubViewController.h"

#import "Globals.h"
#import "GameState.h"
#import "FacebookDelegate.h"
#import "SoundEngine.h"

#import "TangoDelegate.h"

@implementation SettingsSubViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.fbProfilePicIcon.layer.cornerRadius = self.fbProfilePicIcon.frame.size.width/2;
  self.fbConnectSpinner.hidden = YES;
  
  self.tangoProfilePicIcon.layer.cornerRadius = self.tangoProfilePicIcon.frame.size.width/2;
  
  // Taking out tango connect button because they don't want it apparently
  [self.tangoConnectButton removeFromSuperview];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self loadSettings];
}

- (void) loadSettings {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  self.musicSwitch.on = ![ud boolForKey:MUSIC_DEFAULTS_KEY];
  self.soundSwitch.on = ![ud boolForKey:SOUND_EFFECTS_DEFAULTS_KEY];
  
  GameState *gs = [GameState sharedGameState];
  if (gs.facebookId) {
    self.fbConnectButton.hidden = YES;
    self.fbProfilePicIcon.hidden = NO;
    self.fbProfilePicIcon.profileID = gs.facebookId;
  } else {
    self.fbConnectButton.hidden = NO;
    self.fbProfilePicIcon.hidden = YES;
  }
  
#ifdef TOONSQUAD
  
  if ([TangoDelegate isTangoAuthenticated]) {
    self.tangoConnectButton.hidden = YES;
    self.tangoProfilePicIcon.hidden = NO;
    
    [TangoDelegate getProfilePicture:^(UIImage *img) {
      self.tangoProfilePicIcon.image = img;
    }];
  } else {
    self.tangoConnectButton.hidden = NO;
    self.tangoProfilePicIcon.hidden = YES;
  }
  
#else
  
  self.tangoConnectButton.hidden = YES;
  self.tangoProfilePicIcon.hidden = YES;
  
#endif
}

- (IBAction) emailSupport:(id)sender {
  NSString *e = @"support@lvl6.com";
  GameState *gs = [GameState sharedGameState];
  NSString *userId = gs.facebookId ? gs.facebookId : [NSString stringWithFormat:@"%d", gs.userId];
  NSString *messageBody = [NSString stringWithFormat:@"\n\nSent by user %@ with id %@.", gs.name, userId];
  if ([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:[NSArray arrayWithObject:e]];
    
    [controller setMessageBody:messageBody isHTML:NO];
    if (controller) [self.navigationController presentViewController:controller animated:YES completion:nil];
  } else {
    // Launches the Mail application on the device.
    
    NSString *email = [NSString stringWithFormat:@"mailto:%@?body=%@", e, messageBody];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
  }
}

- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) forums:(id)sender {
  NSString *forumLink = @"http://forum.lvl6.com";
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:forumLink]];
}

- (IBAction) writeAReview:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:gl.reviewPageURL]];
}

- (IBAction) facebookConnectClicked:(id)sender {
  if (self.fbConnectSpinner.hidden) {
    self.fbConnectLabelView.hidden = YES;
    self.fbConnectSpinner.hidden = NO;
    [self.fbConnectSpinner startAnimating];
    [FacebookDelegate openSessionWithLoginUI:YES completionHandler:^(BOOL success) {
      self.fbConnectLabelView.hidden = NO;
      self.fbConnectSpinner.hidden = YES;
      
      [self loadSettings];
    }];
  }
}

- (IBAction)tangoClicked:(id)sender {
#ifdef TOONSQUAD
  [TangoDelegate authenticate];
#endif
}

- (IBAction) musicChanged:(id)sender {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  // Note that this is NO when music should be on
  [ud setBool:!self.musicSwitch.isOn forKey:MUSIC_DEFAULTS_KEY];
  
  if (self.musicSwitch.isOn) {
    [[SoundEngine sharedSoundEngine] resumeBackgroundMusic];
  } else {
    [[SoundEngine sharedSoundEngine] stopBackgroundMusic];
  }
}

- (IBAction) soundsChanged:(id)sender {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  // Note that this is NO when music should be on
  [ud setBool:!self.soundSwitch.isOn forKey:SOUND_EFFECTS_DEFAULTS_KEY];
}

@end
