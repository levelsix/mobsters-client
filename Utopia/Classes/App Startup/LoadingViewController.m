//
//  LoadingViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "LoadingViewController.h"
#import "Globals.h"

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
  self.loadingBar.percentage = _initPercentage;
}

- (void) viewWillAppear:(BOOL)animated {
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  BOOL loading = [def boolForKey:FIRST_TIME_DEFAULTS_KEY];
  NSString *bgd = nil;
  if (!loading) {
    [def setBool:YES forKey:FIRST_TIME_DEFAULTS_KEY];
    
    bgd = @"1splashbg.png";
  } else {
    bgd = [NSString stringWithFormat:@"%dsplashbg.png", (arc4random()%6)+1];
  }
  
  [Globals imageNamed:bgd withView:self.bgdImageView greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  if ([Globals isLongiPhone]) {
    self.fgdImageView.image = [Globals imageNamed:@"splashguyswide.png"];
  }
  
  self.tipLabel.text = [Globals getRandomTipFromFile:@"tips"];
}

- (void) progressToPercentage:(float)percentage {
  if (percentage > 0.1) {
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

@end
