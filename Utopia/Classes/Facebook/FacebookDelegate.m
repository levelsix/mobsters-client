//
//  FacebookDelegate.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "FacebookDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "GenericPopupController.h"
#import "SocketCommunication.h"
#import "GameViewController.h"

#define PUBLISH_PERMISSIONS @[@"publish_actions"]
#define READ_PERMISSIONS @[@"public_profile", @"user_friends", @"email"]

#ifdef DEBUG
#define TEST_APP_SWITCH 1
#endif

@implementation FacebookDelegate

+ (FacebookDelegate *) sharedFacebookDelegate
{
  static FacebookDelegate *sharedSingleton;
  
  @synchronized(self)
  {
    if (!sharedSingleton) {
      sharedSingleton = [[FacebookDelegate alloc] init];
    }
    
    return sharedSingleton;
  }
}

- (id) init {
  if ((self = [super init])) {
    self.friendCache = [[FBFrictionlessRecipientCache alloc] init];
    [self.friendCache prefetchAndCacheForSession:nil];
    
    _completionHandlers = [NSMutableArray array];
    
    //NSArray *log = @[FBLoggingBehaviorFBRequests, FBLoggingBehaviorFBURLConnections, FBLoggingBehaviorAccessTokens,
    //                 FBLoggingBehaviorSessionStateTransitions, FBLoggingBehaviorPerformanceCharacteristics,
    //                 FBLoggingBehaviorAppEvents, FBLoggingBehaviorInformational, FBLoggingBehaviorDeveloperErrors];
    //[FBSettings setLoggingBehavior:[NSSet setWithArray:log]];
  }
  return self;
}

- (void) respondToCompletionHandlersWithSuccess:(BOOL)success {
  NSMutableArray *cp = [_completionHandlers copy];
  [_completionHandlers removeAllObjects];
  for (void (^completionHandler)(BOOL success) in cp) {
    completionHandler(success);
  }
}

+ (void) activateApp {
  NSLog(@"%@", [FBSettings defaultAppID]);
  [FBAppEvents activateApp];
}

+ (BOOL) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
  if ([url.scheme rangeOfString:@"fb"].length > 0) {
    [[GameViewController baseController] openedFromFacebook];
    [[FacebookDelegate sharedFacebookDelegate] setTimeOfLastLoginAttempt:nil];
    [FBSession.activeSession setStateChangeHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
       [[self sharedFacebookDelegate] sessionStateChanged:session state:state error:error];
     }];
  }
  return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

+ (void) handleDidBecomeActive {
  return [FBAppCall handleDidBecomeActive];
}

- (void) showMessage:(NSString *)alertText withTitle:(NSString *)title {
  [GenericPopupController displayNotificationViewWithText:alertText title:title];
}

- (void) facebookIdIsValid {
  // Will be called by game view controller
  LNLog(@"Facebook id verified.. Calling handler.");
  [self respondToCompletionHandlersWithSuccess:YES];
}

+ (void) facebookIdIsValid {
  [[FacebookDelegate sharedFacebookDelegate] facebookIdIsValid];
}

- (void) sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
  // If the session was opened successfully
  if (!error && state == FBSessionStateOpen) {
    LNLog(@"Facebook session opened.");
    // Show the user the logged-in UI
    
    [self getMyFacebookUser:^(NSDictionary<FBGraphUser> *facebookUser) {
      if (facebookUser) {
        LNLog(@"Got facebook user.. Checking if okay to use.");
        if ([[GameViewController baseController] canProceedWithFacebookUser:facebookUser]) {
          [self facebookIdIsValid];
        }
      }
    }];
  } else {
    [self respondToCompletionHandlersWithSuccess:NO];
  }
  self.timeOfLastLoginAttempt = nil;
  
  
  if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
    // If the session is closed
    LNLog(@"Facebook session closed.");
    // Show the user the logged-out UI
  }
  
  // Handle errors
  if (error){
    LNLog(@"Error");
    NSString *alertText;
    NSString *alertTitle;
    // If the error requires people using an app to make an action outside of the app in order to recover
    if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
      alertTitle = @"Something went wrong!";
      alertText = [FBErrorUtility userMessageForError:error];
      [self showMessage:alertText withTitle:alertTitle];
    } else {
      
      // If the user cancelled login, do nothing
      if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        LNLog(@"User cancelled login");
        
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

- (void) openSessionWithLoginUI:(BOOL)login completionHandler:(void (^)(BOOL success))completionHandler {
  if (completionHandler) {
    [_completionHandlers addObject:completionHandler];
  }
  
  // If the session state is any of the two "open" states when the button is clicked
  if (FBSession.activeSession.state == FBSessionStateOpen
      || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
    // Already opened
    // Only accept this completion handler in case we are checking that the fbId is valid
    if (completionHandler) {
      completionHandler(YES);
      [_completionHandlers removeObject:completionHandler];
    }
  } else if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
    [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
      [self sessionStateChanged:session state:state error:error];
    }];
  } else {
    // Open a session showing the user the login UI
    // You must ALWAYS ask for basic_info permissions when opening a session
    BOOL triedToOpen = NO;
    if (false) {//login) {
      triedToOpen = [FBSession openActiveSessionWithPublishPermissions:PUBLISH_PERMISSIONS
                                                       defaultAudience:FBSessionDefaultAudienceFriends
                                                          allowLoginUI:login
                                                     completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                                       [self sessionStateChanged:session state:state error:error];
                                                     }];
    } else {
      FBSession *session = [[FBSession alloc] initWithPermissions:READ_PERMISSIONS];
      [FBSession setActiveSession:session];
      if (login || session.state == FBSessionStateCreatedTokenLoaded) {
#ifdef TEST_APP_SWITCH
        FBSessionLoginBehavior behavior = FBSessionLoginBehaviorWithFallbackToWebView;
#else
        FBSessionLoginBehavior behavior = FBSessionLoginBehaviorUseSystemAccountIfPresent;
#endif
        [session openWithBehavior:behavior completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
          [self sessionStateChanged:session state:state error:error];
        }];
      }
    }
    
    if (login) {
      self.timeOfLastLoginAttempt = [MSDate date];
    }
    
    // If session isn't created.. it means no token was found
    // To check this, call activeSession. Since, this will create a new session if it
    // is not already set, we must check if it's current state is created, since that
    // means it hasn't attempted logging in or anything.
    FBSession *session = [FBSession activeSession];
    if (!triedToOpen && session.state == FBSessionStateCreated) {
      [self respondToCompletionHandlersWithSuccess:NO];
    }
  }
}

+ (void) openSessionWithLoginUI:(BOOL)login completionHandler:(void (^)(BOOL success))completionHandler {
  [[self sharedFacebookDelegate] openSessionWithLoginUI:login completionHandler:completionHandler];
}

+ (void) getInvitableFacebookFriendsWithLoginUI:(BOOL)openLoginUI callback:(void (^)(NSArray *fbFriends))completion {
  [FacebookDelegate openSessionWithLoginUI:openLoginUI completionHandler:^(BOOL success) {
    if (success) {
      [FBRequestConnection startWithGraphPath:@"/me/invitable_friends"
                                   parameters:nil
                                   HTTPMethod:@"GET"
                            completionHandler:^(FBRequestConnection *connection,
                                                id result,
                                                NSError *error) {
                              if (error) {
                                LNLog(@"Error: %@", [error localizedDescription]);
                                completion(nil);
                              } else {
                                completion(result[@"data"]);
                              }
                            }];
    } else {
      completion(nil);
    }
  }];
}

+ (void) getAppFacebookFriendsWithLoginUI:(BOOL)openLoginUI callback:(void (^)(NSArray *fbFriends))completion {
  [FacebookDelegate openSessionWithLoginUI:openLoginUI completionHandler:^(BOOL success) {
    if (success) {
      [FBRequestConnection startWithGraphPath:@"/me/friends"
                                   parameters:nil
                                   HTTPMethod:@"GET"
                            completionHandler:^(FBRequestConnection *connection,
                                                id result,
                                                NSError *error) {
                              if (error) {
                                LNLog(@"Error: %@", [error localizedDescription]);
                                completion(nil);
                              } else {
                                completion(result[@"data"]);
                              }
                            }];
    } else {
      completion(nil);
    }
  }];
}

- (void) initiateRequestToFacebookIds:(NSArray *)fbIds withMessage:(NSString *)message completionBlock:(void(^)(BOOL success, NSArray *friendIds))completion {
  if (fbIds.count == 0) return;
  
  [self openSessionWithLoginUI:YES completionHandler:^(BOOL success) {
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
                                                        LNLog(@"Error sending request.");
                                                      } else {
                                                        if (result == FBWebDialogResultDialogNotCompleted) {
                                                          // Case B: User clicked the "x" icon
                                                          LNLog(@"User closed request.");
                                                        } else {
                                                          NSString *urlParams = resultURL.query;
                                                          if (!urlParams || [urlParams rangeOfString:@"request"].location == NSNotFound) {
                                                            // User clicked the Cancel button
                                                            LNLog(@"User canceled request.");
                                                          } else {
                                                            // Completed
                                                            LNLog(@"User sent request.");
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

- (void) getFacebookUsersWithIds:(NSArray *)idsArr handler:(void (^)(id result))handler {
  if (idsArr.count > 0) {
    [self openSessionWithLoginUI:NO completionHandler:^(BOOL success) {
      if (success) {
        NSMutableString *ids = [NSMutableString stringWithFormat:@"%@", idsArr[0]];
        for (int i = 1; i < idsArr.count; i++) {
          [ids appendFormat:@",%@", idsArr[i]];
        }
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:ids, @"ids", nil];
        [FBRequestConnection startWithGraphPath:@"" parameters:params HTTPMethod:nil completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
          if (error) {
            handler(nil);
          } else {
            handler(result);
          }
        }];
      } else {
        handler(nil);
      }
    }];
  } else {
    handler (nil);
  }
}

+ (void) getFacebookUsersWithIds:(NSArray *)idsArr handler:(void (^)(id result))handler {
  [[FacebookDelegate sharedFacebookDelegate] getFacebookUsersWithIds:idsArr handler:handler];
}

- (void) getMyFacebookUser:(void (^)(NSDictionary<FBGraphUser> *facebookUser))handler {
  if (!self.myFacebookUser) {
    LNLog(@"Attempting login for my facebook user.");
    [self openSessionWithLoginUI:NO completionHandler:^(BOOL success) {
      LNLog(@"Getting my facebook user.");
      if (success) {
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *result, NSError *error) {
          LNLog(@"Received my facebook user.");
          if (!error) {
            self.myFacebookUser = result;
            handler(result);
          } else {
            handler(nil);
          }
        }];
      } else {
        handler(nil);
      }
    }];
  } else {
    handler(self.myFacebookUser);
  }
}

+ (void) getFacebookUserAndDoAction:(void (^)(NSDictionary<FBGraphUser> *facebookId))handler {
  [[FacebookDelegate sharedFacebookDelegate] getMyFacebookUser:handler];
}

+ (void) getFacebookIdAndDoAction:(void (^)(NSString *facebookId))handler {
  [[FacebookDelegate sharedFacebookDelegate] getMyFacebookUser:^(NSDictionary<FBGraphUser> *facebookUser) {
    handler(facebookUser[@"id"]);
  }];
}

+ (void) getFacebookUsernameAndDoAction:(void (^)(NSString *username))handler {
  [[FacebookDelegate sharedFacebookDelegate] getMyFacebookUser:^(NSDictionary<FBGraphUser> *facebookUser) {
    handler(facebookUser.username);
  }];
}

- (void) logout {
  [self respondToCompletionHandlersWithSuccess:NO];
  [FBSession.activeSession closeAndClearTokenInformation];
  self.myFacebookUser = nil;
  [FBSession setActiveSession:nil];
}

+ (void) logout {
  [[FacebookDelegate sharedFacebookDelegate] logout];
}

@end
