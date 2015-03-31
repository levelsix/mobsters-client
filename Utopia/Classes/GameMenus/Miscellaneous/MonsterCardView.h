//
//  EquipCardView.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/29/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@class MonsterCardView;
@class MaskedButton;

@protocol MonsterCardViewDelegate <NSObject>

- (void) infoClicked:(MonsterCardView *)view;
@optional
- (void) monsterCardSelected:(MonsterCardView *)view;

@end

@interface EvoBadge : UIView

@property (nonatomic, strong) IBOutlet UILabel *evoLevel;
@property (nonatomic, strong) IBOutlet UIImageView *bg;

- (void) updateForToonId:(int)toonId;
- (void) updateForToonId:(int)toonId greyscale:(BOOL)greyscale;
- (void) updateForToon:(MonsterProto *)proto;
- (void) updateForToon:(MonsterProto *)proto greyscale:(BOOL)greyscale;

@end

@interface MonsterCardView : UIView

@property (nonatomic, assign) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, assign) IBOutlet UIImageView *cardBgdView;
@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UILabel *qualityLabel;
@property (nonatomic, assign) IBOutlet UIImageView *qualityBgdView;
@property (nonatomic, assign) IBOutlet MaskedButton *overlayButton;
@property (nonatomic, assign) IBOutlet UIButton *infoButton;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *noMonsterView;

@property (nonatomic, retain) IBOutlet EvoBadge *evoBadge;

@property (nonatomic, retain) UserMonster *monster;
@property (nonatomic, assign) IBOutlet id<MonsterCardViewDelegate> delegate;

- (void) updateForMonster:(UserMonster *)um;
- (void) updateForNoMonsterWithLabel:(NSString *)str;
- (void) updateForMonster:(UserMonster *)um backupString:(NSString *)str greyscale:(BOOL)greyscale;

- (IBAction)darkOverlayClicked:(id)sender;
- (IBAction)infoClicked:(id)sender;

@end

@interface MonsterCardContainerView : UIView

@property (nonatomic, retain) IBOutlet MonsterCardView *monsterCardView;

@end

@interface MiniMonsterView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, retain) IBOutlet UIImageView *bgdIcon;
@property (nonatomic, retain) IBOutlet EvoBadge *evoBadge;
@property (nonatomic, retain) IBOutletCollection(UIView) NSArray* sideEffectViews;

@property (nonatomic, assign) int monsterId;
@property (nonatomic, assign) BOOL belongsToPlayer; // Set and used only by BattleScheduleView
@property (nonatomic, readonly) NSMutableDictionary* sideEffectSymbols;

- (void) updateForMonsterId:(int)monsterId;
- (void) updateForMonsterId:(int)monsterId greyscale:(BOOL)greyscale;
- (void) updateForElement:(Element)element imgPrefix:(NSString *)imgPrefix greyscale:(BOOL)greyscale;

- (void) displaySideEffectIcon:(NSString*)icon withKey:(NSString*)key;
- (void) removeSideEffectIconWithKey:(NSString*)key;
- (void) removeAllSideEffectIcons;

@end

@interface CircleMonsterView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, retain) IBOutlet UIImageView *bgdIcon;

@property (nonatomic, assign) int monsterId;

- (void) updateForMonsterId:(int)monsterId;

@end