//
//  ClanHelpViewController.m
//  Utopia
//
//  Created by Ashwin on 10/9/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanHelpViewController.h"

#import "GameState.h"
#import "Globals.h"
#import "ProfileViewController.h"
#import "GameViewController.h"

@implementation ClanHelpCell

- (void) updateForClanHelp:(id<ClanHelp>)help {
  [self.userIcon updateForMonsterId:[help requester].avatarMonsterId];
  self.nameLabel.text = [help requester].name;
  self.actionLabel.text = [help helpString];
  
  int numHelps = [help numHelpers];
  int maxHelps = [help maxHelpers];
  
  NSString *str1 = @"Help: ";
  NSString *str2 = [NSString stringWithFormat:@"%d/%d", numHelps, maxHelps];
  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", str1, str2]];
  [attr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Gotham-Ultra" size:10] range:NSMakeRange(str1.length, str2.length)];
  
  self.numHelpsLabel.attributedText = attr;
  self.progressBar.percentage = numHelps/(float)maxHelps;
  
  GameState *gs = [GameState sharedGameState];
  self.helpButtonView.hidden = ![help canHelpForUserId:gs.userId];
  self.helpedView.hidden = ![help hasHelpedForUserId:gs.userId];
  
  self.clanHelp = help;
}

@end

@implementation ClanHelpViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  GameState *gs = [GameState sharedGameState];
  self.botLabel.text = [NSString stringWithFormat:@"The higher your %@ level, the more help you can receive.", gs.myClanHouse.staticStruct.structInfo.name];
  
  self.botLabel.superview.layer.cornerRadius = 6.f;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self reloadTableAnimated:NO];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(helpsChanged) name:CLAN_HELPS_CHANGED_NOTIFICATION object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) helpsChanged {
  [self reloadTableAnimated:YES];
}

- (void) reloadHelpsArray {
  // Don't want to delete any of the things in the array already.. so use a set.
  GameState *gs = [GameState sharedGameState];
  
  NSArray *arr = [gs.clanHelpUtil getAllHelpableClanHelps];
  NSMutableSet *newHelps = [NSMutableSet setWithArray:arr];
  
  for (id<ClanHelp> ch in self.helpsArray) {
    if ([ch clanId] == gs.clan.clanId) {
      [newHelps addObject:ch];
    }
  }
  
  NSArray *unionArr = newHelps.allObjects;
  
  NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id<ClanHelp> ch, NSDictionary *bindings) {
    return [ch isOpen];
  }];
  unionArr = [unionArr filteredArrayUsingPredicate:pred];
  
  unionArr = [unionArr sortedArrayUsingComparator:^NSComparisonResult(id<ClanHelp> obj1, id<ClanHelp> obj2) {
    return [[obj2 requestedTime] compare:[obj1 requestedTime]];
  }];
  
  self.helpsArray = unionArr;
}

#pragma mark - Table View Delegate

- (void) reloadTableAnimated:(BOOL)animated {
  NSArray *oldArr = self.helpsArray;
  [self reloadHelpsArray];
  
  if (animated) {
    NSMutableArray *removedIps = [NSMutableArray array], *addedIps = [NSMutableArray array];
    NSMutableDictionary *movedIps = [NSMutableDictionary dictionary];
    
    [Globals calculateDifferencesBetweenOldArray:oldArr newArray:self.helpsArray removalIps:removedIps additionIps:addedIps movedIps:movedIps section:0];
    
    [self.helpTable beginUpdates];
    
    [self.helpTable deleteRowsAtIndexPaths:removedIps withRowAnimation:UITableViewRowAnimationFade];
    
    for (NSIndexPath *ip in movedIps) {
      NSIndexPath *newIp = movedIps[ip];
      [self.helpTable moveRowAtIndexPath:ip toIndexPath:newIp];
    }
    [self.helpTable insertRowsAtIndexPaths:addedIps withRowAnimation:UITableViewRowAnimationFade];
    
    [self.helpTable endUpdates];
    
    for (ClanHelpCell *cell in self.helpTable.visibleCells) {
      [cell updateForClanHelp:self.helpsArray[[self.helpTable indexPathForCell:cell].row]];
    }
  } else {
    [self.helpTable reloadData];
  }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  int ct = (int)self.helpsArray.count;
  self.noHelpsLabel.hidden = !!ct;
  self.helpAllView.hidden = !ct;
  return ct;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ClanHelpCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClanHelpCell"];
  
  if (!cell) {
    cell = [[NSBundle mainBundle] loadNibNamed:@"ClanHelpCell" owner:self options:nil][0];
  }
  
  [cell updateForClanHelp:self.helpsArray[indexPath.row]];
  
  return cell;
}

#pragma mark - IBActions

- (IBAction) helpClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[ClanHelpCell class]]) {
    sender = [sender superview];
  }
  
  if (sender) {
    ClanHelpCell *cell = (ClanHelpCell *)sender;
    
    GameState *gs = [GameState sharedGameState];
    [gs.clanHelpUtil giveClanHelps:@[cell.clanHelp]];
    
    [self reloadTableAnimated:NO];
  }
}

- (IBAction) helpAllClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  [gs.clanHelpUtil giveClanHelps:self.helpsArray];
  
  [self reloadTableAnimated:NO];
}

- (IBAction) profileClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[ClanHelpCell class]]) {
    sender = [sender superview];
  }
  
  if (sender) {
    ClanHelpCell *cell = (ClanHelpCell *)sender;
    ProfileViewController *mpvc = [[ProfileViewController alloc] initWithUserId:[cell.clanHelp requester].userId];
    UIViewController *parent = [GameViewController baseController];
    mpvc.view.frame = parent.view.bounds;
    [parent.view addSubview:mpvc.view];
    [parent addChildViewController:mpvc];
  }
}

@end
