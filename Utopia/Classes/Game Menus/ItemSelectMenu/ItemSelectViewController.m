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

@end

@implementation ItemSelectViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.headerView.layer.cornerRadius = 6.f;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [self reloadData];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[SocketCommunication sharedSocketCommunication] flush];
}

- (void) reloadData {
  [self reloadDataAnimated:NO];
}

- (void) reloadDataAnimated:(BOOL)animated {
  if ([self.delegate respondsToSelector:@selector(reloadItemsArray)]) {
    [self.delegate reloadItemsArray];
  }
  
  [self.itemsTable reloadData];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

#pragma mark - UITableView dataSource/delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.delegate numberOfItems];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ItemSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemSelectCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"ItemSelectCell" owner:self options:nil];
    cell = self.selectCell;
  }
  
  [cell updateForItemObject:[self.delegate itemObjectAtIndex:(int)indexPath.row]];
  
  return cell;
}

- (IBAction) cellButtonClicked:(UIView *)sender {
  while (sender && ![sender isKindOfClass:[ItemSelectCell class]]) {
    sender = [sender superview];
  }
  
  if (sender) {
    ItemSelectCell *cell = (ItemSelectCell *)sender;
    NSIndexPath *ip = [self.itemsTable indexPathForCell:cell];
    [self.delegate itemSelected:self atIndex:(int)ip.row];
  }
}

@end
