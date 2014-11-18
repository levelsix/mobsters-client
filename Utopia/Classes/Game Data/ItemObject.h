//
//  ItemObject.h
//  Utopia
//
//  Created by Ashwin on 11/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Protocols.pb.h"

@class MSDate;

@protocol ItemObject <NSObject>

- (int) numOwned;
- (NSString *) name;
- (BOOL) isValid;

- (NSString *) buttonText;
- (BOOL) useGemsButton;

- (NSString *) iconImageName;
- (NSString *) iconText;

@end


@interface UserItem : NSObject <ItemObject>

@property (nonatomic, retain) NSString *userUuid;
@property (nonatomic, assign) int itemId;
@property (nonatomic, assign) int quantity;

+ (id) userItemWithProto:(UserItemProto *)proto;

- (ItemProto *) staticItem;

@end

@interface UserItemUsage : NSObject

@property (nonatomic, retain) NSString *usageUuid;
@property (nonatomic, retain) NSString *userUuid;
@property (nonatomic, assign) int itemId;
@property (nonatomic, retain) MSDate *timeOfEntry;
@property (nonatomic, retain) NSString *userDataUuid;
@property (nonatomic, assign) GameActionType actionType;

+ (id) userItemUsageWithProto:(UserItemUsageProto *)proto;

- (ItemProto *) staticItem;

@end