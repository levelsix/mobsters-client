//
//  MiniJobsListViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/1/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniJobsListViewController.h"

@implementation MiniJobsListViewController

#pragma mark - UITableView delegate/dataSource

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

@end
