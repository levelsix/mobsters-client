//
//  LoadingViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"

@interface LoadingViewController : UIViewController {
  float _initPercentage;
}

@property (nonatomic, assign) IBOutlet ProgressBar *loadingBar;

- (id) initWithPercentage:(float)percentage;

- (void) progressToPercentage:(float)percentage;
- (void) setPercentage:(float)percentage;

@end
