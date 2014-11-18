//
//  FBChooserView.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/3/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "FBChooserView.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Globals.h"
#import <QuartzCore/QuartzCore.h>
#import "FacebookDelegate.h"
#import <UIKit+AFNetworking.h>

@implementation FBFriendCell

- (void) loadForData:(NSDictionary *)data {
  self.nameLabel.text = data[@"name"];
  
  self.profilePic.profileID = nil;
  
  [self.profilePic.imageView cancelImageRequestOperation];
  
  // Invitable friends have picture property..
  // Actual friends don't so just set the id
  if (![data objectForKey:@"picture"]) {
    self.profilePic.profileID = data[@"id"];
  } else if (self.profilePic.subviews.count == 1) {
    UIImageView *iv = self.profilePic.imageView;
    iv.contentMode = UIViewContentModeScaleToFill;
    
    NSURL *url = [NSURL URLWithString:data[@"picture"][@"data"][@"url"]];
    [self.profilePic.imageView setImageWithURL:url];
  }
  
  self.profilePic.layer.cornerRadius = roundf(self.profilePic.frame.size.width/2.0);
  self.profilePic.layer.masksToBounds = YES;
}

@end

@implementation FBChooserView

- (void) awakeFromNib {
  [self retrieveFacebookFriends:NO];
  
  self.chooserTable.tableFooterView = [[UIView alloc] init];
  
  self.allFriendsData = [NSMutableArray array];
  self.gameFriendsData = [NSMutableArray array];
  
  self.state = FBChooserStateAllFriends;
}

- (void) retrieveFacebookFriends:(BOOL)openLoginUI {
  if (_retrievedFriends) return;
  
  self.spinner.hidden = NO;
  [FacebookDelegate getAppFacebookFriendsWithLoginUI:openLoginUI callback:^(NSArray *fbFriends) {
    if (openLoginUI || fbFriends) {
      _retrievedFriends = YES;
      
      if (fbFriends) {
        [self organizeData:fbFriends isAppUser:YES];
        
        [FacebookDelegate getInvitableFacebookFriendsWithLoginUI:NO callback:^(NSArray *fbFriends) {
          if (openLoginUI || fbFriends.count) {
            [self organizeData:fbFriends isAppUser:NO];
          }
          self.spinner.hidden = YES;
          [self.chooserTable reloadData];
        }];
      } else {
        self.spinner.hidden = YES;
      }
    } else {
      self.spinner.hidden = YES;
    }
    [self.chooserTable reloadData];
  }];
}

- (void) setState:(FBChooserState)state {
  _state = state;
  
  self.gameFriendsButton.selected = state == FBChooserStateGameFriends;
  self.gameFriendsButton.userInteractionEnabled = !self.gameFriendsButton.selected;
  self.allFriendsButton.selected = state == FBChooserStateAllFriends;
  self.allFriendsButton.userInteractionEnabled = !self.allFriendsButton.selected;
  
  self.selectedIds = [NSMutableSet set];
  
  for (NSArray *arr in self.data) {
    for (NSDictionary *dict in arr) {
      [self.selectedIds addObject:dict[@"id"]];
    }
  }
  
  self.selectAllCheckmark.hidden = NO;
  
  self.chooserTable.contentOffset = ccp(0,0);
  [self.chooserTable reloadData];
}

- (NSArray *)data {
  return self.state == FBChooserStateGameFriends ? self.gameFriendsData : self.allFriendsData;
}

- (BOOL) areAllEntriesSelected {
  int totalCount = 0;
  for (NSArray *arr in self.data) {
    totalCount += arr.count;
  }
  
  return self.selectedIds.count >= totalCount;
}

- (void) organizeData:(NSArray *)data isAppUser:(BOOL)appUser {
  NSMutableArray *arr = [data mutableCopy];
  
  for (FBGraphObject *fbObj in arr) {
    [self addFbUser:fbObj toList:self.allFriendsData];
    
    if (appUser) {
      [self addFbUser:fbObj toList:self.gameFriendsData];
    }
  }
  
  [self applyBlacklist];
  
  self.state = self.state;
}

- (void) addFbUser:(FBGraphObject *)user toList:(NSMutableArray *)list {
  char userLetter = [user[@"name"] characterAtIndex:0];
  for (int i = 0; i < list.count; i++) {
    NSMutableArray *inner = list[i];
    FBGraphObject *obj = inner[0];
    
    char objLetter = [obj[@"name"] characterAtIndex:0];
    if (userLetter < objLetter) {
      // Add right before this current list
      NSMutableArray *newArr = [NSMutableArray array];
      [newArr addObject:user];
      [list insertObject:newArr atIndex:i];
      
      return;
    } else if (userLetter == objLetter) {
      // Find place inside array to add new object
      int idx = -1;
      for (int j = 0; j < inner.count; j++) {
        FBGraphObject *fbObj = inner[j];
        
        NSComparisonResult comp = [user[@"name"] compare:fbObj[@"name"]];
        if (comp != NSOrderedDescending) {
          // Do this convoluted shit so that we can make sure duplicates don't get through
          if (![user[@"id"] isEqual:fbObj[@"id"]]) {
            if (idx == -1) {
              idx = j;
            }
          } else {
            return;
          }
        }
      }
      
      if (idx == -1) {
        [inner addObject:user];
      } else {
        [inner insertObject:user atIndex:idx];
      }
      return;
    }
  }
  
  NSMutableArray *newArr = [NSMutableArray array];
  [newArr addObject:user];
  [list addObject:newArr];
}

- (void) setBlacklistFriendIds:(NSSet *)blacklistFriendIds {
  _blacklistFriendIds = blacklistFriendIds;
  [self applyBlacklist];
  self.state = self.state;
}

- (void) applyBlacklist {
  for (NSMutableArray *data in [NSArray arrayWithObjects:self.allFriendsData, self.gameFriendsData, nil]) {
    NSMutableArray *toRemoveOuter = [NSMutableArray array];
    for (NSMutableArray *arr in data) {
      NSMutableArray *toRemove = [NSMutableArray array];
      for (FBGraphObject *fbObj in arr) {
        NSString *uid = [NSString stringWithFormat:@"%@", fbObj[@"id"]];
        if ([self.blacklistFriendIds containsObject:uid]) {
          [toRemove addObject:fbObj];
        }
      }
      [arr removeObjectsInArray:toRemove];
      
      if (arr.count == 0) {
        [toRemoveOuter addObject:arr];
      }
    }
    [data removeObjectsInArray:toRemoveOuter];
  }
}

- (void) sendRequestWithString:(NSString *)requestString completionBlock:(void(^)(BOOL success, NSArray *friendIds))completion {
  if (self.selectedIds.count == 0) {
    return;
  }
  
  NSMutableArray *arr = [self.selectedIds.allObjects mutableCopy];
  if (arr.count > 50) {
    [arr shuffle];
    arr = [[arr subarrayWithRange:NSMakeRange(0, 50)] mutableCopy];
  }
  
  [FacebookDelegate initiateRequestToFacebookIds:arr withMessage:requestString completionBlock:completion];
}

#pragma mark - IBActions

- (IBAction)allFriendsClicked:(id)sender {
  self.state = FBChooserStateAllFriends;
}

- (IBAction)gameFriendsClicked:(id)sender {
  self.state = FBChooserStateGameFriends;
}

- (IBAction)unselectAllClicked:(id)sender {
  if ([self areAllEntriesSelected]) {
    [self.selectedIds removeAllObjects];
    self.selectAllCheckmark.hidden = YES;
  } else {
    for (NSArray *arr in self.data) {
      for (NSDictionary *dict in arr) {
        [self.selectedIds addObject:dict[@"id"]];
      }
    }
    self.selectAllCheckmark.hidden = NO;
  }
  [self.chooserTable reloadData];
}

#pragma mark - UITableView methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
  NSInteger count = self.data.count;
  if (count == 0 && _retrievedFriends) {
    self.noFriendsLabel.hidden = NO;
  } else {
    self.noFriendsLabel.hidden = YES;
  }
  return count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return ((NSArray *)self.data[section]).count;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIView *img = [[UIView alloc] initWithFrame:CGRectZero];
  img.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.f];
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 1, 100, 14)];
  [img addSubview:label];
  label.font = [UIFont fontWithName:@"Gotham-Bold" size:10.f];
  label.text = [[self.data[section] lastObject][@"name"] substringToIndex:1];
  label.textColor = [UIColor colorWithWhite:0.24f alpha:0.7f];
  
  return img;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  FBFriendCell *cell = (FBFriendCell *)[tableView cellForRowAtIndexPath:indexPath];
  NSDictionary *obj = self.data[indexPath.section][indexPath.row];
  NSString *num = obj[@"id"];
  if ([self.selectedIds containsObject:num]) {
    [self.selectedIds removeObject:num];
    cell.checkmark.hidden = YES;
  } else {
    [self.selectedIds addObject:num];
    cell.checkmark.hidden = NO;
  }
  
  self.selectAllCheckmark.hidden = ![self areAllEntriesSelected];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FBFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FBFriendCell"];
  
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"FBFriendCell" owner:self options:nil];
    cell = self.friendCell;
  }
  
  NSDictionary *obj = self.data[indexPath.section][indexPath.row];
  [cell loadForData:obj];
  cell.checkmark.hidden = ![self.selectedIds containsObject:obj[@"id"]];
  
  return cell;
}

@end
