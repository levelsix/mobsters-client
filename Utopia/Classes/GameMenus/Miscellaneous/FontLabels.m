//
//  FontLabels.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/13/16.
//  Copyright © 2016 LVL6. All rights reserved.
//

#import "FontLabels.h"
#import "Globals.h"

@implementation FontLabelMikadoBlack

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"MikadoBlack" size:self.font.pointSize];
}

@end

@implementation FontLabelMikadoBold

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"MikadoBold" size:self.font.pointSize];
}

@end