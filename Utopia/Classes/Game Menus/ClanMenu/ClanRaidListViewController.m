//
//  ClanRaidViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanRaidListViewController.h"
#import "ClanRaidViewController.h"
#import "GameState.h"
#import "PersistentEventProto+Time.h"
#import "GameViewController.h"
#import "ClanViewController.h"

@implementation ClanRaidListViewController

- (void) viewWillAppear:(BOOL)animated {
  self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
  
  [self reloadArrays];
}


- (void) viewDidDisappear:(BOOL)animated {
  [self.timer invalidate];
  self.timer = nil;
}

- (void) updateLabels {
  for (ClanRaidListCell *cell in self.raidsTable.visibleCells) {
    [cell updateTime];
  }
}

#pragma mark - UITableView delegate/dataSource

- (void) reloadArrays {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *active = [NSMutableArray array];
  NSMutableArray *inactive = [NSMutableArray array];
  
  for (PersistentClanEventProto *e in gs.persistentClanEvents) {
    if (e.isRunning) {
      [active addObject:e];
    } else {
      [inactive addObject:e];
    }
  }
  
  NSComparator comp = ^NSComparisonResult(PersistentClanEventProto *e1, PersistentClanEventProto *e2) {
    return [e1.startTime compare:e2.startTime];
  };
  
  [active sortUsingComparator:comp];
  [inactive sortUsingComparator:comp];
  
  self.activeEvents = active;
  self.inactiveEvents = inactive;
  
  [self.raidsTable reloadData];
}

- (NSArray *) arrayForSection:(NSInteger)section {
  if (section == 0) {
    return self.activeEvents;
  } else if (section == 1) {
    return self.inactiveEvents;
  }
  return nil;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self arrayForSection:section].count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *str = nil;
  
  if (indexPath.section == 0) {
    str = @"ClanRaidActiveCell";
  } else if (indexPath.section == 1) {
    str = @"ClanRaidInactiveCell";
  }
  
  ClanRaidListCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:str owner:self options:nil];
    cell = self.nibCell;
  }
  
  [cell updateForEvent:[self arrayForSection:indexPath.section][indexPath.row]];
  
  return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    return 139.f;
  } else {
    return 68.f;
  }
}

#pragma mark - IBActions

- (IBAction)raidSelected:(ClanRaidListCell *)sender {
  while (sender && ![sender isKindOfClass:[ClanRaidListCell class]]) {
    sender = (ClanRaidListCell *)sender.superview;
  }
  
  // Check if the clan info has a members list
  ClanViewController *cvc = (ClanViewController *)self.parentViewController;
  ClanRaidViewController *details = [[ClanRaidViewController alloc] initWithClanEvent:sender.clanEvent membersList:cvc.myClanMembersList canStartRaidStage:cvc.canStartRaidStage];
  self.raidViewController = details;
  [self.navigationController pushViewController:details animated:YES];
  
}

@end
