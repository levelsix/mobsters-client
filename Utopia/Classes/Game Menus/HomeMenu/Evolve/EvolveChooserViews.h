//
//  EvolveChooserViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MonsterCardView.h"
#import "UserData.h"
#import "NibUtils.h"

#define EVO_NUM_ELEMENTS 5
#define EVO_NUM_LEVELS 3

@protocol EvolveCardDelegate <NSObject>

- (void) infoClicked:(id)sender;
- (void) cardClicked:(id)sender;

@end

@interface EvolveCardCell : UICollectionViewCell <MonsterCardViewDelegate>

@property (nonatomic, retain) IBOutlet MonsterCardContainerView *topContainer;
@property (nonatomic, retain) IBOutlet MonsterCardContainerView *botContainer;

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UILabel *reqEvoChamberLabel;

@property (nonatomic, assign) id<EvolveCardDelegate> delegate;

- (void) updateForEvoItem:(EvoItem *)evoItem;

@end

@protocol EvolveScientistDelegate

- (void) scientistViewClicked:(id)sender;

@end

@interface EvolveScientistView : EmbeddedNibView

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet THLabel *quantityLabel;

@property (nonatomic, assign) IBOutlet id<EvolveScientistDelegate> delegate;

- (IBAction)cardClicked:(id)sender;

@end

@interface EvolveChooserBottomView : UIView <EvolveScientistDelegate> {
  int _quantityVals[EVO_NUM_ELEMENTS][EVO_NUM_LEVELS];
  int _currentSelection;
}

@property (nonatomic, retain) IBOutletCollection(EvolveScientistView) NSArray *scientistViews;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *quantityLabels;
@property (nonatomic, strong) IBOutlet UIView *quantityView;

- (void) updateWithUserMonsters:(NSArray *)userMonsters;

@end
