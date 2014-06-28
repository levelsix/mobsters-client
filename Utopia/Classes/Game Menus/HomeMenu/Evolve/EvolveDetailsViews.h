//
//  EvolveDetailsViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NibUtils.h"

@interface EvolveDetailsMonsterView : EmbeddedNibView

@property (nonatomic, retain) IBOutlet UIImageView *monsterImage;
@property (nonatomic, retain) IBOutlet UIImageView *monsterImageOverlay;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

- (void) updateBaseMonsterWithMonsterId:(int)monsterId level:(int)level;
- (void) updateCatalystMonsterWithMonsterId:(int)monsterId ownsMonster:(BOOL)ownsMonster;
- (void) updateEvolutionMonsterWithMonsterId:(int)monsterId;

@end

@interface EvolveDetailsMiddleView : UIView

@property (nonatomic, retain) IBOutlet EvolveDetailsMonsterView *baseMonsterView1;
@property (nonatomic, retain) IBOutlet EvolveDetailsMonsterView *baseMonsterView2;
@property (nonatomic, retain) IBOutlet EvolveDetailsMonsterView *cataMonsterView;
@property (nonatomic, retain) IBOutlet EvolveDetailsMonsterView *evoMonsterView;

- (void) updateWithEvoItem:(EvoItem *)evoItem;

@end