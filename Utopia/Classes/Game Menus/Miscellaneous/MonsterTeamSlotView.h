//
//  MonsterTeamSlotView.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"
#import "NibUtils.h"

@class MonsterTeamSlotView;

@protocol MonsterTeamSlotDelegate <NSObject>

- (void) minusClickedForTeamSlotView:(MonsterTeamSlotView *)mv;

@optional
- (void) healAreaClicked:(MonsterTeamSlotView *)mv;

@end

@interface MonsterTeamSlotView : UIView

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet UIImageView *emptyIcon;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtitleLabel;

@property (nonatomic, retain) IBOutlet UIView *healthView;
@property (nonatomic, retain) IBOutlet ProgressBar *healthBar;

@property (nonatomic, retain) IBOutlet UIButton *minusButton;

@property (nonatomic, retain) IBOutlet UIView *rightView;

@property (nonatomic, retain) UserMonster *monster;

@property (nonatomic, assign) id<MonsterTeamSlotDelegate> delegate;

- (void) updateForMyCroniesConfiguration:(UserMonster *)um;
- (void) updateForEnhanceConfiguration:(UserMonster *)um;

- (void) animateNewMonster:(UserMonster *)um;

- (IBAction)minusClicked:(id)sender;
- (IBAction)healAreaClicked:(id)sender;

@end

@interface MonsterTeamSlotContainerView : UIView

@property (nonatomic, retain) IBOutlet MonsterTeamSlotView *teamSlotView;

@end
