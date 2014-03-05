//
//  ClanRaidHealthBar.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/26/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <cocos2d.h>
#import "Protocols.pb.h"
#import "PersistentEventProto+Time.h"

@interface ClanMemberAttack : NSObject

@property (nonatomic, assign) int monsterId;
@property (nonatomic, assign) int attackDamage;
@property (nonatomic, copy) NSString *name;

- (id) initWithMonsterId:(int)monsterId attackDmg:(int)dmg name:(NSString *)name;

@end

@interface ClanRaidHealthBar : CCNode {
  BOOL _leftCapIsFull;
}

@property (nonatomic, retain) CCClippingNode *leftCap;
@property (nonatomic, retain) CCSprite *middleBar;
@property (nonatomic, retain) CCClippingNode *rightCap;
@property (nonatomic, retain) CCSprite *rightCapSprite;

@property (nonatomic, retain) NSArray *bubbles;

- (id) initWithStage:(ClanRaidStageProto *)stage width:(float)width;
- (void) updateForPercentage:(float)percent;

@end
