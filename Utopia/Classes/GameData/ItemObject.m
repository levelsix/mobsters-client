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

- (BOOL) canBeOwned {
  switch (self.staticItem.itemType) {
      
    case ItemTypeItemGachaCredit:
      return NO;
      
    case ItemTypeItemCash:
    case ItemTypeItemOil:
    case ItemTypeSpeedUp:
    case ItemTypeBoosterPack:
    case ItemTypeBuilder:
    case ItemTypeRefreshMiniJob:
    case ItemTypeGachaMultiSpin:
      return YES;
  }
}

- (NSString *) name {
  return self.staticItem.name;
}

- (BOOL) isValid {
  return self.quantity > 0;
}

- (NSString *) buttonText {
  switch (self.staticItem.itemType) {
      
    case ItemTypeRefreshMiniJob:
    case ItemTypeItemGachaCredit:
      if (self.useGemsButton) {
        return [NSString stringWithFormat:@"%d",[self costToPurchase]];
      } else {
        return @"Use";
      }
      
    case ItemTypeItemCash:
    case ItemTypeItemOil:
    case ItemTypeSpeedUp:
    case ItemTypeBoosterPack:
    case ItemTypeBuilder:
    case ItemTypeGachaMultiSpin:
      return @"Use";
  }
}

- (BOOL) useGemsButton {
  switch (self.staticItem.itemType) {
      
    case ItemTypeRefreshMiniJob:
    case ItemTypeItemGachaCredit:
      return !self.isValid;
      
    case ItemTypeItemCash:
    case ItemTypeItemOil:
    case ItemTypeSpeedUp:
    case ItemTypeBoosterPack:
    case ItemTypeBuilder:
    case ItemTypeGachaMultiSpin:
      return NO;
  }
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
  } else if (ip.itemType == ItemTypeItemCash || ip.itemType == ItemTypeItemOil || ip.itemType == ItemTypeItemGachaCredit) {
    return [Globals shortenNumber:ip.amount];
  }
  
  return nil;
}

- (GameActionType)gameActionType {
  return self.staticItem.gameActionType;
}

- (Quality) quality {
  return [self staticItem].quality;
}

- (int) costToPurchase {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  MiniJobCenterProto *miniJobCenter = (MiniJobCenterProto *)gs.myMiniJobCenter.staticStruct;
  
  switch (self.staticItem.itemType) {
      
    case ItemTypeRefreshMiniJob:
      return [miniJobCenter itemGemPriceForItemId:self.staticItem.itemId];
      
    case ItemTypeItemGachaCredit:
      return [gl calculateGemConversionForResourceType:ResourceTypeGachaCredits amount:self.staticItem.amount];
      
    case ItemTypeItemCash:
    case ItemTypeItemOil:
    case ItemTypeSpeedUp:
    case ItemTypeBoosterPack:
    case ItemTypeBuilder:
    case ItemTypeGachaMultiSpin:
      return 0;
  }
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
  if (!self.usageUuid && !object.usageUuid) {
    return NO;
  } else if (!self.usageUuid || !object.usageUuid) {
    // Will come here when response occurs
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

- (BOOL) canBeOwned {
  return YES;
}

- (NSString *) name {
  return @"Gems";
}

- (BOOL) isValid {
  return YES;
}

- (NSString *) buttonText {
  return [Globals commafyNumber:[self.delegate numGems]];
}

- (BOOL) useGemsButton {
  return YES;
}

- (BOOL) showFreeLabel {
  return [self.delegate numGems] <= 0;
}

- (NSString *) iconImageName {
  return @"diamond.png";
}

- (NSString *) iconText {
  return nil;
}

- (GameActionType)gameActionType {
  return GameActionTypeNoHelp;
}

@end

@implementation MiniJobCenterProto (ItemPrices)

- (int) itemGemPriceForItemId:(int)itemId {
  for (ItemGemPriceProto *igpp in self.refreshMiniJobItemPricesList) {
    if (igpp.itemId == itemId) {
      return igpp.gemPrice;
    }
  }
  return 0;
}

@end
