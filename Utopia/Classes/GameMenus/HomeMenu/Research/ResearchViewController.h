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

@end

@interface ResearchCategoryCell : UITableViewCell

- (void) updateForDomain:(ResearchDomain) domain;
@property (nonatomic, retain) IBOutlet UIImageView *categoryIcon;
@property (nonatomic, retain) IBOutlet UILabel *categoryTitle;

@end