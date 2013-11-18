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

#define NUM_ENTRIES_PER_ROW 3

@implementation CarpenterListing

- (void) awakeFromNib {
  self.grayscaleView = [[UIImageView alloc] initWithFrame:self.mainView.frame];
  [self insertSubview:self.grayscaleView atIndex:0];
}

- (void) createMask {
  UIView *view = self.mainView;
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.f);
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  self.grayscaleView.image = [Globals greyScaleImageWithBaseImage:image];
}

- (void) setFsp:(FullStructureProto *)f {
  _fsp = f;
  
  if (!_fsp) {
    self.hidden = YES;
    _canClick = NO;
    return;
  } else {
    self.hidden = NO;
  }
  
  self.nameLabel.text = _fsp.name;
  _structId = _fsp.structId;
  
  GameState *gs = [GameState sharedGameState];
  self.rateLabel.text = [NSString stringWithFormat:@"%@ in %@", [Globals cashStringForNumber:_fsp.income], [Globals convertTimeToShortString:_fsp.minutesToGain*60]];
  
  if (!_fsp.isPremiumCurrency) {
    // Highlighted image is the gold icon.
    self.moneyIcon.highlighted = NO;
    self.costLabel.text = [Globals cashStringForNumber:_fsp.buildPrice];
  } else {
    self.moneyIcon.highlighted = YES;
    self.costLabel.text = [Globals commafyNumber:_fsp.buildPrice];
  }
  
  if (gs.level >= _fsp.minLevel) {
    [Globals loadImageForStruct:_fsp.structId toView:self.buildingImageView masked:NO indicator:UIActivityIndicatorViewStyleGray];
    self.button.userInteractionEnabled = YES;
    self.mainView.hidden = NO;
    self.grayscaleView.hidden = YES;
  } else {
    [Globals loadImageForStruct:_fsp.structId toView:self.buildingImageView masked:YES indicator:UIActivityIndicatorViewStyleGray];
    self.button.userInteractionEnabled = NO;
    
    // Unhide main view before creating mask
    self.mainView.hidden = NO;
    [self createMask];
    self.mainView.hidden = YES;
    self.grayscaleView.hidden = NO;
  }
}

@end

@implementation CarpenterListingContainer

- (void) awakeFromNib {
  [super awakeFromNib];
  [[NSBundle mainBundle] loadNibNamed:@"CarpenterListing" owner:self options:nil];
  [self addSubview:self.carpenterListing];
  [self setBackgroundColor:[UIColor clearColor]];
}

@end


@implementation CarpenterListingCell

@end

@implementation CarpenterViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.structsList = [NSMutableArray array];
  self.title = @"Buildings";
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  //add rope to the very top
  UIColor *c = [UIColor colorWithPatternImage:[Globals imageNamed:@"rope.png"]];
  UIView *leftRope = [[UIView alloc] initWithFrame:CGRectMake(14, -143, 3, 150)];
  UIView *rightRope = [[UIView alloc] initWithFrame:CGRectMake(463, -143, 2, 150)];
  leftRope.backgroundColor = c;
  rightRope.backgroundColor = c;
  [self.carpTable addSubview:leftRope];
  [self.carpTable addSubview:rightRope];
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
  Globals *gl = [Globals sharedGlobals];
  
  [self.structsList removeAllObjects];
  
  NSArray *structs = [[gs staticStructs] allValues];
  
  int max = [gl maxRepeatedNormStructs];
  
  for (FullStructureProto *fsp in structs) {
    if (fsp.predecessorStructId) {
      continue;
    }
    
    int count = 0;
    for (FullUserStructureProto *fusp in [gs myStructs]) {
      if (fusp.structId == fsp.structId) {
        count++;
      }
      if (count >= max) {
        break;
      }
    }
    if (count < max) {
      [self.structsList addObject:fsp];
    }
  }
  
  [self.structsList sortUsingComparator:^NSComparisonResult(FullStructureProto *obj1, FullStructureProto *obj2) {
    if (obj1.minLevel < obj2.minLevel) {
      return NSOrderedAscending;
    } else if (obj1.minLevel > obj2.minLevel) {
      return NSOrderedDescending;
    } else {
      if (obj1.structId < obj2.structId) {
        return NSOrderedAscending;
      }
      return NSOrderedDescending;
    }
  }];
  
  [self.carpTable reloadData];
}

#pragma mark - UITableView delegate methods

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray *list = self.structsList;
  
  int rows = (int)ceilf((float)list.count/NUM_ENTRIES_PER_ROW);
  
  if (rows > 0) {
    tableView.scrollEnabled = YES;
    [self.spinner stopAnimating];
    self.spinner.hidden = YES;
  } else {
    tableView.scrollEnabled = NO;
    [self.spinner startAnimating];
    self.spinner.hidden = NO;
  }
  return rows;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"CarpenterListingCell";
  
  CarpenterListingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"CarpenterRow" owner:self options:nil];
    cell = self.carpRow;
    
    [cell.listing1.carpenterListing.button addTarget:self action:@selector(buildingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.listing2.carpenterListing.button addTarget:self action:@selector(buildingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.listing3.carpenterListing.button addTarget:self action:@selector(buildingClicked:) forControlEvents:UIControlEventTouchUpInside];
  }
  
  int baseIndex = NUM_ENTRIES_PER_ROW*indexPath.row;
  int count = self.structsList.count;
  
  FullStructureProto *fsp1 = baseIndex<count ? [self.structsList objectAtIndex:baseIndex] : nil;
  FullStructureProto *fsp2 = baseIndex+1<count ? [self.structsList objectAtIndex:baseIndex+1] : nil;
  FullStructureProto *fsp3 = baseIndex+2<count ? [self.structsList objectAtIndex:baseIndex+2] : nil;
  
  cell.listing1.carpenterListing.fsp = fsp1;
  cell.listing2.carpenterListing.fsp = fsp2;
  cell.listing3.carpenterListing.fsp = fsp3;
  
  // Hide the bottom ropes if this is the last cell
  UIView *r1 = [cell.contentView viewWithTag:133];
  UIView *r2 = [cell.contentView viewWithTag:134];
  if (indexPath.row == [self tableView:self.carpTable numberOfRowsInSection:0]-1) {
    r1.hidden = YES;
    r2.hidden = YES;
  } else {
    r1.hidden = NO;
    r2.hidden = NO;
  }
  
  return cell;
}

- (IBAction) goToGoldShop:(id)sender {
  [self.navigationController pushViewController:[[DiamondShopViewController alloc] init] animated:YES];
}

- (IBAction)buildingClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[CarpenterListing class]]) {
    sender = [sender superview];
  }
  GameState *gs = [GameState sharedGameState];
  CarpenterListing *carp = (CarpenterListing *)sender;
  FullStructureProto *fsp = carp.fsp;
  
  if (gs.level < fsp.minLevel) {
    [Globals popupMessage:[NSString stringWithFormat:@"You must be level %d to purchase the %@", fsp.minLevel, fsp.name]];
  } else {
    UINavigationController *nav = (UINavigationController *)self.navigationController.presentingViewController;
    UIViewController *vc = [nav.childViewControllers objectAtIndex:0];
    if ([vc isKindOfClass:[GameViewController class]]) {
      GameViewController *gvc = (GameViewController *)vc;
      [gvc buildingPurchased:fsp.structId];
    }
  }
}

@end
