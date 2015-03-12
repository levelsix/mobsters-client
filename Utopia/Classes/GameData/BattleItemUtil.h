//
//  BattleItemUtil.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BattleItemQueue.h"

@interface UserBattleItem : NSObject

@property (nonatomic, assign) int battleItemId;
@property (nonatomic, retain) NSString *userUuid;
@property (nonatomic, assign) int quantity;

@end

@interface BattleItemUtil : NSObject

@property (nonatomic, retain) BattleItemQueue *battleItemQueue;
@property (nonatomic, retain) NSMutableArray *battleItems;

- (id) initWithQueueProtos:(NSArray *)queueProtos itemProtos:(NSArray *)itemProtos;

@end
