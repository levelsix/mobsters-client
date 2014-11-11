//
//  BuildingViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "BuildingViews.h"

#import "Globals.h"

@implementation BuildingCardCell

- (void) updateForStructInfo:(StructureInfoProto *)structInfo townHall:(UserStruct *)townHall structs:(NSArray *)structs {
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineSpacing:1.8];
  [paragraphStyle setAlignment:NSTextAlignmentCenter];
  
  Globals *gl = [Globals sharedGlobals];
  TownHallProto *thp = (TownHallProto *)townHall.staticStructForCurrentConstructionLevel;
  
  self.nameLabel.text = structInfo.name;
  
  NSShadow *shadow = [[NSShadow alloc] init];
  shadow.shadowColor = self.descriptionLabel.shadowColor;
  shadow.shadowBlurRadius = 0.9;
  shadow.shadowOffset = CGSizeMake(0.0, 1.0);
  self.descriptionLabel.attributedText = [[NSAttributedString alloc] initWithString:structInfo.description attributes:@{NSShadowAttributeName:shadow, NSParagraphStyleAttributeName:paragraphStyle}];
  
  self.costLabel.text = [Globals commafyNumber:structInfo.buildCost];
  [Globals adjustViewForCentering:self.costLabel.superview withLabel:self.costLabel];
  self.cashIcon.hidden = structInfo.buildResourceType != ResourceTypeCash;
  self.oilIcon.hidden = structInfo.buildResourceType != ResourceTypeOil;
  
  self.timeLabel.text = [Globals convertTimeToShortString:structInfo.minutesToBuild*60];
  
  int cur = [gl calculateCurrentQuantityOfStructId:structInfo.structId structs:structs];
  int max = [gl calculateMaxQuantityOfStructId:structInfo.structId withTownHall:thp];
  TownHallProto *nextThp = [gl calculateNextTownHallForQuantityIncreaseForStructId:structInfo.structId];
  self.numOwnedLabel.text = [NSString stringWithFormat:@"Built: %d/%d", cur, max];
  
  BOOL greyscale = NO;
  NSMutableArray *incomplete = [[gl incompletePrereqsForStructId:structInfo.structId] mutableCopy];
  
  // Create a new prereq for th level
  if (cur >= max && nextThp) {
    PrereqProto_Builder *pre = [PrereqProto builder];
    pre.quantity = 1;
    pre.prereqGameType = GameTypeStructure;
    pre.prereqGameEntityId = nextThp.structInfo.structId;
    [incomplete addObject:pre.build];
  }
  
  if (incomplete.count) {
    self.lockedLabel.text = [NSString stringWithFormat:@"Requires %@", [[incomplete firstObject] prereqString]];
    self.lockedLabel.textColor = [UIColor colorWithRed:254/255.f green:2/255.f blue:0.f alpha:1.f];
    greyscale = YES;
  }
  // This means that nextThLevel was not found, meaning that the max number of this structure has already been built
  else if (cur >= max) {
    self.lockedLabel.text = @"Max Number Built";
    self.lockedLabel.textColor = [UIColor colorWithWhite:90/255.f alpha:1.f];
    greyscale = YES;
  }
  
  // Reassign the text with blurred shadow
  shadow = [[NSShadow alloc] init];
  shadow.shadowColor = self.lockedLabel.shadowColor;
  shadow.shadowBlurRadius = 0.9;
  shadow.shadowOffset = CGSizeMake(0.0, 1.0);
  self.lockedLabel.attributedText = [[NSAttributedString alloc] initWithString:self.lockedLabel.text attributes:@{NSShadowAttributeName:shadow, NSParagraphStyleAttributeName:paragraphStyle}];
  
  NSString *fileName = [NSString stringWithFormat:@"Menu%@", structInfo.imgName];
  [Globals imageNamed:fileName withView:self.buildingIcon greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.lockedView.hidden = !greyscale;
  self.unlockedView.hidden = greyscale;
}

@end
