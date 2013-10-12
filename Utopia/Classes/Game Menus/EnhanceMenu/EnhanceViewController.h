//
//  EnhanceViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/29/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "MonsterCardView.h"

@interface EnhanceBrowseCell : UITableViewCell

@property (nonatomic, retain) IBOutletCollection(MonsterCardContainerView) NSArray *containerViews;

@end

@interface EnhanceViewController : GenViewController <UITableViewDataSource, UITableViewDelegate> {
  BOOL _isAnimating;
}

@property (nonatomic, retain) UserMonster *baseMonster;
@property (nonatomic, retain) NSMutableArray *feeders;
@property (nonatomic, retain) NSMutableArray *feederCards;

@property (nonatomic, retain) IBOutlet EnhanceBrowseCell *browseCell;
@property (nonatomic, retain) IBOutlet MonsterCardView *monsterCardView;

@property (nonatomic, assign) IBOutlet MonsterCardContainerView *baseCard;
@property (nonatomic, assign) IBOutlet UIScrollView *feederScrollView;
@property (nonatomic, assign) IBOutlet UITableView *monsterTable;
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

@property (nonatomic, retain) IBOutlet UIView *monsterChosenView;
@property (nonatomic, retain) IBOutlet UIView *noMonsterChosenView;

@property (nonatomic, assign) IBOutlet UIView *topLeftView;
@property (nonatomic, assign) IBOutlet UIView *topRightView;

- (IBAction)submitClicked:(id)sender;

@end
