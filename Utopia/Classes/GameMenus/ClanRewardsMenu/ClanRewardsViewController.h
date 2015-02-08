//
//  ClanRewardsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/24/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NibUtils.h"

@protocol ClanRewardsQuestDelegate <NSObject>

- (void) collectClicked:(id)sender;

@end

@interface ClanRewardsQuestView : EmbeddedNibView

@property (nonatomic, retain) IBOutlet UIImageView *numberIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *gemsLabel;
@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet UIImageView *descriptionIcon;

@property (nonatomic, retain) IBOutlet UIView *rewardView;
@property (nonatomic, retain) IBOutlet UIView *collectView;
@property (nonatomic, retain) IBOutlet UIView *completeView;

@property (nonatomic, retain) IBOutlet UIView *progressView;
@property (nonatomic, retain) IBOutlet UIView *checkView;

@property (nonatomic, assign) IBOutlet id<ClanRewardsQuestDelegate> delegate;

@end

@interface ClanRewardsViewController : UIViewController <ClanRewardsQuestDelegate>

@property (nonatomic, retain) IBOutletCollection(ClanRewardsQuestView) NSArray *questViews;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UIView *containerView;

@end
