//
//  TangoDelegate.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TangoSDK/TangoProfileEntry.h>

@interface TangoDelegate : NSObject

+ (BOOL) attemptInitialLogin;
+ (BOOL) authenticate;

+ (BOOL) isTangoAvailable;
+ (BOOL) isTangoAuthenticated;
+ (void) getProfilePicture:(void (^)(UIImage *img))comp;
+ (void) getPictureForProfile:(TangoProfileEntry *)profile comp:(void (^)(UIImage *img))comp;

+ (void) fetchCachedFriends:(void (^)(NSArray *friends))comp;

+ (void) fetchOwnGifts:(void (^)(NSArray *gifts))comp;
+ (void) redeemGiftIds:(NSArray *)giftIds;
+ (void) sendGiftsToTangoUsers:(NSArray *)userIds;

+ (void) validatePurchase:(id)transaction;

+ (BOOL) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)requester;

@end
