//
//  EnhanceViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/29/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "EquipCardView.h"

@interface EnhanceBrowseCell : UITableViewCell

@property (nonatomic, retain) IBOutletCollection(EquipCardContainerView) NSArray *containerViews;

@end

@interface EnhanceViewController : GenViewController <UITableViewDataSource, UITableViewDelegate> {
  BOOL _isAnimating;
}

@property (nonatomic, retain) UserEquip *baseEquip;
@property (nonatomic, retain) NSMutableArray *feeders;
@property (nonatomic, retain) NSMutableArray *feederCards;

@property (nonatomic, retain) IBOutlet EnhanceBrowseCell *browseCell;
@property (nonatomic, retain) IBOutlet EquipCardView *equipCardView;

@property (nonatomic, assign) IBOutlet EquipCardContainerView *baseCard;
@property (nonatomic, assign) IBOutlet UIScrollView *feederScrollView;
@property (nonatomic, assign) IBOutlet UITableView *equipTable;
@property (nonatomic, assign) IBOutlet UILabel *curAttackLabel;
@property (nonatomic, assign) IBOutlet UILabel *curDefenseLabel;
@property (nonatomic, assign) IBOutlet UILabel *nextAttackLabel;
@property (nonatomic, assign) IBOutlet UILabel *nextDefenseLabel;
@property (nonatomic, assign) IBOutlet UIImageView *blankFeederCard;

@property (nonatomic, assign) IBOutlet ProgressBar *orangeBar;
@property (nonatomic, assign) IBOutlet ProgressBar *yellowBar;
@property (nonatomic, assign) IBOutlet UILabel *progressLabel;
@property (nonatomic, assign) IBOutlet UILabel *costLabel;
@property (nonatomic, retain) IBOutlet UIView *enhanceButtonView;

@property (nonatomic, retain) IBOutlet UIView *equipChosenView;
@property (nonatomic, retain) IBOutlet UIView *noEquipChosenView;

@property (nonatomic, assign) IBOutlet UIView *topLeftView;
@property (nonatomic, assign) IBOutlet UIView *topRightView;

- (IBAction)submitClicked:(id)sender;

@end
