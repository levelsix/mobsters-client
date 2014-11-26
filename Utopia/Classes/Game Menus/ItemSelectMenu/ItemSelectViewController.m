//
//  ItemSelectViewController.m
//  Utopia
//
//  Created by Ashwin on 11/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ItemSelectViewController.h"

#import "GameState.h"
#import "Globals.h"

#import "SocketCommunication.h"

@implementation ItemSelectCell

- (void) awakeFromNib {
  [super awakeFromNib];
  
  self.gemsButtonView.frame = self.useButtonView.frame;
  
  self.iconLabel.strokeSize = 2.1f;
  self.iconLabel.strokeColor = [UIColor colorWithWhite:236/255.f alpha:1.f];
  
  _origIconLabelColor = self.iconLabel.textColor;
}

- (void) updateForItemObject:(id<ItemObject>)itemObject {
  BOOL available = [itemObject isValid];
  
  self.nameLabel.text = [itemObject name];
  self.nameLabel.highlighted = !available;
  
  NSString *str1 = @"Owned: ";
  NSString *str2 = [Globals commafyNumber:[itemObject numOwned]];
  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[str1 stringByAppendingString:str2]];
  
  if (available) {
    NSRange range = NSMakeRange(str1.length, str2.length);
    [attr addAttribute:NSFontAttributeName value:self.nameLabel.font range:range];
    [attr addAttribute:NSForegroundColorAttributeName value:self.nameLabel.textColor range:range];
  }
  self.quantityLabel.attributedText = attr;
  
  [Globals imageNamed:[itemObject iconImageName] withView:self.itemIcon greyscale:!available indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.iconLabel.text = [itemObject iconText];
  self.iconLabel.textColor = available ? _origIconLabelColor : self.nameLabel.highlightedTextColor;
  
  if ([itemObject useGemsButton]) {
    [self updateForTime:itemObject];
    
    self.gemsButtonView.hidden = NO;
    self.useButtonView.hidden = YES;
  } else {
    self.buttonLabel.text = [itemObject buttonText];
    
    if (!available) {
      [self.useButton setImage:[Globals imageNamed:@"greyitemsbutton.png"] forState:UIControlStateNormal];
      self.buttonLabel.textColor = [UIColor colorWithHexString:@"666666"];
      self.buttonLabel.shadowColor = [UIColor colorWithWhite:1.f alpha:0.75f];
    } else {
      [self.useButton setImage:[Globals imageNamed:@"greenitemsbutton.png"] forState:UIControlStateNormal];
      self.buttonLabel.textColor = [UIColor colorWithHexString:@"065d18"];
      self.buttonLabel.shadowColor = [UIColor colorWithHexString:@"eeffbbbd"];
    }
    
    self.gemsButtonView.hidden = YES;
    self.useButtonView.hidden = NO;
  }
}

- (void) updateForTime:(id<ItemObject>)itemObject {
  if ([itemObject useGemsButton]) {
    if ([itemObject showFreeLabel]) {
      self.freeLabel.hidden = NO;
      self.gemsLabel.superview.hidden = YES;
    } else {
      self.gemsLabel.text = [itemObject buttonText];
      [Globals adjustViewForCentering:self.gemsLabel.superview withLabel:self.gemsLabel];
      
      self.freeLabel.hidden = YES;
      self.gemsLabel.superview.hidden = NO;
    }
  }
}

@end

@implementation ItemSelectViewController

static BOOL _instanceOpened = NO;

- (id) init {
  if (!_instanceOpened) {
    return [super init];
  }
  LNLog(@"Trying to create multiple item select. Rejecting..");
  return nil;
}

+ (BOOL) canCreateNewVc {
  return !_instanceOpened;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.headerView.layer.cornerRadius = 6.f;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [self reloadData];
  
  _instanceOpened = YES;
  [[NSNotificationCenter defaultCenter] postNotificationName:ITEM_SELECT_OPENED_NOTIFICATION object:self];
  
  self.updateTimer = [NSTimer timerWithTimeInterval:0.2f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  [self updateLabels];
}

- (void) anchorToInvokingView:(UIView*)invokingView withDirection:(ViewAnchoringDirection)direction inkovingViewImage:(UIImage*)invokingViewImage
{
  if (invokingView != nil)
  {
    const CGPoint invokingViewAbsolutePosition = [invokingView convertPoint:invokingView.frame.origin toView:nil]; // Window coordinates
    const CGSize windowSize = [Globals screenSize];
    CGFloat viewTargetX = self.mainView.frame.origin.x;
    CGFloat viewTargetY = self.mainView.frame.origin.y;
    CGFloat viewScale = 1.f;
    CGFloat arrowTargetX = -1.f;
    CGFloat arrowTargetY = -1.f;
    
    switch (direction)
    {
      case ViewAnchoringPreferTopPlacement:
      {
        const CGFloat verticalClearance = invokingViewAbsolutePosition.y;
        if (verticalClearance < self.mainView.frame.size.height) // Not enough room vertically; scale down the view
        {
          viewScale = verticalClearance / self.mainView.frame.size.height;
          [self.mainView setTransform:CGAffineTransformMakeScale(viewScale, viewScale)];
        }
        const CGFloat horizontalClearanceLeft = invokingViewAbsolutePosition.x + invokingView.frame.size.width * .5f;
        const CGFloat horizontalClearanceRight = windowSize.width - horizontalClearanceLeft;
        const CGFloat horizontalClearance = MIN(horizontalClearanceLeft, horizontalClearanceRight);
        if (horizontalClearance < self.mainView.frame.size.width * .5f) // Not enough room horizontally; scale down the view even further
        {
          viewScale *= horizontalClearance / (self.mainView.frame.size.width * .5f);
          [self.mainView setTransform:CGAffineTransformMakeScale(viewScale, viewScale)];
        }
        
        viewTargetX = invokingViewAbsolutePosition.x - (self.mainView.frame.size.width - invokingView.frame.size.width) * .5f;
        viewTargetY = invokingViewAbsolutePosition.y - self.mainView.frame.size.height;
        
        [self.triangle setTransform:CGAffineTransformMakeRotation(M_PI_2)]; // Point arrow down
        
        arrowTargetX = invokingViewAbsolutePosition.x - (self.triangle.frame.size.width * viewScale - invokingView.frame.size.width) * .5f - viewTargetX;
        arrowTargetY = self.mainView.frame.size.height - 9.f * viewScale; // This magic number is the bottom padding of the view, coming from the nib
      }
        break;
      case ViewAnchoringPreferBottomPlacement:
      {
        const CGFloat verticalClearance = windowSize.height - (invokingViewAbsolutePosition.y + invokingView.frame.size.height);
        if (verticalClearance < self.mainView.frame.size.height) // Not enough room vertically; scale down the view
        {
          viewScale = verticalClearance / self.mainView.frame.size.height;
          [self.mainView setTransform:CGAffineTransformMakeScale(viewScale, viewScale)];
        }
        const CGFloat horizontalClearanceLeft = invokingViewAbsolutePosition.x + invokingView.frame.size.width * .5f;
        const CGFloat horizontalClearanceRight = windowSize.width - horizontalClearanceLeft;
        const CGFloat horizontalClearance = MIN(horizontalClearanceLeft, horizontalClearanceRight);
        if (horizontalClearance < self.mainView.frame.size.width * .5f) // Not enough room horizontally; scale down the view even further
        {
          viewScale *= horizontalClearance / (self.mainView.frame.size.width * .5f);
          [self.mainView setTransform:CGAffineTransformMakeScale(viewScale, viewScale)];
        }
        
        viewTargetX = invokingViewAbsolutePosition.x - (self.mainView.frame.size.width - invokingView.frame.size.width) * .5f;
        viewTargetY = invokingViewAbsolutePosition.y + invokingView.frame.size.height;
        
        [self.triangle setTransform:CGAffineTransformMakeRotation(-M_PI_2)]; // Point arrow up
        
        arrowTargetX = invokingViewAbsolutePosition.x - (self.triangle.frame.size.width * viewScale - invokingView.frame.size.width) * .5f - viewTargetX;
        arrowTargetY = 1.f * viewScale; // Adding a small offset so that the arrow blends with the view
      }
        break;
      case ViewAnchoringPreferLeftPlacement:
      {
        const CGFloat horizontalClearance = invokingViewAbsolutePosition.x;
        if (horizontalClearance < self.mainView.frame.size.width) // Not enough room horizontally; scale down the view
        {
          viewScale = horizontalClearance / self.mainView.frame.size.width;
          [self.mainView setTransform:CGAffineTransformMakeScale(viewScale, viewScale)];
        }
        const CGFloat verticalClearanceTop = invokingViewAbsolutePosition.y + invokingView.frame.size.height * .5f;;
        const CGFloat verticalClearanceBottom = windowSize.height - verticalClearanceTop;
        const CGFloat verticalClearance = MIN(verticalClearanceTop, verticalClearanceBottom);
        if (verticalClearance < self.mainView.frame.size.height * .5f) // Not enough room vertically; scale down the view even further
        {
          viewScale *= verticalClearance / (self.mainView.frame.size.height * .5f);
          [self.mainView setTransform:CGAffineTransformMakeScale(viewScale, viewScale)];
        }
        
        viewTargetX = invokingViewAbsolutePosition.x - self.mainView.frame.size.width;
        viewTargetY = invokingViewAbsolutePosition.y - (self.mainView.frame.size.height - invokingView.frame.size.height) * .5f;
        
        // Arrow is initially pointing to the right
        
        arrowTargetX = self.mainView.frame.size.width - 8.f * viewScale; // This magic number is the right padding of the view, coming from the nib
        arrowTargetY = invokingViewAbsolutePosition.y - (self.triangle.frame.size.height * viewScale - invokingView.frame.size.height) * .5f - viewTargetY;
      }
        break;
      case ViewAnchoringPreferRightPlacement:
      {
        const CGFloat horizontalClearance = windowSize.width - (invokingViewAbsolutePosition.x + invokingView.frame.size.width);
        if (horizontalClearance < self.mainView.frame.size.width) // Not enough room horizontally; scale down the view
        {
          viewScale = horizontalClearance / self.mainView.frame.size.width;
          [self.mainView setTransform:CGAffineTransformMakeScale(viewScale, viewScale)];
        }
        const CGFloat verticalClearanceTop = invokingViewAbsolutePosition.y + invokingView.frame.size.height * .5f;;
        const CGFloat verticalClearanceBottom = windowSize.height - verticalClearanceTop;
        const CGFloat verticalClearance = MIN(verticalClearanceTop, verticalClearanceBottom);
        if (verticalClearance < self.mainView.frame.size.height * .5f) // Not enough room vertically; scale down the view even further
        {
          viewScale *= verticalClearance / (self.mainView.frame.size.height * .5f);
          [self.mainView setTransform:CGAffineTransformMakeScale(viewScale, viewScale)];
        }
        
        viewTargetX = invokingViewAbsolutePosition.x + invokingView.frame.size.width;
        viewTargetY = invokingViewAbsolutePosition.y - (self.mainView.frame.size.height - invokingView.frame.size.height) * .5f;
        
        [self.triangle setTransform:CGAffineTransformMakeRotation(M_PI)]; // Point arrow to the left
        
        arrowTargetX = 1.f * viewScale; // Adding a small offset so that the arrow blends with the view
        arrowTargetY = invokingViewAbsolutePosition.y - (self.triangle.frame.size.height * viewScale - invokingView.frame.size.height) * .5f - viewTargetY;
      }
        break;
        
      default:
        break;
    }
    
    [self.mainView setFrame:CGRectMake(viewTargetX, viewTargetY, self.mainView.frame.size.width, self.mainView.frame.size.height)];
    
    if (arrowTargetX > 0 || arrowTargetY > 0)
    {
      // Place arrow relative to its parent view
      [self.triangle setFrame:CGRectMake(arrowTargetX / viewScale, arrowTargetY / viewScale, self.triangle.size.width, self.triangle.size.height)];
      [self.triangle setHidden:NO];
    }

    // Use masking layers to darken behind the dialog
    // but have the invokingViewImage show through
    if (invokingViewImage != nil)
    {
      CALayer* maskLayer = [CALayer layer];
      CALayer* maskTopLayer = [CALayer layer];
      {
        [maskTopLayer setFrame:CGRectMake(0, 0,
                                          CGRectGetWidth(self.bgdView.frame), invokingViewAbsolutePosition.y)];
        [maskTopLayer setBackgroundColor:[UIColor blackColor].CGColor];
        [maskLayer addSublayer:maskTopLayer];
      }
      CALayer* maskBottomLayer = [CALayer layer];
      {
        [maskBottomLayer setFrame:CGRectMake(0, invokingViewAbsolutePosition.y + CGRectGetHeight(invokingView.frame),
                                             CGRectGetWidth(self.bgdView.frame), windowSize.height - (invokingViewAbsolutePosition.y + CGRectGetHeight(invokingView.frame)))];
        [maskBottomLayer setBackgroundColor:[UIColor blackColor].CGColor];
        [maskLayer addSublayer:maskBottomLayer];
      }
      CALayer* maskLeftLayer = [CALayer layer];
      {
        [maskLeftLayer setFrame:CGRectMake(0, invokingViewAbsolutePosition.y,
                                           invokingViewAbsolutePosition.x, CGRectGetHeight(invokingView.frame))];
        [maskLeftLayer setBackgroundColor:[UIColor blackColor].CGColor];
        [maskLayer addSublayer:maskLeftLayer];
      }
      CALayer* maskRightLayer = [CALayer layer];
      {
        [maskRightLayer setFrame:CGRectMake(invokingViewAbsolutePosition.x + CGRectGetWidth(invokingView.frame), invokingViewAbsolutePosition.y,
                                            windowSize.width - (invokingViewAbsolutePosition.x + CGRectGetWidth(invokingView.frame)), CGRectGetHeight(invokingView.frame))];
        [maskRightLayer setBackgroundColor:[UIColor blackColor].CGColor];
        [maskLayer addSublayer:maskRightLayer];
      }
      
      CALayer* maskImageLayer = [CALayer layer];
      CGImageRef invokingViewImageRef = invokingViewImage.CGImage;
      CGImageRef invokingViewMaskImageRef = CGImageMaskCreate(CGImageGetWidth(invokingViewImageRef),
                                                              CGImageGetHeight(invokingViewImageRef),
                                                              CGImageGetBitsPerComponent(invokingViewImageRef),
                                                              CGImageGetBitsPerPixel(invokingViewImageRef),
                                                              CGImageGetBytesPerRow(invokingViewImageRef),
                                                              CGImageGetDataProvider(invokingViewImageRef), NULL, false);
      CGRect invokingViewAbsoluteFrame = { invokingViewAbsolutePosition, invokingView.frame.size };
      [maskImageLayer setFrame:invokingViewAbsoluteFrame];
      [maskImageLayer setContents:(__bridge id)(invokingViewMaskImageRef)];
      [maskLayer addSublayer:maskImageLayer];

      self.bgdView.layer.mask = maskLayer;
    }
  }
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self.updateTimer invalidate];
  self.updateTimer = nil;
  
  [[SocketCommunication sharedSocketCommunication] flush];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateLabels {
  self.titleLabel.text = [self.delegate titleName];
  
  [self updateProgressBar];
  
  for (ItemSelectCell *cell in self.itemsTable.visibleCells) {
    id<ItemObject> io = self.items[[self.itemsTable indexPathForCell:cell].row];
    [cell updateForTime:io];
  }
}

- (void) reloadData {
  [self reloadDataAnimated:NO];
}

- (void) reloadDataAnimated:(BOOL)animated {
  NSArray *oldArray = self.items;
  self.items = [self.delegate reloadItemsArray];
  
  if (animated) {
    NSMutableArray *removedIps = [NSMutableArray array], *addedIps = [NSMutableArray array];
    NSMutableDictionary *movedIps = [NSMutableDictionary dictionary];
    
    [Globals calculateDifferencesBetweenOldArray:oldArray newArray:self.items removalIps:removedIps additionIps:addedIps movedIps:movedIps section:0];
    
    [self.itemsTable beginUpdates];
    
    [self.itemsTable deleteRowsAtIndexPaths:removedIps withRowAnimation:UITableViewRowAnimationFade];
    
    for (NSIndexPath *ip in movedIps) {
      NSIndexPath *newIp = movedIps[ip];
      [self.itemsTable moveRowAtIndexPath:ip toIndexPath:newIp];
    }
    [self.itemsTable insertRowsAtIndexPaths:addedIps withRowAnimation:UITableViewRowAnimationFade];
    
    [self.itemsTable endUpdates];
    
    for (ItemSelectCell *cell in self.itemsTable.visibleCells) {
      id<ItemObject> io = self.items[[self.itemsTable indexPathForCell:cell].row];
      [cell updateForItemObject:io];
    }
  } else {
    [self.itemsTable reloadData];
  }
  
  self.titleLabel.text = [self.delegate titleName];
  
  [self updateProgressBar];
}

- (void) updateProgressBar {
  self.progressBarLabel.text = [self.delegate progressBarText];
  
  // Use tag of the progress bar to determine what color it is
  TimerProgressBarColor color = [self.delegate progressBarColor];
  if (self.progressBar.tag != color) {
    // Reload it
    NSString *prefix = nil;
    if (color == TimerProgressBarColorYellow) {
      prefix = @"obtimeryellow";
    } else if (color == TimerProgressBarColorGreen) {
      prefix = @"obtimergreen";
    } else if (color == TimerProgressBarColorPurple) {
      prefix = @"obtimerpurple";
    }
    
    self.progressBar.leftCap.image = [Globals imageNamed:[prefix stringByAppendingString:@"cap.png"]];
    self.progressBar.rightCap.image = [Globals imageNamed:[prefix stringByAppendingString:@"cap.png"]];
    self.progressBar.middleBar.image = [Globals imageNamed:[prefix stringByAppendingString:@"middle.png"]];
    
    self.progressBar.tag = color;
  }
  
  [self.progressBar setPercentage:[self.delegate progressBarPercent]];
}

- (IBAction)closeClicked:(id)sender {
  // Do the appearance transition so that viewWillDisappear gets called immediately
  [self beginAppearanceTransition:NO animated:YES];
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [self endAppearanceTransition];
  }];
  
  [self.delegate itemSelectClosed:self];
  self.delegate = nil;
  
  _instanceOpened = NO;
  [[NSNotificationCenter defaultCenter] postNotificationName:ITEM_SELECT_CLOSED_NOTIFICATION object:self];
}

#pragma mark - UITableView dataSource/delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.items.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ItemSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemSelectCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"ItemSelectCell" owner:self options:nil];
    cell = self.selectCell;
  }
  
  [cell updateForItemObject:self.items[indexPath.row]];
  
  return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return self.progressBarView;
}

- (IBAction) cellButtonClicked:(UIView *)sender {
  while (sender && ![sender isKindOfClass:[ItemSelectCell class]]) {
    sender = [sender superview];
  }
  
  if (sender) {
    ItemSelectCell *cell = (ItemSelectCell *)sender;
    NSIndexPath *ip = [self.itemsTable indexPathForCell:cell];
    id<ItemObject> item = self.items[ip.row];
    [self.delegate itemSelected:item viewController:self];
  }
}

@end
