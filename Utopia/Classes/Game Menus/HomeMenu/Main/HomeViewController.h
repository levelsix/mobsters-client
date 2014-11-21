//
//  HomeViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/20/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupNavViewController.h"

@interface HomeTitleView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *titleImageView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@end

@protocol HomeViewControllerDelegate <NSObject>

- (void) homeViewControllerClosed;

@end

@interface HomeViewController : PopupNavViewController {
  Class _initViewControllerClass;
  int _currentIndex;
}

@property (nonatomic, retain) IBOutlet HomeTitleView *curHomeTitleView;

@property (nonatomic, retain) IBOutlet UIView *selectorView;

@property (nonatomic, retain) NSMutableArray *mainViewControllers;

@property (nonatomic, retain) id<HomeViewControllerDelegate> delegate;

- (id) initWithSell;
- (id) initWithHeal;
- (id) initWithTeam;
- (id) initWithEnhance;
- (id) initWithEvolve;
- (id) initWithMiniJobs;

- (void) loadMainViewControllers;

@end
