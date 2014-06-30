//
//  GachaChooserViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/30/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "GachaChooserViewController.h"

#import "GameState.h"
#import "Globals.h"

#import "GameViewController.h"
#import "GachaponViewController.h"
#import "MenuNavigationController.h"

@implementation GachaChooserViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.listView.cellClassName = @"GachaChooserCardCell";
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self reloadListView];
}

#pragma mark - Reloading list view

- (void) reloadListView {
  [self reloadPackagesArray];
  [self.listView reloadTableAnimated:NO listObjects:self.boosterPacks];
  
  CGSize cs = self.listView.collectionView.contentSize;
  CGRect f = self.listView.collectionView.frame;
  if (cs.width < f.size.width) {
    self.listView.collectionView.contentOffset = ccp(cs.width/2-f.size.width/2, 0);
    self.listView.collectionView.scrollEnabled = NO;
  } else {
    self.listView.collectionView.contentOffset = ccp(0,0);
    self.listView.collectionView.scrollEnabled = YES;
  }
}

- (void) reloadPackagesArray {
  GameState *gs = [GameState sharedGameState];
  self.boosterPacks = [gs.boosterPacks copy];
}

#pragma mark - List view delegate

- (void) listView:(ListCollectionView *)listView updateCell:(ListCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath listObject:(BoosterPackProto *)bpp {
  UIButton *button = [cell.subviews[0] subviews][0];
  [Globals imageNamed:bpp.listBackgroundImgName withView:button greyscale:NO indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  GameViewController *gvc = [GameViewController baseController];;
  [gvc presentViewController:m animated:YES completion:nil];
  GachaponViewController *gach = [[GachaponViewController alloc] initWithBoosterPack:self.boosterPacks[indexPath.row]];
  [m pushViewController:gach animated:NO];
  
  [self.parentViewController close];
}

@end
