//
//  TopBarView.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/14/13.
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

@property (nonatomic, assign) IBOutlet SplitImageProgressBar *energyBar;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *expBar;
@property (nonatomic, assign) IBOutlet UILabel *silverLabel;
@property (nonatomic, assign) IBOutlet UILabel *goldLabel;
@property (nonatomic, assign) IBOutlet UILabel *expLabel;
@property (nonatomic, assign) IBOutlet UILabel *energyLabel;

@property (nonatomic, assign) IBOutlet UIView *barButtonView;

@property (nonatomic, assign) IBOutlet UIView *curViewOverChatView;

- (IBAction)menuClicked:(id)sender;
- (void) replaceChatViewWithView:(UIView *)view;
- (void) removeViewOverChatView;

@end
