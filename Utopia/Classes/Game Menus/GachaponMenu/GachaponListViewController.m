//
//  GachaponListViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "GachaponListViewController.h"
#import "GameState.h"
#import "Globals.h"
#import "GachaponViewController.h"

@implementation GachaponListCell

- (void) loadForBoosterPack:(BoosterPackProto *)bpp {
  self.boosterPack = bpp;
  
  [Globals imageNamed:bpp.listBackgroundImgName withView:self.bgdButton greyscale:NO indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  self.descriptionLabel.text = bpp.listDescription;
}

@end

@implementation GachaponListViewController

- (void) viewDidLoad {
  self.title = @"Mobster Machines";
  self.shortTitle = @"Machines";
  [self setUpCloseButton];
  [self setUpImageBackButton];
}

- (IBAction)machineClicked:(id)sender {
  while (![sender isKindOfClass:[GachaponListCell class]]) {
    sender = [sender superview];
  }
  GachaponListCell *cell = (GachaponListCell *)sender;
  
  GachaponViewController *gvc = [[GachaponViewController alloc] initWithBoosterPack:cell.boosterPack];
  [self.navigationController pushViewController:gvc animated:YES];
}

#pragma mark - TableView methods

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  return gs.boosterPacks.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GachaponListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GachaponListCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"GachaponListCell" owner:self options:nil];
    cell = self.listCell;
  }
  
  GameState *gs = [GameState sharedGameState];
  [cell loadForBoosterPack:gs.boosterPacks[indexPath.row]];
  
  return cell;
}

@end
