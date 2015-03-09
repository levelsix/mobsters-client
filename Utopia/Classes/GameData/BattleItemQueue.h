//
//  BattleItemQueue.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserBattleItem : NSObject

@property (nonatomic, assign) int battleItemId;
@property (nonatomic, retain) NSString *userUuid;
@property (nonatomic, assign) int quantity;

@end

@interface BattleItemQueue : NSObject

@end
