//
//  BattlePlayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"

@interface BattlePlayer : NSObject

@property (nonatomic, assign) int curHealth;
@property (nonatomic, assign) int maxHealth;

@property (nonatomic, assign) int fireDamage;
@property (nonatomic, assign) int waterDamage;
@property (nonatomic, assign) int earthDamage;
@property (nonatomic, assign) int lightDamage;
@property (nonatomic, assign) int nightDamage;

- (id) initWithMonster:(MonsterProto *)monster level:(int)level;

@end
