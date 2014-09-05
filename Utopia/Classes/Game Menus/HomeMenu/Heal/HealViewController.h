//
//  HealViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/26/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

#import "NibUtils.h"
#import "ListCollectionView.h"

@interface HealQueueFooterView : UICollectionReusableView

@property (nonatomic, retain) IBOutlet UICollectionReusableView *openSlotsView;
@property (nonatomic, retain) IBOutlet UILabel *openSlotsLabel;
@property (nonatomic, retain) IBOutlet UILabel *queueFullLabel;
@property (nonatomic, retain) IBOutlet UIImageView *openSlotsBorder;

@end

@interface HealViewController : PopupSubViewController <ListCollectionDelegate> {
  UserMonster *_tempMonster;
  
  HealQueueFooterView *_footerView;
  
  BOOL _waitingForResponse;
}

@property (nonatomic, retain) IBOutlet ListCollectionView *listView;
@property (nonatomic, strong) IBOutlet ListCollectionView *queueView;

@property (nonatomic, strong) IBOutlet MonsterListCell *cardCell;
@property (nonatomic, strong) IBOutlet MonsterQueueCell *queueCell;

@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedupCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *freeLabel;

@property (nonatomic, retain) IBOutlet UILabel *noMobstersLabel;
@property (nonatomic, retain) IBOutlet UILabel *queueEmptyLabel;

@property (nonatomic, retain) IBOutlet UIImageView *queueArrow;

@property (nonatomic, retain) IBOutlet UIView *buttonLabelsView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *buttonSpinner;

@property (nonatomic, retain) NSArray *userMonsters;

@property (nonatomic, strong) NSTimer *updateTimer;

- (void) updateLabels;
- (IBAction) speedupButtonClicked:(id)sender;

- (BOOL) userMonsterIsAvailable:(UserMonster *)um;

- (void) handleHealMonsterResponseProto:(id)fe;

@end
