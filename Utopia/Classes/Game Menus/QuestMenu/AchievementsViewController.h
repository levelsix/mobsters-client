//
//  AchievementsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/24/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBarViewController.h"

@interface AchievementsCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *rankLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet UILabel *gemRewardLabel;

@property (nonatomic, retain) IBOutlet SplitImageProgressBar *progressBar;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UILabel *collectLabel;

@property (nonatomic, retain) IBOutlet UIView *collectView;
@property (nonatomic, retain) IBOutlet UIView *progressView;

@property (nonatomic, retain) IBOutletCollection(UIImageView) NSArray *starViews;

@property (nonatomic, retain) IBOutlet UIView *mainView;

@property (nonatomic, assign) int achievementId;

@end

@interface AchievementsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
  int _redeemingAchievementId;
}

@property (nonatomic, retain) IBOutlet UITableView *achievementsTable;

@property (nonatomic, retain) IBOutlet AchievementsCell *achievementsCell;

@property (nonatomic, copy) NSDictionary *allAchievements;
@property (nonatomic, retain) NSMutableArray *activeAchievements;
@property (nonatomic, copy) NSDictionary *userAchievements;

- (void) reloadWithAchievements:(NSDictionary *)achievements userAchievements:(NSDictionary *)userAchievements;

@end
