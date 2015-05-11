//
//  TangoGiftViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 5/8/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "TangoGiftViewController.h"
#import "FBChooserView.h"

@implementation TangoGiftViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.containerView.superview.layer.cornerRadius = 5.f;
  self.containerView.superview.clipsToBounds = YES;
}

#pragma mark - table delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
  return 0;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 0;
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
  
//  self.selectAllCheckmark.hidden = ![self areAllEntriesSelected];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FBFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FBFriendCell"];
  
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"FBFriendCell" owner:self options:nil];
    cell = self.friendCell;
  }
  
//  NSDictionary *obj = self.data[indexPath.section][indexPath.row];
//  [cell loadForData:obj];
//  cell.checkmark.hidden = ![self.selectedIds containsObject:obj[@"id"]];
//  
  return cell;
}

@end
