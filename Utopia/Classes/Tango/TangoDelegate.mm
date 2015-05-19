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
#import <TangoSdK/TangoGifting.h>
#import <TangoSdK/TangoGiftingResponse.h>
#import <TangoSDK/TangoInviting.h>
#import <TangoSDK/TangoInvitingResponse.h>
#import <error_codes.h>

#define TANGO_ENABLED

//#define TANGO_RESOURCE_ID @"TEST_INVITE_ID"
#define TANGO_RESOURCE_ID @"INVITE_ID1"

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
      NSLog(@"Tango Authentication returned with status: %d", (int)error.code);
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
//  GameState *gs = [GameState sharedGameState];
  
  if (!profileEntry) {
    [TangoProfile fetchMyProfileWithHandler:^(TangoProfileResult *profileResult, NSError *error) {
      for (id obj in profileResult.profileEnumerator) {
        profileEntry = obj;
      }
      
//      if (![gs.tangoId isEqualToString:profileEntry.profileID]) {
//        [[OutgoingEventController sharedOutgoingEventController] updateTangoId:profileEntry.profileID];
//      }
      
      NSLog(@"Fetch my Tango profile returned with status: %d", (int)error.code);
    }];
  }
#endif
}

+ (NSString *) getMyId {
#ifdef TANGO_ENABLED
  return profileEntry.profileID;
#else
  return nil;
#endif
}

+ (NSArray *) getTangoIdsForProfiles:(NSArray *)profiles {
  NSMutableArray *ids = [[NSMutableArray alloc] init];
  
  for (TangoProfileEntry *tpf in profiles) {
    [ids addObject:tpf.profileID];
  }
  
  return ids;
}

//limit if you get results for people that do or do not have our app installed
+ (NSArray *) getTangoIdsForProfiles:(NSArray *)profiles withApp:(BOOL)withApp{
  NSMutableArray *ids = [[NSMutableArray alloc] init];
  
  for (TangoProfileEntry *tpf in profiles) {
    if (tpf.hasTheApp == withApp) {
      [ids addObject:tpf.profileID];
    }
  }
  
  return ids;
}

+ (void) getProfilePicture:(void (^)(UIImage *img))comp {
#ifdef TANGO_ENABLED
  //Cooper made his own default picture
  if (profileEntry.profilePictureIsPlaceholder) {
    comp([UIImage imageNamed:@"tangodefault.png"]);
    return;
  }
  
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

+ (void) getPictureForProfile:(id)pf comp:(void (^)(UIImage *img))comp {
#ifdef TANGO_ENABLED
  TangoProfileEntry *profile = (TangoProfileEntry *)pf;
  
  //Cooper made his own default picture
  if (profile.profilePictureIsPlaceholder) {
    comp([UIImage imageNamed:@"tangodefault.png"]);
    return;
  }
  
  if (!profile.profilePictureIsPlaceholder && profile.cachedProfilePicture) {
    comp(profile.cachedProfilePicture);
  } else {
    [profile fetchProfilePictureWithHandler:^(UIImage *image) {
      dispatch_sync(dispatch_get_main_queue(), ^{
        comp(image);
      });
    }];
  }
#endif
}

+ (NSString *) getFullNameForProfile:(id)pf {
#ifdef TANGO_ENABLED
  TangoProfileEntry *profile = (TangoProfileEntry *)pf;
  
  return  [NSString stringWithFormat:@"%@ %@", [profile.firstName capitalizedString], [profile.lastName   capitalizedString]];
#endif
}

+ (NSString *) getTangoIdForProfile:(id)pf {
#ifdef TANGO_ENABLED
  TangoProfileEntry *profile = (TangoProfileEntry *)pf;
  
  return profile.profileID;
#endif
}

+ (void) fetchCachedFriends:(void (^)(NSArray *friends))comp {
#ifdef TANGO_ENABLED
  [TangoProfile fetchMyCachedFriendsWithHandler:^(TangoProfileResult *profileResult, NSError *error) {
    
    dispatch_sync(dispatch_get_main_queue(), ^{
      comp(profileResult.profileEnumerator.allObjects);
      
      NSLog(@"Fetch cached Tango Friends returned with status: %d", (int)error.code);
    });
  }];
#endif
}

+ (void) fetchInvitableProfiles:(void (^)(NSArray *friends))comp {
#ifdef TANGO_ENABLED
  [TangoInviting fetchProfilesWithinLimitsForResourceId:TANGO_RESOURCE_ID handler:^(TangoInvitingFetchProfilesResponse *response, NSError *error) {
    dispatch_sync(dispatch_get_main_queue(), ^{
      comp(response.filteredProfiles.profileEnumerator.allObjects);
    });
  }];
#endif
}

//+ (void) fetchMyGifts:(void (^)(NSArray *gifts))comp {
//#ifdef TANGO_ENABLED
//  [TangoGifting fetchGiftsWithHandler:^(TangoGiftingFetchGiftsResponse *response, NSError *error) {
//    dispatch_sync(dispatch_get_main_queue(), ^{
//      comp(response.gifts);
//      
//      NSLog(@"Fetched my Gifts returned with status: %d", (int)error.code);
//    });
//  }];
//#endif
//}
//
//+ (void) consumeAllGiftsFromUser:(NSString *)userId {
//#ifdef TANGO_ENABLED
//  [self fetchMyGifts:^(NSArray *gifts) {
//    
//    NSMutableArray *giftIdsToRedeem = [[NSMutableArray alloc] init];
//    for (TangoGift *gift in gifts) {
//      if ([gift.senderAccountId isEqualToString:userId]) {
//        [giftIdsToRedeem addObject:userId];
//      }
//    }
//    
//    [TangoGifting consumeGifts:giftIdsToRedeem handler:^(TangoGiftingConsumeGiftsResponse *response, NSError *error) {
//      NSLog(@"Tango consume all gifts for user with status: %d",(int)error.code);
//    }];
//  }];
//#endif
//}
//
//+ (void) consumeUserGifts:(NSArray *)userGifts {
//#ifdef TANGO_ENABLED
//  [self fetchMyGifts:^(NSArray *gifts) {
//    NSMutableArray *tangoGiftIds = [[NSMutableArray alloc] init];
//    
//    for (UserGiftProto *ugp in userGifts) {
//      for (TangoGift *tangoGift in gifts) {
//        if ([tangoGift.senderAccountId isEqualToString:ugp.tangoGift.gifterTangoUserId]) {
//          [tangoGiftIds addObject:tangoGift.senderAccountId];
//          break;
//        }
//      }
//    }
//    
//    [TangoGifting consumeGifts:tangoGiftIds handler:^(TangoGiftingConsumeGiftsResponse *response, NSError *error) {
//      NSLog(@"Consume Tango Gifts return with status: %d", (int)error.code);
//    }];
//  }];
//#endif
//}
//
//+ (void) sendGiftsToTangoUsers:(NSArray *)userIds {
//#ifdef TANGO_ENABLED
//  NSString *resourceId = @"GIFT_ID1";
////  NSString *resourceId = @"TEST_GIFT_ID";
//  
//  [TangoGifting sendGiftToRecipients:userIds withResourceId:resourceId handler:^(TangoGiftingSendGiftResponse *response, NSError *error) {
//    NSLog(@"Send Tango Gifts return with status: %d", (int)error.code);
//  }];
//#endif
//}

+ (void) sendInvitesToTangoUsers:(NSArray *)userIds {
#ifdef TANGO_ENABLED
  [TangoInviting sendInvitationToRecipients:userIds resourceId:TANGO_RESOURCE_ID handler:^(TangoInvitingSendInvitationsResponse *response, NSError *error) {
    NSLog(@"Send Tango invites returned with status: %d", (int)error.code);
  }];
#endif
}

+ (void) validatePurchase:(SKPaymentTransaction *)transaction {
  TangoSession *session = [TangoSession sharedSession];
  if (session.isInitialized || [TangoSession sessionInitialize]) {
    [TangoTools validateReceipt:transaction.transactionReceipt forProduct:transaction.payment.productIdentifier withHandler:^(enum ValidationStatus status, NSError *error) {
      NSLog(@"Tango validate purchase: Status %d, Error %d", status, (int)error.code);
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

+ (void) enableLogs {
#ifdef TANGO_ENABLED
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"toonsquad4t://log?action=logenable&http=trace&http_details=trace&sdk_session=trace&sdk_impl=trace&sdk_token_fetcher=trace&ipc_comm=trace&sdk_http_cmd=trace&sdk_feed=trace"]];
#endif
}

+ (void) disableLogs {
#ifdef TANGO_ENABLED
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"toonsquad4t://log?action=logdisable"]];
#endif
}

@end
