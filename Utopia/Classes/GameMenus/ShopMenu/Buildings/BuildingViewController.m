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

#define TREE_WIDTH 259
#define TREE_HEIGHT 180

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
  // Nab the root struct
  GameState *gs = [GameState sharedGameState];
  id<StaticStructure> ss = [gs structWithId:structId];
  while (ss.structInfo.predecessorStructId) {
    ss = [gs structWithId:ss.structInfo.predecessorStructId];
  }
  structId = ss.structInfo.structId;
  
  // Find the struct
  NSInteger section = 0, row = -1;
  for (id<StaticStructure> ss in self.staticStructs) {
    StructureInfoProto *fsp = [ss structInfo];
    if (fsp.structId == structId) {
      row = [self.staticStructs indexOfObject:ss];
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

- (void) updateLabels {
  for (id<StaticStructure> ss in self.staticStructs) {
    if ([ss structInfo].structType == StructureInfoProto_StructTypeMoneyTree) {
      // update cell for time
      NSInteger idx = [self.staticStructs indexOfObject:ss];
      BuildingCardCell *cell = (BuildingCardCell *)[self.listView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
      
      if (cell) {
        GameState *gs = [GameState sharedGameState];
        [cell updateTime:gs.timeLeftOnMoneyTree];
      }
    }
  }
}

#pragma mark - Refreshing list view

- (void) reloadListView {
  [self reloadCarpenterStructs];
  [self.listView reloadTableAnimated:NO listObjects:self.staticStructs];
}

- (int) isTypeRecommended:(StructureInfoProto_StructType)structType {
  switch (structType) {
    case StructureInfoProto_StructTypeMoneyTree:
      return 4;
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
  NSArray *myStructs = gs.myStructs;
  
  for (id<StaticStructure> s in structs) {
    StructureInfoProto *fsp = s.structInfo;
    if (fsp.predecessorStructId ||
        fsp.structType == StructureInfoProto_StructTypeTownHall ||
        fsp.structType == StructureInfoProto_StructTypeTeamCenter ||
        fsp.structType  == StructureInfoProto_StructTypeLab) {
      continue;
    }
    
    // Don't show money tree if it's already been built
    if (fsp.structType == StructureInfoProto_StructTypeMoneyTree) {
      if ([gl calculateCurrentQuantityOfStructId:fsp.structId structs:myStructs] > 0) {
        continue;
      }
    }
    
    [validStructs addObject:s];
  }
  
  UserStruct *townHall = gs.myTownHall;
  TownHallProto *thp = (TownHallProto *)townHall.staticStructForCurrentConstructionLevel;
  NSComparator comp = ^NSComparisonResult(id<StaticStructure> ss1, id<StaticStructure> ss2) {
    StructureInfoProto *obj1 = [ss1 structInfo], *obj2 = [ss2 structInfo];
    int cur = [gl calculateCurrentQuantityOfStructId:obj1.structId structs:myStructs];
    int max = [gl calculateMaxQuantityOfStructId:obj1.structId withTownHall:thp];
    BOOL avail1 = cur < max && [gl satisfiesPrereqsForStructId:obj1.structId];
    
    cur = [gl calculateCurrentQuantityOfStructId:obj2.structId structs:myStructs];
    max = [gl calculateMaxQuantityOfStructId:obj2.structId withTownHall:thp];
    BOOL avail2 = cur < max && [gl satisfiesPrereqsForStructId:obj2.structId];
    
    int isSpecial1 = avail1 ? [self isTypeRecommended:obj1.structType] : 0;
    int isSpecial2 = avail2 ? [self isTypeRecommended:obj2.structType] : 0;
    
    if (avail1 != avail2) {
      return [@(avail2) compare:@(avail1)];
    } else if (isSpecial1 != isSpecial2) {
      return [@(isSpecial2) compare:@(isSpecial1)];
    } else {
        return [@(obj1.structId) compare:@(obj2.structId)];
    }
  };
  
  [validStructs sortUsingComparator:comp];
  self.staticStructs = validStructs;
  
  for (id<StaticStructure> ss in self.staticStructs) {
    StructureInfoProto *potRec = [ss structInfo];
    if (potRec.structType == StructureInfoProto_StructTypeMoneyTree) {
      continue;
    }
    
    if ([self isTypeRecommended:potRec.structType]) {
      _recommendedStructId = potRec.structId;
    }
    break;
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
  if (![self.delegate buildingPurchased:structId]) {
    [self.parentViewController close];
  }
}

#pragma mark - List view delegate

- (CGSize) specialCellSizeWithIndex:(NSInteger)index {
  StructureInfoProto *sip = [self.staticStructs[index] structInfo];
  if(sip.structType == StructureInfoProto_StructTypeMoneyTree){
    return CGSizeMake(TREE_WIDTH, TREE_HEIGHT);
  }
  return CGSizeMake(0, 0);
}

- (void) listView:(ListCollectionView *)listView updateCell:(BuildingCardCell *)cell forIndexPath:(NSIndexPath *)indexPath listObject:(id<StaticStructure>)lo {
  StructureInfoProto *listObject = [lo structInfo];
  
  if (listObject.structType != StructureInfoProto_StructTypeMoneyTree) {
    [cell updateForStructInfo:listObject townHall:[self townHall] structs:[self curStructsList]];
    cell.recommendedTag.hidden = listObject.structId != _recommendedStructId;
  } else {
    [cell updateForMoneyTree:(MoneyTreeProto *)lo];
    
    GameState *gs = [GameState sharedGameState];
    [cell updateTime:gs.timeLeftOnMoneyTree];
  }
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  Globals *gl = [Globals sharedGlobals];
  StructureInfoProto *fsp = [self.staticStructs[indexPath.row] structInfo];
  
  UserStruct *townHall = [self townHall];
  TownHallProto *thp = (TownHallProto *)townHall.staticStructForCurrentConstructionLevel;
  int cur = [gl calculateCurrentQuantityOfStructId:fsp.structId structs:[self curStructsList]];
  int max = [gl calculateMaxQuantityOfStructId:fsp.structId withTownHall:thp];
  
  NSArray *incomplete = [gl incompletePrereqsForStructId:fsp.structId];
  if (incomplete.count) {
    [Globals addAlertNotification:[NSString stringWithFormat:@"Requires %@ to unlock!", [[incomplete firstObject] prereqString]]];
  } else if (cur >= max) {
    TownHallProto *nextThp = [gl calculateNextTownHallForQuantityIncreaseForStructId:fsp.structId];
    if (nextThp) {
      [Globals addAlertNotification:[NSString stringWithFormat:@"Upgrade %@ to level %d to build more!", thp.structInfo.name, nextThp.structInfo.level]];
    } else {
      [Globals addAlertNotification:@"You have already reached the max number of this building."];
    }
  } else {
    [self buildingPurchased:fsp.structId];
  }
}

@end
