//
//  BuildingViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "BuildingViewController.h"

#import "GameState.h"
#import "Globals.h"

@implementation BuildingViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.listView.cellClassName = @"BuildingCardCell";
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self reloadListView];
  
  self.listView.collectionView.contentOffset = ccp(0,0);
  
  [Globals removeUIArrowFromViewRecursively:self.view];
}

- (void) displayArrowOverStructId:(int)structId {
  // Find the struct
  NSInteger section = 0, row = -1;
  for (StructureInfoProto *fsp in self.staticStructs) {
    if (fsp.structId == structId) {
      row = [self.staticStructs indexOfObject:fsp];
    }
  }
  
  if (row != -1) {
    NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:section];
    [self.listView.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [self.listView.collectionView layoutIfNeeded];
    
    UIView *v = [self.listView.collectionView cellForItemAtIndexPath:ip];
    [Globals createUIArrowForView:v atAngle:0];
  }
}

#pragma mark - Refreshing list view

- (void) reloadListView {
  [self reloadCarpenterStructs];
  [self.listView reloadTableAnimated:NO listObjects:self.staticStructs];
}

- (void) reloadCarpenterStructs {
  GameState *gs = [GameState sharedGameState];
  NSArray *structs = [[gs staticStructs] allValues];
  NSMutableArray *validStructs = [NSMutableArray array];
  
  for (id<StaticStructure> s in structs) {
    StructureInfoProto *fsp = s.structInfo;
    if (fsp.predecessorStructId ||
        fsp.structType == StructureInfoProto_StructTypeTownHall ||
        fsp.structType == StructureInfoProto_StructTypeMiniJob ||
        fsp.structType == StructureInfoProto_StructTypeTeamCenter) {
      continue;
    }
    
    [validStructs addObject:fsp];
  }
  
  NSComparator comp = ^NSComparisonResult(StructureInfoProto *obj1, StructureInfoProto *obj2) {
    if (obj1.prerequisiteTownHallLvl != obj2.prerequisiteTownHallLvl) {
      return [@(obj1.prerequisiteTownHallLvl) compare:@(obj2.prerequisiteTownHallLvl)];
    } else {
      return [@(obj1.structId) compare:@(obj2.structId)];
    }
  };
  
  [validStructs sortUsingComparator:comp];
  self.staticStructs = validStructs;
}

#pragma mark - Overridable methods

- (NSArray *) curStructsList {
  GameState *gs = [GameState sharedGameState];
  return gs.myStructs;
}

- (UserStruct *) townHall {
  GameState *gs = [GameState sharedGameState];
  return [gs myTownHall];
}

- (int) townHallLevel {
  return [[[[self townHall] staticStruct] structInfo] level];
}

- (void) buildingPurchased:(int)structId {
  [self.delegate buildingPurchased:structId];
  [self.parentViewController close];
}

#pragma mark - List view delegate

- (void) listView:(ListCollectionView *)listView updateCell:(BuildingCardCell *)cell forIndexPath:(NSIndexPath *)indexPath listObject:(id)listObject {
  [cell updateForStructInfo:listObject townHall:[self townHall] structs:[self curStructsList]];
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  Globals *gl = [Globals sharedGlobals];
  StructureInfoProto *fsp = self.staticStructs[indexPath.row];
  
  UserStruct *townHall = [self townHall];
  TownHallProto *thp = townHall.isComplete ? (TownHallProto *)townHall.staticStruct : (TownHallProto *)townHall.staticStructForPrevLevel;
  int thLevel = thp.structInfo.level;
  int cur = [gl calculateCurrentQuantityOfStructId:fsp.structId structs:[self curStructsList]];
  int max = [gl calculateMaxQuantityOfStructId:fsp.structId withTownHall:thp];
  
  if (fsp.prerequisiteTownHallLvl > thLevel) {
    [Globals addAlertNotification:[NSString stringWithFormat:@"Upgrade %@ to level %d to unlock!", thp.structInfo.name, fsp.prerequisiteTownHallLvl]];
  } else if (cur >= max) {
    int nextThLevel = [gl calculateNextTownHallLevelForQuantityIncreaseForStructId:fsp.structId];
    if (nextThLevel) {
      [Globals addAlertNotification:[NSString stringWithFormat:@"Upgrade %@ to level %d to build more!", thp.structInfo.name, nextThLevel]];
    } else {
      [Globals addAlertNotification:@"You have already reached the max number of this building."];
    }
  } else {
    [self buildingPurchased:fsp.structId];
  }
}

@end
