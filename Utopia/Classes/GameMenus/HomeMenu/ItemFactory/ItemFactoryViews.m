//
//  ItemFactoryViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ItemFactoryViews.h"

#import "Globals.h"
#import "Protocols.pb.h"

@implementation ItemFactoryCardCell

- (void) updateForListObject:(BattleItemProto *)bip {
  [Globals imageNamed:bip.imgName withView:self.itemIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.nameLabel.text = bip.name;
  
  self.costLabel.text = [@" " stringByAppendingString:[Globals commafyNumber:bip.createCost]];
  self.cashIcon.hidden = bip.createResourceType != ResourceTypeCash;
  self.oilIcon.hidden = bip.createResourceType != ResourceTypeOil;
  
  [Globals adjustViewForCentering:self.costLabel.superview withLabel:self.costLabel];
}

@end
