//
//  FacebookSpammer.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "FacebookSpammer.h"
#import "FacebookDelegate.h"
#import "MSWindow.h"
#import "Globals.h"

@implementation FacebookSpammer

+ (void) spamAllFriendsWithRequest {
  [FacebookDelegate getFacebookFriendsWithLoginUI:NO callback:^(NSArray *fbFriends) {
    NSArray *arr = [self facebookIdsFromFbData:fbFriends];
    int maxSize = 50;
    UIApplication *app = [UIApplication sharedApplication];
    MSWindow *window = (MSWindow *)app.keyWindow;
    window.silentlyAcceptFacebookRequests = YES;
    for (int i = 0; i < arr.count; i += maxSize) {
      [self openDialogForFacebookIds:[arr subarrayWithRange:NSMakeRange(i, MIN(maxSize, arr.count-i))]];
    }
    window.silentlyAcceptFacebookRequests = NO;
  }];
}

+ (NSArray *) facebookIdsFromFbData:(NSArray *)data {
  NSMutableArray *arr = [NSMutableArray array];
  for (NSDictionary *dict in data) {
    [arr addObject:dict[@"uid"]];
  }
  return arr;
}

+ (void) openDialogForFacebookIds:(NSArray *)ids {
  [FacebookDelegate initiateRequestToFacebookIds:ids withMessage:@"Come play Mob Squad with me!" completionBlock:^(BOOL success, NSArray *friendIds) {
    if (success) {
      LNLog(@"Spammed %@", friendIds);
    }
  }];
}

@end
