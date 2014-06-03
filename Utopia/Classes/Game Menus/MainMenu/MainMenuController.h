//
//  MainMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/15/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"

@interface MainMenuController : GenViewController

@property (nonatomic, retain) IBOutlet UIView *menuSettingsButton;

@property (nonatomic, retain) IBOutlet UIView *enhanceButtonView;
@property (nonatomic, retain) IBOutlet UIView *evolveButtonView;

@property (nonatomic, retain) IBOutlet UIView *buildingsButtonView;

- (IBAction)fundsClicked:(id)sender;

@end
