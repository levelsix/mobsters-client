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

- (void) monsterCardSelected:(MonsterCardView *)view;
@optional
- (void) combineClicked:(MonsterCardView *)view;

@end

@interface MonsterCardView : UIView {
  int _overlayMaskStatus;
}

@property (nonatomic, assign) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, assign) IBOutlet UIImageView *cardBgdView;
@property (nonatomic, assign) IBOutlet UIImageView *borderView;
@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UILabel *levelLabel;
@property (nonatomic, assign) IBOutlet UIImageView *levelBgdView;
@property (nonatomic, assign) IBOutlet UILabel *qualityLabel;
@property (nonatomic, assign) IBOutlet UIImageView *qualityBgdView;
@property (nonatomic, assign) IBOutlet ProgressBar *healthBar;
@property (nonatomic, assign) IBOutlet UIView *starView;
@property (nonatomic, assign) IBOutlet MaskedButton *overlayButton;

@property (nonatomic, assign) IBOutlet UILabel *noMonsterLabel;
@property (nonatomic, assign) IBOutlet UILabel *overlayLabel;
@property (nonatomic, assign) IBOutlet UILabel *piecesLabel;
@property (nonatomic, assign) IBOutlet UILabel *combineTimeLabel;
@property (nonatomic, assign) IBOutlet UILabel *combineSpeedupLabel;
@property (nonatomic, assign) IBOutlet UIImageView *overlayMask;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *noMonsterView;
@property (nonatomic, retain) IBOutlet UIView *piecesView;
@property (nonatomic, retain) IBOutlet UIView *combineView;
@property (nonatomic, retain) IBOutlet UIView *overlayView;

@property (nonatomic, retain) UserMonster *monster;
@property (nonatomic, assign) id<MonsterCardViewDelegate> delegate;

- (void) updateForMonster:(UserMonster *)um;
- (void) updateForNoMonsterWithLabel:(NSString *)str;

- (void) updateTime;

@end

@interface MonsterCardContainerView : UIView

@property (nonatomic, retain) IBOutlet MonsterCardView *monsterCardView;

@end