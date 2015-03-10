//
//  ResearchViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 2/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSubViewController.h"

@interface ResearchViewController : PopupSubViewController
@property (nonatomic, retain) IBOutlet UIView *curReseaerchBar;
@property (nonatomic, retain) IBOutlet UILabel *cureSkillTitle;
@property (nonatomic, retain) IBOutlet NiceFontLabel8T *curTimeRemaining;

@property (nonatomic, retain) IBOutlet UIView *selectFieldView;

@end

@interface ResearchCategoryCell : UITableViewCell

- (void) updateForDomain:(ResearchDomain) domain;
@property (nonatomic, retain) IBOutlet UIImageView *categoryIcon;
@property (nonatomic, retain) IBOutlet UILabel *categoryTitle;

@end