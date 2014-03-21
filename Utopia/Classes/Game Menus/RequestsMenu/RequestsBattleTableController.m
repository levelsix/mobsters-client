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

@implementation RequestsBattleCell

- (void) awakeFromNib {
  for (ClanTeamMonsterView *mv in self.monsterViews) {
    mv.transform = CGAffineTransformMakeScale(0.7, 0.7);
  }
}

- (void) updateForBattleHistory:(PvpHistoryProto *)history {
  self.battleHistory = history;
  
  if (history.attackerWon) {
    // You lost
    self.bgdImage.image = [Globals imageNamed:@"teamlostbg.png"];
    
    self.titleLabel.text = @"Your team lost";
    self.titleLabel.highlighted = YES;
    
    self.rankChangeLabel.highlighted = YES;
    
    self.lootLostView.hidden = NO;
    self.oilLabel.text = [Globals commafyNumber:ABS(history.defenderOilChange)];
    self.cashLabel.text = [Globals cashStringForNumber:ABS(history.defenderCashChange)];
  } else {
    // You won
    self.bgdImage.image = [Globals imageNamed:@"teamwonbg.png"];
    
    self.titleLabel.text = @"Your team won";
    self.titleLabel.highlighted = NO;
    
    self.rankChangeLabel.highlighted = NO;
    
    self.lootLostView.hidden = YES;
  }
  
  [self.nameButton setTitle:history.attacker.name forState:UIControlStateNormal];
  
  if (history.attacker.hasClan) {
    [self.clanButton setTitle:history.attacker.clan.name forState:UIControlStateNormal];
    self.clanButton.enabled = YES;
    
    CGRect r = self.clanButton.frame;
    r.origin.x = self.shieldIcon.frame.size.width+3;
    self.clanButton.frame = r;
    
    self.shieldIcon.hidden = NO;
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
    um.teamSlot = (int)[cell.battleHistory.attackersMonstersList indexOfObject:mon];
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
  while (![sender isKindOfClass:[RequestsBattleCell class]]) {
    sender = [sender superview];
  }
  RequestsBattleCell *cell = (RequestsBattleCell *)sender;
  
  if ([Globals checkEnteringDungeonWithTarget:self selector:@selector(visitTeamPage)]) {
    GameViewController *gvc = [GameViewController baseController];
    [gvc beginPvpMatch:cell.battleHistory];
  }
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
  return 92.f;
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
