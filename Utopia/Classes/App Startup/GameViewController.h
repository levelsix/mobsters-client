//
//  RootViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "TopBarViewController.h"

@interface GameViewController : UIViewController

@property (nonatomic, strong) TopBarViewController *topBarViewController;

- (void) handleConnectedToHost;

@end
