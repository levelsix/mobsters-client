//
//  ActivityFeedController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/17/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ActivityFeedController.h"
#import "LNSynthesizeSingleton.h"
#import "cocos2d.h"
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "GameLayer.h"

@implementation ActivityFeedCell

@synthesize notiView;

- (void) updateForNotification:(UserNotification *)n {
  [self.notiView updateForNotification:n];
}

@end

@implementation NotificationView

@synthesize titleLabel, subtitleLabel, userIcon, button, buttonLabel, timeLabel;
@synthesize notification;

- (void) updateForNotification:(UserNotification *)n {
  self.notification = n;
  
  NSString *name = [Globals fullNameWithName:notification.otherPlayer.name clanTag:notification.otherPlayer.clan.tag];
  
  timeLabel.text = [Globals stringForTimeSinceNow:n.time shortened:NO];
  
  if (notification.type == kNotificationBattle) {
    
    BOOL won = notification.battleResult != BattleResultAttackerWin ? YES : NO;
    if (won) {
      titleLabel.text = [NSString stringWithFormat:@"You beat %@.", name ];
      titleLabel.textColor = [Globals greenColor];
      buttonLabel.text = @"Attack";
    } else {
      titleLabel.text = [NSString stringWithFormat:@"You lost to %@.", name ];
      titleLabel.textColor = [Globals redColor];
      buttonLabel.text = @"Revenge";
    }
    
    [button setImage:[Globals imageNamed:@"revenge.png"] forState:UIControlStateNormal];
  } else if (notification.type == kNotificationPrivateChat) {
    // This will only be used in the drop down notifications
    titleLabel.text = [NSString stringWithFormat:@"%@ has sent you a message.", name];
    subtitleLabel.text = notification.wallPost;
    
    titleLabel.textColor = [Globals blueColor];
  } else if (notification.type == kNotificationGeneral) {
    titleLabel.text = notification.title;
    subtitleLabel.text = notification.subtitle;
    
    titleLabel.textColor = notification.color;
  }
  
  NSArray *users = [[ActivityFeedController sharedActivityFeedController] users];
  if (users) {
    button.hidden = NO;
    buttonLabel.hidden = NO;
  } else {
    button.hidden = YES;
    buttonLabel.hidden = YES;
  }
}

- (IBAction)buttonClicked:(id)sender {
  if (notification.type == kNotificationBattle) {
    NSArray *users = [[ActivityFeedController sharedActivityFeedController] users];
    
    FullUserProto *user = nil;
    for (FullUserProto *fup in users) {
      if (fup.userId == notification.otherPlayer.userId) {
        user = fup;
        break;
      }
    }
    
    if (user) {
//      BOOL success = [[BattleLayer sharedBattleLayer] beginBattleAgainst:user];
//      if (success) {
//        [[ActivityFeedController sharedActivityFeedController] close];
//      }
    }
    
    [Analytics clickedRevenge];
  }
}

- (IBAction)profilePicClicked:(id)sender {
//    NSArray *users = [[ActivityFeedController sharedActivityFeedController] users];
//    
//    FullUserProto *user = nil;
//    for (FullUserProto *fup in users) {
//      if (fup.userId == notification.otherPlayer.userId) {
//        user = fup;
//        break;
//      }
//    }
//    
//    if (user) {
//      [[ProfileViewController sharedProfileViewController] loadProfileForPlayer:user buttonsEnabled:YES];
//    } else {
//      [[ProfileViewController sharedProfileViewController] loadProfileForMinimumUser:notification.otherPlayer withState:kProfileState];
//    }
//    [ProfileViewController displayView];
}

@end

@implementation ActivityFeedController

@synthesize activityTableView, actCell, users;
@synthesize mainView, bgdView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ActivityFeedController);

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  self.users = [NSMutableArray array];
}

- (void) viewWillAppear:(BOOL)animated {
  NSArray *notifications = [[GameState sharedGameState] notifications];
  NSMutableArray *userIds = [NSMutableArray arrayWithCapacity:notifications.count];
  
  for (UserNotification *un in notifications) {
    [userIds addObject:[NSNumber numberWithInt:un.otherPlayer.userId]];
  }
  
  [self.users removeAllObjects];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  [[OutgoingEventController sharedOutgoingEventController] retrieveUsersForUserIds:userIds];
  
  [self.activityTableView reloadData];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  self.noNotificationLabel.hidden = gs.notifications.count > 0;
  return gs.notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"ActivityFeed";
  
  ActivityFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"ActivityFeedCell" owner:self options:nil];
    cell = self.actCell;
  }
  
  UserNotification *un = [[[GameState sharedGameState] notifications] objectAtIndex:indexPath.row];
  [cell updateForNotification:un];
  
  [[cell.contentView viewWithTag:1001] removeFromSuperview];
  if (!un.hasBeenViewed) {
    UIView *view = [[UIView alloc] initWithFrame:cell.bounds];
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08f];
    view.tag = 1001;
    [cell.contentView insertSubview:view atIndex:0];
  }
  
  if (un.type == kNotificationBattle) {
    FullUserProto *user = nil;
    for (FullUserProto *fup in users) {
      if (fup.userId == un.otherPlayer.userId) {
        user = fup;
        break;
      }
    }
    if (user) {
      cell.notiView.button.hidden = NO;
      cell.notiView.buttonLabel.hidden = NO;
    } else {
      cell.notiView.button.hidden = YES;
      cell.notiView.buttonLabel.hidden = YES;
    }
  }
  
  return cell;
}

- (IBAction)closeClicked:(id)sender {
  [self close];
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [ActivityFeedController removeView];
  }];
  
  // Set all the notifications as viewed.
  for (UserNotification *un in [GameState sharedGameState].notifications) {
    un.hasBeenViewed = YES;
  }
}

- (void) receivedUsers:(RetrieveUsersForUserIdsResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  NSArray *notifications = gs.notifications;
  for (FullUserProto *fup in proto.requestedUsersList) {
    for (UserNotification *un in notifications) {
      if (un.otherPlayer.userId == fup.userId) {
        [self.users addObject:fup];
      }
    }
  }
  [self.activityTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.activityTableView = nil;
    self.actCell = nil;
    self.users = nil;
    self.mainView = nil;
    self.noNotificationLabel = nil;
    self.bgdView = nil;
  }
}

@end
