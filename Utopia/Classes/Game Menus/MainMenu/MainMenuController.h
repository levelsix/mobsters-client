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

@property (nonatomic, retain) IBOutlet UIView *labButtonView;
@property (nonatomic, retain) IBOutlet UIButton *labButton;

- (IBAction)fundsClicked:(id)sender;

@end
