//
//  RequestsBattleTableController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/19/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "RequestsBattleTableController.h"
#import "GameState.h"
#import "GameViewController.h"
#import "ProfileViewController.h"
#import "MenuNavigationController.h"
#import "MyCroniesViewController.h"
#import "UnreadNotifications.h"
#import "GenericPopupController.h"

@implementation RequestsBattleCell

- (void) awakeFromNib {
  for (ClanTeamMonsterView *mv in self.monsterViews) {
    mv.transform = CGAffineTransformMakeScale(0.64, 0.64);
  }
}

- (void) updateForBattleHistory:(PvpHistoryProto *)history {
  GameState *gs = [GameState sharedGameState];
  self.battleHistory = history;
  
  if (history.attackerWon) {
    // You lost
    self.bgdImage.highlighted = YES;
    
    self.titleLabel.text = @"Your team lost";
    self.titleLabel.highlighted = YES;
    
    self.rankChangeLabel.highlighted = YES;
    
    self.lootLostView.hidden = NO;
    self.oilLabel.text = [Globals commafyNumber:ABS(history.defenderOilChange)];
    self.cashLabel.text = [Globals cashStringForNumber:ABS(history.defenderCashChange)];
  } else {
    // You won
    self.bgdImage.highlighted = NO;
    
    self.titleLabel.text = @"Your team won";
    self.titleLabel.highlighted = NO;
    
    self.rankChangeLabel.highlighted = NO;
    
    self.lootLostView.hidden = YES;
  }
  
  [self.nameButton setTitle:history.attacker.name forState:UIControlStateNormal];
  
  if (history.attacker.hasClan) {
    [self.clanButton setTitle:history.attacker.clan.name forState:UIControlStateNormal];
    self.clanButton.enabled = YES;
    
    self.shieldIcon.hidden = NO;
    ClanIconProto *icon = [gs clanIconWithId:history.attacker.clan.clanIconId];
    [Globals imageNamed:icon.imgName withView:self.shieldIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    CGRect r = self.clanButton.frame;
    r.origin.x = self.shieldIcon.frame.size.width+3;
    self.clanButton.frame = r;
    
  } else {
    self.clanButton.enabled = NO;
    self.shieldIcon.hidden = YES;
    
    CGRect r = self.clanButton.frame;
    r.origin.x = 0;
    self.clanButton.frame = r;
  }
  
  for (int i = 0; i < self.monsterViews.count; i++) {
    FullUserMonsterProto *um = i < history.attackersMonstersList.count ? history.attackersMonstersList[i] : nil;
    ClanTeamMonsterView *mv = self.monsterViews[i];
    [mv updateForMonsterId:um.monsterId];
  }
  
  self.revengeButtonView.hidden = history.exactedRevenge;
}

@end

@implementation RequestsBattleTableController

- (void) becameDelegate:(UITableView *)requestsTable noRequestsLabel:(UILabel *)noRequestsLabel spinner:(UIActivityIndicatorView *)spinner {
  self.requestsTable = requestsTable;
  self.noRequestsLabel = noRequestsLabel;
  self.spinner = spinner;
  [self reloadRequestsArray];
  self.spinner.hidden = YES;
}

- (void) resignDelegate {
  self.requestsTable = nil;
  self.noRequestsLabel = nil;
  self.spinner = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) reloadRequestsArray {
  GameState *gs = [GameState sharedGameState];
  self.battles = [gs.battleHistory mutableCopy];
  
  for (PvpHistoryProto *pvp in self.battles) {
    [pvp markAsRead];
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:BATTLE_HISTORY_VIEWED_NOTIFICATION object:nil];
  
  [self.requestsTable reloadData];
}

- (IBAction) nameClicked:(id)sender {
  while (![sender isKindOfClass:[RequestsBattleCell class]]) {
    sender = [sender superview];
  }
  RequestsBattleCell *cell = (RequestsBattleCell *)sender;
  
  NSMutableArray *monsters = [NSMutableArray array];
  for (MinimumUserMonsterProto *mon in cell.battleHistory.attackersMonstersList) {
    UserMonster *um = [UserMonster userMonsterWithMinProto:mon];
    um.teamSlot = (int)[cell.battleHistory.attackersMonstersList indexOfObject:mon]+1;
    [monsters addObject:um];
  }
  
  GameViewController *gvc = [GameViewController baseController];
  ProfileViewController *pvc = [[ProfileViewController alloc] initWithFullUserProto:cell.battleHistory.attacker andCurrentTeam:monsters];
  [gvc addChildViewController:pvc];
  pvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:pvc.view];
}

- (IBAction) clanClicked:(id)sender {
  while (![sender isKindOfClass:[RequestsBattleCell class]]) {
    sender = [sender superview];
  }
  RequestsBattleCell *cell = (RequestsBattleCell *)sender;
  
  if (cell.battleHistory.attacker.hasClan) {
    GameViewController *gvc = [GameViewController baseController];
    ClanInfoViewController *cvc = [[ClanInfoViewController alloc] initWithClanId:cell.battleHistory.attacker.clan.clanId andName:cell.battleHistory.attacker.clan.name];
    
    MenuNavigationController *m = [[MenuNavigationController alloc] init];
    [gvc presentViewController:m animated:YES completion:nil];
    [m pushViewController:cvc animated:NO];
  }
}

- (IBAction) revengeClicked:(id)sender {
  if (!_curClickedCell) {
    while (![sender isKindOfClass:[RequestsBattleCell class]]) {
      sender = [sender superview];
    }
    RequestsBattleCell *cell = (RequestsBattleCell *)sender;
    _curClickedCell = cell;
    
    if ([Globals checkEnteringDungeonWithTarget:self selector:@selector(visitTeamPage)]) {
      GameState *gs = [GameState sharedGameState];
      if (gs.hasActiveShield) {
        NSString *desc = @"Attacking will disable your shield, and other players will be able to attack you. Are you sure?";
        [GenericPopupController displayNegativeConfirmationWithDescription:desc title:@"Shield is active" okayButton:@"Attack" cancelButton:@"Cancel" okTarget:self okSelector:@selector(performRevenge) cancelTarget:self cancelSelector:@selector(deniedRevenge)];
      } else {
        [self performRevenge];
      }
    }
  }
}

- (void) performRevenge {
  GameViewController *gvc = [GameViewController baseController];
  [gvc beginPvpMatch:_curClickedCell.battleHistory];
}

- (void) deniedRevenge {
  _curClickedCell = nil;
}

- (void) visitTeamPage {
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  GameViewController *gvc = [GameViewController baseController];
  [gvc presentViewController:m animated:YES completion:nil];
  [m pushViewController:[[MyCroniesViewController alloc] init] animated:NO];
}

#pragma mark - UITableViewDelegate/DataSource methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger ct = self.battles.count;
  if (ct == 0) {
    self.noRequestsLabel.text = @"You have never been attacked.";
    self.noRequestsLabel.hidden = NO;
  } else {
    self.noRequestsLabel.hidden = YES;
  }
  return ct;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 90.f;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  RequestsBattleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RequestsBattleCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"RequestsBattleCell" owner:self options:nil];
    cell = self.requestCell;
  }
  GameState *gs = [GameState sharedGameState];
  PvpHistoryProto_Builder *bldr = [PvpHistoryProto builder];
  FullUserProto *fup = [gs convertToFullUserProto];
  bldr.attacker = fup;
  bldr.attackerWon = arc4random() %2;
  bldr.defenderOilChange = -12421;
  bldr.defenderCashChange = -5932;
  bldr.exactedRevenge = arc4random() %2;
  
  for (UserMonster *um in gs.allMonstersOnMyTeam) {
    [bldr addAttackersMonsters:[um convertToMinimumProto]];
  }

  PvpHistoryProto *req = self.battles[indexPath.row];
  [cell updateForBattleHistory:req];
  
  return cell;
}

@end
