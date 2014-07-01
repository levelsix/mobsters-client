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
  TownHallProto *thp = townHall.isComplete ? (TownHallProto *)townHall.staticStruct : (TownHallProto *)townHall.staticStructForPrevLevel;
  int thLevel = thp.structInfo.level;
  
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
  int nextThLevel = [gl calculateNextTownHallLevelForQuantityIncreaseForStructId:structInfo.structId];
  self.numOwnedLabel.text = [NSString stringWithFormat:@"Built: %d/%d", cur, max];
  
  BOOL greyscale = NO;
  int reqThLevel = structInfo.prerequisiteTownHallLvl > thLevel ? structInfo.prerequisiteTownHallLvl : cur >= max ? nextThLevel : 0;
  if (reqThLevel) {
    self.lockedLabel.text = [NSString stringWithFormat:@"Requires Level %d %@", reqThLevel, thp.structInfo.name];
    self.lockedLabel.textColor = [UIColor colorWithRed:254/255.f green:2/255.f blue:0.f alpha:1.f];
    greyscale = YES;
  } else if (cur >= max) {
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
