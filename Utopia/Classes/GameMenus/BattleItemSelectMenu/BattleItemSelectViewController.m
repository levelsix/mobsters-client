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
#import "OutgoingEventController.h"

#import "TimerAction.h"

@implementation BattleItemSelectCell

- (void) updateForEditing:(BOOL)editing {
  if (editing) {
    self.infoView.originX = 0.f;
  } else {
    self.infoView.originX = self.infoView.superview.width-self.infoView.width;
  }
}

@end

@implementation BattleItemInfoView

- (void) awakeFromNib {
  [super awakeFromNib];
  
  self.gemsButtonView.frame = self.useButtonView.frame;
}

- (void) updateForBattleItem:(UserBattleItem *)itemObject isValid:(BOOL)isValid isButtonValid:(BOOL)isButtonValid showButton:(BOOL)showButton {
  BattleItemProto *bip = itemObject.staticBattleItem;
  
  self.nameLabel.text = bip.name;
  float color = isValid ? 51/255.f : 101/255.f;
  self.nameLabel.textColor = [UIColor colorWithWhite:color alpha:1.f];
  
  self.typeLabel.text = [NSString stringWithFormat:@"Type: %@", bip.battleItemCategory == BattleItemCategoryPotion ? @"Potion" : @"Puzzle"];
  
  // For the big info view
  if (self.descriptionLabel) {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3.f];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:bip.description attributes:@{NSParagraphStyleAttributeName:paragraphStyle, NSFontAttributeName:self.descriptionLabel.font}];
    self.descriptionLabel.attributedText = attributedString;
    
    CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(self.descriptionLabel.width, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    self.descriptionLabel.height = ceilf(rect.size.height)+16.f;
    
    self.useButtonView.superview.originY = CGRectGetMaxY(self.descriptionLabel.frame);
  }
  
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
  
  NSString *bgdImgName = isValid ? @"ifitemsquareverysmall.png" : @"itemsquareverysmallgrey.png";
  [Globals imageNamed:bgdImgName withView:self.bgdIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  if (showButton) {
    
    if (!isButtonValid) {
      [self.useButton setImage:[Globals imageNamed:@"greyitemsbutton.png"] forState:UIControlStateNormal];
      [self.gemsButton setImage:[Globals imageNamed:@"greyitemsbutton.png"] forState:UIControlStateNormal];
      self.buttonLabel.textColor = [UIColor colorWithHexString:@"666666"];
      self.buttonLabel.shadowColor = [UIColor colorWithWhite:1.f alpha:0.75f];
      self.gemsLabel.textColor = [UIColor colorWithHexString:@"666666"];
      self.gemsLabel.shadowColor = [UIColor colorWithWhite:1.f alpha:0.75f];
      
    } else {
      [self.useButton setImage:[Globals imageNamed:@"greenitemsbutton.png"] forState:UIControlStateNormal];
      [self.gemsButton setImage:[Globals imageNamed:@"purpleitemsbutton.png"] forState:UIControlStateNormal];
      self.buttonLabel.textColor = [UIColor colorWithHexString:@"065d18"];
      self.buttonLabel.shadowColor = [UIColor colorWithHexString:@"eeffbbbd"];
      self.gemsLabel.textColor = [UIColor colorWithHexString:@"ffffff"];
      self.gemsLabel.shadowColor = [UIColor colorWithWhite:0.f alpha:0.5f];
    }
    
    [Globals imageNamed:@"diamond.png" withView:self.gemIcon greyscale:!isButtonValid indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
    
    if (itemObject.quantity <= 0) {
      self.gemsLabel.text = [Globals commafyNumber:bip.inBattleGemCost];
      [Globals adjustViewForCentering:self.gemsLabel.superview withLabel:self.gemsLabel];
      
      self.gemsButtonView.hidden = NO;
      self.useButtonView.hidden = YES;
    } else {
      self.gemsButtonView.hidden = YES;
      self.useButtonView.hidden = NO;
    }
    self.useButtonView.superview.hidden = NO;
  } else {
    self.useButtonView.superview.hidden = YES;
  }
}

@end

@implementation BattleItemSelectViewController

- (id) initWithShowUseButton:(BOOL)showUseButton showFooterView:(BOOL)showFooterView {
  if ((self = [super init])) {
    _showUseButton = showUseButton;
    _showFooterView = showFooterView;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [self.containerView addSubview:self.contentView];
  
  self.containerView.layer.cornerRadius = self.headerView.layer.cornerRadius;
  
  [self loadListViewAnimated:NO];
  
  
  if (_showFooterView) {
    NSString *desc = self.footerDescLabel.text;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:desc];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, desc.length)];
    self.footerDescLabel.attributedText = attributedString;
  } else {
    self.footerView.hidden = !_showFooterView;
    
    self.itemsTable.height = self.itemsTable.superview.height-self.itemsTable.originY;
    
    self.editButton.superview.hidden = YES;
  }
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self reloadDataAnimated:NO];
  
  if ([self.delegate respondsToSelector:@selector(progressBarText)]) {
    self.itemsTable.tableHeaderView = self.progressBarView;
  }
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
  
  if ([self.delegate respondsToSelector:@selector(progressBarText)]) {
    [self updateProgressBar];
  }
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

- (void) loadInfoViewForBattleItem:(UserBattleItem *)ubi animated:(BOOL)animated {
  // Load the view in case it isn't loaded
  [self view];
  
  _selectedItem = ubi;
  
  BOOL isValid = YES;
  if ([self.delegate respondsToSelector:@selector(battleItemIsValid:)]) {
    isValid = [self.delegate battleItemIsValid:ubi];
  }
  
  [self.infoView updateForBattleItem:ubi isValid:YES isButtonValid:isValid  showButton:_showUseButton];
  self.infoTitleLabel.text = self.infoView.nameLabel.text.uppercaseString;
  
  // If animated, show back button otherwise don't.
  if (animated) {
    [UIView animateWithDuration:0.3f animations:^{
      self.contentView.centerX = 0.f;
      self.backView.alpha = 1.f;
    }];
  } else {
    self.contentView.centerX = 0.f;
  }
}

- (void) loadListViewAnimated:(BOOL)animated {
  _selectedItem = nil;
  
  if (animated) {
    [UIView animateWithDuration:0.3f animations:^{
      self.contentView.originX = 0.f;
      self.backView.alpha = 0.f;
    }];
  } else {
    self.contentView.originX = 0.f;
    self.backView.alpha = 0.f;
  }
}

- (IBAction)backClicked:(id)sender {
  [self loadListViewAnimated:YES];
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
  [cell updateForEditing:_isEditing];
  
  return cell;
}

- (void) updateCell:(BattleItemSelectCell *)cell battleItem:(UserBattleItem *)ubi {
  BOOL isValid = YES;
  if ([self.delegate respondsToSelector:@selector(battleItemIsValid:)]) {
    isValid = [self.delegate battleItemIsValid:ubi];
  }
  [cell.infoView updateForBattleItem:ubi isValid:isValid isButtonValid:isValid showButton:_showUseButton];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  UserBattleItem *bi = self.battleItems[indexPath.row];
  [self loadInfoViewForBattleItem:bi animated:YES];
}

- (IBAction) cellButtonClicked:(UIView *)sender {
  sender = [sender getAncestorInViewHierarchyOfType:[BattleItemSelectCell class]];
  
  if (sender) {
    BattleItemSelectCell *cell = (BattleItemSelectCell *)sender;
    NSIndexPath *ip = [self.itemsTable indexPathForCell:cell];
    UserBattleItem *item = self.battleItems[ip.row];
    [self.delegate battleItemSelected:item viewController:self];
  } else if (_selectedItem) {
    [self.delegate battleItemSelected:_selectedItem viewController:self];
  }
}

#pragma mark - Edit/Done

- (IBAction) editClicked:(id)sender {
  if (_isEditing) {
    self.editLabel.text = @"Edit";
    
    _isEditing = NO;
  } else {
    self.editLabel.text = @"Done";
    
    _isEditing = YES;
  }
  
  self.itemsTable.allowsSelection = !_isEditing;
  
  [self.editButton remakeImage];
  
  [UIView animateWithDuration:0.3f animations:^{
    for (BattleItemSelectCell *cell in self.itemsTable.visibleCells) {
      [cell updateForEditing:_isEditing];
    }
  }];
}

- (IBAction) minusClicked:(id)sender {
  BattleItemSelectCell *cell = [sender getAncestorInViewHierarchyOfType:[BattleItemSelectCell class]];
  NSIndexPath *ip = [self.itemsTable indexPathForCell:cell];
  UserBattleItem *item = self.battleItems[ip.row];
  [[OutgoingEventController sharedOutgoingEventController] removeBattleItems:@[@(item.battleItemId)]];
  
  [self.delegate battleItemDiscarded:item];
  
  [self reloadDataAnimated:YES];
}

@end
