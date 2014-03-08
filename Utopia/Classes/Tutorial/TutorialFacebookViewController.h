//
//  TutorialFacebookViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TutorialFacebookDelegate <NSObject>

- (void) facebookConnectAccepted;
- (void) facebookConnectRejected;

@end

@interface TutorialFacebookViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UILabel *connectLabel;

@property (nonatomic, assign) id<TutorialFacebookDelegate> delegate;

- (void) allowClick;

@end
