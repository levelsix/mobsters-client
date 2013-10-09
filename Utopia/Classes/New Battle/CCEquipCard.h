//
//  CCEquipCard.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "CCSprite.h"
#import "BattlePlayer.h"
#import "cocos2d.h"

@interface CCEquipCard : CCSprite

@property (nonatomic, assign) CCProgressTimer *durabilityBar;

+ (id) cardWithBattleEquip:(BattleEquip *)equip isOnRightSide:(BOOL)isOnRightSide;
- (id) initWithBattleEquip:(BattleEquip *)equip isOnRightSide:(BOOL)isOnRightSide;

@end
