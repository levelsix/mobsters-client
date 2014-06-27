//
//  HomeViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/20/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupNavViewController.h"

@interface HomeViewController : PopupNavViewController {
  Class _initViewControllerClass;
  int _currentIndex;
}

// HomeTitleView views
@property (nonatomic, retain) IBOutlet UIImageView *homeTitleImageView;
@property (nonatomic, retain) IBOutlet UILabel *homeTitleLabel;
@property (nonatomic, retain) IBOutlet UIView *homeTitleView;

@property (nonatomic, retain) IBOutlet UILabel *bigTitleLabel;

@property (nonatomic, retain) IBOutlet UIView *selectorView;

@property (nonatomic, retain) NSArray *mainViewControllers;

- (id) initWithSell;
- (id) initWithHeal;
- (id) initWithTeam;
- (id) initWithEnhance;

@end
