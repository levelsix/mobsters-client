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

@property (nonatomic, retain) IBOutlet SplitImageProgressBar *energyBar;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *expBar;
@property (nonatomic, retain) IBOutlet UILabel *silverLabel;
@property (nonatomic, retain) IBOutlet UILabel *goldLabel;
@property (nonatomic, retain) IBOutlet UILabel *expLabel;
@property (nonatomic, retain) IBOutlet UILabel *energyLabel;


@property (nonatomic, retain) IBOutlet UIView *barButtonView;

- (IBAction)menuClicked:(id)sender;

@end
