//
//  ItemFactoryViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ListCollectionView.h"

@interface ItemFactoryCardCell : ListCollectionViewCell <MonsterCardViewDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *bgdIcon;
@property (nonatomic, retain) IBOutlet UIImageView *itemIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;

@property (nonatomic, retain) IBOutlet UIImageView *cashIcon;
@property (nonatomic, retain) IBOutlet UIImageView *oilIcon;
@property (nonatomic, retain) IBOutlet UILabel *costLabel;

@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) IBOutlet UIButton *overlayButton;

- (void) updateForListObject:(id)listObject greyscale:(BOOL)greyscale;

@end