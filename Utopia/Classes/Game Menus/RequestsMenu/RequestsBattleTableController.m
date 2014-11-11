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
#import "UnreadNotifications.h"
#import "GenericPopupController.h"
#import "ClanInfoViewController.h"

@implementation RequestsBattleCell

- (void) awakeFromNib {
  for (MiniMonsterView *mv in self.monsterViews) {
    mv.transform = CGAffineTransformMakeScale(0.5, 0.5);
  }
}

- (void) updateForBattleHistory:(PvpHistoryProto *)history {
  GameState *gs = [GameState sharedGameState];
  self.battleHistory = history;
  
  if (history.attackerWon) {
    // You lost
    self.resultLabel.text = @"Defeat";
    self.resultLabel.highlighted = YES;
    
    self.rankChangeLabel.highlighted = YES;
    
    self.lootLostView.hidden = NO;
    self.oilLabel.text = [Globals commafyNumber:ABS(history.defenderOilChange)];
    self.cashLabel.text = [Globals commafyNumber:ABS(history.defenderCashChange)];
  } else {
    // You won
    self.resultLabel.text = @"Victory";
    self.resultLabel.highlighted = NO;
    
    self.rankChangeLabel.highlighted = NO;
    
    self.lootLostView.hidden = YES;
  }
  
  self.nameLabel.text = history.attacker.name;
  self.timeLabel.text = [Globals stringForTimeSinceNow:[MSDate dateWithTimeIntervalSince1970:history.battleEndTime/1000.] shortened:YES];
  
  CGSize s = [self.resultLabel.text getSizeWithFont:self.resultLabel.font];
  CGRect r = self.timeLabel.frame;
  r.origin.x = self.resultLabel.frame.origin.x+s.width+5;
  self.timeLabel.frame = r;
  
  for (int i = 0; i < self.monsterViews.count; i++) {
    FullUserMonsterProto *um = i < history.attackersMonstersList.count ? history.attackersMonstersList[i] : nil;
    MiniMonsterView *mv = self.monsterViews[i];
    [mv updateForMonsterId:um.monsterId];
  }
  
  self.revengeButtonView.hidden = history.exactedRevenge;
  
  UserPvpLeagueProto *pvpBefore = history.defenderBefore;
  UserPvpLeagueProto *pvpAfter = history.defenderAfter;
  
  if (pvpBefore.leagueId != pvpAfter.leagueId) {
    self.rankChangeLabel.text = @"New!";
  } else {
    int change = pvpAfter.rank-pvpBefore.rank;
    self.rankChangeLabel.text = [NSString stringWithFormat:@"%+d", -change];
  }
  PvpLeagueProto *pvp = [gs leagueForId:pvpAfter.leagueId];
  NSString *icon = [pvp.imgPrefix stringByAppendingString:@"icon.png"];
  [Globals imageNamed:icon withView:self.rankIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
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
    ClanInfoViewController *cvc = [[ClanInfoViewController alloc] initWithClanUuid:cell.battleHistory.attacker.clan.clanUuid andName:cell.battleHistory.attacker.clan.name];
    
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
    
    if ([Globals checkEnteringDungeon]) {
      GameViewController *gvc = [GameViewController baseController];
      [gvc beginPvpMatch:_curClickedCell.battleHistory];
    }
  }
}

#pragma mark - UITableViewDelegate/DataSource methods

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (self.battles.count > 0) {
    if (!self.headerView) {
      [[NSBundle mainBundle] loadNibNamed:@"RequestsBattleHeader" owner:self options:nil];
    }
    return self.headerView;
  }
  return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return self.battles.count ? tableView.sectionHeaderHeight :  0.f;
}

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
  return 45.f;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  RequestsBattleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RequestsBattleCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"RequestsBattleCell" owner:self options:nil];
    cell = self.requestCell;
  }

  PvpHistoryProto *req = self.battles[indexPath.row];
  [cell updateForBattleHistory:req];
  
  return cell;
}

@end
