//
//  ResearchViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 2/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchViewController.h"

#import "GameState.h"

@implementation ResearchViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.titleImageName = @"residencemenuheader.png";
  self.title = @"RESEARCH LAB";
}

#pragma TableView Delegates

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ResearchCategoryViewCell *cell;
  cell = [tableView dequeueReusableCellWithIdentifier:@"ResearchCategoryCellView"];
  if (!cell) {
    cell = [[NSBundle mainBundle] loadNibNamed:@"ResearchCategoryCellView" owner:self options:nil][0];
  }
  
  return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 15;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  ResearchInfoViewController *rivc = [[ResearchInfoViewController alloc] init];
  [self.parentViewController pushViewController:rivc animated:YES];
}

@end
