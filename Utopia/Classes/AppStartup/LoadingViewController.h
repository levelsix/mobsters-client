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
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *splitLoadingBar; //IPAD VERSION
@property (nonatomic, assign) IBOutlet UILabel *tipLabel;
@property (nonatomic, assign) IBOutlet UIImageView *bgdImageView;
@property (nonatomic, assign) IBOutlet UIImageView *fgdImageView;
@property (nonatomic, assign) IBOutlet UIView *mainView;
@property (nonatomic, assign) IBOutlet UILabel *versionLabel;

- (id) initWithPercentage:(float)percentage;

- (void) progressToPercentage:(float)percentage;
- (void) setPercentage:(float)percentage;

@end
