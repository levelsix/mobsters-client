//
//  CashStack.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/31/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"

@interface Drop : CCSprite <CCTouchOneByOneDelegate> {
  BOOL _clicked;
}

@end

@interface CashStack : Drop

@property (nonatomic, assign) int amount;

- (id) initWithAmount:(int)amt;

@end

@interface GoldStack : Drop

@property (nonatomic, assign) int amount;

- (id) initWithAmount:(int)amt;

@end

@interface EquipDrop : Drop

@property (nonatomic, assign) int equipId;

- (id) initWithEquipId:(int)equipId;

@end

@interface LockBoxDrop : Drop

- (id) initWithEventId:(int)eventId;

@end

@interface GemDrop : Drop

@property (nonatomic, assign) int gemId;

- (id) initWithGemId:(int)gemId;

@end
