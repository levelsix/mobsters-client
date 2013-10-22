//
//  TopBarViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"

@interface SplitImageProgressBar : UIView

@property (nonatomic, retain) IBOutlet UIImageView *leftCap;
@property (nonatomic, retain) IBOutlet UIImageView *rightCap;
@property (nonatomic, retain) IBOutlet UIImageView *middleBar;

@property (nonatomic, assign) float percentage;

@end

@interface TopBarView : UIView

@end

@interface TopBarViewController : UIViewController <NumTransitionLabelDelegate>

@property (nonatomic, assign) IBOutlet SplitImageProgressBar *expBar;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *expLabel;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *silverLabel;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *goldLabel;

@property (nonatomic, assign) UIView *curViewOverChatView;

- (IBAction)menuClicked:(id)sender;
- (void) replaceChatViewWithView:(UIView *)view;
- (void) removeViewOverChatView;

@end
