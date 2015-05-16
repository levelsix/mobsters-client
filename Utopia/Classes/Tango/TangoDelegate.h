//
//  TangoDelegate.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Protocols.pb.h"

@interface TangoDelegate : NSObject

+ (BOOL) attemptInitialLogin;
+ (BOOL) authenticate;

+ (BOOL) isTangoAvailable;
+ (BOOL) isTangoAuthenticated;

+ (NSString *) getMyId;
+ (NSArray *) getTangoIdsForProfiles:(NSArray *)profiles;
+ (NSArray *) getTangoIdsForProfiles:(NSArray *)profiles withApp:(BOOL)withApp;

+ (void) getProfilePicture:(void (^)(UIImage *img))comp;
+ (void) getPictureForProfile:(id)pf comp:(void (^)(UIImage *img))comp;
+ (NSString *) getFullNameForProfile:(id)pf;

+ (void) fetchCachedFriends:(void (^)(NSArray *friends))comp;

+ (void) fetchMyGifts:(void (^)(NSArray *gifts))comp;
+ (void) consumeAllGiftsFromUser:(NSString *)userId;
+ (void) consumeUserGifts:(NSArray *)gift;

+ (void) sendGiftsToTangoUsers:(NSArray *)userIds;
+ (void) sendInvitesToTangoUsers:(NSArray *)userIds;

+ (void) validatePurchase:(id)transaction;

+ (BOOL) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)requester;

+ (void) enableLogs;
+ (void) disableLogs;

@end
