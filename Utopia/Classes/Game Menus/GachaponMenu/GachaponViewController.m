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

@implementation GachaponPrizeView

- (void) animateWithMonsterId:(int)monsterId {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *proto = [gs monsterWithId:monsterId];
  
  self.nameLabel.text = proto.displayName;
  self.nameLabel.textColor = [Globals colorForElement:proto.monsterElement];
  self.descriptionLabel.text = proto.description;
  
  self.rarityLabel.text = [Globals stringForRarity:proto.quality];
  self.rarityIcon.image = [Globals imageNamed:[Globals imageNameForRarity:proto.quality suffix:@"gtag.png"]];
  self.rarityIcon.frame = CGRectMake(self.rarityIcon.frame.origin.x, self.rarityIcon.frame.origin.y, self.rarityIcon.image.size.width, self.rarityIcon.frame.size.height);
  self.rarityLabel.frame = self.rarityIcon.frame;
  
  NSString *fileName = [proto.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamed:fileName withView:self.monsterIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.monsterIcon.contentMode = UIViewContentModeBottomLeft;
  
  self.pieceLabel.hidden = YES;
  self.rarityIcon.hidden = NO;
  self.rarityLabel.hidden = NO;
  
  [self doAnimation];
}

- (void) animateWithMonsterId:(int)monsterId numPuzzlePieces:(int)numPuzzlePieces {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *proto = [gs monsterWithId:monsterId];
  
  [self animateWithMonsterId:monsterId];
  self.pieceLabel.hidden = NO;
  self.pieceLabel.text = [NSString stringWithFormat:@"Pieces: %d/%d", numPuzzlePieces, proto.numPuzzlePieces];
}

- (void) animateWithGems:(int)numGems {
  Globals *gl = [Globals sharedGlobals];
  IAPHelper *iap = [IAPHelper sharedIAPHelper];
  InAppPurchasePackageProto *pkg = nil;
  
  for (InAppPurchasePackageProto *p in gl.iapPackages) {
    if (p.currencyAmount <= numGems && p.currencyAmount > pkg.currencyAmount) {
      pkg = p;
    }
  }
  
  self.pieceLabel.hidden = YES;
  self.rarityIcon.hidden = YES;
  self.rarityLabel.hidden = YES;
  
  SKProduct *prod = iap.products[pkg.iapPackageId];
  self.nameLabel.text = prod.localizedTitle;
  
  [Globals imageNamed:pkg.imageName withView:self.monsterIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.monsterIcon.contentMode = UIViewContentModeCenter;
  
  self.descriptionLabel.text = [NSString stringWithFormat:@"%@ gems", [Globals commafyNumber:numGems]];
  
  [self doAnimation];
}

- (void) doAnimation {
  self.infoView.center = ccp(self.frame.size.width+self.infoView.frame.size.width/2, self.frame.size.height/2);
  self.monsterSpinner.alpha = 0.f;
  self.pieceLabel.alpha = 0.f;
  
  CGPoint curPoint = self.monsterIcon.center;
  self.monsterIcon.center = ccp(self.frame.size.width/2, self.frame.size.height/2);
  [UIView animateWithDuration:0.3f delay:1.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.monsterIcon.center = curPoint;
    self.infoView.center = ccp(self.frame.size.width-self.infoView.frame.size.width/2, self.frame.size.height/2);
    self.monsterSpinner.alpha = 1.f;
    self.pieceLabel.alpha = 1.f;
  } completion:nil];
}

- (IBAction)closeClicked:(id)sender {
  [UIView animateWithDuration:0.2f animations:^{
    self.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
    self.alpha = 1.f;
  }];
}

@end

@implementation GachaponFeaturedView

- (void) awakeFromNib {
  self.monsterIcon.superview.transform = CGAffineTransformMakeScale(0.8, 0.8);
}

- (void) updateForMonsterId:(int)monsterId {
  if (!monsterId) {
    self.hidden = YES;
    return;
  } else {
    self.hidden = NO;
  }
  
  if (_curMonsterId == monsterId) {
    return;
  }
  
  _curMonsterId = monsterId;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  MonsterProto *proto = [gs monsterWithId:monsterId];
  
  self.nameLabel.text = proto.displayName;
  self.nameLabel.textColor = [Globals colorForElement:proto.monsterElement];
  
  self.rarityLabel.text = [Globals stringForRarity:proto.quality];
  self.rarityIcon.image = [Globals imageNamed:[Globals imageNameForRarity:proto.quality suffix:@"gtag.png"]];
  self.rarityIcon.frame = CGRectMake(self.rarityIcon.frame.origin.x, self.rarityIcon.frame.origin.y, self.rarityIcon.image.size.width, self.rarityIcon.frame.size.height);
  self.rarityLabel.frame = self.rarityIcon.frame;
  
  NSString *fileName = [proto.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamed:fileName withView:self.monsterIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:[Globals imageNameForElement:proto.monsterElement suffix:@"orb.png"] withView:self.elementIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  UserMonster *um = [[UserMonster alloc] init];
  um.monsterId = monsterId;
  um.level = proto.maxLevel;
  self.attackLabel.text = [Globals commafyNumber:[gl calculateTotalDamageForMonster:um]];
  self.hpLabel.text = [Globals commafyNumber:[gl calculateMaxHealthForMonster:um]];
}

@end

@implementation GachaponItemCell

- (void) awakeFromNib {
  self.icon.layer.anchorPoint = ccp(0.5, 0.75);
  self.icon.center = ccpAdd(self.icon.center, ccp(0, self.icon.frame.size.height*(self.icon.layer.anchorPoint.y-0.5)));
}

- (void) updateForGachaDisplayItem:(BoosterDisplayItemProto *)item {
  NSString *iconName = nil;
  if (item.isMonster) {
    NSString *bgdImage = [@"gacha" stringByAppendingString:[Globals imageNameForRarity:item.quality suffix:@"bg.png"]];
    [Globals imageNamed:bgdImage withView:self.bgdView greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    if (item.isComplete) {
      iconName = [Globals imageNameForRarity:item.quality suffix:@"capsule.png"];
      self.shadowIcon.hidden = NO;
    } else {
      iconName = [Globals imageNameForRarity:item.quality suffix:@"piece.png"];
      self.shadowIcon.hidden = YES;
    }
    self.label.text = [[Globals stringForRarity:item.quality] lowercaseString];
    
    self.diamondIcon.hidden = YES;
    self.icon.hidden = NO;
  } else {
    NSString *bgdImage = @"gachagemsbg.png";
    [Globals imageNamed:bgdImage withView:self.bgdView greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    self.label.text = [NSString stringWithFormat:@"%@ gems", [Globals commafyNumber:item.gemReward]];
    
    self.diamondIcon.hidden = NO;
    self.shadowIcon.hidden = YES;
    self.icon.hidden = YES;
  }
  [Globals imageNamed:iconName withView:self.icon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

- (void) shakeIconNumTimes:(int)numTimes durationPerShake:(float)duration delay:(float)delay completion:(void (^)(void))comp {
  CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
  // Divide by 2 to account for autoreversing
  int repeatCt = numTimes;
  [animation setDuration:duration];
  [animation setRepeatCount:repeatCt];
  [animation setBeginTime:CACurrentMediaTime()+delay];
  animation.values = [NSArray arrayWithObjects:   	// i.e., Rotation values for the 3 keyframes, in RADIANS
                      [NSNumber numberWithFloat:0.0 * M_PI],
                      [NSNumber numberWithFloat:0.04 * M_PI],
                      [NSNumber numberWithFloat:-0.04 * M_PI],
                      [NSNumber numberWithFloat:0.0 * M_PI], nil];
  animation.keyTimes = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat:0],
                        [NSNumber numberWithFloat:.25],
                        [NSNumber numberWithFloat:.75],
                        [NSNumber numberWithFloat:1.0], nil];
  animation.timingFunctions = [NSArray arrayWithObjects:
                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], nil];
  animation.removedOnCompletion = YES;
  animation.delegate = self;
  _completion = comp;
  [self.icon.layer addAnimation:animation forKey:@"rotation"];
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  if (_completion) {
    _completion();
  }
}

@end

@implementation GachaponViewController

#define NUM_COLS INT_MAX/700000
#define TABLE_CELL_WIDTH 65

- (id) initWithBoosterPack:(BoosterPackProto *)bpp {
  if ((self = [super init])) {
    self.boosterPack = bpp;
    [self setupItems];
  }
  return self;
}

- (void) setupItems {
  NSMutableArray *arr = [NSMutableArray array];
  for (BoosterDisplayItemProto *item in self.boosterPack.displayItemsList) {
    // Add it as many times as quantity
    // Multiply quantity to increase variability
    for (int i = 0; i < item.quantity*4; i++) {
      [arr addObject:item];
    }
  }
  [arr shuffle];
  self.items = arr;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  if (self.boosterPack.hasNavTitleImgName) {
    UIImageView *img = [[UIImageView alloc] initWithImage:[Globals imageNamed:self.boosterPack.navTitleImgName]];
    [self.topBar addSubview:img];
    img.center = self.topBarLabel.center;
    img.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.topBarLabel.hidden = YES;
  }
  self.title = self.boosterPack.boosterPackName;
  self.topBarLabel.text = self.title;
  
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  [self setupGachaTable];
  [self setupFeaturedViews];
  
  self.gemCostLabel.text = [Globals commafyNumber:self.boosterPack.gemPrice];
  self.prizeView.gemCostLabel.text = [Globals commafyNumber:self.boosterPack.gemPrice];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self.coinBar];
  
  [Globals imageNamed:self.boosterPack.machineImgName withView:self.machineIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

- (void) viewWillAppear:(BOOL)animated {
  if (self.boosterPack.hasNavBarImgName) {
    self.topBarBgd = [[UIImageView alloc] initWithImage:[Globals imageNamed:self.boosterPack.navBarImgName]];
    [self.navigationController.navigationBar insertSubview:self.topBarBgd atIndex:0];
    [(CustomNavBar *)self.navigationController.navigationBar setBgdView:self.topBarBgd];
    self.topBarBgd.alpha = 0.f;
    [UIView animateWithDuration:0.3f animations:^{
      self.topBarBgd.alpha = 1.f;
    }];
  }
}

- (void) viewWillDisappear:(BOOL)animated {
  CustomNavBar *nav = (CustomNavBar *)self.navigationController.navigationBar;
  [UIView animateWithDuration:0.3f animations:^{
    self.topBarBgd.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self.topBarBgd removeFromSuperview];
    [nav setBgdView:nil];
  }];
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
  
  int arrIndex = 0;
  GameState *gs = [GameState sharedGameState];
  for (int i = 0; i < self.items.count; i++) {
    BoosterDisplayItemProto *disp = self.items[i];
    if (disp.isMonster && bip.monsterId && disp.isComplete == bip.isComplete) {
      MonsterProto *mp = [gs monsterWithId:bip.monsterId];
      if (mp.quality == disp.quality) {
        arrIndex = i;
        break;
      }
    } else if (!disp.isMonster && bip.gemReward) {
      if (bip.gemReward == disp.gemReward) {
        arrIndex = i;
        break;
      }
    }
  }
  
  float nearest = ceilf(row/(float)self.items.count)*self.items.count+arrIndex+0.5;
  pt.y = nearest*TABLE_CELL_WIDTH-table.frame.size.width/2;
  return pt;
}

- (IBAction)spinClicked:(id)sender {
  TimingFunctionTableView *table = self.gachaTable.tableView;
  if (table.isTracking || _isSpinning) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  if (gs.gold < self.boosterPack.gemPrice) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] purchaseBoosterPack:self.boosterPack.boosterPackId delegate:self];
    [self.coinBar updateLabels];
    
    self.spinner.hidden = NO;
    self.spinView.hidden = YES;
    
    self.gachaTable.userInteractionEnabled = NO;
    _isSpinning = YES;
  }
}

- (void) handlePurchaseBoosterPackResponseProto:(FullEvent *)fe {
  PurchaseBoosterPackResponseProto *proto = (PurchaseBoosterPackResponseProto *)fe.event;
  
  if (proto.status == PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusSuccess) {
    TimingFunctionTableView *table = self.gachaTable.tableView;
    CGPoint pt = table.contentOffset;
    pt = [self nearestCellMiddleFromPoint:ccp(pt.x, pt.y+7000) withBoosterItem:proto.prize];
    [table setContentOffset:pt withTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0 :.51 :0 :.99] duration:10.f];
    
    self.prize = proto.prize;
    
    if (self.prize.monsterId) {
      GameState *gs = [GameState sharedGameState];
      MonsterProto *mp = [gs monsterWithId:self.prize.monsterId];
      NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Character.png"];
      [Globals imageNamed:fileName withView:nil greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
      
      if (!self.prize.isComplete) {
        if (proto.updatedOrNewList.count > 0) {
          _numPuzzlePieces = [(FullUserMonsterProto *)proto.updatedOrNewList[0] numPieces];
        } else {
          _numPuzzlePieces = 1;
        }
      }
    }
  }
  
  self.spinner.hidden = YES;
  self.spinView.hidden = NO;
}

#pragma mark - EasyTableView methods

- (void) setupGachaTable {
  self.gachaTable = [[EasyTableView alloc] initWithFrame:self.tableContainerView.bounds numberOfColumns:NUM_COLS ofWidth:TABLE_CELL_WIDTH];
  self.gachaTable.delegate = self;
  self.gachaTable.tableView.separatorColor = [UIColor clearColor];
  self.gachaTable.tableView.repeatSize = CGSizeMake(0, TABLE_CELL_WIDTH*self.items.count);
  self.gachaTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.tableContainerView addSubview:self.gachaTable];
  
  [self.gachaTable.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NUM_COLS/2 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (UIView *) easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect withIndexPath:(NSIndexPath *)indexPath {
  [[NSBundle mainBundle] loadNibNamed:@"GachaponItemCell" owner:self options:nil];
  self.itemCell.center = ccp(rect.size.width/2, rect.size.height/2);
  return self.itemCell;
}

- (void) easyTableView:(EasyTableView *)easyTableView setDataForView:(GachaponItemCell *)view forIndexPath:(NSIndexPath *)indexPath {
  int index = indexPath.row % self.items.count;
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
      UITableView* table = self.gachaTable.tableView;
      int row = (table.contentOffset.y+table.frame.size.width/2)/TABLE_CELL_WIDTH;
      GachaponItemCell *cell = (GachaponItemCell *)[self.gachaTable viewAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
      [cell shakeIconNumTimes:1 durationPerShake:0.2 delay:0.f completion:^{
        [cell shakeIconNumTimes:3 durationPerShake:0.15 delay:0.5f completion:^{
          [cell shakeIconNumTimes:8 durationPerShake:0.1 delay:0.5f completion:^{
            [self displayWhiteFlash];
          }];
        }];
      }];
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
    
    [self.coinBar updateLabels];
    
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

#pragma mark - Featured views methods

- (void) setupFeaturedViews {
  [[NSBundle mainBundle] loadNibNamed:@"GachaponFeaturedView" owner:self options:nil];
  self.leftFeaturedView = self.featuredView;
  [[NSBundle mainBundle] loadNibNamed:@"GachaponFeaturedView" owner:self options:nil];
  self.curFeaturedView = self.featuredView;
  [[NSBundle mainBundle] loadNibNamed:@"GachaponFeaturedView" owner:self options:nil];
  self.rightFeaturedView = self.featuredView;
  
  self.spotlightContainer.transform = CGAffineTransformMakeScale(0.8, 0.8);
  
  [self.featuredScrollView addSubview:self.leftFeaturedView];
  [self.featuredScrollView addSubview:self.curFeaturedView];
  [self.featuredScrollView addSubview:self.rightFeaturedView];
  
  [self updateFeaturedViews];
}

- (void) updateFeaturedViews {
  NSArray *specials = self.boosterPack.specialItemsList;
  BoosterItemProto *leftItem = _curPage-1 >= 0 && _curPage-1 < specials.count ? specials[_curPage-1] : nil;
  BoosterItemProto *curItem = _curPage >= 0 && _curPage < specials.count ? specials[_curPage] : nil;
  BoosterItemProto *rightItem = _curPage+1 >= 0 && _curPage+1 < specials.count ? specials[_curPage+1] : nil;
  
  [self.leftFeaturedView updateForMonsterId:leftItem.monsterId];
  [self.curFeaturedView updateForMonsterId:curItem.monsterId];
  [self.rightFeaturedView updateForMonsterId:rightItem.monsterId];
  
  self.leftFeaturedView.center = ccp(self.featuredScrollView.frame.size.width/2*(2*_curPage-1), self.featuredScrollView.frame.size.height/2);
  self.curFeaturedView.center = ccp(self.featuredScrollView.frame.size.width/2*(2*_curPage+1), self.featuredScrollView.frame.size.height/2);
  self.rightFeaturedView.center = ccp(self.featuredScrollView.frame.size.width/2*(2*_curPage+3), self.featuredScrollView.frame.size.height/2);
  
  self.featuredScrollView.contentSize = CGSizeMake(self.featuredScrollView.frame.size.width*self.boosterPack.specialItemsList.count, self.featuredScrollView.frame.size.height);
}

- (IBAction)rightArrowClicked:(id)sender {
  NSArray *specials = self.boosterPack.specialItemsList;
  if (_curPage+1 < specials.count) {
    CGPoint co = ccp(self.featuredScrollView.frame.size.width*(_curPage+1), 0);
    [self.featuredScrollView setContentOffset:co animated:YES];
  }
}

- (IBAction)leftArrowClicked:(id)sender {
  if (_curPage-1 >= 0) {
    CGPoint co = ccp(self.featuredScrollView.frame.size.width*(_curPage-1), 0);
    [self.featuredScrollView setContentOffset:co animated:YES];
  }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat pageWidth = scrollView.frame.size.width;
  float fractionalPage = scrollView.contentOffset.x / pageWidth;
  int oldPage = _curPage;
  _curPage = lround(fractionalPage);
  if (oldPage < _curPage) {
    // Moved right
    GachaponFeaturedView *oldLeft = self.leftFeaturedView;
    self.leftFeaturedView = self.curFeaturedView;
    self.curFeaturedView = self.rightFeaturedView;
    self.rightFeaturedView = oldLeft;
    
    [self updateFeaturedViews];
  } else if (oldPage > _curPage) {
    // Moved left
    GachaponFeaturedView *oldRight = self.rightFeaturedView;
    self.rightFeaturedView = self.curFeaturedView;
    self.curFeaturedView = self.leftFeaturedView;
    self.leftFeaturedView = oldRight;
    
    [self updateFeaturedViews];
  }
}

@end
