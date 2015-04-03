//
//  ResearchDetailViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 3/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSubViewController.h"

@interface ResearchDetailViewCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UIView *bgView;
@property (nonatomic, assign) IBOutlet UIImageView *checkMark;
@property (nonatomic, assign) IBOutlet UILabel *rankLabel;
@property (nonatomic, assign) IBOutlet UILabel *improvementLabel;

- (void) updateWithRank:(NSString *)rank description:(NSString *)description showCheckMark:(BOOL)show;

@end

@interface ResearchDetailView : UIView

@property (nonatomic, assign) IBOutlet UILabel *researchNameLabel;
@property (nonatomic, assign) IBOutlet UILabel *researchRank;
@property (nonatomic, assign) IBOutlet UIImageView *researchIcon;

- (void) updateWithResearch:(UserResearch *)userResearch;

@end

@interface ResearchDetailViewController : PopupSubViewController {
  UserResearch *_userResearch;
}

- (id) initWithUserResearch:(UserResearch *)userResearch;

@property (nonatomic, assign) IBOutlet ResearchDetailView *view;

@end
