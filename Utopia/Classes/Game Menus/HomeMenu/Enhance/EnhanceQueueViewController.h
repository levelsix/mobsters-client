//
//  EnhanceQueueViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/24/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

#import "UserData.h"

#import "ListCollectionView.h"

#import "DailyEventCornerView.h"

#import "SpeedupItemsFiller.h"

@interface EnhanceSmallCardCell : ListCollectionViewCell

@property (nonatomic, retain) IBOutlet UIImageView *bgdIcon;
@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, retain) IBOutlet UIImageView *qualityBgdView;
@property (nonatomic, retain) IBOutlet UILabel *qualityLabel;
@property (nonatomic, retain) IBOutlet UILabel *enhancePercentLabel;
@property (nonatomic, retain) IBOutlet MonsterCardView *cardView;
@property (nonatomic, retain) IBOutlet UIImageView *lockIcon;

@end

@interface EnhanceQueueViewController : PopupSubViewController <ListCollectionDelegate, DailyEventCornerDelegate, SpeedupItemsFillerDelegate> {
  UserMonster *_confirmUserMonster;
  
  UserEnhancement *_currentEnhancement;
  
  BOOL _waitingForResponse;
}

@property (nonatomic, retain) IBOutlet ListCollectionView *queueView;
@property (nonatomic, retain) IBOutlet ListCollectionView *listView;

@property (nonatomic, retain) MonsterQueueCell *queueCell;
@property (nonatomic, retain) EnhanceSmallCardCell *cardCell;

@property (nonatomic, retain) IBOutlet UIImageView *monsterImageView;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *healthLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedLabel;
@property (nonatomic, retain) IBOutlet UILabel *afterEnhanceLevelLabel;
@property (nonatomic, retain) IBOutlet UILabel *nextLevelLabel;
@property (nonatomic, retain) IBOutlet UILabel *queueingCostLabel;

@property (nonatomic, retain) IBOutlet UILabel *totalTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *totalQueueCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *gemCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *freeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *speedupIcon;

@property (nonatomic, retain) IBOutlet UIView *oilButtonView;
@property (nonatomic, retain) IBOutlet UIView *finishButtonView;
@property (nonatomic, retain) IBOutlet UIView *helpButtonView;
@property (nonatomic, retain) IBOutlet UIView *collectButtonView;
@property (nonatomic, retain) IBOutlet UIView *buttonViewsContainer;

@property (nonatomic, retain) IBOutlet THLabel *selectMobsterLabel;

@property (nonatomic, retain) IBOutlet UIImageView *monsterGlowIcon;
@property (nonatomic, retain) IBOutlet UIView *levelUpView;
@property (nonatomic, retain) IBOutlet UIImageView *levelIcon;
@property (nonatomic, retain) IBOutlet UIImageView *upIcon;
@property (nonatomic, retain) IBOutlet UILabel *levelUpNumLabel;

@property (nonatomic, retain) IBOutlet UILabel *curLevelLabel;
@property (nonatomic, retain) IBOutlet UILabel *curExpLabel;
@property (nonatomic, retain) IBOutlet UILabel *maxLevelLabel;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *curProgressBar;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *addedProgressBar;

@property (nonatomic, retain) IBOutlet UIImageView *queueArrow;

@property (nonatomic, retain) NSMutableArray *userMonsters;

@property (nonatomic, retain) IBOutlet UILabel *noMobstersLabel;
@property (nonatomic, retain) IBOutlet UILabel *queueEmptyLabel;

@property (nonatomic, retain) IBOutlet UIView *oilLabelsView;
@property (nonatomic, retain) IBOutlet UIView *finishLabelsView;
@property (nonatomic, retain) IBOutlet UIView *collectLabelsView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *buttonSpinner;

@property (nonatomic, retain) IBOutlet UIView *skipButtonView;
@property (nonatomic, retain) IBOutlet UIView *enhanceButtonView;

@property (nonatomic, retain) DailyEventCornerView *dailyEventView;

@property (nonatomic, retain) ItemSelectViewController *itemSelectViewController;
@property (nonatomic, retain) SpeedupItemsFiller *speedupItemsFiller;

- (void) waitTimeComplete;

- (id) initWithBaseMonster:(UserMonster *)um;
- (id) initWithCurrentEnhancement;

- (UserEnhancement *) currentEnhancement;

- (void) reloadQueueViewAnimated:(BOOL)animated;
- (void) reloadListViewAnimated:(BOOL)animated;
- (void) updateLabelsNonTimer;
- (void) updateStats;

- (IBAction)helpClicked:(id)sender;
- (IBAction)finishClicked:(id)sender;

@end
