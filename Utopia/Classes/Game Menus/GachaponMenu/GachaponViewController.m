//
//  GachaponViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/31/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "GachaponViewController.h"
#import "cocos2d.h"
#import "Globals.h"
#import "MenuNavigationController.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "IAPHelper.h"
#import "GenericPopupController.h"
#import "UIImage+ImageEffects.h"
#import "GPUImage.h"
#import "HomeViewController.h"
#import "GameViewController.h"

@implementation GachaponViewController

#define NUM_COLS INT_MAX/700000
#define TABLE_CELL_WIDTH 57

- (id) initWithBoosterPack:(BoosterPackProto *)bpp {
  if ((self = [super init])) {
    self.boosterPack = bpp;
  }
  return self;
}

- (void) setupItems {
  NSMutableArray *arr = [NSMutableArray array];
  for (int i = 0; i < 20; i++) {
    NSMutableArray *sub = [NSMutableArray array];
    for (BoosterDisplayItemProto *item in self.boosterPack.displayItemsList) {
      // Add it as many times as quantity
      // Multiply quantity to increase variability
      for (int j = 0; j < item.quantity; j++) {
        [sub addObject:item];
      }
    }
    [sub shuffle];
    [arr addObjectsFromArray:sub];
  }
  self.items = arr;
  
  self.gachaTable.tableView.repeatSize = CGSizeMake(0, TABLE_CELL_WIDTH*self.items.count);
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _cachedFreeGachas = [[Globals sharedGlobals] calculateFreeGachasCount];
  
  [self setUpCloseButton];
  
  [self setupGachaTable];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self.topBar];
  
  [self.navBar button:3 shouldBeHidden:YES];
  
  [self loadBoosterPacks];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self setUpImageBackButton];
  
  if (self.boosterPack.boosterPackId == self.badBoosterPack.boosterPackId) {
    [self button1Clicked:nil];
  } else {
    [self button2Clicked:nil];
  }
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  self.focusScrollView.delegate = nil;
}

- (void) loadBoosterPacks {
  GameState *gs = [GameState sharedGameState];
  self.badBoosterPack = gs.boosterPacks[0];
  self.goodBoosterPack = gs.boosterPacks[1];
  
  self.navBar.label1.text = [self.badBoosterPack.boosterPackName uppercaseString];
  self.navBar.label2.text = [self.goodBoosterPack.boosterPackName uppercaseString];
}

- (void) updateForBoosterPack:(BoosterPackProto *)bpp {
  self.boosterPack = bpp;
  [self setupItems];
  [self.gachaTable reloadData];
  [self.focusScrollView reloadData];
  
  self.title = self.boosterPack.boosterPackName;
  
  self.gemCostLabel.text = [Globals commafyNumber:self.boosterPack.gemPrice];
  self.prizeView.gemCostLabel.text = [Globals commafyNumber:self.boosterPack.gemPrice];
  [Globals adjustViewForCentering:self.gemCostLabel.superview withLabel:self.gemCostLabel];
  
  [self.gachaTable.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NUM_COLS/2 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
  
  [Globals imageNamed:bpp.machineImgName withView:self.machineImage greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
}

- (void) updateFreeGachasCounter
{
  BOOL firstPageSelected = (self.boosterPack == self.badBoosterPack);
  
  if (_cachedFreeGachas > 0 && firstPageSelected)
  {
    self.gemCostLabel.superview.hidden = YES;
    self.spinActionLabel.hidden = NO;
    self.spinActionLabel.text = [NSString stringWithFormat:self.spinActionLabel.text, _cachedFreeGachas > 1 ? @"s" : @""];
    self.spinCountLabel.text = [NSString stringWithFormat:@"%d Free", _cachedFreeGachas];
  }
  else
  {
    self.gemCostLabel.superview.hidden = NO;
    self.spinActionLabel.hidden = YES;
    self.spinCountLabel.text = @"1 Spin";
  }
}

#pragma mark - Button Top Bar

- (void) button1Clicked:(id)sender {
  if (!_isSpinning) {
    [self.navBar clickButton:1];
    
    [self updateForBoosterPack:self.badBoosterPack];
    
    [self updateFreeGachasCounter];
  }
}

- (void) button2Clicked:(id)sender {
  if (!_isSpinning) {
    [self.navBar clickButton:2];
    
    [self updateForBoosterPack:self.goodBoosterPack];
    
    [self updateFreeGachasCounter];
  }
}

#pragma mark - Manipulating bottom view

- (CGPoint) nearestCellMiddleFromPoint:(CGPoint)pt {
  // Input and output will be relative to contentOffset
  UITableView *table = self.gachaTable.tableView;
  float nearest = roundf((pt.y+table.frame.size.width/2)/TABLE_CELL_WIDTH+0.5)-0.5;
  pt.y = nearest*TABLE_CELL_WIDTH-table.frame.size.width/2;
  return pt;
}

- (CGPoint) nearestCellMiddleFromPoint:(CGPoint)pt withBoosterItem:(BoosterItemProto *)bip {
  UITableView *table = self.gachaTable.tableView;
  int row = (pt.y+table.frame.size.width/2)/TABLE_CELL_WIDTH;
  int rowIdx = row % self.items.count;
  
  int arrIndex = 0;
  GameState *gs = [GameState sharedGameState];
  for (int i = 0; i < self.items.count; i++) {
    int j = (rowIdx+i) % self.items.count;
    BoosterDisplayItemProto *disp = self.items[j];
    if (disp.isMonster && bip.monsterId && disp.isComplete == bip.isComplete) {
      MonsterProto *mp = [gs monsterWithId:bip.monsterId];
      if (mp.quality == disp.quality) {
        arrIndex = j;
        break;
      }
    } else if (!disp.isMonster && bip.gemReward) {
      if (bip.gemReward == disp.gemReward) {
        arrIndex = j;
        break;
      }
    }
  }
  
  float base = floorf(row/(float)self.items.count)*self.items.count;
  float nearest = base+arrIndex+0.5;
  pt.y = nearest*TABLE_CELL_WIDTH-table.frame.size.width/2;
  return pt;
}

- (IBAction)spinClicked:(id)sender {
  TimingFunctionTableView *table = self.gachaTable.tableView;
  if (table.isTracking || _isSpinning) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  BOOL freeGachasAvailable = (self.boosterPack == self.badBoosterPack) && (_cachedFreeGachas > 0);
  if (gs.gems < self.boosterPack.gemPrice && ! freeGachasAvailable) {
    [GenericPopupController displayNotEnoughGemsView];
  } else if (gs.myMonsters.count > gs.maxInventorySlots) {
    [GenericPopupController displayConfirmationWithDescription:[NSString stringWithFormat:@"Uh oh, your residences are full. Sell some %@s to free up space.", MONSTER_NAME] title:@"Residences Full" okayButton:@"Sell" cancelButton:@"Cancel" target:self selector:@selector(manageTeam)];
  } else {
    _lastSpinWasFree = freeGachasAvailable;
    [[OutgoingEventController sharedOutgoingEventController] purchaseBoosterPack:self.boosterPack.boosterPackId isFree:freeGachasAvailable delegate:self];
    [self.topBar updateLabels];
    
    self.spinner.hidden = NO;
    self.spinView.hidden = YES;
    
    self.gachaTable.userInteractionEnabled = NO;
    _isSpinning = YES;
  }
}

- (void) manageTeam {
  GameViewController *gvc = [GameViewController baseController];
  [gvc dismissViewControllerAnimated:YES completion:^{
    [gvc pointArrowOnSellMobsters];
  }];
}

- (void) handlePurchaseBoosterPackResponseProto:(FullEvent *)fe {
  PurchaseBoosterPackResponseProto *proto = (PurchaseBoosterPackResponseProto *)fe.event;
  
  if (proto.status == PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusSuccess) {
    TimingFunctionTableView *table = self.gachaTable.tableView;
    CGPoint pt = table.contentOffset;
    pt = [self nearestCellMiddleFromPoint:ccp(pt.x, pt.y+2000) withBoosterItem:proto.prize];
    float time = rand()/(float)RAND_MAX*3.5+3.5;
    [table setContentOffset:pt withTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.23 :.9 :.28 :.95] duration:time];
    
    self.prize = proto.prize;
    
    GameState *gs = [GameState sharedGameState];
    if (self.prize.monsterId) {
      MonsterProto *mp = [gs monsterWithId:self.prize.monsterId];
      NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Character.png"];
      [Globals imageNamed:fileName withView:nil greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
      
      if (!self.prize.isComplete) {
        if (proto.updatedOrNewList.count > 0) {
          _numPuzzlePieces = [(FullUserMonsterProto *)proto.updatedOrNewList[0] numPieces];
        } else {
          _numPuzzlePieces = 1;
        }
      } else {
        _numPuzzlePieces = 0;
      }
    }
    
    int gemChange = self.prize.gemReward-self.boosterPack.gemPrice;
    [Analytics buyGacha:self.boosterPack.boosterPackId monsterId:self.prize.monsterId isPiece:!self.prize.isComplete gemChange:gemChange gemBalance:gs.gems];
    
    // Decrement cached free gachas count locally and update UI
    if ( _lastSpinWasFree )
      _cachedFreeGachas--;
    [self updateFreeGachasCounter];
  }
  
  self.spinner.hidden = YES;
  self.spinView.hidden = NO;
}

- (IBAction)menuCloseClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  if (!_isSpinning || gs.isAdmin) {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
  }
}

- (IBAction)menuBackClicked:(id)sender {
  if (!_isSpinning) {
    [super menuBackClicked:sender];
  }
}

#pragma mark - EasyTableView methods

- (void) setupGachaTable {
  self.gachaTable = [[EasyTableView alloc] initWithFrame:self.tableContainerView.bounds numberOfColumns:NUM_COLS ofWidth:TABLE_CELL_WIDTH];
  self.gachaTable.delegate = self;
  self.gachaTable.tableView.separatorColor = [UIColor clearColor];
  self.gachaTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.tableContainerView addSubview:self.gachaTable];
}

- (UIView *) easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect withIndexPath:(NSIndexPath *)indexPath {
  [[NSBundle mainBundle] loadNibNamed:@"GachaponItemCell" owner:self options:nil];
  self.itemCell.center = ccp(rect.size.width/2, rect.size.height/2);
  return self.itemCell;
}

- (void) easyTableView:(EasyTableView *)easyTableView setDataForView:(GachaponItemCell *)view forIndexPath:(NSIndexPath *)indexPath {
  NSInteger index = indexPath.row % self.items.count;
  [view updateForGachaDisplayItem:[self.items objectAtIndex:index]];
}

- (void) easyTableViewWillEndDragging:(EasyTableView *)easyTableView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
  CGPoint pt = *targetContentOffset;
  pt = [self nearestCellMiddleFromPoint:pt];
  targetContentOffset->y = pt.y;
}

- (void) easyTableViewDidEndScrollingAnimation:(EasyTableView *)easyTableView {
  if (_isSpinning) {
    if (self.prize.monsterId) {
      [self displayWhiteFlash];
    } else {
      [self displayWhiteFlash];
      self.gachaTable.userInteractionEnabled = YES;
      _isSpinning = NO;
    }
  }
}

- (void) displayWhiteFlash {
  UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
  [self.navigationController.view addSubview:view];
  view.backgroundColor = [UIColor whiteColor];
  view.alpha = 0.f;
  
  [UIView animateWithDuration:0.4f animations:^{
    view.alpha = 1.f;
  } completion:^(BOOL finished) {
    [self displayPrizeView];
    [view.superview bringSubviewToFront:view];
    
    [self.topBar updateLabels];
    
    [UIView animateWithDuration:0.4f animations:^{
      view.alpha = 0.f;
    } completion:^(BOOL finished) {
      [view removeFromSuperview];
    }];
  }];
  
  self.gachaTable.userInteractionEnabled = YES;
  _isSpinning = NO;
}

- (void) displayPrizeView {
  UIView *parent = self.navigationController.view;
  self.prizeView.frame = parent.bounds;
  [parent addSubview:self.prizeView];
  
  if (self.prize.monsterId) {
    if (_numPuzzlePieces > 0) {
      [self.prizeView animateWithMonsterId:self.prize.monsterId numPuzzlePieces:_numPuzzlePieces];
    } else {
      [self.prizeView animateWithMonsterId:self.prize.monsterId];
    }
  } else {
    [self.prizeView animateWithGems:self.prize.gemReward];
  }
}

#pragma mark - Focus Scroll View

- (int) numberOfItems {
  return (int)self.boosterPack.specialItemsList.count;
}

- (CGFloat) widthPerItem {
  return 180;
}

- (UIView *) viewForItemNum:(int)itemNum reusableView:(GachaponFeaturedView *)view {
  if (!view) {
    [[NSBundle mainBundle] loadNibNamed:@"GachaponFeaturedView" owner:self options:nil];
    view = self.featuredView;
  }
  BoosterItemProto *item = self.boosterPack.specialItemsList[itemNum];
  [view updateForMonsterId:item.monsterId];
  return view;
}

- (CGFloat) scaleForOutOfFocusView {
  return 0.75;
}

- (BOOL) shouldLoopItems {
  return YES;
}

@end
