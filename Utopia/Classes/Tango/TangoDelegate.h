//
//  TangoDelegate.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TangoDelegate : NSObject

+ (BOOL) attemptInitialLogin;
+ (BOOL) authenticate;

+ (BOOL) isTangoAvailable;
+ (BOOL) isTangoAuthenticated;

+ (NSString *) getMyId;
+ (NSString *) getMyName;
+ (NSArray *) getTangoIdsForProfiles:(NSArray *)profiles;
+ (NSArray *) getTangoIdsForProfiles:(NSArray *)profiles withApp:(BOOL)withApp;

+ (void) getProfilePicture:(void (^)(UIImage *img))comp;
+ (void) getPictureForProfile:(id)pf comp:(void (^)(UIImage *img))comp;
+ (NSString *) getFullNameForProfile:(id)pf;
+ (NSString *) getTangoIdForProfile:(id)pf;

+ (void) fetchCachedFriends:(void (^)(NSArray *friends))comp;
+ (void) fetchInvitableProfiles:(void (^)(NSArray *friends))comp;

//+ (void) fetchMyGifts:(void (^)(NSArray *gifts))comp;
//+ (void) consumeAllGiftsFromUser:(NSString *)userId;
//+ (void) consumeUserGifts:(NSArray *)gift;
//+ (void) sendGiftsToTangoUsers:(NSArray *)userIds;

+ (void) sendInvitesToTangoUsers:(NSArray *)userIds;
+ (void) sendGiftsToTangoUsers:(NSArray *)userIds;

+ (void) validatePurchase:(id)transaction;

+ (BOOL) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)requester;

+ (void) enableLogs;
+ (void) disableLogs;

@end
