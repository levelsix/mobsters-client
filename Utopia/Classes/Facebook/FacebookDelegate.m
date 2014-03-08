//
//  FacebookDelegate.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "FacebookDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Globals.h"

@implementation FacebookDelegate

+ (FacebookDelegate *) sharedFacebookDelegate
{
  static FacebookDelegate *sharedSingleton;
  
  @synchronized(self)
  {
    if (!sharedSingleton)
      sharedSingleton = [[FacebookDelegate alloc] init];
    
    return sharedSingleton;
  }
}

- (id) init {
  if ((self = [super init])) {
    self.friendCache = [[FBFrictionlessRecipientCache alloc] init];
    [self.friendCache prefetchAndCacheForSession:nil];
  }
  return self;
}

+ (void) checkForCachedToken {
  [[self sharedFacebookDelegate] openSessionWithReadPermissionsWithLoginUI:NO completionHandler:nil];
}

+ (void) activateApp {
  [FBAppEvents activateApp];
}

+ (BOOL) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
  [FBSession.activeSession setStateChangeHandler:
   ^(FBSession *session, FBSessionState state, NSError *error) {
     [[self sharedFacebookDelegate] sessionStateChanged:session state:state error:error];
   }];
  return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

+ (void) handleDidBecomeActive {
  return [FBAppCall handleDidBecomeActive];
}

- (void) showMessage:(NSString *)alertText withTitle:(NSString *)title {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:alertText delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
  [alert show];
}

- (void) sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
  // If the session was opened successfully
  if (!error && state == FBSessionStateOpen){
    NSLog(@"Session opened");
    // Show the user the logged-in UI
    return;
  }
  if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
    // If the session is closed
    NSLog(@"Session closed");
    // Show the user the logged-out UI
  }
  
  // Handle errors
  if (error){
    NSLog(@"Error");
    NSString *alertText;
    NSString *alertTitle;
    // If the error requires people using an app to make an action outside of the app in order to recover
    if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
      alertTitle = @"Something went wrong";
      alertText = [FBErrorUtility userMessageForError:error];
      [self showMessage:alertText withTitle:alertTitle];
    } else {
      
      // If the user cancelled login, do nothing
      if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"User cancelled login");
        
        // Handle session closures that happen outside of the app
      } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
        alertTitle = @"Session Error";
        alertText = @"Your current Facebook session is no longer valid. Please log in again.";
        [self showMessage:alertText withTitle:alertTitle];
        
        // Here we will handle all other errors with a generic error message.
        // We recommend you check our Handling Errors guide for more information
        // https://developers.facebook.com/docs/ios/errors/
      } else {
        //Get more error information from the error
        NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
        
        // Show the user an error message
        alertTitle = @"Something went wrong";
        alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
        [self showMessage:alertText withTitle:alertTitle];
      }
    }
    // Clear this token
    [FBSession.activeSession closeAndClearTokenInformation];
  }
}

- (void) openSessionWithReadPermissionsWithLoginUI:(BOOL)login completionHandler:(void (^)(BOOL success))completionHandler {
  // If the session state is any of the two "open" states when the button is clicked
  if (FBSession.activeSession.state == FBSessionStateOpen
      || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
    // Already opened
    if (completionHandler) {
      completionHandler(YES);
    }
  } else {
    if (completionHandler) {
      _loginCompletionHandler = completionHandler;
    }
    
    // Open a session showing the user the login UI
    // You must ALWAYS ask for basic_info permissions when opening a session
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email"]
                                       allowLoginUI:login
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
       // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
       [self sessionStateChanged:session state:state error:error];
       
       if (_loginCompletionHandler) {
         _loginCompletionHandler(!error && state == FBSessionStateOpen);
       }
     }];
  }
}

+ (void) openSessionWithReadPermissionsWithLoginUI:(BOOL)login completionHandler:(void (^)(BOOL success))completionHandler {
  [[self sharedFacebookDelegate] openSessionWithReadPermissionsWithLoginUI:login completionHandler:completionHandler];
}

+ (void) getFacebookFriendsWithLoginUI:(BOOL)openLoginUI callback:(void (^)(NSArray *fbFriends))completion {
  [FacebookDelegate openSessionWithReadPermissionsWithLoginUI:openLoginUI completionHandler:^(BOOL success) {
    if (success) {
      NSString *query =
      @"SELECT uid, name, pic, is_app_user FROM user WHERE uid IN "
      @"(SELECT uid2 FROM friend WHERE uid1 = me())";
      // Set up the query parameter
      NSDictionary *queryParam = @{ @"q": query };
      // Make the API request that uses FQL
      [FBRequestConnection startWithGraphPath:@"/fql"
                                   parameters:queryParam
                                   HTTPMethod:@"GET"
                            completionHandler:^(FBRequestConnection *connection,
                                                id result,
                                                NSError *error) {
                              if (error) {
                                NSLog(@"Error: %@", [error localizedDescription]);
                                completion(nil);
                              } else {
                                completion(result[@"data"]);
                              }
                            }];
    }
  }];
}

- (void) initiateRequestToFacebookIds:(NSArray *)fbIds withMessage:(NSString *)message completionBlock:(void(^)(BOOL success, NSArray *friendIds))completion {
  if (fbIds.count == 0) return;
  
  [self openSessionWithReadPermissionsWithLoginUI:YES completionHandler:^(BOOL success) {
    if (success) {
      NSMutableString *str = [NSMutableString stringWithFormat:@"%@", fbIds[0]];
      for (int i = 1; i < fbIds.count; i++) {
        [str appendFormat:@", %@", fbIds[i]];
      }
      
      NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:str, @"to", nil];
      [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                    message:message
                                                      title:nil
                                                 parameters:params
                                                    handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      BOOL success = NO;
                                                      if (error) {
                                                        // Case A: Error launching the dialog or sending request.
                                                        NSLog(@"Error sending request.");
                                                      } else {
                                                        if (result == FBWebDialogResultDialogNotCompleted) {
                                                          // Case B: User clicked the "x" icon
                                                          NSLog(@"User closed request.");
                                                        } else {
                                                          NSString *urlParams = resultURL.query;
                                                          if (!urlParams || [urlParams rangeOfString:@"request"].location == NSNotFound) {
                                                            // User clicked the Cancel button
                                                            NSLog(@"User canceled request.");
                                                          } else {
                                                            // Completed
                                                            NSLog(@"User sent request.");
                                                            success = YES;
                                                          }
                                                        }
                                                      }
                                                      
                                                      if (completion) {
                                                        completion(success, fbIds);
                                                      }
                                                    }
                                                friendCache:self.friendCache];
    } else if (completion) {
      completion(NO, nil);
    }
  }];
}

+ (void) initiateRequestToFacebookIds:(NSArray *)fbIds withMessage:(NSString *)message completionBlock:(void(^)(BOOL success, NSArray *friendIds))completion {
  [[FacebookDelegate sharedFacebookDelegate] initiateRequestToFacebookIds:fbIds withMessage:message completionBlock:completion];
}

- (void) getMyFacebookUser:(void (^)(NSDictionary<FBGraphUser> *facebookUser))handler {
  if (!self.myFacebookUser) {
    [self openSessionWithReadPermissionsWithLoginUI:NO completionHandler:^(BOOL success) {
      [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *result, NSError *error) {
        if (!error) {
          self.myFacebookUser = result;
          handler(result);
        } else {
          handler(nil);
        }
      }];
    }];
  } else {
    handler(self.myFacebookUser);
  }
}

+ (void) getFacebookIdAndDoAction:(void (^)(NSString *facebookId))handler {
  [[FacebookDelegate sharedFacebookDelegate] getMyFacebookUser:^(NSDictionary<FBGraphUser> *facebookUser) {
    handler(facebookUser.id);
  }];
}

+ (void) getFacebookUsernameAndDoAction:(void (^)(NSString *facebookId))handler {
  [[FacebookDelegate sharedFacebookDelegate] getMyFacebookUser:^(NSDictionary<FBGraphUser> *facebookUser) {
    handler(facebookUser.username);
  }];
}

@end
