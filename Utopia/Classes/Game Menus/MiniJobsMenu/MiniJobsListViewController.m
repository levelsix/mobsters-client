//
//  MiniJobsListViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/1/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniJobsListViewController.h"

@implementation MiniJobsListCell

@end

@implementation MiniJobsListViewController

#pragma mark - UITableView delegate/dataSource

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return self.headerView;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  MiniJobsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MiniJobsListCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"MiniJobsListCell" owner:self options:nil];
    cell = self.listCell;
  }
  
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  MiniJobsListCell *cell = (MiniJobsListCell *)[tableView cellForRowAtIndexPath:indexPath];
  [self.delegate miniJobsListCellClicked:cell];
}

@end
