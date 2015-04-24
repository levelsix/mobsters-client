//
//  ItemUtil.h
//  Utopia
//
//  Created by Ashwin on 11/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ItemObject.h"

@interface ItemUtil : NSObject

@property (nonatomic, retain) NSMutableArray *myItems;
@property (nonatomic, retain) NSMutableArray *myItemUsages;

- (id) initWithItemProtos:(NSArray *)items itemUsageProtos:(NSArray *)itemUsages;

- (void) addToMyItems:(NSArray *)itemProtos;
- (void) addToMyItemUsages:(NSArray *)itemUsageProtos;

- (UserItem *) getUserItemForItemId:(int)itemId;
- (NSArray *) getItemsForType:(ItemType)type;
- (NSArray *) getItemsForType:(ItemType)type staticDataId:(int)staticDataId;
- (NSArray *) getItemsForType:(ItemType)type staticDataId:(int)staticDataId gameActionType:(GameActionType)gameActionType;
- (int) getSpeedupMinutesForType:(GameActionType)type userDataUuid:(NSString *)userDataUuid earliestDate:(MSDate *)date;

- (void) incrementItemId:(int)itemId quantity:(int)quantity;

- (void) cleanupRogueItemUsages;

@end
