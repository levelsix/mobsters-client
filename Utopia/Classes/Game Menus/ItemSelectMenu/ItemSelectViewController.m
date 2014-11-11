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

@implementation ItemSelectCell

- (void) awakeFromNib {
  [super awakeFromNib];
  
  self.gemsButtonView.frame = self.useButtonView.frame;
}

- (void) updateForItemObject:(id<ItemObject>)itemObject {
  BOOL available = [itemObject isValid];
  
  self.nameLabel.text = [itemObject name];
  
  NSString *str1 = @"Owned: ";
  NSString *str2 = [Globals commafyNumber:[itemObject numOwned]];
  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[str1 stringByAppendingString:str2]];
  
  if (available) {
    [attr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Gotham-Bold" size:self.quantityLabel.font.pointSize] range:NSMakeRange(str1.length, str2.length)];
  }
  self.quantityLabel.attributedText = attr;
  
  [Globals imageNamed:[itemObject iconImageName] withView:self.itemIcon greyscale:!available indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.iconLabel.text = [itemObject iconText];
  
  if ([itemObject useGemsButton]) {
    self.gemsLabel.text = [itemObject buttonText];
    [Globals adjustViewForCentering:self.gemsLabel.superview withLabel:self.gemsLabel];
    
    self.gemsButtonView.hidden = NO;
    self.useButtonView.hidden = YES;
  } else {
    self.buttonLabel.text = [itemObject buttonText];
    
    self.gemsButtonView.hidden = YES;
    self.useButtonView.hidden = NO;
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

- (void) reloadData {
  [self reloadDataAnimated:NO];
}

- (void) reloadDataAnimated:(BOOL)animated {
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
  
  [cell updateForItemObject:[self.delegate itemObjectAtIndex:indexPath.row]];
  
  return cell;
}

- (IBAction) cellButtonClicked:(UIView *)sender {
  while (sender && ![sender isKindOfClass:[ItemSelectCell class]]) {
    sender = [sender superview];
  }
  
  if (sender) {
    ItemSelectCell *cell = (ItemSelectCell *)sender;
    NSIndexPath *ip = [self.itemsTable indexPathForCell:cell];
    [self.delegate itemSelectedAtIndex:ip.row];
  }
}

@end
