//
//  MainMenuViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupNavViewController.h"

#import "NibUtils.h"

@interface MainMenuViewController : PopupNavViewController <TabBarDelegate>

@property (nonatomic, retain) ButtonTopBar *tabBar;

@end
