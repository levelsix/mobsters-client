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

@interface EnhanceSmallCardCell : ListCollectionViewCell

@property (nonatomic, retain) IBOutlet UIImageView *bgdIcon;
@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, retain) IBOutlet UIImageView *qualityBgdView;
@property (nonatomic, retain) IBOutlet UILabel *qualityLabel;
@property (nonatomic, retain) IBOutlet UILabel *enhancePercentLabel;
@property (nonatomic, retain) IBOutlet MonsterCardView *cardView;

@end

@interface EnhanceQueueViewController : PopupSubViewController <ListCollectionDelegate> {
  BOOL _allowAddingToQueue;
  
  UserMonster *_confirmUserMonster;
  int _percentIncrease;
  
  BOOL _waitingForResponse;
}

@property (nonatomic, retain) IBOutlet ListCollectionView *queueView;
@property (nonatomic, retain) IBOutlet ListCollectionView *listView;

@property (nonatomic, retain) IBOutlet MonsterQueueCell *queueCell;
@property (nonatomic, retain) IBOutlet EnhanceSmallCardCell *cardCell;

@property (nonatomic, retain) IBOutlet UIImageView *monsterImageView;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *healthLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedLabel;
@property (nonatomic, retain) IBOutlet UILabel *curPercentLabel;
@property (nonatomic, retain) IBOutlet UILabel *addedPercentLabel;
@property (nonatomic, retain) IBOutlet UILabel *nextLevelLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedupCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *queueingCostLabel;

@property (nonatomic, retain) IBOutlet THLabel *selectMobsterLabel;

@property (nonatomic, retain) IBOutlet UILabel *curLevelLabel;
@property (nonatomic, retain) IBOutlet UILabel *curExpLabel;
@property (nonatomic, retain) IBOutlet UILabel *maxLevelLabel;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *curProgressBar;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *addedProgressBar;

@property (nonatomic, retain) IBOutlet UIImageView *queueArrow;

@property (nonatomic, retain) UserMonster *baseMonster;
@property (nonatomic, retain) NSMutableArray *userMonsters;

@property (nonatomic, retain) IBOutlet UILabel *noMobstersLabel;
@property (nonatomic, retain) IBOutlet UILabel *queueEmptyLabel;

@property (nonatomic, retain) IBOutlet UIView *buttonLabelsView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *buttonSpinner;

@property (nonatomic, strong) NSTimer *updateTimer;

- (void) waitTimeComplete;
- (void) updateLabels;

- (id) initWithBaseMonster:(UserMonster *)um allowAddingToQueue:(BOOL)allowAddingToQueue;
- (id) initWithCurrentEnhancement;

- (UserEnhancement *) currentEnhancement;

@end
