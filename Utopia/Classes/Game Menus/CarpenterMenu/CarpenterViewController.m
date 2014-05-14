//
//  CarpenterViewController.m
//  Utopia
//
//  Created by Danny on 9/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "CarpenterViewController.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "Protocols.pb.h"
#import "DiamondShopViewController.h"
#import "GameViewController.h"

#define TABLE_CELL_WIDTH 142

@implementation CarpenterListing

- (void) setViewToGreyScale:(UIView *)view {
  for (UIView *v in view.subviews) {
    if ([v isKindOfClass:[UIImageView class]]) {
      UIImageView *imgView = (UIImageView *)v;
      if (imgView.image) {
        imgView.image = [Globals greyScaleImageWithBaseImage:imgView.image];
      }
    } else if ([v isKindOfClass:[UIButton class]]) {
      UIButton *button = (UIButton *)v;
      UIImage *img = [button imageForState:UIControlStateNormal];
      if (img) {
        [button setImage:[Globals greyScaleImageWithBaseImage:img] forState:UIControlStateNormal];
      }
    }
    
    [self setViewToGreyScale:v];
  }
}

- (void) flip {
  UIView *startView = self.isFlipped ? self.descriptionView : self.mainView;
  UIView *endView = self.isFlipped ? self.mainView : self.descriptionView;
  [UIView transitionFromView:startView toView:endView duration:0.3f options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
  
  self.isFlipped = !self.isFlipped;
}

- (void) updateForStructInfo:(StructureInfoProto *)structInfo townHall:(UserStruct *)townHall structs:(NSArray *)structs {
  Globals *gl = [Globals sharedGlobals];
  TownHallProto *thp = townHall.isComplete ? (TownHallProto *)townHall.staticStruct : (TownHallProto *)townHall.staticStructForPrevLevel;
  int thLevel = thp.structInfo.level;
  
  [self.descriptionView removeFromSuperview];
  [self addSubview:self.mainView];
  self.isFlipped = NO;
  
  self.structInfo = structInfo;
  
  self.nameLabel.text = structInfo.name;
  self.nameDescriptionLabel.text = structInfo.name;
  
  self.descriptionLabel.text = structInfo.description;
  
  CGRect r = self.descriptionLabel.frame;
  r.size.height = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(self.descriptionLabel.frame.size.width, 9999) lineBreakMode:NSLineBreakByWordWrapping].height;
  self.descriptionLabel.frame = r;
  
  self.buildCashCostLabel.text = [Globals cashStringForNumber:structInfo.buildCost];
  self.buildOilCostLabel.text = [Globals commafyNumber:structInfo.buildCost];
  [Globals adjustViewForCentering:self.buildOilCostLabel.superview withLabel:self.buildOilCostLabel];
  self.buildCashCostLabel.hidden = structInfo.buildResourceType != ResourceTypeCash;
  self.buildOilCostLabel.superview.hidden = structInfo.buildResourceType != ResourceTypeOil;
  
  self.buildTimeLabel.text = [Globals convertTimeToShortString:structInfo.minutesToBuild*60];
  
  int cur = [gl calculateCurrentQuantityOfStructId:structInfo.structId structs:structs];
  int max = [gl calculateMaxQuantityOfStructId:structInfo.structId withTownHall:thp];
  self.quantityLabel.text = [NSString stringWithFormat:@"%d/%d", cur, max];
  
  // We will manually grey the struct in case it is not downloaded yet
  self.buildingImageView.image = nil;
  
  if (structInfo.prerequisiteTownHallLvl > thLevel) {
    self.unavailableLabel.text = [NSString stringWithFormat:@"Level %d %@ Required", structInfo.prerequisiteTownHallLvl, thp.structInfo.name];
    
    self.unavailableLabel.hidden = NO;
    self.availableView.hidden = YES;
  } else {
    self.availableView.hidden = NO;
    self.unavailableLabel.hidden = YES;
  }
  
  BOOL greyscale = structInfo.prerequisiteTownHallLvl > thLevel || cur >= max;
  [Globals imageNamed:structInfo.imgName    withView:self.buildingImageView greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:@"buildingbg.png"     withView:self.bgdImageView      greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:@"buildinginfobg.png" withView:self.bgdInfoImageView  greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:@"clock.png"          withView:self.clockIcon         greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:@"oilicon.png"        withView:self.oilIcon           greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:@"chatinfoi.png"      withView:self.infoButton        greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

@end

@implementation CarpenterViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.incomeStructsList = [NSMutableArray array];
  self.mobsterStructsList = [NSMutableArray array];
  self.title = @"Buildings";
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  [self setupStructTable];
}

- (void)viewWillAppear:(BOOL)animated {
  [self updateLabels];
  [self reloadCarpenterStructs];
}

- (void)updateLabels {
  GameState *gs = [GameState sharedGameState];
  self.diamondLabel.text = [NSString stringWithFormat:@"%@",[Globals commafyNumber:gs.gold]];
  self.cashLabel.text = [NSString stringWithFormat:@"$%@",[Globals commafyNumber:gs.silver]];
}

- (void) reloadCarpenterStructs {
  GameState *gs = [GameState sharedGameState];
  [self.incomeStructsList removeAllObjects];
  [self.mobsterStructsList removeAllObjects];
  
  NSArray *structs = [[gs staticStructs] allValues];
  
  for (id<StaticStructure> s in structs) {
    StructureInfoProto *fsp = s.structInfo;
    if (fsp.predecessorStructId || fsp.structType == StructureInfoProto_StructTypeTownHall) {
      continue;
    }
    
    if (fsp.structType == StructureInfoProto_StructTypeResourceGenerator ||
        fsp.structType == StructureInfoProto_StructTypeResourceStorage) {
      [self.incomeStructsList addObject:fsp];
    } else if (fsp.structType != StructureInfoProto_StructTypeMiniJob) {
      [self.mobsterStructsList addObject:fsp];
    }
  }
  
  NSComparator comp = ^NSComparisonResult(StructureInfoProto *obj1, StructureInfoProto *obj2) {
    if (obj1.prerequisiteTownHallLvl != obj2.prerequisiteTownHallLvl) {
      return [@(obj1.prerequisiteTownHallLvl) compare:@(obj2.prerequisiteTownHallLvl)];
    } else {
      return [@(obj1.structId) compare:@(obj2.structId)];
    }
  };
  
  [self.incomeStructsList sortUsingComparator:comp];
  [self.mobsterStructsList sortUsingComparator:comp];
  
  [self.structTable reloadData];
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
  UINavigationController *nav = (UINavigationController *)self.navigationController.presentingViewController;
  UIViewController *vc = [nav.childViewControllers objectAtIndex:0];
  if ([vc isKindOfClass:[GameViewController class]]) {
    GameViewController *gvc = (GameViewController *)vc;
    [gvc buildingPurchased:structId];
  }
}

#pragma mark - EasyTableView delegate methods

- (void) setupStructTable {
  self.structTable = [[EasyTableView alloc] initWithFrame:self.tableContainerView.bounds numberOfColumns:0 ofWidth:TABLE_CELL_WIDTH];
  self.structTable.delegate = self;
  self.structTable.tableView.separatorColor = [UIColor clearColor];
  self.structTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.tableContainerView addSubview:self.structTable];
}

- (NSUInteger) numberOfSectionsInEasyTableView:(EasyTableView *)easyTableView {
  return 2;
}

- (NSUInteger) numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section {
  return section == 0 ? self.incomeStructsList.count : self.mobsterStructsList.count;
}

- (UIView *) easyTableView:(EasyTableView *)easyTableView viewForHeaderInSection:(NSInteger)section {
  return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, easyTableView.frame.size.height)];
}

- (UIView *) easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect withIndexPath:(NSIndexPath *)indexPath {
  [[NSBundle mainBundle] loadNibNamed:@"CarpenterListing" owner:self options:nil];
  self.carpListing.center = ccp(CGRectGetMidX(rect), CGRectGetMidY(rect));
  return self.carpListing;
}

- (void) easyTableView:(EasyTableView *)easyTableView setDataForView:(CarpenterListing *)view forIndexPath:(NSIndexPath *)indexPath {
  NSArray *arr = indexPath.section == 0 ? self.incomeStructsList : self.mobsterStructsList;
  [view updateForStructInfo:arr[indexPath.row] townHall:[self townHall] structs:[self curStructsList]];
}

- (NSString *) easyTableView:(EasyTableView *)easyTableView stringForHorizontalHeaderInDesction:(NSInteger)section {
  if (section == 0) {
    return @"Income Buildings";
  } else {
    return @"Mobster Buildings";
  }
}

#pragma mark Carpenter Listing IBActions

- (IBAction)buildingClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[CarpenterListing class]]) {
    sender = [sender superview];
  }
  
  Globals *gl = [Globals sharedGlobals];
  CarpenterListing *carp = (CarpenterListing *)sender;
  StructureInfoProto *fsp = carp.structInfo;
  
  if (carp.isFlipped) {
    [carp flip];
  } else {
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
}

- (IBAction)infoClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[CarpenterListing class]]) {
    sender = [sender superview];
  }
  
  CarpenterListing *carp = (CarpenterListing *)sender;
  [carp flip];
}

@end
