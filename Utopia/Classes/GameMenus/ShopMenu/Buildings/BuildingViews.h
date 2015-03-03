//
//  BuildingViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ListCollectionView.h"

@interface BuildingCardCell : ListCollectionViewCell

@property (nonatomic, retain) IBOutlet UIImageView *buildingIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *costLabel;
@property (nonatomic, retain) IBOutlet UIImageView *cashIcon;
@property (nonatomic, retain) IBOutlet UIImageView *oilIcon;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *numOwnedLabel;
@property (nonatomic, retain) IBOutlet UILabel *lockedLabel;

@property (nonatomic, retain) IBOutlet UIImageView *recommendedTag;

@property (nonatomic, retain) IBOutlet UIView *lockedView;
@property (nonatomic, retain) IBOutlet UIView *unlockedView;

@property (nonatomic, retain) IBOutlet UIView *buildingView;
@property (nonatomic, retain) IBOutlet UIView *moneyTreeView;

@property (nonatomic, retain) IBOutlet THLabel *timeLeftLabel;
@property (nonatomic, retain) IBOutlet UILabel *producesLabel;
@property (nonatomic, retain) IBOutlet UILabel *daysLabel;
@property (nonatomic, retain) IBOutlet UILabel *oldCostLabel;
@property (nonatomic, retain) IBOutlet THLabel *curCostLabel;
@property (nonatomic, retain) IBOutlet UIImageView *timerIcon;

- (void) updateForStructInfo:(StructureInfoProto *)structInfo townHall:(UserStruct *)townHall structs:(NSArray *)structs;
- (void) updateForMoneyTree:(MoneyTreeProto *)mtp;
- (void) updateTime:(int)secsLeft;

@end
