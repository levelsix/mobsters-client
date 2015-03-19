//
//  AttackedAlertViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 2/6/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "AttackedAlertViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "GameViewController.h"

#import "ChatCell.h"

#define GREEN @"3E7D16"
#define RED @"BA0010"

#define LIGHT_RED @"E90005"
#define DARK_RED @"D30004"

#define ATTACK_ALERT_COUNT_KEY @"AttackAlertCountKey"

@implementation AttackAlertCell

- (void) updateForBattleHistory:(PvpHistoryProto *)php {
  [super updateForPrivateChat:php];
  
  self.msgLabel.textColor = php.userWon ? [UIColor colorWithHexString:GREEN] : [UIColor colorWithHexString:RED];
}

@end

@implementation AttackedAlertViewController

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.tableContainerView.layer.cornerRadius = 5.f;
  self.tableContainerView.layer.masksToBounds = YES;
  self.resultsContainerView.layer.cornerRadius = 5.f;
  self.alertsTable.backgroundColor = [UIColor clearColor];
  
  self.titleView.layer.cornerRadius = 5.f;
  self.titleView.layer.masksToBounds = YES;
  
  self.titleLabel.gradientStartColor = [UIColor colorWithHexString:LIGHT_RED];
  self.titleLabel.gradientEndColor = [UIColor colorWithHexString:DARK_RED];
  
  GameState *gs = [GameState sharedGameState];
  _curDefenses = [gs allUnreadDefenseHistorySinceLastLogin];
  _oilLost = 0;
  _cashLost = 0;
  _rankLost = 0;
  for( PvpHistoryProto *pvp in _curDefenses) {
    _oilLost += pvp.defenderOilChange;
    _cashLost += pvp.defenderCashChange;
    int change = pvp.defenderAfter.rank - pvp.defenderBefore.rank;
    _rankLost += change;
  }
  
  _oilLabel.text = [NSString stringWithFormat:@"%d", _oilLost];
  _cashLabel.text = [NSString stringWithFormat:@"%d", _cashLost];
  _rankLabel.text = [NSString stringWithFormat:@"%@%d", _rankLost > 0 ? "+" : "", _rankLost];
  
  PvpLeagueProto *league = gs.pvpLeague;
  NSString *icon = [league.imgPrefix stringByAppendingString:@"icon.png"];
  [Globals imageNamed:icon withView:self.rankIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

- (IBAction)clickedClose:(id)sender {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  GameViewController *gvc = [GameViewController baseController];
  
  NSInteger numAlerts = [defaults integerForKey:ATTACK_ALERT_COUNT_KEY];
  numAlerts++;
  [defaults setInteger:numAlerts forKey:ATTACK_ALERT_COUNT_KEY];
  
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgView completion:^{
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    if ((numAlerts%7 == 0) && ![defaults boolForKey:[Globals userConfimredPushNotificationsKey]]) {
      [gvc openPushNotificationRequestWithMessage:@"Would you like to recieve push notifications when you've been attacked?"];
    }
  }];
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    if(_completion) {
      _completion();
    }
  }];
}

#pragma mark - TableView delegate

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  AttackAlertCell *cell;
  cell = [tableView dequeueReusableCellWithIdentifier:@"AttackAlertCell"];
  if (!cell) {
    cell = [[NSBundle mainBundle] loadNibNamed:@"AttackAlertCell" owner:self options:nil][0];
  }
  
  PvpHistoryProto *php = _curDefenses[indexPath.row];
  
  [cell updateForBattleHistory:php];
  cell.backgroundColor = [UIColor clearColor];
  
  return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _curDefenses.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  id<ChatObject> post  = _curDefenses[indexPath.row];
  [post markAsRead];
  GameViewController *gvc = [GameViewController baseController];
  
  [gvc openPrivateChatWithUserUuid:post.otherUser.userUuid name:post.otherUser.name];
  [self close];
}

#pragma mark - TopBarNotification protocol

- (NotificationLocationType) locationType {
  return NotificationLocationTypeFullScreen;
}

- (NotificationPriority) priority {
  return NotificationPriorityFullScreen;
}

- (void) animateWithCompletionBlock:(dispatch_block_t)completion {
  GameViewController *gvc = [GameViewController baseController];
  [gvc addChildViewController:self];
  self.view.frame = gvc.view.bounds;
  [gvc.view addSubview:self.view];
  [Globals bounceView:self.mainView fadeInBgdView:self.bgView];
  _completion = completion;
}

- (void) endAbruptly {
  [self close];
}

@end
