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
#import "SecretGiftViewController.h"
#import "SoundEngine.h"
#import "SkillProtoHelper.h"
#import "MiniEventManager.h"

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
  // No longer randomizing, just use the current display items list with db order
  /*
  NSMutableArray *arr = [NSMutableArray array];
  for (int i = 0; i < 20; i++) {
   */
  NSMutableArray *sub = [NSMutableArray array];
  for (BoosterDisplayItemProto *item in self.boosterPack.displayItemsList) {
    // Add it as many times as quantity
    // Multiply quantity to increase variability
    for (int j = 0; j < item.quantity; j++) {
      [sub addObject:item];
    }
  }
  /*
    [sub shuffle];
    [arr addObjectsFromArray:sub];
  }
   */
  self.items = sub;
  
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
  
  _tickerController = [[NewGachaTicker alloc] initWithImageView:self.ticker
                                                      cellWidth:TABLE_CELL_WIDTH
                                                    anchorPoint:CGPointMake(.5f, 12.f / 50.f)];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self setUpImageBackButton];
  
  [self loadBoosterPacks];
  
  [self setupGachaTable];
  
  [self layoutViews];
  
  THLabel* singleSpinLabel = (THLabel*)self.singleSpinActionLabel; {
    singleSpinLabel.strokePosition = THLabelStrokePositionOutside;
    singleSpinLabel.strokeSize = 1.f;
    singleSpinLabel.strokeColor = [UIColor colorWithRed:59.f / 255.f green:4.f / 255.f blue:134.f / 255.f alpha:1.f];
    singleSpinLabel.gradientStartColor = [UIColor whiteColor];
    singleSpinLabel.gradientEndColor = [UIColor colorWithRed:248.f / 255.f green:191.f / 255.f blue:255.f / 255.f alpha:1.f];
  }
  
  THLabel* sinlgeSpinGemLabel = (THLabel*)self.singleSpinGemCostLabel; {
    sinlgeSpinGemLabel.strokePosition = THLabelStrokePositionOutside;
    sinlgeSpinGemLabel.strokeSize = 1.f;
    sinlgeSpinGemLabel.strokeColor = [UIColor colorWithRed:59.f / 255.f green:4.f / 255.f blue:134.f / 255.f alpha:1.f];
    sinlgeSpinGemLabel.gradientStartColor = [UIColor whiteColor];
    sinlgeSpinGemLabel.gradientEndColor = [UIColor colorWithRed:248.f / 255.f green:191.f / 255.f blue:255.f / 255.f alpha:1.f];
    sinlgeSpinGemLabel.originY += 1.f;
  }
  
  _isMultiSpinAvailable = [[GameState sharedGameState].itemUtil getItemsForType:ItemTypeGachaMultiSpin].count > 0;
  {
    THLabel* multiSpinLabel = (THLabel*)self.multiSpinActionLabel;
    if (_isMultiSpinAvailable) {
      multiSpinLabel.strokePosition = THLabelStrokePositionOutside;
      multiSpinLabel.strokeSize = 1.f;
      multiSpinLabel.strokeColor = [UIColor colorWithHexString:@"B84A00"];
      multiSpinLabel.gradientStartColor = [UIColor whiteColor];
      multiSpinLabel.gradientEndColor = [UIColor colorWithHexString:@"FFF0BA"];
      multiSpinLabel.shadowColor = [UIColor colorWithHexString:@"B84A00BF"];
    } else {
      multiSpinLabel.strokeSize = 0.f;
    }
    
    THLabel* multiSpinGemLabel = (THLabel*)self.multiSpinGemCostLabel;
    if (_isMultiSpinAvailable) {
      multiSpinGemLabel.strokePosition = THLabelStrokePositionOutside;
      multiSpinGemLabel.strokeSize = 1.f;
      multiSpinGemLabel.strokeColor = [UIColor colorWithHexString:@"B84A00"];
      multiSpinGemLabel.gradientStartColor = [UIColor whiteColor];
      multiSpinGemLabel.gradientEndColor = [UIColor colorWithHexString:@"FFF0BA"];
      multiSpinGemLabel.shadowColor = [UIColor colorWithHexString:@"B84A00BF"];
      multiSpinGemLabel.originY += 1.f;
    } else {
      multiSpinGemLabel.strokeSize = 0.f;
    }
    
    if (_isMultiSpinAvailable) {
      [self.multiSpinButton setImage:[Globals imageNamed:@"bigspingold.png"] forState:UIControlStateNormal];
      [self.multiSpinButton setImage:[Globals imageNamed:@"bigspingoldpressed.png"] forState:UIControlStateHighlighted];
      
      self.multiSpinTapToUnlockLabel.hidden = YES;
      
      self.multiSpinActionLabel.font = [UIFont fontWithName:self.multiSpinActionLabel.font.fontName size:12.f];
      self.multiSpinActionLabel.centerY = self.multiSpinView.height * .5f - 3;
      
      self.multiSpinView.originX += 3;
      
      const CGPoint gemCostIconCenter = self.multiSpinGemCostIcon.center;
      self.multiSpinGemCostIcon.size = CGSizeMake(22, 22);
      self.multiSpinGemCostIcon.centerX = gemCostIconCenter.x;
      
      self.multiSpinGemCostLabel.font = [UIFont fontWithName:self.multiSpinGemCostLabel.font.fontName size:12.f];
    } else {
      [Globals imageNamed:@"diamond.png" withView:self.multiSpinGemCostIcon greyscale:YES indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];
      
      self.multiSpinTapToUnlockLabel.originY = 11;
      self.multiSpinActionLabel.originY = self.multiSpinView.height - self.multiSpinActionLabel.height - 15;
      self.multiSpinGemCostLabel.originY += 1;
    }
    
    self.multiSpinGemCostView.originX = (self.multiSpinView.centerX - self.multiSpinView.originX) + 10;
    self.multiSpinGemCostView.centerY = self.multiSpinActionLabel.centerY - 2;
    
    self.multiSpinGemCostLabel.originX = CGRectGetMaxX(self.multiSpinGemCostIcon.frame);
    self.multiSpinGemCostIcon.centerY = self.multiSpinGemCostLabel.centerY;
  }
  
  [Globals alignSubviewsToPixelsBoundaries:self.machineImage.superview];
  
  if (self.boosterPack.boosterPackId == self.badBoosterPack.boosterPackId) {
    [self button1Clicked:nil];
  } else {
    [self button2Clicked:nil];
  }
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  self.focusScrollView.delegate = nil;
  
  [_tickerController performCleanUp];
  _tickerController = nil;
}

- (void) layoutViews {
  const CGFloat navBarHeight = self.topBar.height;
  const CGFloat deviceScale = [Globals screenSize].width / 667.f;
  
  const CGSize bgTopLeftScaledSize = CGSizeMake(self.gachaBgTopLeft.image.size.width * deviceScale, self.gachaBgTopLeft.image.size.height * deviceScale);
  [self.gachaBgTopLeft setFrame:CGRectMake(0.f,
                                           navBarHeight,
                                           bgTopLeftScaledSize.width,
                                           bgTopLeftScaledSize.height)];
  [self.gachaBgTopLeft setContentMode:UIViewContentModeScaleToFill];
  const CGSize bgBottomRightScaledSize = CGSizeMake(self.gachaBgBottomRight.image.size.width * deviceScale, self.gachaBgBottomRight.image.size.height * deviceScale);
  [self.gachaBgBottomRight setFrame:CGRectMake(self.view.width - bgBottomRightScaledSize.width,
                                              self.view.height - bgBottomRightScaledSize.height,
                                              bgBottomRightScaledSize.width,
                                               bgBottomRightScaledSize.height)];
  [self.gachaBgBottomRight setContentMode:UIViewContentModeScaleToFill];
  
  UIView *featuredContainer = self.focusScrollView.superview;
  featuredContainer.height = CGRectGetMaxY(featuredContainer.frame) - navBarHeight;
  featuredContainer.originY = navBarHeight;
  
  if ([Globals isSmallestiPhone])
  {
    self.logoImage.hidden = YES;
    self.logoSeparatorImage.hidden = YES;
    
    CGFloat moveBy = featuredContainer.originX;
    featuredContainer.originX -= moveBy;
    featuredContainer.width += moveBy + 50.f;
    featuredContainer.originY -= 15.f;
    featuredContainer.height += 15.f;
  }
  else
  {
    UIImageView* leftGradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gachagradientbarleft.png"]];
    {
      [leftGradient setFrame:CGRectMake(172.f * deviceScale,
                                        navBarHeight,
                                        leftGradient.image.size.width * deviceScale,
                                        leftGradient.image.size.height * deviceScale)];
      [leftGradient setContentMode:UIViewContentModeScaleToFill];
      [self.view insertSubview:leftGradient aboveSubview:featuredContainer];
    }
    
    featuredContainer.originX = leftGradient.originX;
    featuredContainer.width = (542.f * deviceScale) - featuredContainer.originX;
  }
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
  
  [_tickerController resetState];
  
  self.title = self.boosterPack.boosterPackName;
  
  self.singleSpinGemCostLabel.text = [NSString stringWithFormat:@" %@ ", [Globals commafyNumber:self.boosterPack.gemPrice]];
  self.multiSpinGemCostLabel.text  = [NSString stringWithFormat:@" %@ ", [Globals commafyNumber:self.boosterPack.gemPrice * [Globals sharedGlobals].boosterPackPurchaseAmountRequired]];
  
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
  
  const BOOL regularGrab = (self.boosterPack.boosterPackId == self.badBoosterPack.boosterPackId);
  if (regularGrab) {
    self.multiSpinContainer.hidden = YES;
    self.singleSpinContainer.centerY = self.multiSpinContainer.centerY;
  } else {
    self.multiSpinContainer.hidden = NO;
    self.singleSpinContainer.centerY = self.multiSpinContainer.centerY - 41;
  }
  
  [self updateSingleSpinButton];
  
  [Globals alignSubviewsToPixelsBoundaries:self.machineImage.superview];
}

- (void) updateSingleSpinButton
{
  const BOOL regularGrab = (self.boosterPack.boosterPackId == self.badBoosterPack.boosterPackId);
  
  const CGPoint spinButtonCenter = self.singleSpinButton.center;
  [self.singleSpinButton setImage:[Globals imageNamed:regularGrab ? @"bigspinpurple.png" : @"minibuttonpurple.png"] forState:UIControlStateNormal];
  [self.singleSpinButton setImage:[Globals imageNamed:regularGrab ? @"bigspinpurplepressed.png" : @"minibuttonpurplepressed.png"] forState:UIControlStateHighlighted];
  self.singleSpinButton.size = self.singleSpinButton.imageView.image.size;
  self.singleSpinButton.center = spinButtonCenter;
  
  const CGSize newSize = self.singleSpinButton.imageView.image.size;
  const CGFloat widthRatio = newSize.width / self.singleSpinButton.width;
  const CGFloat heightRatio = newSize.height / self.singleSpinButton.height;
  self.singleSpinView.size = CGSizeMake(self.singleSpinView.width * widthRatio, self.singleSpinView.height * heightRatio);
  self.singleSpinView.center = self.singleSpinButton.center;
  
  self.singleSpinGemCostView.originX = (self.singleSpinView.centerX - self.singleSpinView.originX) + (regularGrab ? 7 : 3);
  self.singleSpinGemCostView.originY = (self.singleSpinView.height - self.singleSpinGemCostView.height) * .5f - 16;
  
  self.singleSpinActionLabel.font = [UIFont fontWithName:self.singleSpinActionLabel.font.fontName size:regularGrab ? 13.f : 9.f];
  self.singleSpinActionLabel.centerY = [self.singleSpinButton.superview convertPoint:self.singleSpinButton.center toView:self.singleSpinActionLabel.superview].y - (regularGrab ? 3 : 2);
  
  const CGPoint gemCostIconCenter = self.singleSpinGemCostIcon.center;
  self.singleSpinGemCostIcon.size = regularGrab ? CGSizeMake(22, 22) : CGSizeMake(16, 16);
  self.singleSpinGemCostIcon.center = CGPointMake(gemCostIconCenter.x, self.singleSpinActionLabel.centerY + 1);
  
  self.singleSpinGemCostLabel.font = [UIFont fontWithName:self.singleSpinGemCostLabel.font.fontName size:regularGrab ? 13.f : 9.f];
  self.singleSpinGemCostLabel.centerY = self.singleSpinActionLabel.centerY + 1;
  self.singleSpinGemCostLabel.originX = CGRectGetMaxX(self.singleSpinGemCostIcon.frame) - 1;
}

- (void) updateFreeGachasCounter
{
  BOOL firstPageSelected = (self.boosterPack == self.badBoosterPack);
  
  GameState *gs = [GameState sharedGameState];
  int numFreeSpins = [gs numberOfFreeSpinsForBoosterPack:self.boosterPack.boosterPackId];
  
  if (_cachedDailySpin && firstPageSelected)
  {
    self.singleSpinGemCostView.hidden = YES;
    self.singleSpinActionLabel.textAlignment = NSTextAlignmentCenter;
    self.singleSpinActionLabel.text = @" DAILY SPIN! ";
    self.singleSpinActionLabel.originX = 0;
  }
  else if (numFreeSpins)
  {
    self.singleSpinGemCostView.hidden = YES;
    self.singleSpinActionLabel.textAlignment = NSTextAlignmentCenter;
    self.singleSpinActionLabel.text = [NSString stringWithFormat:@" %d FREE SPIN%@! ", numFreeSpins, numFreeSpins > 1 ? @"S" : @""];
    self.singleSpinActionLabel.originX = 0;
  }
  else
  {
    self.singleSpinGemCostView.hidden = NO;
    self.singleSpinActionLabel.textAlignment = NSTextAlignmentLeft;
    self.singleSpinActionLabel.text = @" 1 SPIN ";
    
    CGFloat labelTextWidth = [self.singleSpinActionLabel.text getSizeWithFont:self.singleSpinActionLabel.font
                                                            constrainedToSize:self.singleSpinActionLabel.frame.size
                                                                lineBreakMode:self.singleSpinActionLabel.lineBreakMode].width;
    self.singleSpinActionLabel.originX = (self.singleSpinView.centerX - self.singleSpinView.originX) - labelTextWidth + 3;
  }
  
  self.multiSpinActionLabel.text = [NSString stringWithFormat:@" %d SPINS!", [Globals sharedGlobals].boosterPackNumberOfPacksGiven];
  
  CGFloat labelTextWidth = [self.multiSpinActionLabel.text getSizeWithFont:self.multiSpinActionLabel.font
                                                         constrainedToSize:self.multiSpinActionLabel.frame.size
                                                             lineBreakMode:self.multiSpinActionLabel.lineBreakMode].width;
  self.multiSpinActionLabel.originX = (self.multiSpinView.centerX - self.multiSpinView.originX) - labelTextWidth + 3;
  
  int badSpins = [gs numberOfFreeSpinsForBoosterPack:self.badBoosterPack.boosterPackId];
  int goodSpins = [gs numberOfFreeSpinsForBoosterPack:self.goodBoosterPack.boosterPackId];
  self.badBadge.badgeNum = _cachedDailySpin + badSpins;
  self.goodBadge.badgeNum = goodSpins;
}

#pragma mark - Button Top Bar

- (void) button1Clicked:(id)sender {
  if (!_isSpinning) {
    [self hideSkillPopup:self];
    
    [self.navBar clickButton:1];
    
    [self updateForBoosterPack:self.badBoosterPack];
    
    [self updateFreeGachasCounter];
  }
}

- (void) button2Clicked:(id)sender {
  if (!_isSpinning) {
    [self hideSkillPopup:self];
    
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
    } else if (disp.itemId && disp.itemId == bip.itemId && disp.itemQuantity == bip.itemQuantity) {
      arrIndex = j;
      break;
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

- (IBAction) singleSpinClicked:(id)sender {
  TimingFunctionTableView *table = self.gachaTable.tableView;
  if (table.isTracking || _isSpinning) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  BOOL isDailySpin = (self.boosterPack == self.badBoosterPack) && _cachedDailySpin;
  int numFreeSpins = [gs numberOfFreeSpinsForBoosterPack:self.boosterPack.boosterPackId];
  if (gs.gems < self.boosterPack.gemPrice && !isDailySpin && !numFreeSpins) {
    [GenericPopupController displayNotEnoughGemsView];
    // Don't stop them from spinning due to residences anymore. Unnecessary friction..
    /*
  } else if (gs.myMonsters.count > gs.maxInventorySlots) {
    [GenericPopupController displayConfirmationWithDescription:[NSString stringWithFormat:@"Uh oh, your residences are full. Sell some %@s to free up space.", MONSTER_NAME]
                                                         title:@"Residences Full" okayButton:@"Sell" cancelButton:@"Cancel" target:self selector:@selector(manageTeam)];
     */
  } else {
    _lastSpinWasFree = isDailySpin;
    _lastSpinWasMultiSpin = NO;
    
    // Prioritize daily spin
    if (isDailySpin || !numFreeSpins) {
      [[OutgoingEventController sharedOutgoingEventController] purchaseBoosterPack:self.boosterPack.boosterPackId isFree:isDailySpin isMultiSpin:NO delegate:self];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] tradeItemForFreeBoosterPack:self.boosterPack.boosterPackId delegate:self];
    }
    
    [self.topBar updateLabels];
    
    self.singleSpinSpinner.hidden = NO;
    self.singleSpinView.hidden = YES;
    
    self.gachaTable.userInteractionEnabled = NO;
    _isSpinning = YES;
  }
}

- (IBAction) multiSpinClicked:(id)sender {
  if (_isMultiSpinAvailable) {
    TimingFunctionTableView *table = self.gachaTable.tableView;
    if (table.isTracking || _isSpinning) {
      return;
    }
    
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    const int32_t boosterPackGemPrice = self.boosterPack.gemPrice * gl.boosterPackPurchaseAmountRequired;
    if (gs.gems < boosterPackGemPrice) {
      [GenericPopupController displayNotEnoughGemsView];
    } else {
      _lastSpinWasFree = NO;
      _lastSpinWasMultiSpin = YES;
      
      [[OutgoingEventController sharedOutgoingEventController] purchaseBoosterPack:self.boosterPack.boosterPackId isFree:NO isMultiSpin:YES delegate:self];
      
      [self.topBar updateLabels];
      
      self.multiSpinSpinner.hidden = NO;
      self.multiSpinView.hidden = YES;
      
      self.gachaTable.userInteractionEnabled = NO;
      _isSpinning = YES;
    }
  }
  else {
    // TODO - Display a popup that will take the player to Packages screen
  }
}

- (void) manageTeam {
  GameViewController *gvc = [GameViewController baseController];
  [gvc dismissViewControllerAnimated:YES completion:^{
    [gvc pointArrowOnSellMobsters];
  }];
}

- (void) responseReceivedWithSuccess:(BOOL)success prizes:(NSArray*)prizes monsters:(NSArray*)monsters {
  _lastSpinPrizes = nil;
  _lastSpinMonsterDescriptors = nil;
  
  if (success) {
    _lastSpinPrizes = prizes;
    
    GameState *gs = [GameState sharedGameState];
    if (prizes.count > 1 || ((BoosterItemProto*)prizes[0]).monsterId) {
      NSMutableArray* monsterIds = [NSMutableArray array];
      NSMutableArray* monsterDescriptors = [NSMutableArray array];
      NSMutableSet*   monsterElements = [NSMutableSet set];
      
      for (int i = 0; i < prizes.count; ++i) {
        BoosterItemProto* prize = prizes[i];
        if (prize.monsterId) {
          MonsterProto *mp = [gs monsterWithId:prize.monsterId];
          NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Character.png"];
          [Globals imageNamedWithiPhone6Prefix:fileName withView:nil greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
          
          // In the new UserReward system, we only give away either full monsters or a single piece in each spin
          int numPuzzlePieces = 0;
          if (!prize.isComplete) {
            // Find any puzzle pieces awarded for this monster that have not yet been accounted for
            int numUnaccountedPiecesForMonster = 0;
            for (int j = i; j < prizes.count; ++j) {
              if (((BoosterItemProto*)prizes[j]).monsterId == prize.monsterId)
                  ++numUnaccountedPiecesForMonster;
            }
            
            // Get the total number of pieces for monsters with this ID
            int numTotalPiecesForMonster = 0;
            for (FullUserMonsterProto* monster in monsters) {
              if (monster.monsterId == prize.monsterId)
                numTotalPiecesForMonster += monster.numPieces;
            }
            
            // To explain what's going on here -- let's say the player has a certain monster with 2 out of 5 pieces
            // already in place. Assuming a multi-spin has awarded 4 pieces of the same monster, 4 elements in the
            // prizes array will be pieces for that monster, and 2 elements in the monsters array will be a monster
            // of that type; one being complete (5/5) and one that has 1 out of 5 pieces. In the Gacha reveal screen,
            // the first piece for this monster will show 3/5 progess, the next one 4/5, followed by 5/5 and finally
            // 1/5, since 4 puzzle pieces have led to the player having two of the same monster, one complete and
            // one incomplete.
            numPuzzlePieces = ((numTotalPiecesForMonster - numUnaccountedPiecesForMonster) % mp.numPuzzlePieces) + 1;
          }
          
          [monsterIds addObject:@(prize.monsterId)];
          [monsterDescriptors addObject:@{ @"MonsterId" : @(prize.monsterId), @"NumPuzzlePieces" : @(numPuzzlePieces) }];
          [monsterElements addObject:@(mp.monsterElement)];
        }
      }
      
      _lastSpinMonsterDescriptors = monsterDescriptors;
      
      // If it's immediate, it will just delete the loading view and start the spin
      TravelingLoadingView *tlv = [[NSBundle mainBundle] loadNibNamed:@"TravelingLoadingView" owner:self options:nil][0];
      NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
      {
        [paragraphStyle setLineSpacing:3];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [tlv.label setAttributedText:[[NSAttributedString alloc] initWithString:@"Loading\nAssets"
                                                                     attributes:@{NSParagraphStyleAttributeName : paragraphStyle}]];
        [tlv display:self.navigationController.view];
      }
      
      NSMutableArray* assetsToDownload = [NSMutableArray array];
      for (NSNumber* monsterElement in monsterElements) {
        const NSString* elementStr = [[Globals stringForElement:(Element)[monsterElement intValue]] lowercaseString];
        [assetsToDownload addObjectsFromArray:@[ [elementStr stringByAppendingString:@"grbackground.jpg"],
                                                 [elementStr stringByAppendingString:@"grbigflash1.png"],
                                                 [elementStr stringByAppendingString:@"grglow2glowblend.png"],
                                                 [elementStr stringByAppendingString:@"lightsflashlow1.png"] ]];
      }
      [Globals checkAndLoadFiles:assetsToDownload completion:^(BOOL success) {
        if (success) {
          [self.prizeView preloadWithMonsterIds:monsterIds];
          [self completeGachaSpinWithKnownPrizes:prizes isMultiSpin:prizes.count > 1];
        }
        [tlv stop];
      }];
    }
    else {
      [self completeGachaSpinWithKnownPrizes:prizes isMultiSpin:NO];
    }
    
    [[MiniEventManager sharedInstance] checkBoosterPack:self.boosterPack.boosterPackId];
  }
  else {
    _isSpinning = NO;
  }
  
  if (_lastSpinWasMultiSpin) {
    self.multiSpinSpinner.hidden = YES;
    self.multiSpinView.hidden = NO;
  }
  else {
    self.singleSpinSpinner.hidden = YES;
    self.singleSpinView.hidden = NO;
  }
}

- (void) completeGachaSpinWithKnownPrizes:(NSArray*)prizes isMultiSpin:(BOOL)multiSpin
{
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (multiSpin) {
    // TODO - TableView's animation needs to spin out of control, followed by a white flash
  } else {
    BoosterItemProto* prize = prizes[0];
    TimingFunctionTableView *table = self.gachaTable.tableView;
    CGPoint pt = table.contentOffset;
    pt = [self nearestCellMiddleFromPoint:ccp(pt.x, pt.y+6000) withBoosterItem:prize];
    float time = (rand() / (float)RAND_MAX) * 2.f + 6.f;
    [table setContentOffset:pt withTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.1f :0.8f :0.35f :1.f] duration:time];
  }
  
  const int32_t boosterPackGemPrice = multiSpin ? self.boosterPack.gemPrice * gl.boosterPackPurchaseAmountRequired : self.boosterPack.gemPrice;
  int32_t prizesGemReward = 0; for (BoosterItemProto* prize in prizes) prizesGemReward += prize.gemReward;
  int gemChange = prizesGemReward - boosterPackGemPrice;
  
  NSMutableArray* monsterList = nil;
  int itemId = 0, itemQuantity = 0;
  
  if (prizes.count > 1 || ((BoosterItemProto*)prizes[0]).monsterId) {
    monsterList = [NSMutableArray array];
    for (BoosterItemProto* prize in prizes) {
      if (prize.monsterId)
        [monsterList addObject:@{ @"monster_id" : @(prize.monsterId), @"piece" : @(!prize.isComplete) }];
    }
  }
  else if (((BoosterItemProto*)prizes[0]).itemId) {
    BoosterItemProto* prize = prizes[0];
    itemId = prize.itemId;
    itemQuantity = prize.itemQuantity;
  }
  
  [Analytics buyGacha:self.boosterPack.boosterPackId monsterList:monsterList itemId:itemId itemQuantity:itemQuantity highRoller:multiSpin gemChange:gemChange gemBalance:gs.gems];
  
  // Decrement cached daily spin count locally and update UI
  if ( _lastSpinWasFree )
    _cachedDailySpin = NO;
  
  [self updateFreeGachasCounter];
  
  [SoundEngine gachaSpinStart];
}

- (void) handlePurchaseBoosterPackResponseProto:(FullEvent *)fe {
  PurchaseBoosterPackResponseProto *proto = (PurchaseBoosterPackResponseProto *)fe.event;
  
  BOOL success = proto.status == PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusSuccess;
  NSArray* prizes = proto.prizeList;
  NSArray* monsters = proto.reward.updatedOrNewMonstersList;
  
  [self responseReceivedWithSuccess:success prizes:prizes monsters:monsters];
}

- (void) handleTradeItemForBoosterResponseProto:(FullEvent *)fe {
  TradeItemForBoosterResponseProto *proto = (TradeItemForBoosterResponseProto *)fe.event;
  
  BOOL success = proto.status == TradeItemForBoosterResponseProto_TradeItemForBoosterStatusSuccess;
  BoosterItemProto *prize = proto.prize;
  NSArray *monsters = proto.updatedOrNewList;
  
  [self responseReceivedWithSuccess:success prizes:@[ prize ] monsters:monsters];
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
    if (_lastSpinPrizes.count > 1 || ((BoosterItemProto*)_lastSpinPrizes[0]).monsterId) {
      [self displayWhiteFlash];
    } else if (((BoosterItemProto*)_lastSpinPrizes[0]).itemId) {
      [self displayItemPrizeView];
    } else {
      self.gachaTable.userInteractionEnabled = YES;
      _isSpinning = NO;
      
      [self.topBar updateLabels];
    }
    
    [SoundEngine stopRepeatingEffect];
    
    /*
    if (self.prize.monsterId) {
      [self displayWhiteFlash];
    } else {
      [self displayWhiteFlash];
      self.gachaTable.userInteractionEnabled = YES;
      _isSpinning = NO;
    }
     */
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
      [self.prizeView beginAnimation];
    }];
    
    self.gachaTable.userInteractionEnabled = YES;
    _isSpinning = NO;
  }];
  
  [SoundEngine gachaReveal];
}

- (void) displayPrizeView {
  UIView *parent = self.navigationController.view;
  self.prizeView.frame = parent.bounds;
  [parent addSubview:self.prizeView];
  
  /*
  if (self.prize.monsterId) {
    if (_numPuzzlePieces > 0) {
      [self.prizeView animateWithMonsterId:self.prize.monsterId numPuzzlePieces:_numPuzzlePieces];
    } else {
      [self.prizeView animateWithMonsterId:self.prize.monsterId];
    }
  } else {
    [self.prizeView animateWithGems:self.prize.gemReward];
  }
   */
  
  if (_lastSpinMonsterDescriptors) {
    [self.prizeView initializeWithMonsterDescriptors:_lastSpinMonsterDescriptors];
  }
}

- (void) displayItemPrizeView {
  BoosterItemProto* prize = _lastSpinPrizes[0];
  SecretGiftViewController *svc = [[SecretGiftViewController alloc] initWithBoosterItem:prize];
  svc.view.frame = self.navigationController.view.bounds;
  [self.navigationController.view addSubview:svc.view];
  [self.navigationController addChildViewController:svc];
  
  // Call this so that since nav controller blocks calls?
  [svc viewWillAppear:YES];
  
  self.gachaTable.userInteractionEnabled = YES;
  _isSpinning = NO;
}

- (void) easyTableView:(EasyTableView *)easyTableView scrolledToOffset:(CGPoint)contentOffset
{
  TimingFunctionTableView *table = self.gachaTable.tableView;
  if (_isSpinning || table.isTracking || table.dragging || table.decelerating)
    [_tickerController updateWithContentOffset:contentOffset.x];
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
                            description:[SkillProtoHelper offDescForSkill:skill]
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
