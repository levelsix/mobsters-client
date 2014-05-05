//
//  MiniJobsDetailsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/1/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniJobsDetailsViewController.h"
#import "GameState.h"
#import "Globals.h"

@implementation MiniJobsDetailsCell

- (void) updateForUserMonster:(UserMonster *)um requiredHp:(int)reqHp requiredAttack:(int)reqAtk {
  Globals *gl = [Globals sharedGlobals];
  MonsterProto *mp = um.staticMonster;
  
  [self.monsterView updateForMonsterId:um.monsterId];
  
  self.nameLabel.text = mp.name;
  self.levelLabel.text = [NSString stringWithFormat:@"LVL. %d", um.level];
  
  int curHealth = um.curHealth, curAtk = [gl calculateTotalDamageForMonster:um];
  self.hpLabel.text = [NSString stringWithFormat:@"HP: %@", [Globals commafyNumber:curHealth]];
  self.attackLabel.text = [NSString stringWithFormat:@"ATTACK: %@", [Globals commafyNumber:curAtk]];
  
  self.hpProgressBar.percentage = curHealth/(float)reqHp;
  self.attackProgressBar.percentage = curAtk/(float)reqAtk;
  
  self.userMonster = um;
}

@end

@implementation MiniJobsDetailsViewController

- (void) viewWillAppear:(BOOL)animated {
  [self reloadTableAnimated:animated];
}

- (void) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [NSMutableArray array];
  
  for (UserMonster *um in gs.myMonsters) {
    if (um.isDonatable && ![self.pickedMonsters containsObject:um]) {
      [arr addObject:um];
    }
  }
  
  [arr sortUsingComparator:^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    return [obj1 compare:obj2];
  }];
  
  self.monsterArray = arr;
}

- (void) reloadTableAnimated:(BOOL)animated {
  [self reloadMonstersArray];
  [self.monstersTable reloadData];
}

#pragma mark - Picking and unpicking monsters

- (void) pickMonsterAtRow:(int)row {
  
}

#pragma mark - UITableView dataSource/delegate

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return self.headerView;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.monsterArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  MiniJobsDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MiniJobsDetailsCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"MiniJobsDetailsCell" owner:self options:nil];
    cell = self.detailsCell;
  }
  
  UserMonster *um = self.monsterArray[indexPath.row];
  [cell updateForUserMonster:um requiredHp:1000 requiredAttack:150];
  
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  [self pickMonsterAtRow:indexPath.row];
}

@end
