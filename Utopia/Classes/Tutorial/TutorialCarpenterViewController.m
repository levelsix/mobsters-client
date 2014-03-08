//
//  TutorialCarpenterViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialCarpenterViewController.h"

@implementation TutorialCarpenterViewController

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants curStructs:(NSArray *)curStructs {
  if ((self = [super initWithNibName:@"CarpenterViewController" bundle:nil])) {
    self.constants = constants;
    self.curStructs = curStructs;
  }
  return self;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // Find the struct
  int section = -1, row = -1;
  for (StructureInfoProto *fsp in self.incomeStructsList) {
    if (fsp.structId == self.clickableStructId) {
      section = 0;
      row = [self.incomeStructsList indexOfObject:fsp];
    }
  }
  
  if (section != -1) {
    NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:section];
    UIView *v = [self.structTable viewAtIndexPath:ip];
    [Globals createUIArrowForView:v.superview.superview.superview.superview atAngle:-M_PI_2];
    
    [self.structTable.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
  }
}

- (void) allowPurchaseOfStructId:(int)structId {
  self.clickableStructId = structId;
}

#pragma mark - Overwritten methods

- (NSArray *) curStructsList {
  return self.curStructs;
}

- (UserStruct *) townHall {
  for (UserStruct *us in self.curStructs) {
    if (us.staticStruct.structInfo.structType == StructureInfoProto_StructTypeTownHall) {
      return us;
    }
  }
  return nil;
}

- (void) buildingPurchased:(int)structId {
  [self.delegate buildingPurchased:structId];
}

- (IBAction)buildingClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[CarpenterListing class]]) {
    sender = [sender superview];
  }
  
  CarpenterListing *carp = (CarpenterListing *)sender;
  StructureInfoProto *fsp = carp.structInfo;
  
  if (fsp.structId == self.clickableStructId) {
    [super buildingClicked:sender];
  }
}

- (void) popCurrentViewController:(id)sender {
  // Do nothing
}

//- (voi÷

@end
