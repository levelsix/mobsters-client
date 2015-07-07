//
//  LoadingViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "LoadingViewController.h"
#import "Globals.h"
#import "ClientProperties.h"
#import "GameViewController.h"

#define SECONDS_PER_PART 5.f

#define FIRST_TIME_DEFAULTS_KEY @"FirstTimeLoading"

@implementation LoadingViewController

- (id) initWithPercentage:(float)percentage {
  if ((self = [super init])) {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    _initPercentage = percentage;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.loadingBar.percentage = _initPercentage;
  
#ifndef APPSTORE
  self.versionLabel.text = [NSString stringWithFormat:@"%@\n%@", CLIENT_BRANCH, SERVER_ID];
  self.chatButton.hidden = NO;
#else
  [self.versionLabel removeFromSuperview];
  [self.chatButton removeFromSuperview];
#endif
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
//  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//  BOOL loading = [def boolForKey:FIRST_TIME_DEFAULTS_KEY];
//  NSString *bgd = nil;
//  if (!loading) {
//    [def setBool:YES forKey:FIRST_TIME_DEFAULTS_KEY];
//    
//    bgd = @"1splashbg.png";
//  } else {
//    bgd = [NSString stringWithFormat:@"%dsplashbg.png", (arc4random()%6)+1];
//  }
//  
//  [Globals imageNamed:bgd withView:self.bgdImageView greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
//  
//  if (![Globals isSmallestiPhone]) {
//    self.fgdImageView.image = [Globals imageNamed:@"splashguyswide.png"];
//  }
//  
//  if (self.view.width >= self.mainView.width) {
//    self.mainView.center = ccp(self.view.width/2, self.view.height/2);
//  }
  
  self.tipLabel.text = [Globals getRandomTipFromFile:@"tips"];
}

- (void) progressToPercentage:(float)percentage {
  if (percentage > 0.01) {
    [UIView animateWithDuration:SECONDS_PER_PART animations:^{
      self.loadingBar.percentage = percentage;
    }];
  } else {
    [self setPercentage:percentage];
  }
}

- (void) setPercentage:(float)percentage {
  self.loadingBar.percentage = percentage;
}

- (BOOL) prefersStatusBarHidden {
  return YES;
}

- (IBAction)chatClicked:(id)sender {
  GameViewController *gvc = [GameViewController baseController];
  [gvc openChatWithScope:ChatScopeGlobal];
}

@end
