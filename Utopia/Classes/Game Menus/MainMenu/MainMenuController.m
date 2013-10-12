//
//  MainMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/15/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "MainMenuController.h"
#import "Globals.h"
#import "ClanViewController.h"
#import "EnhanceViewController.h"

@interface MainMenuController ()

@end

@implementation MainMenuController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.title = @"Menu";
      
      [self setUpSettingsAndCloseButtons];
      [self setUpImageBackButton];
    }
    return self;
}

- (IBAction)fundsClicked:(id)sender {
}

- (IBAction)cratesClicked:(id)sender {
  
}

- (IBAction)buildingsClicked:(id)sender {
  
}

- (IBAction)labClicked:(id)sender {
  [self.navigationController pushViewController:[[EnhanceViewController alloc] init] animated:YES];
}

- (IBAction)clansClicked:(id)sender {
  [self.navigationController pushViewController:[[ClanViewController alloc] init] animated:YES];
}

- (IBAction)profileClicked:(id)sender {
  
}

@end
