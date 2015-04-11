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
    
    self.useButton.type = 0;
    if (available && [itemObject isKindOfClass:[UserItem class]]) {
      self.useButton.type = [(UserItem *)itemObject staticItem].itemType;
    }
    
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
  
  self.gameActionTypeIcon.hidden = NO;
  switch ([itemObject gameActionType]) {
    case GameActionTypeCreateBattleItem:
      self.gameActionTypeIcon.image = [Globals imageNamed:@"timercreateitems.png"];
      break;
    case GameActionTypeEnhanceTime:
      self.gameActionTypeIcon.image = [Globals imageNamed:@"timerenhance.png"];
      break;
    case GameActionTypeEvolve:
      self.gameActionTypeIcon.image = [Globals imageNamed:@"timerevolve.png"];
      break;
    case GameActionTypeHeal:
      self.gameActionTypeIcon.image = [Globals imageNamed:@"timerheal.png"];
      break;
    case GameActionTypeMiniJob:
      self.gameActionTypeIcon.image = [Globals imageNamed:@"timerminijobs.png"];
      break;
    case GameActionTypeRemoveObstacle:
      self.gameActionTypeIcon.image = [Globals imageNamed:@"timerremove.png"];
      break;
    case GameActionTypePerformingResearch:
      self.gameActionTypeIcon.image = [Globals imageNamed:@"timerresearch.png"];
      break;
    case GameActionTypeUpgradeStruct:
      self.gameActionTypeIcon.image = [Globals imageNamed:@"timerupgrade.png"];
      break;
    default:
      self.gameActionTypeIcon.hidden = YES;
      break;
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

- (void) viewDidLoad {
  [super viewDidLoad];
  [self.progressBarView removeFromSuperview];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:ITEM_SELECT_OPENED_NOTIFICATION object:self];
  
  [self reloadData];
  
  self.updateTimer = [NSTimer timerWithTimeInterval:0.2f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  [self updateLabels];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self.updateTimer invalidate];
  self.updateTimer = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateLabels {
  self.titleLabel.text = [self.delegate titleName];
  
  if ([self.delegate respondsToSelector:@selector(progressBarText)]) {
    [self updateProgressBar];
  }
  
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
  
  if ([self.delegate respondsToSelector:@selector(progressBarText)]) {
    [self updateProgressBar];
  }
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
  
  float perc = [self.delegate progressBarPercent];
  if (perc < 1.f) {
    [self.progressBar setPercentage:[self.delegate progressBarPercent]];
  } else {
    // This is mostly just a precaution
    if ([self.delegate canCloseOnFullBar]) {
      [self closeClicked:nil];
    } else {
      self.progressBar.percentage = 1.f;
    }
  }
}

- (IBAction)closeClicked:(id)sender {
  [super closeClicked:sender];
  
  // Clear all the delegates
  for (id io in self.items) {
    if ([io respondsToSelector:@selector(setDelegate:)]) {
      [io setDelegate:nil];
    }
  }
  
  [self.delegate itemSelectClosed:self];
  self.delegate = nil;
  
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

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if ([self.delegate respondsToSelector:@selector(progressBarText)]) {
    return self.progressBarView.height;
  } else {
    return 0.f;
  }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if ([self.delegate respondsToSelector:@selector(progressBarText)]) {
    return self.progressBarView;
  } else {
    return nil;
  }
}

- (IBAction) cellButtonClicked:(UIView *)sender {
  sender = [sender getAncestorInViewHierarchyOfType:[ItemSelectCell class]];
  
  if (sender) {
    ItemSelectCell *cell = (ItemSelectCell *)sender;
    NSIndexPath *ip = [self.itemsTable indexPathForCell:cell];
    id<ItemObject> item = self.items[ip.row];
    [self.delegate itemSelected:item viewController:self];
  }
}

@end
