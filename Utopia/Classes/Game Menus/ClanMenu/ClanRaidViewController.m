//
//  ClanRaidViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanRaidViewController.h"
#import "ClanRaidDetailsViewController.h"

@implementation ClanRaidViewController

#pragma mark - UITableView delegate/dataSource

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  [[NSBundle mainBundle] loadNibNamed:@"ClanRaidActiveCell" owner:self options:nil];
  return self.nibCell;
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    return 144.f;
  } else {
    return 56.f;
  }
}

#pragma mark - IBActions

- (IBAction)raidSelected:(id)sender {
  ClanRaidDetailsViewController *details = [[ClanRaidDetailsViewController alloc] init];
  [self.navigationController pushViewController:details animated:YES];
}

@end
