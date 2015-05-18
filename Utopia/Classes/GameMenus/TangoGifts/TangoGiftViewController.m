//
//  TangoGiftViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 5/8/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "TangoGiftViewController.h"
#import "GameViewController.h"
#import "OutgoingEventController.h"

#import "Globals.h"

@implementation TangoFriendViewCell

- (void) setDefaultProfilePicture {
  self.tangoPic.image = [Globals imageNamed:@"tangodefault.png"];
}

- (void) loadForTangoProfile:(id)tangoProfile {
// get full name
#ifdef TOONSQUAD
  self.nameLabel.text = [TangoDelegate getFullNameForProfile:tangoProfile];
  
  [TangoDelegate getPictureForProfile:tangoProfile comp:^(UIImage *img) {
    self.tangoPic.image = img;
  }];
#endif
  
  self.tangoPic.layer.cornerRadius = roundf(self.tangoPic.frame.size.width/2.0);
  self.tangoPic.layer.masksToBounds = YES;
}

@end

@implementation TangoGiftViewController

- (void) awakeFromNib {
  self.tangoFriends = [NSMutableArray array];
  self.selectedFriends = [NSMutableArray array];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgView];
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.containerView.superview.layer.cornerRadius = 5.f;
  self.containerView.superview.clipsToBounds = YES;
}

- (void) updateForTangoFriends:(NSArray *)friends {
  
  NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"profileID" ascending:YES selector:@selector(caseInsensitiveCompare:)];
  
  self.tangoFriends  = [friends mutableCopy];
  [self.tangoFriends sortedArrayUsingDescriptors:@[sorter]];
  self.selectedFriends = [self.tangoFriends mutableCopy];
  self.rewardLabel.text = [NSString stringWithFormat:@"%d", (int)MIN(self.tangoFriends.count, 3)];
  
  self.friendListActivityIndicator.hidesWhenStopped = YES;
  [self.friendListActivityIndicator stopAnimating];
  
  [self.tableView reloadData];
}

- (BOOL) areAllEntriesSelected {
  [self.tableView reloadData];
  return self.selectedFriends.count == self.tangoFriends.count;
}

- (int) updateRewardAmount {
  Globals *gl = [Globals sharedGlobals];
  if (!self.selectedFriends.count) {
    self.rewardLabel.text = @"0";
    return 0;
  } else {
    int rewardAmount = MAX(gl.tangoMaxGemReward - ((int)self.tangoFriends.count - (int)self.selectedFriends.count), gl.tangoMinGemReward);
    rewardAmount = MIN(gl.tangoMaxGemReward, rewardAmount);
    self.rewardLabel.text = [NSString stringWithFormat:@"%d", rewardAmount];
    return rewardAmount;
  }
}

- (IBAction) close:(id)sender {
  [self close];
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

- (IBAction) selectallClicked:(id)sender {
  if ([self areAllEntriesSelected]) {
    [self.selectedFriends removeAllObjects];
    self.selectAllCheckmark.hidden = YES;
    
  } else {
    self.selectedFriends = [self.tangoFriends mutableCopy];
    self.selectAllCheckmark.hidden = NO;
  }
  
  [self updateRewardAmount];
}

- (IBAction) sendClicked:(id)sender {
#ifdef TOONSQUAD
  NSArray *withAppList = [TangoDelegate getTangoIdsForProfiles:self.selectedFriends withApp:YES];
  NSArray *withoutAppList = [TangoDelegate getTangoIdsForProfiles:self.selectedFriends withApp:NO];
  int reward = [self updateRewardAmount];
  if (withAppList.count > 0 || withoutAppList.count > 0) {
    [[OutgoingEventController sharedOutgoingEventController] sendTangoGiftsToTangoUsers:withAppList gemReward:reward delegate:self];
  }
  
  if (withoutAppList.count > 0) {
    [TangoDelegate sendInvitesToTangoUsers:withoutAppList];
  }
#endif
  [self close];
}

#pragma mark - table delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.tangoFriends.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  TangoFriendViewCell *cell = (TangoFriendViewCell *)[tableView cellForRowAtIndexPath:indexPath];
  id tangoProfile = self.tangoFriends[indexPath.row];
  
  if ([self.selectedFriends containsObject:tangoProfile]) {
    [self.selectedFriends removeObject:tangoProfile];
    cell.checkmark.hidden = YES;
  } else {
    [self.selectedFriends addObject:tangoProfile];
    cell.checkmark.hidden = NO;
  }
  
  self.selectAllCheckmark.hidden = ![self areAllEntriesSelected];
  [self updateRewardAmount];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  //TangoFriendViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TangoFriendViewCell"];
  //Can't use reusableCells becuase the profile picture code block passed into the tangoDelegate returns after the the cell has been reused
  //if the player is scrolling too fase so profile pictures seem to random flash to other images.
  
  TangoFriendViewCell *cell = (TangoFriendViewCell *)[[NSBundle mainBundle] loadNibNamed:@"TangoFriendViewCell" owner:self options:nil][0];
  //loading Tango profile picture is delayed, so load the default now.
  [cell setDefaultProfilePicture];
  
  id tangoProfile = self.tangoFriends[indexPath.row];
  [cell loadForTangoProfile:tangoProfile];
  cell.checkmark.hidden = ![self.selectedFriends containsObject:tangoProfile];
  return cell;
}

#pragma mark - TopBarNotification protocol

- (NotificationLocationType) locationType {
  return NotificationLocationTypeFullScreen;
}

- (NotificationPriority) priority {
  return NotificationPriorityRegular;
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
