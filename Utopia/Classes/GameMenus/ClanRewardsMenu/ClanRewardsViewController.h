//
//  ClanRewardsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/24/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NibUtils.h"
#import "FullEvent.h"

@protocol ClanRewardsQuestDelegate <NSObject>

- (void) collectClicked:(id)sender;
- (void) goClicked:(id)sender;

@end

@interface ClanRewardsQuestView : EmbeddedNibView
@property (nonatomic, assign) BOOL greyScale;

@property (nonatomic, retain) IBOutlet UIImageView *numberIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *gemsLabel;
@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet UIImageView *descriptionIcon;

@property (nonatomic, retain) IBOutlet UIImageView *rewardBg;
@property (nonatomic, retain) IBOutlet UIImageView *diamondIcon;

@property (nonatomic, retain) IBOutlet UIView *collectView;
@property (nonatomic, retain) IBOutlet UIView *completeView;

@property (nonatomic, retain) IBOutlet UIView *progressView;
@property (nonatomic, retain) IBOutlet UIView *checkView;

@property (nonatomic, retain) IBOutlet THLabel *goButtonLabel;
@property (nonatomic, retain) IBOutlet UIImageView *circleImage;

@property (nonatomic, weak) IBOutlet id<ClanRewardsQuestDelegate> delegate;

@end

@interface ClanRewardsViewController : UIViewController <ClanRewardsQuestDelegate>

@property (nonatomic, retain) IBOutletCollection(ClanRewardsQuestView) NSArray *questViews;

@property (weak, nonatomic) IBOutlet UIImageView *squadRewardArrow;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UIView *containerView;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *titleDiamond;

@end
