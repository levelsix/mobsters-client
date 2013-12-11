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

@implementation FBFriendCell

- (void) loadForData:(NSDictionary *)data {
  self.nameLabel.text = data[@"name"];
  
  self.profilePic.profileID = nil;
  self.profilePic.profileID = data[@"uid"];
  self.profilePic.layer.cornerRadius = roundf(self.profilePic.frame.size.width/2.0);
  self.profilePic.layer.masksToBounds = YES;
}

@end

@implementation FBChooserView

- (void) awakeFromNib {
  self.friendCache = [[FBFrictionlessRecipientCache alloc] init];
  [self.friendCache prefetchAndCacheForSession:nil];
  [self retrieveFacebookFriends:NO];
  
  self.unselectAllButton.superview.layer.cornerRadius = 5.f;
  
  self.chooserTable.tableFooterView = [[UIView alloc] init];
  
  self.state = FBChooserStateAllFriends;
}

- (void) retrieveFacebookFriends:(BOOL)openLoginUI {
  if (_retrievedFriends) return;
  
  self.spinner.hidden = NO;
  if (!FBSession.activeSession.isOpen) {
    // if the session is closed, then we open it here, and establish a handler for state changes
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:openLoginUI
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState state,
                                                      NSError *error) {
                                    if (error) {
                                      [Globals popupMessage:error.localizedDescription];
                                    } else if (session.isOpen) {
                                      [self retrieveFacebookFriends:openLoginUI];
                                    }
                                  }];
    return;
  }
  
  _retrievedFriends = YES;
  
  NSString *query =
  @"SELECT uid, name, pic, is_app_user FROM user WHERE uid IN "
  @"(SELECT uid2 FROM friend WHERE uid1 = me())";
  // Set up the query parameter
  NSDictionary *queryParam = @{ @"q": query };
  // Make the API request that uses FQL
  [FBRequestConnection startWithGraphPath:@"/fql"
                               parameters:queryParam
                               HTTPMethod:@"GET"
                        completionHandler:^(FBRequestConnection *connection,
                                            id result,
                                            NSError *error) {
                          if (error) {
                            NSLog(@"Error: %@", [error localizedDescription]);
                          } else {
                            // Get the friend data to display
                            [self organizeData:(NSArray *) result[@"data"]];
                            // Show the friend details display
                            [self.chooserTable reloadData];
                          }
                          self.spinner.hidden = YES;
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
      [self.selectedIds addObject:dict[@"uid"]];
    }
  }
  
  self.chooserTable.contentOffset = ccp(0,0);
  [self.chooserTable reloadData];
}

- (NSArray *)data {
  return self.state == FBChooserStateGameFriends ? self.gameFriendsData : self.allFriendsData;
}

- (void) organizeData:(NSArray *)data {
  NSMutableArray *arr = [data mutableCopy];
  
  [arr sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
    return [obj1[@"name"] compare:obj2[@"name"]];
  }];
  
  NSMutableArray *arr2 = [NSMutableArray array];
  NSMutableArray *arr3 = [NSMutableArray array];
  for (NSDictionary *fbObj in arr) {
    NSMutableArray *last = [arr2 lastObject];
    NSDictionary *obj = [last lastObject];
    if ([obj[@"name"] characterAtIndex:0] == [fbObj[@"name"] characterAtIndex:0]) {
      [last addObject:fbObj];
    } else {
      NSMutableArray *newArr = [NSMutableArray array];
      [newArr addObject:fbObj];
      [arr2 addObject:newArr];
    }
    
    if ([fbObj[@"is_app_user"] boolValue]) {
      NSMutableArray *last = [arr3 lastObject];
      NSDictionary *obj = [last lastObject];
      if ([obj[@"name"] characterAtIndex:0] == [fbObj[@"name"] characterAtIndex:0]) {
        [last addObject:fbObj];
      } else {
        NSMutableArray *newArr = [NSMutableArray array];
        [newArr addObject:fbObj];
        [arr3 addObject:newArr];
      }
    }
  }
  
  self.allFriendsData = arr2;
  self.gameFriendsData = arr3;
  
  [self applyBlacklist];
  
  self.state = self.state;
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
      for (NSDictionary *fbObj in arr) {
        if ([self.blacklistFriendIds containsObject:fbObj[@"uid"]]) {
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
  NSMutableString *str = [NSMutableString stringWithFormat:@"%@", arr[0]];
  
  for (int i = 1; i < arr.count; i++) {
    [str appendFormat:@", %@", arr[i]];
  }
  
  NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:str, @"to", nil];
  [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                message:requestString
                                                  title:nil
                                             parameters:params
                                                handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  BOOL success = NO;
                                                  if (error) {
                                                    // Case A: Error launching the dialog or sending request.
                                                    NSLog(@"Error sending request.");
                                                  } else {
                                                    if (result == FBWebDialogResultDialogNotCompleted) {
                                                      // Case B: User clicked the "x" icon
                                                      NSLog(@"User closed request.");
                                                    } else {
                                                      NSString *urlParams = resultURL.query;
                                                      if (!urlParams || [urlParams rangeOfString:@"request"].location == NSNotFound) {
                                                        // User clicked the Cancel button
                                                        NSLog(@"User canceled request.");
                                                      } else {
                                                        // Completed
                                                        NSLog(@"User sent request.");
                                                        success = YES;
                                                      }
                                                    }
                                                  }
                                                  
                                                  if (completion) {
                                                    completion(success, arr);
                                                  }
                                                }
                                            friendCache:self.friendCache];
}

#pragma mark - IBActions

- (IBAction)allFriendsClicked:(id)sender {
  self.state = FBChooserStateAllFriends;
}

- (IBAction)gameFriendsClicked:(id)sender {
  self.state = FBChooserStateGameFriends;
}

- (IBAction)unselectAllClicked:(id)sender {
  [self.selectedIds removeAllObjects];
  [self.chooserTable reloadData];
}

#pragma mark - UITableView methods

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return self.data.count;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return ((NSArray *)self.data[section]).count;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIImageView *img = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"letterheader.png"]];
  img.contentMode = UIViewContentModeScaleToFill;
  
  UILabel *label = [[NiceFontLabel2 alloc] initWithFrame:CGRectMake(10, -1, 100, img.frame.size.height)];
  [img addSubview:label];
  label.font = [UIFont systemFontOfSize:9];
  [label awakeFromNib];
  label.text = [[self.data[section] lastObject][@"name"] substringToIndex:1];
  label.textColor = [UIColor whiteColor];
  label.shadowColor = [UIColor colorWithWhite:0.f alpha:0.7f];
  label.shadowOffset = CGSizeMake(0, 1);
  
  return img;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  FBFriendCell *cell = (FBFriendCell *)[tableView cellForRowAtIndexPath:indexPath];
  NSDictionary *obj = self.data[indexPath.section][indexPath.row];
  NSString *num = obj[@"uid"];
  if ([self.selectedIds containsObject:num]) {
    [self.selectedIds removeObject:num];
    cell.checkmark.hidden = YES;
  } else {
    [self.selectedIds addObject:num];
    cell.checkmark.hidden = NO;
  }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FBFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FBFriendCell"];
  
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"FBFriendCell" owner:self options:nil];
    cell = self.friendCell;
  }
  
  NSDictionary *obj = self.data[indexPath.section][indexPath.row];
  [cell loadForData:obj];
  cell.checkmark.hidden = ![self.selectedIds containsObject:obj[@"uid"]];
  
  return cell;
}

@end
