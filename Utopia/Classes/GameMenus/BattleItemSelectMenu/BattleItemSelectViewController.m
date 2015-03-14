//
//  BattleItemSelectViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BattleItemSelectViewController.h"

#import "GameState.h"
#import "Globals.h"

#import "SocketCommunication.h"

#import "TimerAction.h"

@implementation BattleItemSelectCell

- (void) awakeFromNib {
  [super awakeFromNib];
  
  self.gemsButtonView.frame = self.useButtonView.frame;
}

- (void) updateForBattleItem:(UserBattleItem *)itemObject isValid:(BOOL)isValid showButton:(BOOL)showButton {
  BattleItemProto *bip = itemObject.staticBattleItem;
  
  self.nameLabel.text = bip.name;
  self.nameLabel.highlighted = !isValid;
  
  NSString *str1 = @"Owned: ";
  NSString *str2 = [Globals commafyNumber:itemObject.quantity];
  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[str1 stringByAppendingString:str2]];
  
  if (isValid) {
    NSRange range = NSMakeRange(str1.length, str2.length);
    [attr addAttribute:NSFontAttributeName value:self.nameLabel.font range:range];
    [attr addAttribute:NSForegroundColorAttributeName value:self.nameLabel.textColor range:range];
  }
  self.quantityLabel.attributedText = attr;
  
  [Globals imageNamed:bip.imgName withView:self.itemIcon greyscale:!isValid indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  if (itemObject.quantity <= 0) {
    self.gemsLabel.text = [Globals commafyNumber:bip.inBattleGemCost];
    [Globals adjustViewForCentering:self.gemsLabel.superview withLabel:self.gemsLabel];
    
    self.gemsButtonView.hidden = NO;
    self.useButtonView.hidden = YES;
  } else {
    
    if (!isValid) {
      [self.useButton setImage:[Globals imageNamed:@"greyitemsbutton.png"] forState:UIControlStateNormal];
      [self.gemsButton setImage:[Globals imageNamed:@"greyitemsbutton.png"] forState:UIControlStateNormal];
      self.buttonLabel.textColor = [UIColor colorWithHexString:@"666666"];
      self.buttonLabel.shadowColor = [UIColor colorWithWhite:1.f alpha:0.75f];
      self.gemsLabel.textColor = [UIColor colorWithHexString:@"666666"];
      self.gemsLabel.shadowColor = [UIColor colorWithWhite:1.f alpha:0.75f];
    } else {
      [self.useButton setImage:[Globals imageNamed:@"greenitemsbutton.png"] forState:UIControlStateNormal];
      [self.gemsButton setImage:[Globals imageNamed:@"purpleitemsbutton.png"] forState:UIControlStateNormal];
      self.gemIcon.image = [Globals imageNamed:@"diamond.png"];
      self.buttonLabel.textColor = [UIColor colorWithHexString:@"065d18"];
      self.buttonLabel.shadowColor = [UIColor colorWithHexString:@"eeffbbbd"];
      self.gemsLabel.textColor = [UIColor colorWithHexString:@"ffffff"];
      self.gemsLabel.shadowColor = [UIColor colorWithWhite:0.f alpha:0.5f];
    }
    
    self.gemsButtonView.hidden = YES;
    self.useButtonView.hidden = NO;
  }
}

@end

@implementation BattleItemSelectViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [self.containerView addSubview:self.contentView];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self reloadDataAnimated:NO];
}

- (void) reloadDataAnimated:(BOOL)animated {
  NSArray *oldArray = self.battleItems;
  self.battleItems = [self.delegate reloadBattleItemsArray];
  
  if (animated) {
    NSMutableArray *removedIps = [NSMutableArray array], *addedIps = [NSMutableArray array];
    NSMutableDictionary *movedIps = [NSMutableDictionary dictionary];
    
    [Globals calculateDifferencesBetweenOldArray:oldArray newArray:self.battleItems removalIps:removedIps additionIps:addedIps movedIps:movedIps section:0];
    
    [self.itemsTable beginUpdates];
    
    [self.itemsTable deleteRowsAtIndexPaths:removedIps withRowAnimation:UITableViewRowAnimationFade];
    
    for (NSIndexPath *ip in movedIps) {
      NSIndexPath *newIp = movedIps[ip];
      [self.itemsTable moveRowAtIndexPath:ip toIndexPath:newIp];
    }
    [self.itemsTable insertRowsAtIndexPaths:addedIps withRowAnimation:UITableViewRowAnimationFade];
    
    [self.itemsTable endUpdates];
    
    for (BattleItemSelectCell *cell in self.itemsTable.visibleCells) {
      UserBattleItem *io = self.battleItems[[self.itemsTable indexPathForCell:cell].row];
      [self updateCell:cell battleItem:io];
    }
  } else {
    [self.itemsTable reloadData];
  }
  
  self.titleLabel.text = @"MY ITEMS";
  
  [self updateProgressBar];
}

- (void) updateProgressBar {
  self.progressBarLabel.text = [self.delegate progressBarText];
  
  // Use tag of the progress bar to determine what color it is
  TimerProgressBarColor color = TimerProgressBarColorYellow;
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
    self.progressBar.percentage = 1.f;
  }
}

- (IBAction)closeClicked:(id)sender {
  [super closeClicked:sender];
  
  [self.delegate battleItemSelectClosed:self];
  self.delegate = nil;
}

#pragma mark - UITableView dataSource/delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.battleItems.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BattleItemSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BattleItemSelectCell"];
  if (cell == nil) {
    cell = [[NSBundle mainBundle] loadNibNamed:@"BattleItemSelectCell" owner:self options:nil][0];
  }
  
  [self updateCell:cell battleItem:self.battleItems[indexPath.row]];
  
  return cell;
}

- (void) updateCell:(BattleItemSelectCell *)cell battleItem:(UserBattleItem *)ubi {
  [cell updateForBattleItem:ubi isValid:YES showButton:YES];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return self.progressBarView;
}

- (IBAction) cellButtonClicked:(UIView *)sender {
  sender = [sender getAncestorInViewHierarchyOfType:[BattleItemSelectCell class]];
  
  if (sender) {
    BattleItemSelectCell *cell = (BattleItemSelectCell *)sender;
    NSIndexPath *ip = [self.itemsTable indexPathForCell:cell];
    UserBattleItem *item = self.battleItems[ip.row];
    [self.delegate battleItemSelected:item viewController:self];
  }
}

@end
