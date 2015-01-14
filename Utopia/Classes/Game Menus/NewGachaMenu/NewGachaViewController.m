//
//  NewGachaViewController.m
//  Utopia
//
//  Created by Behrouz N. on 12/18/14.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "NewGachaViewController.h"
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

@implementation NewGachaViewController

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
  
  GameState *gs = [GameState sharedGameState];
  _cachedDailySpin = [gs hasDailyFreeSpin];
  
  [self setUpCloseButton];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self.topBar];
  
  [self.navBar button:3 shouldBeHidden:YES];
  
  [self.skillPopup setHidden:YES];
  [self.view addSubview:self.skillPopup];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self setUpImageBackButton];
  
  [self loadBoosterPacks];
  
  [self setupGachaTable];
  
  [self layoutViews];
  
  THLabel* spinLabel = (THLabel*)self.spinActionLabel; {
    spinLabel.strokePosition = THLabelStrokePositionOutside;
    spinLabel.strokeSize = 1.f;
    spinLabel.strokeColor = [UIColor colorWithRed:59.f / 255.f green:4.f / 255.f blue:134.f / 255.f alpha:1.f];
    spinLabel.gradientStartColor = [UIColor whiteColor];
    spinLabel.gradientEndColor = [UIColor colorWithRed:248.f / 255.f green:191.f / 255.f blue:255.f / 255.f alpha:1.f];
  }
  
  THLabel* gemLabel = (THLabel*)self.gemCostLabel; {
    gemLabel.strokePosition = THLabelStrokePositionOutside;
    gemLabel.strokeSize = 1.f;
    gemLabel.strokeColor = [UIColor colorWithRed:59.f / 255.f green:4.f / 255.f blue:134.f / 255.f alpha:1.f];
    gemLabel.gradientStartColor = [UIColor whiteColor];
    gemLabel.gradientEndColor = [UIColor colorWithRed:248.f / 255.f green:191.f / 255.f blue:255.f / 255.f alpha:1.f];
  }
  
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

- (void) layoutViews {
  /*
  // Account for nav bar
  float navHeight = self.navigationController.navigationBar.height;
  
  // Adjust the right view first by finding size of image and keeping distance from right the same
  UIView *spinContainer = self.machineImage.superview;
  CGSize s = self.machineImage.image.size;
  CGRect oldRect = spinContainer.frame;
  self.machineImage.size = s;
  spinContainer.size = s;
  
  // Find the approx perc of where spinView used to be and adjust for that
  self.spinView.superview.center = ccp(spinContainer.width/2, self.spinView.superview.centerY/oldRect.size.height*spinContainer.height);
  
  if ([Globals isiPhone6Plus]) {
    spinContainer.transform = CGAffineTransformMakeScale(1.2, 1.2);
  }
  
  spinContainer.originX = CGRectGetMaxX(oldRect)-spinContainer.width;
  spinContainer.centerY = (self.tableContainerView.originY+navHeight)/2;
  
  
  // Now use the remaining space for the featured views
  UIView *featuredContainer = self.focusScrollView.superview;
  featuredContainer.width = spinContainer.originX+10;
  featuredContainer.height = self.tableContainerView.originY-navHeight;
  featuredContainer.originY = navHeight;
  
  if ([Globals isSmallestiPhone]) {
    featuredContainer.originX -= 20.f;
  }
   */
  
  const CGFloat navBarHeight = self.topBar.height;
  
  self.gachaBgTopLeft.originY += navBarHeight;
  self.gachaBgTopLeft.height -= navBarHeight;
  self.gachaBgBottomRight.originY += navBarHeight;
  self.gachaBgBottomRight.height -= navBarHeight;
  
  UIView *featuredContainer = self.focusScrollView.superview;
  featuredContainer.originY += navBarHeight;
  featuredContainer.height -= navBarHeight;

  CGPoint oldCenter = self.spinButton.center;
  {
    [Globals imageNamedWithiPhone6Prefix:@"spinbutton.png" withView:self.spinButton greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];

    CGSize newSize = self.spinButton.imageView.image.size;
    CGFloat widthRatio = newSize.width / self.spinButton.width;
    CGFloat heightRatio = newSize.height / self.spinButton.height;
    self.spinButton.size = newSize;
    self.spinButton.center = oldCenter;
    
    self.spinView.size = CGSizeMake(self.spinView.width * widthRatio, self.spinView.height * heightRatio);
    self.spinView.center = self.spinButton.center;
  }
  
  if ([Globals isSmallestiPhone])
  {
    self.logoImage.hidden = YES;
    self.logoSeparatorImage.hidden = YES;
    
    CGFloat moveBy = featuredContainer.originX - self.logoImage.originX;
    featuredContainer.originX -= moveBy;
    featuredContainer.width += moveBy;
    featuredContainer.originY -= 15.f;
    featuredContainer.height += 15.f;
  }

  self.gemCostView.originX = (self.spinView.centerX - self.spinView.originX) + 5;
  self.gemCostView.originY = (self.spinView.height - self.gemCostView.height) * .5f - 5;
  
  self.topBar.gemIcon.transform = CGAffineTransformMakeScale(-1.f, 1.f);
  
  [Globals alignSubviewsToPixelsBoundaries:self.spinButton.superview];
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
  
  self.gemCostLabel.text = [NSString stringWithFormat:@" %@ ", [Globals commafyNumber:self.boosterPack.gemPrice]];
  self.prizeView.gemCostLabel.text = [Globals commafyNumber:self.boosterPack.gemPrice];
//[Globals adjustViewForCentering:self.gemCostLabel.superview withLabel:self.gemCostLabel];
  
  [self.gachaTable.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NUM_COLS/2 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
  
  [Globals imageNamed:bpp.machineImgName withView:self.machineImage greyscale:NO
            indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  [Globals imageNamed:bpp.navBarImgName withView:self.logoImage greyscale:NO
            indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  CGFloat deviceScale = MIN([Globals screenSize].height / 375.f, 1.1f); // These images are designed for iPhone 6
  {
    const CGPoint oldCenter = self.logoImage.center;
    self.logoImage.size = CGSizeMake(self.logoImage.image.size.width * deviceScale, self.logoImage.image.size.height * deviceScale);
    self.logoImage.center = oldCenter;
  }
  if (deviceScale < 1.f) deviceScale *= deviceScale; // Scale down a bit further on smaller screens
  {
    const CGPoint oldCenter = self.machineImage.center;
    self.machineImage.size = CGSizeMake(self.machineImage.image.size.width * deviceScale, self.machineImage.image.size.height * deviceScale);
    self.machineImage.center = oldCenter;
  }
}

- (void) updateFreeGachasCounter
{
  BOOL firstPageSelected = (self.boosterPack == self.badBoosterPack);
  
  GameState *gs = [GameState sharedGameState];
  int numFreeSpins = [gs numberOfFreeSpinsForBoosterPack:self.boosterPack.boosterPackId];
  
  if (_cachedDailySpin && firstPageSelected)
  {
    self.gemCostLabel.superview.hidden = YES;
    self.spinActionLabel.textAlignment = NSTextAlignmentCenter;
    self.spinActionLabel.text = @" DAILY SPIN! ";
    self.spinActionLabel.originX = 0;
  }
  else if (numFreeSpins)
  {
    self.gemCostLabel.superview.hidden = YES;
    self.spinActionLabel.textAlignment = NSTextAlignmentCenter;
    self.spinActionLabel.text = [NSString stringWithFormat:@" %d FREE SPIN%@! ", numFreeSpins, numFreeSpins > 1 ? @"S" : @""];
    self.spinActionLabel.originX = 0;
  }
  else
  {
    self.gemCostLabel.superview.hidden = NO;
    self.spinActionLabel.textAlignment = NSTextAlignmentLeft;
    self.spinActionLabel.text = @" SPIN! ";
    
    CGFloat labelTextWidth = [self.spinActionLabel.text getSizeWithFont:self.spinActionLabel.font
                                                      constrainedToSize:self.spinActionLabel.frame.size
                                                          lineBreakMode:self.spinActionLabel.lineBreakMode].width;
    self.spinActionLabel.originX = (self.spinView.centerX - self.spinView.originX) - labelTextWidth - 5;
  }
  
  int badSpins = [gs numberOfFreeSpinsForBoosterPack:self.badBoosterPack.boosterPackId];
  int goodSpins = [gs numberOfFreeSpinsForBoosterPack:self.goodBoosterPack.boosterPackId];
  self.badBadge.badgeNum = _cachedDailySpin + badSpins;
  self.goodBadge.badgeNum = goodSpins;
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
  BOOL isDailySpin = (self.boosterPack == self.badBoosterPack) && _cachedDailySpin;
  int numFreeSpins = [gs numberOfFreeSpinsForBoosterPack:self.boosterPack.boosterPackId];
  if (gs.gems < self.boosterPack.gemPrice && !isDailySpin && !numFreeSpins) {
    [GenericPopupController displayNotEnoughGemsView];
  } else if (gs.myMonsters.count > gs.maxInventorySlots) {
    [GenericPopupController displayConfirmationWithDescription:[NSString stringWithFormat:@"Uh oh, your residences are full. Sell some %@s to free up space.", MONSTER_NAME] title:@"Residences Full" okayButton:@"Sell" cancelButton:@"Cancel" target:self selector:@selector(manageTeam)];
  } else {
    _lastSpinWasFree = isDailySpin;
    
    // Prioritize daily spin
    if (isDailySpin || !numFreeSpins) {
      [[OutgoingEventController sharedOutgoingEventController] purchaseBoosterPack:self.boosterPack.boosterPackId isFree:isDailySpin delegate:self];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] tradeItemForFreeBoosterPack:self.boosterPack.boosterPackId delegate:self];
    }
    
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

- (void) responseReceivedWithSuccess:(BOOL)success prize:(BoosterItemProto *)prize monsters:(NSArray *)monsters {
  if (success) {
    TimingFunctionTableView *table = self.gachaTable.tableView;
    CGPoint pt = table.contentOffset;
    pt = [self nearestCellMiddleFromPoint:ccp(pt.x, pt.y+2000) withBoosterItem:prize];
    float time = rand()/(float)RAND_MAX*3.5+3.5;
    [table setContentOffset:pt withTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.23 :.9 :.28 :.95] duration:time];
    
    self.prize = prize;
    
    GameState *gs = [GameState sharedGameState];
    if (self.prize.monsterId) {
      MonsterProto *mp = [gs monsterWithId:self.prize.monsterId];
      NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Character.png"];
      [Globals imageNamedWithiPhone6Prefix:fileName withView:nil greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
      
      if (!self.prize.isComplete) {
        if (monsters.count > 0) {
          _numPuzzlePieces = [(FullUserMonsterProto *)monsters[0] numPieces];
        } else {
          _numPuzzlePieces = 1;
        }
      } else {
        _numPuzzlePieces = 0;
      }
    }
    
    int gemChange = self.prize.gemReward-self.boosterPack.gemPrice;
    [Analytics buyGacha:self.boosterPack.boosterPackId monsterId:self.prize.monsterId isPiece:!self.prize.isComplete gemChange:gemChange gemBalance:gs.gems];
    
    // Decrement cached daily spin count locally and update UI
    if ( _lastSpinWasFree )
      _cachedDailySpin = NO;
    
    [self updateFreeGachasCounter];
  } else {
    _isSpinning = NO;
  }
  
  self.spinner.hidden = YES;
  self.spinView.hidden = NO;
}

- (void) handlePurchaseBoosterPackResponseProto:(FullEvent *)fe {
  PurchaseBoosterPackResponseProto *proto = (PurchaseBoosterPackResponseProto *)fe.event;
  
  BOOL success = proto.status == PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusSuccess;
  BoosterItemProto *prize = proto.prize;
  NSArray *monsters = proto.updatedOrNewList;
  
  [self responseReceivedWithSuccess:success prize:prize monsters:monsters];
}

- (void) handleTradeItemForBoosterResponseProto:(FullEvent *)fe {
  TradeItemForBoosterResponseProto *proto = (TradeItemForBoosterResponseProto *)fe.event;
  
  BOOL success = proto.status == TradeItemForBoosterResponseProto_TradeItemForBoosterStatusSuccess;
  BoosterItemProto *prize = proto.prize;
  NSArray *monsters = proto.updatedOrNewList;
  
  [self responseReceivedWithSuccess:success prize:prize monsters:monsters];
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
  [[NSBundle mainBundle] loadNibNamed:@"NewGachaItemCell" owner:self options:nil];
  self.itemCell.center = ccp(rect.size.width/2, rect.size.height/2);
  return self.itemCell;
}

- (void) easyTableView:(EasyTableView *)easyTableView setDataForView:(NewGachaItemCell *)view forIndexPath:(NSIndexPath *)indexPath {
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
  return self.focusScrollView.scrollView.width;
}

- (UIView *) viewForItemNum:(int)itemNum reusableView:(NewGachaFeaturedView *)view {
  if (!view) {
    [[NSBundle mainBundle] loadNibNamed:@"NewGachaFeaturedView" owner:self options:nil];
    view = self.featuredView;
    
    float aspRatio = view.width/view.height;
    view.width = self.focusScrollView.scrollView.width;
    view.height = view.width / aspRatio;
    if ([Globals isSmallestiPhone]) view.height *= .8f;
    
    view.delegate = self;
  }
  BoosterItemProto *item = self.boosterPack.specialItemsList[itemNum];
  [view updateForMonsterId:item.monsterId];
  return view;
}

- (CGFloat) scaleForOutOfFocusView {
  return 0.5f;
}

- (BOOL) shouldLoopItems {
  return YES;
}

#pragma mark - Featured View

- (void) skillTapped:(SkillProto*)skill element:(Element)element position:(CGPoint)pos
{
  NSString *bgName = [NSString stringWithFormat:@"%@.png", [Globals imageNameForElement:element suffix:@"skilldescription"]];
  NSString *orbImage = nil, *orbDesc = nil;
  
  if (skill.activationType == SkillActivationTypePassive)
    orbDesc = @"PASSIVE";
  else
  {
    orbDesc = [NSString stringWithFormat:@"BREAK %d %@ ORBS TO ACTIVATE", skill.orbCost, [[Globals stringForElement:element] uppercaseString]];
    orbImage = [NSString stringWithFormat:@"%@.png", [Globals imageNameForElement:element suffix:@"orb"]];
  }
  
  [self.skillPopup displayWithSkillName:skill.name
                            description:skill.desc
                           counterLabel:nil
                         orbDescription:orbDesc
                        backgroundImage:bgName
                               orbImage:orbImage
                             atPosition:pos];
}

- (void) skillPopupDisplayed
{
  [self.skillPopupCloseButton setUserInteractionEnabled:YES];
}

- (void) hideSkillPopup:(id)sender
{
  [self.skillPopup hide];
  [self.skillPopupCloseButton setUserInteractionEnabled:NO];
}

@end
