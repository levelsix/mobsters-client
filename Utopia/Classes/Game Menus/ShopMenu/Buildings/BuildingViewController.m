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

- (int) isTypeRecommended:(StructureInfoProto_StructType)structType {
  switch (structType) {
    case StructureInfoProto_StructTypeClan:
      return 3;
    case StructureInfoProto_StructTypeMiniJob:
      return 2;
    case StructureInfoProto_StructTypeEvo:
    case StructureInfoProto_StructTypeLab:
      return 1;
      
    default:
      return 0;
  }
}

- (void) reloadCarpenterStructs {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSArray *structs = [[gs staticStructs] allValues];
  NSMutableArray *validStructs = [NSMutableArray array];
  
  for (id<StaticStructure> s in structs) {
    StructureInfoProto *fsp = s.structInfo;
    if (fsp.predecessorStructId ||
        fsp.structType == StructureInfoProto_StructTypeTownHall ||
        fsp.structType == StructureInfoProto_StructTypeTeamCenter ||
        fsp.structType == StructureInfoProto_StructTypeLab) {
      continue;
    }
    
    [validStructs addObject:fsp];
  }
  
  UserStruct *townHall = gs.myTownHall;
  TownHallProto *thp = (TownHallProto *)townHall.staticStructForCurrentConstructionLevel;
  NSArray *myStructs = gs.myStructs;
  NSComparator comp = ^NSComparisonResult(StructureInfoProto *obj1, StructureInfoProto *obj2) {
    int cur = [gl calculateCurrentQuantityOfStructId:obj1.structId structs:myStructs];
    int max = [gl calculateMaxQuantityOfStructId:obj1.structId withTownHall:thp];
    BOOL avail1 = cur < max && obj1.prerequisiteTownHallLvl <= thp.structInfo.level;
    
    cur = [gl calculateCurrentQuantityOfStructId:obj2.structId structs:myStructs];
    max = [gl calculateMaxQuantityOfStructId:obj2.structId withTownHall:thp];
    BOOL avail2 = cur < max && obj2.prerequisiteTownHallLvl <= thp.structInfo.level;
    
    int isSpecial1 = avail1 ? [self isTypeRecommended:obj1.structType] : 0;
    int isSpecial2 = avail2 ? [self isTypeRecommended:obj2.structType] : 0;
    
    if (avail1 != avail2) {
      return [@(avail2) compare:@(avail1)];
    } else if (isSpecial1 != isSpecial2) {
      return [@(isSpecial2) compare:@(isSpecial1)];
    } else {
      if (obj1.prerequisiteTownHallLvl != obj2.prerequisiteTownHallLvl) {
        return [@(obj1.prerequisiteTownHallLvl) compare:@(obj2.prerequisiteTownHallLvl)];
      } else {
        return [@(obj1.structId) compare:@(obj2.structId)];
      }
    }
  };
  
  [validStructs sortUsingComparator:comp];
  self.staticStructs = validStructs;
  
  StructureInfoProto *potRec = [self.staticStructs firstObject];
  if ([self isTypeRecommended:potRec.structType]) {
    _recommendedStructId = potRec.structId;
  }
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

- (void) listView:(ListCollectionView *)listView updateCell:(BuildingCardCell *)cell forIndexPath:(NSIndexPath *)indexPath listObject:(StructureInfoProto *)listObject {
  [cell updateForStructInfo:listObject townHall:[self townHall] structs:[self curStructsList]];
  cell.recommendedTag.hidden = listObject.structId != _recommendedStructId;
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  Globals *gl = [Globals sharedGlobals];
  StructureInfoProto *fsp = self.staticStructs[indexPath.row];
  
  UserStruct *townHall = [self townHall];
  TownHallProto *thp = (TownHallProto *)townHall.staticStructForCurrentConstructionLevel;
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
