//
//  ItemObject.m
//  Utopia
//
//  Created by Ashwin on 11/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ItemObject.h"

#import "GameState.h"
#import "Globals.h"

@implementation UserItem

+ (id) userItemWithProto:(UserItemProto *)proto {
  return [[UserItem alloc] initWithProto:proto];
}

- (id) initWithProto:(UserItemProto *)proto {
  if ((self = [super init])) {
    self.userUuid = proto.userUuid;
    self.itemId = proto.itemId;
    self.quantity = proto.quantity;
  }
  return self;
}

- (ItemProto *) staticItem {
  GameState *gs = [GameState sharedGameState];
  return [gs itemForId:self.itemId];
}

- (BOOL) isEqual:(id)object {
  return [self class] == [object class] && self.itemId == [object itemId];
}

- (NSUInteger) hash {
  return self.itemId*129;
}

#pragma mark - Item Object

- (int) numOwned {
  return self.quantity;
}

- (NSString *) name {
  return self.staticItem.name;
}

- (BOOL) isValid {
  return self.quantity > 0;
}

- (NSString *) buttonText {
  return @"Use";
}

- (BOOL) useGemsButton {
  return NO;
}

- (NSString *) iconImageName {
  return self.staticItem.imgName;
}

- (NSString *) iconText {
  ItemProto *ip = self.staticItem;
  if (ip.itemType == ItemTypeSpeedUp) {
    return [Globals convertTimeToShorterString:ip.amount];
  }
  
  return nil;
}

@end

@implementation UserItemUsage

+ (id) userItemUsageWithProto:(UserItemUsageProto *)proto {
  return [[UserItemUsage alloc] initWithProto:proto];
}

- (id) initWithProto:(UserItemUsageProto *)proto {
  if ((self = [super init])) {
    self.userUuid = proto.userUuid;
    self.itemId = proto.itemId;
    self.usageUuid = proto.usageUuid;
    self.timeOfEntry = [MSDate dateWithTimeIntervalSince1970:proto.timeOfEntry/1000.];
    self.userDataUuid = proto.userDataUuid;
    self.actionType = proto.actionType;
  }
  return self;
}

- (ItemProto *) staticItem {
  GameState *gs = [GameState sharedGameState];
  return [gs itemForId:self.itemId];
}

@end
