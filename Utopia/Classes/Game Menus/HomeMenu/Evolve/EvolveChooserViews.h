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

@protocol EvolveCardDelegate <NSObject>

- (void) infoClicked:(id)sender;
- (void) cardClicked:(id)sender;

@end

@interface EvolveCardCell : UICollectionViewCell <MonsterCardViewDelegate>

@property (nonatomic, retain) IBOutlet MonsterCardContainerView *topContainer;
@property (nonatomic, retain) IBOutlet MonsterCardContainerView *botContainer;

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;

@property (nonatomic, assign) id<EvolveCardDelegate> delegate;

- (void) updateForEvoItem:(EvoItem *)evoItem;

@end
