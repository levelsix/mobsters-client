//
//  GachaponViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/31/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "GachaponViewController.h"

@interface GachaponViewController ()

@end

@implementation GachaponItemCell

- (void) awakeFromNib {
  self.containerView.layer.cornerRadius = 5.f;
}

- (void) update {
  
}

@end

@implementation GachaponViewController

#define NUM_ROWS INT_MAX/100000

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = @"Goonie Grab";
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  [self.gachaTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NUM_ROWS/2 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

#pragma mark - UITableViewDelegate/DataSource methods

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return NUM_ROWS;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GachaponItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GachaponItemCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"GachaponItemCell" owner:self options:nil];
    cell = self.itemCell;
  }
  
  [cell update];
  
  return cell;
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
  CGPoint pt = *targetContentOffset;
  
  float nearest = roundf((pt.y+self.gachaTable.frame.size.height/2)/self.gachaTable.rowHeight+0.5)-0.5;
  pt.y = nearest*self.gachaTable.rowHeight-self.gachaTable.frame.size.height/2;
  targetContentOffset->y = pt.y;
}

@end
