//
//  GachaViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ListCollectionView.h"

@interface GachaCardCell : ListCollectionViewCell

@property (weak, nonatomic) IBOutlet GeneralButton *mainButton;
@property (weak, nonatomic) IBOutlet BadgeIcon *badge;

@end
