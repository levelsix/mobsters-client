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
+ (void) getProfilePicture:(void (^)(UIImage *img))comp;

+ (BOOL) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)requester;

@end
