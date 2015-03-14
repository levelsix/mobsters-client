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
  [FacebookDelegate getInvitableFacebookFriendsWithLoginUI:NO callback:^(NSArray *fbFriends) {
    NSMutableArray *arr = [self facebookIdsFromFbData:fbFriends];
    
    [self openDialogForFacebookIds:arr];
  }];
}

+ (NSMutableArray *) facebookIdsFromFbData:(NSArray *)data {
  NSMutableArray *arr = [NSMutableArray array];
  for (NSDictionary *dict in data) {
    [arr addObject:dict[@"id"]];
  }
  return arr;
}

+ (void) openDialogForFacebookIds:(NSArray *)arr {
  int maxSize = 50;
  NSArray *subarr = [arr subarrayWithRange:NSMakeRange(0, MIN(maxSize, arr.count))];
  NSArray *rest = nil;
  if (arr.count > maxSize) {
    rest = [arr subarrayWithRange:NSMakeRange(maxSize, arr.count-maxSize)];
  }
  
  UIApplication *app = [UIApplication sharedApplication];
  MSWindow *window = (MSWindow *)app.keyWindow;
  window.silentlyAcceptFacebookRequests = YES;
  
  [FacebookDelegate initiateRequestToFacebookIds:subarr withMessage:[NSString stringWithFormat:@"Come play %@ with me!", GAME_NAME] completionBlock:^(BOOL success, NSArray *friendIds) {
    if (success) {
      LNLog(@"Spammed %@", friendIds);
      
      [Analytics sentFbSpam:(int)friendIds.count];
      
      [self openDialogForFacebookIds:rest];
    }
  }];
  
  window.silentlyAcceptFacebookRequests = NO;
}

@end
