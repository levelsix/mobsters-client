//
//  BuildingViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "BuildingViewController.h"

@implementation BuildingViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.listView.cellClassName = @"BuildingCardCell";
}

#pragma mark - List view delegate

- (void) listView:(MonsterListView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  
}

@end
