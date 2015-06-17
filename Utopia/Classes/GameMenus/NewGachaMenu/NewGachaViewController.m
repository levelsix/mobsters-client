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
#define TABLE_CELL_WIDTH ([Globals isiPad] ? 95 : 57)

- (id) initWithBoosterPack:(BoosterPackProto *)bpp {
  if ((self = [super init])) {
    self.boosterPack = bpp;
  }
  return self;
}

- (void) setupItems {
  self.items = self.boosterPack.displayItemsList;
  
  self.gachaTable.tableView.repeatSize = CGSizeMake(0, TABLE_CELL_WIDTH*self.items.count);
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  GameState *gs = [GameState sharedGameState];
  _cachedDailySpin = [gs hasDailyFreeSpin];
  
  [self setUpCloseButton:[Globals isiPad]]; // Place the close button on the right on iPad
  
  [[NSNotificationCenter defaultCenter] removeObserver:self.topBar];
  
  [self.navBar button:3 shouldBeHidden:YES];
  
  [self.skillPopup setHidden:YES];
  [self.view addSubview:self.skillPopup];
  
  self.itemSelectFooterView.layer.cornerRadius = POPUP_CORNER_RADIUS;
  
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
  
  self.singleSpinGemCostLabel.width += 10.f;
  self.singleSpinGemCostLabel.height = self.singleSpinActionLabel.height;
  self.multiSpinGemCostLabel.width += 10.f;
  self.multiSpinGemCostLabel.height = self.multiSpinActionLabel.height;
  
  [self updateMultiSpinButton];
  
  THLabel* itemSelectPackagesLabel = (THLabel*)self.itemSelectPackagesLabel;
  {
    itemSelectPackagesLabel.gradientStartColor = [UIColor whiteColor];
    itemSelectPackagesLabel.gradientEndColor = [UIColor colorWithHexString:@"DEFFC2"];
    itemSelectPackagesLabel.strokeSize = 1.f;
    itemSelectPackagesLabel.shadowBlur = .5f;
  }
  
  [Globals alignSubviewsToPixelsBoundaries:self.machineImage.superview];
  
  if (self.boosterPack.boosterPackId == self.badBoosterPack.boosterPackId) {
    [self button1Clicked:nil];
  } else {
    [self button2Clicked:nil];
  }
  
  [[GameViewController baseController] clearTutorialArrows];
}

- (void) viewWillLayoutSubviews {
  self.topBar.tokensView.centerX = [self.singleSpinContainer convertPoint:self.singleSpinButton.center toView:self.topBar].x;
  if ([Globals isSmallestiPhone]) self.topBar.tokensView.centerX += 13.f;
  
  CGFloat leftAnchor = 0.f;
  if (![Globals isiPad]) {
    CGRect closeButtonFrame = [(UIView*)[self.navigationItem.leftBarButtonItem valueForKey:@"view"] frame]; // Magical way of getting the frame of a UIBarButtonItem
    leftAnchor = CGRectGetMaxX(closeButtonFrame);
  }
  self.topBar.gemsView.centerX = (leftAnchor + self.navBar.originX) * .5f;
  if ([Globals isSmallestiPhone]) self.topBar.gemsView.hidden = YES;
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [SoundEngine stopRepeatingEffect];
  
  self.focusScrollView.delegate = nil;
  
  if (self.itemSelectViewController)
    [self.itemSelectViewController closeClicked:self];
  
  [_tickerController performCleanUp];
  _tickerController = nil;
}

- (void) layoutViews {
  const CGFloat navBarHeight = self.topBar.height;
  CGFloat deviceScale = [Globals screenSize].width / 667.f;
  if ([Globals isiPad]) deviceScale *= 1.2f;
  
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
  
  if ([Globals isiPad])
  {
    self.gachaBgTopLeft.layer.transform = CATransform3DMakeScale(1.f, -1.f, 1.f);
    self.logoSeparatorImage.hidden = YES;
  }
  else
  {
    featuredContainer.height = CGRectGetMaxY(featuredContainer.frame) - navBarHeight;
    featuredContainer.originY = navBarHeight;
  }
  
  if ([Globals isSmallestiPhone])
  {
    self.logoImage.hidden = YES;
    self.logoSeparatorImage.hidden = YES;
    
    CGFloat moveBy = featuredContainer.originX;
    featuredContainer.originX -= moveBy;
    featuredContainer.width += moveBy + 50.f;
    featuredContainer.originY -= 15.f;
    featuredContainer.height += 15.f;
    
    self.machineImage.superview.originX -= 15.f;
  }
  else if (![Globals isiPad])
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

- (void) updateMultiSpinButton {
  _isMultiSpinAvailable = [[GameState sharedGameState].itemUtil getItemsForType:ItemTypeGachaMultiSpin].count > 0;

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
  
  [Globals imageNamed:@"grabchip.png" withView:self.multiSpinGemCostIcon greyscale:!_isMultiSpinAvailable indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];
  
  if (_isMultiSpinAvailable) {
    [self.multiSpinButton setImage:[Globals imageNamed:@"bigspingold.png"] forState:UIControlStateNormal];
    [self.multiSpinButton setImage:[Globals imageNamed:@"bigspingoldpressed.png"] forState:UIControlStateHighlighted];
    
    self.multiSpinTapToUnlockLabel.hidden = YES;
    
    self.multiSpinActionLabel.font = [UIFont fontWithName:self.multiSpinActionLabel.font.fontName size:[Globals isiPad] ? 18.f : 11.f];
    self.multiSpinActionLabel.centerY = self.multiSpinView.height * .5f - 3;
    
    self.multiSpinView.originX = [Globals isiPad] ? 2 : 6;
    self.multiSpinGemCostView.centerY = self.multiSpinActionLabel.centerY - 3;
    
    const CGPoint gemCostIconCenter = self.multiSpinGemCostIcon.center;
    self.multiSpinGemCostIcon.size = [Globals isiPad] ? CGSizeMake(38, 38) : CGSizeMake(20, 20);
    self.multiSpinGemCostIcon.centerX = gemCostIconCenter.x;
    
    self.multiSpinGemCostLabel.font = [UIFont fontWithName:self.multiSpinGemCostLabel.font.fontName size:[Globals isiPad] ? 18.f : 11.f];
    self.multiSpinGemCostLabel.originY = 4;
  } else {
    self.multiSpinGemCostView.centerY = self.multiSpinActionLabel.centerY - ([Globals isiPad] ? 8 : 4);
    self.multiSpinTapToUnlockLabel.originY = [Globals isiPad] ? 0 : -1;
    self.multiSpinActionLabel.originY = self.multiSpinView.height - self.multiSpinActionLabel.height - ([Globals isiPad] ? 8 : 4);
    self.multiSpinGemCostLabel.originY = [Globals isiPad] ? 3 : 2;
    
    if ([Globals isiPad]) { self.multiSpinView.originX -= 5; self.multiSpinTapToUnlockLabel.originX += 5; }
  }
  
  self.multiSpinGemCostView.originX = (self.multiSpinView.centerX - self.multiSpinView.originX) + 8;
  self.multiSpinGemCostLabel.originX = CGRectGetMaxX(self.multiSpinGemCostIcon.frame) + 1;
  self.multiSpinGemCostIcon.centerY = self.multiSpinGemCostLabel.centerY;
}

- (void) loadBoosterPacks {
  GameState *gs = [GameState sharedGameState];
  self.badBoosterPack = gs.boosterPacks[0];
  self.goodBoosterPack = gs.boosterPacks[1];
  
  self.navBar.label1.text = [self.badBoosterPack.boosterPackName uppercaseString];
  self.navBar.label2.text = [self.goodBoosterPack.boosterPackName uppercaseString];
  
  NSString* desc = @"Packages contain tons of tokens at huge discounts!";
  {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4.f;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:desc];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, desc.length)];
    self.itemSelectDescriptionLabel.attributedText = attributedString;
  }
  self.itemSelectTitleLabel.text = @"GET MORE TOKENS!";
}

- (void) updateForBoosterPack:(BoosterPackProto *)bpp {
  self.boosterPack = bpp;
  [self setupItems];
  [self.gachaTable reloadData];
  [self.focusScrollView reloadData];
  
  [_tickerController resetState];
  
  self.title = self.boosterPack.boosterPackName;
  
  self.singleSpinGemCostLabel.text = [NSString stringWithFormat:@" %d ", self.boosterPack.gachaCreditsPrice];
  self.multiSpinGemCostLabel.text  = [NSString stringWithFormat:@" %d ", self.boosterPack.gachaCreditsPrice * [Globals sharedGlobals].boosterPackPurchaseAmountRequired];
  
  [self.gachaTable.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NUM_COLS/2 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
  
  [Globals imageNamed:bpp.machineImgName withView:self.machineImage greyscale:NO
            indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  [Globals imageNamed:bpp.navBarImgName withView:self.logoImage greyscale:NO
            indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  CGFloat deviceScale = MIN([Globals screenSize].height / 375.f, 1.1f); // These images are designed for iPhone 6
  if (![Globals isiPad])
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
    self.singleSpinContainer.centerY = self.multiSpinContainer.centerY - ([Globals isiPad] ? -4 : 12);
  } else {
    self.multiSpinContainer.hidden = NO;
    self.singleSpinContainer.centerY = self.multiSpinContainer.centerY - ([Globals isiPad] ? 77 : 41);
  }
  
  [self updateSingleSpinButton];
  
//[Globals alignSubviewsToPixelsBoundaries:self.machineImage.superview];
}

- (void) updateSingleSpinButton
{
  const BOOL regularGrab = (self.boosterPack.boosterPackId == self.badBoosterPack.boosterPackId);
  
  const CGPoint spinButtonCenter = self.singleSpinButton.center;
  [self.singleSpinButton setImage:[Globals imageNamed:regularGrab ? @"bigspinpurple.png" : @"smallspinpurple.png"] forState:UIControlStateNormal];
  [self.singleSpinButton setImage:[Globals imageNamed:regularGrab ? @"bigspinpurplepressed.png" : @"smallspinpurplepressed.png"] forState:UIControlStateHighlighted];
  self.singleSpinButton.size = self.singleSpinButton.imageView.image.size;
  self.singleSpinButton.center = spinButtonCenter;
  
  const CGSize newSize = self.singleSpinButton.imageView.image.size;
  const CGFloat widthRatio = newSize.width / self.singleSpinButton.width;
  const CGFloat heightRatio = newSize.height / self.singleSpinButton.height;
  self.singleSpinView.size = CGSizeMake(self.singleSpinView.width * widthRatio, self.singleSpinView.height * heightRatio);
  self.singleSpinView.centerY = self.singleSpinButton.centerY;
  
  self.singleSpinGemCostView.originX = (self.singleSpinView.centerX - self.singleSpinView.originX) + (regularGrab ? 6 : 3);
  self.singleSpinGemCostView.originY = (self.singleSpinView.height - self.singleSpinGemCostView.height) * .5f - 4;
  
  const CGFloat labelFontSize = [Globals isiPad] ? (regularGrab ? 20.f : 15.f) : (regularGrab ? 11.f : 9.f);
  const CGSize iconSize = [Globals isiPad] ? (regularGrab ? CGSizeMake(32, 32) : CGSizeMake(25, 25)) : (regularGrab ? CGSizeMake(20, 20) : CGSizeMake(14, 14));
  
  self.singleSpinActionLabel.font = [UIFont fontWithName:self.singleSpinActionLabel.font.fontName size:labelFontSize];
  self.singleSpinActionLabel.height = floorf(self.singleSpinActionLabel.height * (self.singleSpinButton.width / self.singleSpinActionLabel.width));
  self.singleSpinActionLabel.width = self.singleSpinButton.width;
  self.singleSpinActionLabel.centerX = self.singleSpinActionLabel.superview.width * .5f;
  self.singleSpinActionLabel.centerY = [self.singleSpinButton.superview convertPoint:self.singleSpinButton.center
                                                                              toView:self.singleSpinActionLabel.superview].y - ([Globals isiPad] ? 5 : 3);
  
  const CGPoint gemCostIconCenter = self.singleSpinGemCostIcon.center;
  self.singleSpinGemCostIcon.size = iconSize;
  self.singleSpinGemCostIcon.center = CGPointMake(gemCostIconCenter.x, self.singleSpinActionLabel.centerY + 1);
  
  self.singleSpinGemCostLabel.font = [UIFont fontWithName:self.singleSpinGemCostLabel.font.fontName size:labelFontSize];
  self.singleSpinGemCostLabel.width = floorf(self.singleSpinGemCostLabel.width * (self.singleSpinActionLabel.height / self.singleSpinGemCostLabel.height));
  self.singleSpinGemCostLabel.height = self.singleSpinActionLabel.height;
  self.singleSpinGemCostLabel.centerY = self.singleSpinActionLabel.centerY + 1;
  self.singleSpinGemCostLabel.originX = CGRectGetMaxX(self.singleSpinGemCostIcon.frame) + 1;
}

- (void) updateFreeGachasCounter
{
  BOOL firstPageSelected = (self.boosterPack == self.badBoosterPack);
  
  GameState *gs = [GameState sharedGameState];
  int numFreeSpins = [gs numberOfFreeSpinsForBoosterPack:self.boosterPack.boosterPackId];
  
  if (_cachedDailySpin && firstPageSelected)
  {
    self.singleSpinView.centerX = self.singleSpinButton.centerX;
    self.singleSpinGemCostView.hidden = YES;
    self.singleSpinActionLabel.textAlignment = NSTextAlignmentCenter;
    self.singleSpinActionLabel.text = @" DAILY SPIN! ";
  }
  else if (numFreeSpins)
  {
    self.singleSpinView.centerX = self.singleSpinButton.centerX;
    self.singleSpinGemCostView.hidden = YES;
    self.singleSpinActionLabel.textAlignment = NSTextAlignmentCenter;
    self.singleSpinActionLabel.text = [NSString stringWithFormat:@" %d FREE SPIN%@! ", numFreeSpins, numFreeSpins > 1 ? @"S" : @""];
  }
  else
  {
    self.singleSpinGemCostView.hidden = NO;
    self.singleSpinView.centerX = self.singleSpinButton.centerX - 4;
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
  GameState *gs = [GameState sharedGameState];
  
  UITableView *table = self.gachaTable.tableView;
  int row = (pt.y+table.frame.size.width/2)/TABLE_CELL_WIDTH;
  int rowIdx = row % self.items.count;
  
  int arrIndex = 0;
  for (int i = 0; i < self.items.count; i++) {
    int j = (rowIdx+i) % self.items.count;
    BoosterDisplayItemProto *disp = self.items[j];
    if (bip.reward.typ == disp.reward.typ) {
      if (disp.reward.typ == RewardProto_RewardTypeMonster) {
        MonsterProto *mp1 = [gs monsterWithId:bip.reward.staticDataId];
        MonsterProto *mp2 = [gs monsterWithId:disp.reward.staticDataId];
        if (mp1 && mp2 && mp1.quality == mp2.quality) {
          arrIndex = j;
          break;
        }
      } else {
        if (bip.reward.staticDataId == disp.reward.staticDataId && bip.reward.amt == disp.reward.amt) {
          arrIndex = j;
          break;
        }
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
  const int32_t boosterPackPrice = self.boosterPack.gachaCreditsPrice;
  
  // Sender is nil when invoked right after purchasing tokens,
  // in which case enough resources are known to be available
  if (sender == self.singleSpinButton && gs.tokens < boosterPackPrice && !isDailySpin && !numFreeSpins) {
    [self showItemSelect:self.singleSpinButton];
  } else {
    _lastSpinWasFree = isDailySpin;
    _lastSpinWasMultiSpin = NO;
    
    if (sender == self.singleSpinButton)
    {
      _lastSpinPurchaseGemsSpent = 0;
      _lastSpinPurchaseTokensChange = -boosterPackPrice;
    }
    
    // Prioritize daily spin
    if (isDailySpin || !numFreeSpins) {
      [[OutgoingEventController sharedOutgoingEventController] purchaseBoosterPack:self.boosterPack.boosterPackId
                                                                            isFree:isDailySpin
                                                                       isMultiSpin:NO
                                                                         gemsSpent:_lastSpinPurchaseGemsSpent
                                                                      tokensChange:_lastSpinPurchaseTokensChange
                                                                          delegate:self];
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
  TimingFunctionTableView *table = self.gachaTable.tableView;
  if (table.isTracking || _isSpinning) {
    return;
  }
  
  if (_isMultiSpinAvailable) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    const int32_t boosterPackPrice = self.boosterPack.gachaCreditsPrice * gl.boosterPackPurchaseAmountRequired;
    
    // Sender is nil when invoked right after purchasing tokens,
    // in which case enough resources are known to be available
    if (sender == self.multiSpinButton && gs.tokens < boosterPackPrice) {
      [self showItemSelect:self.multiSpinButton];
    } else {
      _lastSpinWasFree = NO;
      _lastSpinWasMultiSpin = YES;
      
      if (sender == self.multiSpinButton)
      {
        _lastSpinPurchaseGemsSpent = 0;
        _lastSpinPurchaseTokensChange = -boosterPackPrice;
      }
      
      [[OutgoingEventController sharedOutgoingEventController] purchaseBoosterPack:self.boosterPack.boosterPackId
                                                                            isFree:NO
                                                                       isMultiSpin:YES
                                                                         gemsSpent:_lastSpinPurchaseGemsSpent
                                                                      tokensChange:_lastSpinPurchaseTokensChange
                                                                          delegate:self];
      
      [self.topBar updateLabels];
      
      self.multiSpinSpinner.hidden = NO;
      self.multiSpinView.hidden = YES;
      
      self.gachaTable.userInteractionEnabled = NO;
      _isSpinning = YES;
    }
  }
  else {
    // Display a popup that will give players the option to purchase and unlock High Roller mode
    PurchaseHighRollerModeViewController *phrmvc = [[PurchaseHighRollerModeViewController alloc] init];
    [phrmvc setDelegate:self];
    [self.navigationController addChildViewController:phrmvc];
    [phrmvc.view setFrame:self.view.bounds];
    [self.navigationController.view addSubview:phrmvc.view];
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
    if (prizes.count > 1 || ((BoosterItemProto*)prizes[0]).reward.typ == RewardProto_RewardTypeMonster) {
      NSMutableArray* monsterIds = [NSMutableArray array];
      NSMutableArray* monsterDescriptors = [NSMutableArray array];
      NSMutableSet*   monsterElements = [NSMutableSet set];
      
      for (int i = 0; i < prizes.count; ++i) {
        BoosterItemProto* prize = prizes[i];
        if (prize.reward.typ == RewardProto_RewardTypeMonster) {
          const int32_t prizeMonsterId = prize.reward.staticDataId;
          MonsterProto *mp = [gs monsterWithId:prizeMonsterId];
          if (mp) {
            NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Character.png"];
            [Globals imageNamedWithiPhone6Prefix:fileName withView:nil greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
            
            // In the new RewardProto system, we only give away either full monsters or a single piece in each spin
            int numPuzzlePieces = 0;
            if (prize.reward.amt == 0) { // Only one piece is given
              // Find any puzzle pieces awarded for this monster that have not yet been accounted for
              int numUnaccountedPiecesForMonster = 0;
              for (int j = i; j < prizes.count; ++j) {
                BoosterItemProto* p = prizes[j];
                if (p.reward.typ == RewardProto_RewardTypeMonster && p.reward.staticDataId == prizeMonsterId)
                  numUnaccountedPiecesForMonster += (p.reward.amt == 0) ? 1 : mp.numPuzzlePieces;
              }
              
              // Get the total number of pieces for monsters with this ID
              int numTotalPiecesForMonster = 0;
              for (FullUserMonsterProto* monster in monsters) {
                if (monster.monsterId == prizeMonsterId)
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

            [monsterIds addObject:@(prizeMonsterId)];
            [monsterDescriptors addObject:@{ @"MonsterId" : @(prizeMonsterId), @"NumPuzzlePieces" : @(numPuzzlePieces) }];
            [monsterElements addObject:@(mp.monsterElement)];
          }
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
      NSMutableArray* deviceSpecificAssetsToDownload = [NSMutableArray array];
      for (NSNumber* monsterElement in monsterElements) {
        const NSString* elementStr = [[Globals stringForElement:(Element)[monsterElement intValue]] lowercaseString];
        [deviceSpecificAssetsToDownload addObject:[elementStr stringByAppendingString:@"grbackground.jpg"]];
        [assetsToDownload addObjectsFromArray:@[  [elementStr stringByAppendingString:@"grbigflash1.png"],
                                                  [elementStr stringByAppendingString:@"grglow2glowblend.png"],
                                                  [elementStr stringByAppendingString:@"lightsflashlow1.png"] ]];
      }
      
      [Globals checkAndLoadFiles:deviceSpecificAssetsToDownload useiPhone6Prefix:NO useiPadSuffix:YES completion:^(BOOL success) {
        [Globals checkAndLoadFiles:assetsToDownload useiPhone6Prefix:NO useiPadSuffix:NO completion:^(BOOL success) {
          [self.prizeView preloadWithMonsterIds:monsterIds];
          [self completeGachaSpinWithKnownPrizes:prizes isMultiSpin:prizes.count > 1];
          
          [tlv stop];
        }];
      }];
    }
    else {
      [self completeGachaSpinWithKnownPrizes:prizes isMultiSpin:NO];
    }
    
    [[MiniEventManager sharedInstance] checkBoosterPack:self.boosterPack.boosterPackId multiSpin:prizes.count > 1];
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
  
  if (multiSpin) {
    TimingFunctionTableView *table = self.gachaTable.tableView;
    CGPoint pt = table.contentOffset;
    pt = [self nearestCellMiddleFromPoint:ccp(pt.x, pt.y+6000)];
    [table setContentOffset:pt withTimingFunction:[CAMediaTimingFunction functionWithControlPoints:1.f :1.f :.3f :1.f] duration:4.5f];
    
    [self performSelector:@selector(endScrollingAndDisplayPrize) withObject:nil afterDelay:3.f];
  } else {
    BoosterItemProto* prize = prizes[0];
    TimingFunctionTableView *table = self.gachaTable.tableView;
    CGPoint pt = table.contentOffset;
    pt = [self nearestCellMiddleFromPoint:ccp(pt.x, pt.y+6000) withBoosterItem:prize];
    float time = (rand() / (float)RAND_MAX) * 2.f + 6.f;
    [table setContentOffset:pt withTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.1f :0.8f :0.35f :1.f] duration:time];
  }
  
  int32_t prizesGemReward = 0, prizesTokenReward = 0;
  for (BoosterItemProto* prize in prizes) {
    if (prize.reward.typ == RewardProto_RewardTypeGems)
      prizesGemReward += prize.reward.amt;
    else if (prize.reward.typ == RewardProto_RewardTypeGachaCredits)
      prizesTokenReward += prize.reward.amt;
  }
  const int gemChange = prizesGemReward - _lastSpinPurchaseGemsSpent;
  const int tokenChange = prizesTokenReward + _lastSpinPurchaseTokensChange;
  
  NSMutableArray* monsterList = nil;
  int itemId = 0, itemQuantity = 0;

  if (prizes.count > 1 || ((BoosterItemProto*)prizes[0]).reward.typ == RewardProto_RewardTypeMonster) {
    monsterList = [NSMutableArray array];
    for (BoosterItemProto* prize in prizes) {
      if (prize.reward.typ == RewardProto_RewardTypeMonster)
        [monsterList addObject:@{ @"monster_id" : @(prize.reward.staticDataId), @"piece" : @(prize.reward.amt == 0) }];
    }
  }
  else if (((BoosterItemProto*)prizes[0]).reward.typ == RewardProto_RewardTypeItem) {
    BoosterItemProto* prize = prizes[0];
    itemId = prize.reward.staticDataId;
    itemQuantity = prize.reward.amt;
  }
  
  [Analytics buyGacha:self.boosterPack.boosterPackId monsterList:monsterList itemId:itemId itemQuantity:itemQuantity highRoller:multiSpin
            gemChange:gemChange gemBalance:gs.gems tokenChange:tokenChange tokenBalance:gs.tokens];
  
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

- (IBAction) menuCloseClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  if (!_isSpinning || gs.isAdmin) {
    [self viewWillDisappear:YES];
    [super menuCloseClicked:sender];
  }
}

- (IBAction) menuBackClicked:(id)sender {
  if (!_isSpinning) {
    [self viewWillDisappear:YES];
    [super menuBackClicked:sender];
  }
}

#pragma mark - PurchaseHighRollerModeCallbackDelegate

- (void) toPackagesTapped:(BOOL)prioritizeHighRoller {
  if (!_isSpinning) {
    [self viewWillDisappear:YES];
    
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
      GameViewController *gvc = [GameViewController baseController];
      Globals *gl = [Globals sharedGlobals];
      if (prioritizeHighRoller) {
        SalesPackageProto *spp = [gl highRollerModeSale];
        [gvc.topBarViewController openShopWithFunds:spp];
      } else {
        [gvc.topBarViewController openShopWithFunds:nil];
      }
    }];
  }
}

- (void) highRollerModePurchased {
  [self updateMultiSpinButton];
  [self updateFreeGachasCounter];
}

#pragma mark - GrabTokenItemsFillerDelegate

- (IBAction) showItemSelect:(id)sender
{
  if (!_isSpinning) {
    ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
    if (svc)
    {
      int requiredAmount = 0;
      if (sender == self.singleSpinButton)
        requiredAmount = self.boosterPack.gachaCreditsPrice;
      else if (sender == self.multiSpinButton)
        requiredAmount = self.boosterPack.gachaCreditsPrice * [Globals sharedGlobals].boosterPackPurchaseAmountRequired;
      
      GrabTokenItemsFiller *itemsFiller = [[GrabTokenItemsFiller alloc] initWithRequiredAmount:requiredAmount];
      itemsFiller.delegate = self;
      svc.delegate = itemsFiller;
      svc.footerView = self.itemSelectFooterView;
      self.itemSelectViewController = svc;
      self.grabTokenItemsFiller = itemsFiller;
      
      [self.navigationController addChildViewController:svc];
      [svc.view setFrame:self.view.bounds];
      [self.navigationController.view addSubview:svc.view];
      
      [svc viewWillAppear:YES];
      
      if (sender && [sender isKindOfClass:[UIButton class]])
      {
        self.buttonInvokingItemSelect = sender;
        if (sender == self.addTokensButton)
        {
          [svc showAnchoredToInvokingView:self.addTokensButton withDirection:ViewAnchoringPreferBottomPlacement inkovingViewImage:[self.addTokensButton imageForState:UIControlStateNormal]];
        }
        else
        {
          UIButton* invokingButton = (UIButton*)sender;
          [svc showAnchoredToInvokingView:invokingButton withDirection:ViewAnchoringPreferLeftPlacement inkovingViewImage:invokingButton.currentImage];
        }
      }
      else
      {
        self.buttonInvokingItemSelect = nil;
        [svc showCenteredOnScreen];
      }
    }
  }
}

- (void) resourceItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController*)viewController
{
  // Buy a fixed number of tokens with gems. Invoked by the add tokens button
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if ([itemObject isKindOfClass:[UserItem class]])
  {
    UserItem *ui = (UserItem *)itemObject;
    ItemProto *ip = [gs itemForId:ui.itemId];
    if (ip.itemType == ItemTypeItemGachaCredit)
    {
      const int tokens = ip.amount;
      const int gemCost = [gl calculateGemConversionForResourceType:ResourceTypeGachaCredits amount:tokens];
      if (gemCost > gs.gems)
        [GenericPopupController displayNotEnoughGemsView];
      else
        [[OutgoingEventController sharedOutgoingEventController] exchangeGemsForResources:gemCost resources:tokens percFill:0 resType:ResourceTypeGachaCredits delegate:nil];
      
      [viewController reloadDataAnimated:YES];
      
      [self.topBar updateLabels];
    }
  }
}

- (void) resourceItemsUsed:(NSDictionary*)itemUsages
{
  // Buy missing tokens with gems. Invoked by either of the spin buttons
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  const BOOL allowGems = [itemUsages[@0] boolValue];
  const int spinTokenCost = self.grabTokenItemsFiller.requiredAmount;
  const int curTokens = [gl calculateTotalResourcesForResourceType:ResourceTypeGachaCredits itemIdsToQuantity:itemUsages];
  
  int gemCost = 0;
  for (NSNumber *num in itemUsages) {
    int itemId = num.intValue;
    int numUsed = [itemUsages[num] intValue];
    if (itemId > 0) {
      ItemProto *ip = [gs itemForId:itemId];
      if (ip.itemType == ItemTypeItemGachaCredit) {
        gemCost += [gl calculateGemConversionForResourceType:ResourceTypeGachaCredits amount:ip.amount] * numUsed;
      }
    }
  }
  
  if (allowGems)
    gemCost += [gl calculateGemConversionForResourceType:ResourceTypeGachaCredits amount:spinTokenCost - curTokens];
  
  if (gemCost > gs.gems)
    [GenericPopupController displayNotEnoughGemsView];
  else
  {
    _lastSpinPurchaseGemsSpent = gemCost;
    _lastSpinPurchaseTokensChange = allowGems ? -gs.tokens : (curTokens - spinTokenCost) - gs.tokens;
    
    if (self.buttonInvokingItemSelect == self.singleSpinButton)
      [self singleSpinClicked:nil];
    else
      [self multiSpinClicked:nil];
  }
  
  [self.topBar updateLabels];
}

- (void) itemSelectClosed:(id)viewController
{
  self.itemSelectViewController = nil;
  self.grabTokenItemsFiller = nil;
}

- (IBAction) itemSelectToPackagesClicked:(id)sender
{
  [self toPackagesTapped:NO];
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
  if (!_lastSpinWasMultiSpin) {
    [self endScrollingAndDisplayPrize];
  }
}

- (void) endScrollingAndDisplayPrize {
  if (_isSpinning) {
    if (_lastSpinPrizes.count > 1 || ((BoosterItemProto*)_lastSpinPrizes[0]).reward.typ == RewardProto_RewardTypeMonster) {
      [self displayWhiteFlash];
    } else if (((BoosterItemProto*)_lastSpinPrizes[0]).reward.typ == RewardProto_RewardTypeItem) {
      [self displayItemPrizeView];
    } else {
      self.gachaTable.userInteractionEnabled = YES;
      _isSpinning = NO;
      
      [self.topBar updateLabels];
    }
    
    [SoundEngine stopRepeatingEffect];
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
  const int32_t monsterId = item.reward.staticDataId;
  [view updateForMonsterId:monsterId];
  return view;
}

- (CGFloat) scaleForOutOfFocusView {
  return 0.5f;
}

- (CGFloat) fadeOutSpeedForOutOfFocusView {
  return [Globals isiPad] ? 1.3f : 1.f;
}

- (BOOL) shouldLoopItems {
  return YES;
}

#pragma mark - Featured View

- (void) skillTapped:(SkillProto*)skill offensive:(BOOL)offensive element:(Element)element position:(CGPoint)pos
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
                            description:offensive ? [SkillProtoHelper offDescForSkill:skill] : [SkillProtoHelper defDescForSkill:skill]
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
