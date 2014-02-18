//
//  EvoViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/26/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"
#import "NibUtils.h"
#import "MonsterCardView.h"

@class EvoCardCell;

@protocol EvoCardCellDelegate

- (void) infoClicked:(EvoCardCell *)cell;
- (void) cardClicked:(EvoCardCell *)cell;

@end

@interface EvoCardCell : UIView <MonsterCardViewDelegate>

@property (nonatomic, retain) IBOutlet MonsterCardContainerView *readyContainer1;
@property (nonatomic, retain) IBOutlet MonsterCardContainerView *readyContainer2;
@property (nonatomic, retain) IBOutlet UIImageView *readyTeamIcon;
@property (nonatomic, retain) IBOutlet MonsterCardContainerView *notReadyContainer;
@property (nonatomic, retain) IBOutlet UIImageView *notReadyTeamIcon;

@property (nonatomic, retain) IBOutlet UIView *readyView;
@property (nonatomic, retain) IBOutlet UIView *notReadyView;

@property (nonatomic, retain) EvoItem *evoItem;

@property (nonatomic, assign) IBOutlet id<EvoCardCellDelegate> delegate;

- (void) updateForEvoItem:(EvoItem *)item;

@end

@interface EvoScientistView : UIView

@property (nonatomic, strong) IBOutlet UIImageView *bgdIcon;
@property (nonatomic, strong) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, strong) IBOutlet UILabel *quantityLabel;

@end

@interface EvoBottomView : UIView {
  int _curViewNum;
}

@property (nonatomic, strong) IBOutletCollection(EvoScientistView) NSArray *scientistViews;

@property (nonatomic, strong) IBOutlet UIView *leftLabelView;
@property (nonatomic, strong) IBOutlet UIView *quantityView;
@property (nonatomic, strong) IBOutlet UILabel *quantity1Label;
@property (nonatomic, strong) IBOutlet UILabel *quantity2Label;
@property (nonatomic, strong) IBOutlet UILabel *quantity3Label;

@property (nonatomic, strong) IBOutlet UIView *infoLabelView;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *topLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *botLabels;

- (void) updateForEvoItems;
- (void) openView:(int)tag;

- (void) displayScientists;
- (void) displayInfoLabel:(EvoItem *)item;

@end

@interface EvoMiddleView : UIView

@property (nonatomic, retain) IBOutlet MonsterCardContainerView *evoContainer1;
@property (nonatomic, retain) IBOutlet MonsterCardContainerView *evoContainer2;
@property (nonatomic, retain) IBOutlet MonsterCardContainerView *catalystContainer;
@property (nonatomic, retain) IBOutlet UIImageView *evolvedMonsterIcon;
@property (nonatomic, retain) IBOutlet UIButton *minusButton;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *oilCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedupCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *missingCataLabel;

@property (nonatomic, retain) IBOutlet UIView *choosingView;
@property (nonatomic, retain) IBOutlet UIView *evolvingView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *speedupSpinner;

- (void) updateForEvoItem:(EvoItem *)evoItem;
- (void) updateForEvolution:(UserEvolution *)evoItem;
- (void) updateTime;

@end
