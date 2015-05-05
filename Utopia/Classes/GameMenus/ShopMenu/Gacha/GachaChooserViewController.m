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
#import "NewGachaViewController.h"
#import "MenuNavigationController.h"

#import "GachaViews.h"

@implementation GachaChooserViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.listView.cellClassName = @"GachaChooserCardCell";
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self reloadListView];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self adjustSizeOfView];
}

#pragma mark - Reloading list view

- (void) reloadListView {
  [self reloadPackagesArray];
  [self.listView reloadTableAnimated:NO listObjects:self.boosterPacks];
  
  [self adjustSizeOfView];
}

- (void) adjustSizeOfView {
  CGSize cs = self.listView.collectionView.contentSize;
  CGRect f = self.view.frame;
  CGSize ss = self.view.superview.frame.size;
  if (cs.width < ss.width) {
    self.listView.collectionView.scrollEnabled = NO;
    
    f.size.width = cs.width;
    f.origin.x = ss.width/2-f.size.width/2;
    self.view.frame = f;
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

- (void) listView:(ListCollectionView *)listView updateCell:(GachaCardCell *)cell forIndexPath:(NSIndexPath *)indexPath listObject:(BoosterPackProto *)bpp {
  GameState *gs = [GameState sharedGameState];
  [Globals imageNamed:bpp.listBackgroundImgName withView:cell.mainButton greyscale:NO indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  if (indexPath.row == 0)
    [cell.badge instantlySetBadgeNum:[gs hasDailyFreeSpin]+[gs numberOfFreeSpinsForBoosterPack:bpp.boosterPackId]];
  else
    [cell.badge instantlySetBadgeNum:[gs numberOfFreeSpinsForBoosterPack:bpp.boosterPackId]];
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  NewGachaNavigationController *m = [[NewGachaNavigationController alloc] init];
  GameViewController *gvc = [GameViewController baseController];
  [gvc presentViewController:m animated:YES completion:nil];
  NewGachaViewController *gach = [[NewGachaViewController alloc] initWithBoosterPack:self.boosterPacks[indexPath.row]];
  [m pushViewController:gach animated:NO];
  
  [self.parentViewController close];
  [[GameViewController baseController] showEarlyGameTutorialArrow];
}

@end
