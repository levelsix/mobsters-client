//
//  HealViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/26/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

#import "NibUtils.h"
#import "MonsterListView.h"

@interface HealQueueFooterView : UICollectionReusableView

@property (nonatomic, retain) IBOutlet UICollectionReusableView *openSlotsView;
@property (nonatomic, retain) IBOutlet UILabel *openSlotsLabel;
@property (nonatomic, retain) IBOutlet UILabel *queueFullLabel;
@property (nonatomic, retain) IBOutlet UIImageView *openSlotsBorder;

@end

@interface HealViewController : PopupSubViewController <MonsterListDelegate> {
  UserMonster *_tempMonster;
  
  HealQueueFooterView *_footerView;
}

@property (nonatomic, retain) IBOutlet MonsterListView *listView;
@property (nonatomic, strong) IBOutlet MonsterListView *queueView;

@property (nonatomic, strong) IBOutlet MonsterListCell *cardCell;
@property (nonatomic, strong) IBOutlet MonsterQueueCell *queueCell;

@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedupCostLabel;

@property (nonatomic, retain) IBOutlet UIImageView *queueArrow;

@property (nonatomic, retain) NSArray *userMonsters;

@property (nonatomic, strong) NSTimer *updateTimer;

@end
