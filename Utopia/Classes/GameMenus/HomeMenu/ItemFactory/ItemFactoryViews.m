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

- (void) updateForListObject:(BattleItemProto *)bip greyscale:(BOOL)greyscale {
  Globals *gl = [Globals sharedGlobals];
  
  [Globals imageNamed:bip.imgName withView:self.itemIcon greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.bgdIcon.highlighted = greyscale;
  
  self.nameLabel.text = bip.name;
  
  self.costLabel.text = [@" " stringByAppendingString:[Globals commafyNumber:[gl calculateCostToCreateBattleItem:bip]]];
  self.cashIcon.hidden = bip.createResourceType != ResourceTypeCash;
  self.oilIcon.hidden = bip.createResourceType != ResourceTypeOil;
  
  [Globals adjustViewForCentering:self.costLabel.superview withLabel:self.costLabel];
  
  [Globals imageNamed:@"infoi.png" withView:self.infoButton greyscale:greyscale indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  self.statusLabel.hidden = !greyscale;
  self.cashIcon.superview.hidden = greyscale;
}

@end
