//
//  ResearchInfoViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 3/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchInfoViewController.h"

@implementation ResearchInfoViewController

- (void) viewDidLoad {
  self.title = @"info view";
}

- (IBAction)DetailsClicked:(id)sender {
  ResearchDetailViewController *rdvc = [[ResearchDetailViewController alloc] init];
  [self.parentViewController pushViewController:rdvc animated:YES];
}

@end
