//
//  EquipCardView.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/29/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"
#import "NibUtils.h"

@class EquipCardView;

@protocol EquipCardViewDelegate <NSObject>

- (void) equipViewSelected:(EquipCardView *)view;

@end

@interface EquipCardView : UIView

@property (nonatomic, assign) IBOutlet UIImageView *equipIcon;
@property (nonatomic, assign) IBOutlet UIImageView *bgd;
@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UILabel *attackLabel;
@property (nonatomic, assign) IBOutlet UILabel *defenseLabel;
@property (nonatomic, assign) IBOutlet EquipLevelIcon *levelIcon;
@property (nonatomic, assign) IBOutlet MaskedButton *darkOverlay;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *noEquipView;

@property (nonatomic, retain) UserEquip *equip;
@property (nonatomic, assign) id<EquipCardViewDelegate> delegate;

- (void) updateForEquip:(UserEquip *)ue;
- (void) updateForNoEquip;

@end

@interface EquipCardContainerView : UIView

@property (nonatomic, retain) IBOutlet EquipCardView *equipCardView;

@end