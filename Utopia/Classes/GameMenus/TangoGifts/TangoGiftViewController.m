//
//  TangoGiftViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 5/8/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "TangoDelegate.h"
#import "TangoGiftViewController.h"
#import "FBChooserView.h"

#import "Globals.h"

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
  
  self.friendListActivityIndicator.hidesWhenStopped = YES;
  [self.friendListActivityIndicator stopAnimating];
}

- (IBAction)close:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

- (BOOL) areAllEntriesSelected {
  int totalCount = 0;
  for (NSArray *arr in self.tangoFriends) {
    totalCount += arr.count;
  }
  
  return self.selectedFriends.count >= totalCount;
}

-(IBAction)selectallClicked:(id)sender {
  if ([self areAllEntriesSelected]) {
    [self.selectedFriends removeAllObjects];
    self.selectAllCheckmark.hidden = YES;
    
  } else {
    
    for (NSArray *arr in self.tangoFriends) {
      for (TangoProfileEntry *tpe in arr) {
        [self.selectedFriends addObject:tpe];
      }
    }
    
    self.selectAllCheckmark.hidden = NO;
  }
  
  NSLog(self.selectAllCheckmark.hidden ? @"Yes" : @"No");
}

#pragma mark - table delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
  //The number of different friends that start with a different letter
  return self.tangoFriends.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSMutableArray *profileList = self.tangoFriends[section];
  return profileList.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  FBFriendCell *cell = (FBFriendCell *)[tableView cellForRowAtIndexPath:indexPath];
  TangoProfileEntry *tangoProfile = self.tangoFriends[indexPath.row];
  
  if ([self.selectedFriends containsObject:tangoProfile]) {
    [self.selectedFriends removeObject:tangoProfile];
    cell.checkmark.hidden = YES;
  } else {
    [self.selectedFriends addObject:tangoProfile];
    cell.checkmark.hidden = NO;
  }
  
  self.selectAllCheckmark.hidden = ![self areAllEntriesSelected];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FBFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FBFriendCell"];
  
  if (cell == nil) {
    cell = [[NSBundle mainBundle] loadNibNamed:@"FBFriendCell" owner:self options:nil][0];
  }
  
  TangoProfileEntry *tangoProfile = self.tangoFriends[indexPath.row];
  [cell loadForTangoProfile:tangoProfile];
  cell.checkmark.hidden = ![self.selectedFriends containsObject:tangoProfile];
  return cell;
}

@end
