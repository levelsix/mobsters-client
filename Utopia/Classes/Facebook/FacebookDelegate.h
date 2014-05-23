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
  NSMutableArray *_completionHandlers;
}

@property (nonatomic, retain) FBFrictionlessRecipientCache *friendCache;
@property (nonatomic, retain) NSDictionary<FBGraphUser> *myFacebookUser;

@property (nonatomic, retain) MSDate *timeOfLastLoginAttempt;

+ (FacebookDelegate *) sharedFacebookDelegate;

+ (void) activateApp;
+ (BOOL) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;
+ (void) handleDidBecomeActive;

+ (void) openSessionWithLoginUI:(BOOL)login completionHandler:(void (^)(BOOL success))completionHandler;

+ (void) getFacebookFriendsWithLoginUI:(BOOL)openLoginUI callback:(void (^)(NSArray *fbFriends))completion;
+ (void) initiateRequestToFacebookIds:(NSArray *)fbIds withMessage:(NSString *)message completionBlock:(void(^)(BOOL success, NSArray *friendIds))completion;

+ (void) getFacebookUsersWithIds:(NSArray *)idsArr handler:(void (^)(id result))handler;

+ (void) getFacebookIdAndDoAction:(void (^)(NSString *facebookId))handler;
+ (void) getFacebookUsernameAndDoAction:(void (^)(NSString *username))handler;

+ (void) logout;

+ (void) facebookIdIsValid;

@end
