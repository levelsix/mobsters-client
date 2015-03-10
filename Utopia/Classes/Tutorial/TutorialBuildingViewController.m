//
//  TutorialBuildingViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 7/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialBuildingViewController.h"

#import "GameState.h"
#import "Globals.h"

@implementation TutorialBuildingViewController

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants curStructs:(NSArray *)curStructs {
  if ((self = [super initWithNibName:@"BuildingViewController" bundle:nil])) {
    self.constants = constants;
    self.curStructs = curStructs;
  }
  return self;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // Find the struct
  NSInteger section = 0, row = -1;
  for (id<StaticStructure> ss in self.staticStructs) {
    StructureInfoProto *fsp = [ss structInfo];
    if (fsp.structId == self.clickableStructId) {
      row = [self.staticStructs indexOfObject:ss];
    }
  }
  
  if (row != -1) {
    NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:section];
    [self.listView.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    UIView *v = [self.listView.collectionView cellForItemAtIndexPath:ip];
    [Globals createUIArrowForView:v atAngle:0];
  }
}

- (void) reloadCarpenterStructs {
  // Remove the money tree
  [super reloadCarpenterStructs];
  
  NSMutableArray *structs = [self.staticStructs mutableCopy];
  for (id<StaticStructure> ss in self.staticStructs) {
    StructureInfoProto *fsp = [ss structInfo];
    if (fsp.structType == StructureInfoProto_StructTypeMoneyTree) {
      [structs removeObject:ss];
    }
  }
  
  self.staticStructs = structs;
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

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  id<StaticStructure> ss = self.staticStructs[indexPath.row];
  StructureInfoProto *fsp = [ss structInfo];
  
  if (fsp.structId == self.clickableStructId) {
    [super listView:listView cardClickedAtIndexPath:indexPath];
  }
}

- (BOOL) canClose {
  return NO;
}

@end
