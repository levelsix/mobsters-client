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

- (UserItemProto *) toProto {
  UserItemProto_Builder *bldr = [UserItemProto builder];
  bldr.itemId = self.itemId;
  bldr.userUuid = self.userUuid;
  bldr.quantity = self.quantity;
  return bldr.build;
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

- (BOOL) showFreeLabel {
  return NO;
}

- (NSString *) iconImageName {
  return self.staticItem.imgName;
}

- (NSString *) iconText {
  ItemProto *ip = self.staticItem;
  if (ip.itemType == ItemTypeSpeedUp) {
    return [[Globals convertTimeToShorterString:ip.amount*60] uppercaseString];
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
    self.usageUuid = proto.hasUsageUuid ? proto.usageUuid : nil;
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

- (BOOL) isEqual:(UserItemUsage *)object {
  if (!self.usageUuid || !object.usageUuid) {
    return (self.itemId == object.itemId && [self.timeOfEntry isEqualToDate:object.timeOfEntry] &&
            [self.userDataUuid isEqualToString:object.userDataUuid] && self.actionType == object.actionType);
  } else {
    return [self.usageUuid isEqualToString:object.usageUuid];
  }
}

- (NSUInteger) hash {
  return (NSUInteger)(self.itemId*31 + self.userDataUuid.hash*29 + self.actionType*11 + self.timeOfEntry.hash);
}

@end

@implementation GemsItemObject

- (id) initWithNumGems:(int)numGems {
  if ((self = [super init])) {
    self.numGems = numGems;
  }
  return self;
}

// There should only ever be one so just check class comparison
- (BOOL) isEqual:(id)object {
  return [self class] == [object class];
}

- (NSUInteger) hash {
  return 1452;
}

#pragma mark - Item Object

- (int) numOwned {
  GameState *gs = [GameState sharedGameState];
  return gs.gems;
}

- (NSString *) name {
  return @"Gems";
}

- (BOOL) isValid {
  return YES;
}

- (NSString *) buttonText {
  return [Globals commafyNumber:self.numGems];
}

- (BOOL) useGemsButton {
  return YES;
}

- (BOOL) showFreeLabel {
  return self.numGems <= 0;
}

- (NSString *) iconImageName {
  return @"diamond.png";
}

- (NSString *) iconText {
  return nil;
}

@end
