//
//  FacebookDelegate.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FBFrictionlessRecipientCache;
@protocol FBGraphUser;

@interface FacebookDelegate : NSObject {
  void (^_loginCompletionHandler)(BOOL success);
}

@property (nonatomic, retain) FBFrictionlessRecipientCache *friendCache;
@property (nonatomic, retain) NSDictionary<FBGraphUser> *myFacebookUser;

+ (FacebookDelegate *) sharedFacebookDelegate;

+ (void) activateApp;
+ (BOOL) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;
+ (void) handleDidBecomeActive;

+ (void) openSessionWithReadPermissionsWithLoginUI:(BOOL)login completionHandler:(void (^)(BOOL success))completionHandler;

+ (void) getFacebookFriendsWithLoginUI:(BOOL)openLoginUI callback:(void (^)(NSArray *fbFriends))completion;
+ (void) initiateRequestToFacebookIds:(NSArray *)fbIds withMessage:(NSString *)message completionBlock:(void(^)(BOOL success, NSArray *friendIds))completion;

+ (void) getFacebookIdAndDoAction:(void (^)(NSString *facebookId))handler;
+ (void) getFacebookUsernameAndDoAction:(void (^)(NSString *facebookId))handler;

@end
