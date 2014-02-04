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

@class MonsterCardView;

@protocol MonsterCardViewDelegate <NSObject>

- (void) infoClicked:(MonsterCardView *)view;
@optional
- (void) monsterCardSelected:(MonsterCardView *)view;

@end

@interface MonsterCardView : UIView

@property (nonatomic, assign) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, assign) IBOutlet UIImageView *cardBgdView;
@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UILabel *qualityLabel;
@property (nonatomic, assign) IBOutlet UIImageView *qualityBgdView;
@property (nonatomic, assign) IBOutlet UIView *starView;
@property (nonatomic, assign) IBOutlet MaskedButton *overlayButton;
@property (nonatomic, assign) IBOutlet UIButton *infoButton;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *noMonsterView;

@property (nonatomic, retain) UserMonster *monster;
@property (nonatomic, assign) id<MonsterCardViewDelegate> delegate;

- (void) updateForMonster:(UserMonster *)um;
- (void) updateForNoMonsterWithLabel:(NSString *)str;

- (IBAction)darkOverlayClicked:(id)sender;
- (IBAction)infoClicked:(id)sender;

@end

@interface MonsterCardContainerView : UIView

@property (nonatomic, retain) IBOutlet MonsterCardView *monsterCardView;

@end