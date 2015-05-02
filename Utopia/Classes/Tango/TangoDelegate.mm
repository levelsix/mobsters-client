//
//  TangoDelegate.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TangoDelegate.h"

#import <TangoSDK/TangoProfileResult.h>
#import <TangoSDK/TangoProfileEntry.h>
#import <TangoSDK/TangoProfile.h>
#import <TangoSDK/TangoSession.h>
#import <TangoSDK/TangoTools.h>
#import <error_codes.h>

#define TANGO_ENABLED 

@implementation TangoDelegate

static TangoProfileEntry *profileEntry = nil;

+ (BOOL) attemptInitialLogin {
#ifdef TANGO_ENABLED
  BOOL success = [TangoSession sessionInitialize];
  if (success && [self isTangoAvailable]) {
    return [self authenticate];
  }
#endif
  return NO;
}

+ (BOOL) authenticate {
#ifdef TANGO_ENABLED
  TangoSession *session = [TangoSession sharedSession];
  if (!session.isAuthenticated) {
    [session authenticateWithHandler:^(TangoSession *session, NSError *error) {
      if(error.code == TANGO_SDK_SUCCESS) {
        [self fetchMyProfile];
      } else if (error.code == TANGO_SDK_TANGO_APP_NO_SDK_SUPPORT ||
                 error.code == TANGO_SDK_TANGO_APP_NOT_INSTALLED) {
        [session installTango];
      }
    }];
    return YES;
  } else {
    [self fetchMyProfile];
  }
#endif
  return NO;
}

+ (BOOL) isTangoAvailable {
#ifdef TANGO_ENABLED
  TangoSession *session = [TangoSession sharedSession];
  return session.tangoIsInstalled && session.tangoHasSdkSupport;
#endif
  return NO;
}

+ (BOOL) isTangoAuthenticated {
#ifdef TANGO_ENABLED
  TangoSession *session = [TangoSession sharedSession];
  return session.isAuthenticated;
#endif
  return NO;
}

+ (void) fetchMyProfile {
#ifdef TANGO_ENABLED
  if (!profileEntry) {
    [TangoProfile fetchMyProfileWithHandler:^(TangoProfileResult *profileResult, NSError *error) {
      for (id obj in profileResult.profileEnumerator) {
        profileEntry = obj;
      }
    }];
  }
#endif
}

+ (void) getProfilePicture:(void (^)(UIImage *img))comp {
#ifdef TANGO_ENABLED
  if (!profileEntry.profilePictureIsPlaceholder && profileEntry.cachedProfilePicture) {
    comp(profileEntry.cachedProfilePicture);
  } else {
    [profileEntry fetchProfilePictureWithHandler:^(UIImage *image) {
      dispatch_sync(dispatch_get_main_queue(), ^{
        comp(image);
      });
    }];
  }
#endif
}

+ (void) validatePurchase:(SKPaymentTransaction *)transaction {
  TangoSession *session = [TangoSession sharedSession];
  if (session.isInitialized || [TangoSession sessionInitialize]) {
    [TangoTools validateReceipt:transaction.transactionReceipt forProduct:transaction.payment.productIdentifier withHandler:^(enum ValidationStatus status, NSError *error) {
      NSLog(@"Tango validate purchase: Status %d, Error %@", status, error);
    }];
  };
}


+ (BOOL) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)requester {
#ifdef TANGO_ENABLED
  NSLog(@"application:openURL: %@ sourceApplication: %@, url: %@", url.absoluteString, requester, url);
  
  void (^showAlert)(NSString *title, NSString *message) = ^(NSString *title, NSString *message) {
#ifndef APPSTORE
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
#endif
  };
  
  TangoHandleURLResult *resultData = [TangoSession.sharedSession handleURL:url withSourceApp:requester];
  switch(resultData.type) {
    case TangoHandleURLResultTypeError: {
      NSLog(@"TangoSDK HandleURL: reported an error.");
      showAlert(@"Error", @"The URL could not be parsed.");
      return YES;
      break;
    }
    case TangoHandleURLResultTypeNoActionNeeded:
      // The URL is meant specifically for Tango SDK internals and we should not process it ourselves.
      return YES;
      break;
    case TangoHandleURLResultTypeEventGiftMessageReceived: {
      NSLog(@"gift received: %@", resultData.sdkParameters);
      NSString *giftType = resultData.sdkParameters[kTangoHandleUrlResultGiftTypeKey];
      NSString *giftId = resultData.sdkParameters[kTangoHandleUrlResultGiftIdKey];
      NSString *msg = [NSString stringWithFormat:@"You have received a gift. Type = %@, id = %@",
                       giftType, giftId];
      showAlert(@"Gift from friend", msg);
      return YES;
      break;
    }
    case TangoHandleURLResultTypeSharedDataReceived: {
      NSString *msg = [NSString stringWithFormat:@"Shared data received:\nsdkParameters = %@\nuserParameters = %@",
                       resultData.sdkParameters, resultData.userParameters];
      NSLog(@"%@", msg);
      showAlert(@"Shared Data", msg);
      return YES;
      break;
    }
    case TangoHandleURLResultTypeUnknownAction: {
      NSString *msg = [NSString stringWithFormat:@"Unknown action received in URL: \"%@\"",
                       resultData.sdkParameters[kTangoHandleUrlResultUserUrlKey]];
      NSLog(@"%@", msg);
      showAlert(@"Unknown Action", msg);
      return YES;
      break;
    }
    case TangoHandleURLResultTypeUserUrl:
    default:
      // URL may have been embedded in SDK URL, so collect it from SDK result data
      url = [NSURL URLWithString:resultData.sdkParameters[kTangoHandleUrlResultUserUrlKey]];
      break;
  }
#endif
  
  return NO;
}

@end
