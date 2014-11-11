//
//  WBError.h
//  WithBuddiesCore
//
//  Created by odyth on 6/25/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WithBuddiesBase/WBHTTPStatusCode.h>
#import <WithBuddiesBase/WBRequestStatus.h>

/*!
 The key in the userInfo NSDictionary of NSError for the parsed request status
 */
extern NSString *const WBErrorWBRequestStatusKey;

extern NSString * const WBYoureDoingItWrongException;
extern NSString * const WBYoureDoingItWrongExceptionReason;

typedef NS_ENUM(NSInteger, WBErrorCode)
{
    WBErrorCodeNone = 0,
    
    /** server error codes **/
    WBErrorCodeRequestedEntityNotFound = -3,
    WBErrorCodeNeedsUpdate = -7,
    WBErrorCodeInvalidSignature = -8,
    WBErrorCodeSignatureRequiredAndClientUnable = -9,
    WBErrorCodeMaintainence = -10,
    
    WBErrorCodeUsernameInUse = 2001,
    WBErrorCodeEmailInUse =  2002,
    WBErrorCodeInvalidUsername = 2003,
    WBErrorCodeInvalidFacebookAccessToken = 2004,
    WBErrorCodeFacebookAccessTokenRequired = 2005,
    WBErrorCodeInvalidEmailAddress = 2008,
    WBErrorCodeUnableToVerifyGameCenterIdentity = 2009,
    WBErrorCodeInvalidGameCenterIdentity = 2010,
    WBErrorCodeInvalidPassword = 2040,
    
    WBErrorCodeMessagesEmptyMessage = 3001,
    WBErrorCodeMessagesEmptyUnreadCount = 3002,
    WBErrorCodeMessagesUserHasBlockedYou = 3003,
    WBErrorCodeMessagesUnknownRecipient = 3004,
    WBErrorCodeMessagesUnsupportedMimeType = 3005,
    
    WBErrorCodeInvalidLogin = 4001,
    WBErrorCodeFacebookAccessTokenHasNoAccount = 4003,
    WBErrorCodeGameCenterPlayerIdHasNoAccount = 4010,
    WBErrorCodeGameCenterUnableToVerifyIdentity = 4011,
    WBErrorCodeGameCenterIdentityInvalid = 4012,
    
    WBErrorCodeNotYourGame = 5001,
    WBErrorCodeGamesCannotPlaySelf = 5102,
    WBErrorCodeUserNameDoesNotExist = 5101,
    WBErrorCodeUserDoesNotHaveGame = 5006,
    WBErrorCodeUserBlockedYou = 5103,
    WBErrorCodeNotYourTurn = 6001,
    WBErrorCodeStateVersionOutOfSync = 6004,
    WBErrorCodeGameExpired = 6014,
    WBErrorCodeEmptyNotification = 7001,
    WBErrorCodeAddressBookAlreadyUploaded = 9001,
    
    WBErrorCodeOfferAlreadyRedeemed = 11002,
    
    WBErrorCodeEconomyDebitLimit = 15021,
    WBErrorCodeEconomyInsufficientFunds = 15011,
    WBErrorCodeTournamentNotFound = 25001,
    WBErrorCodeTournamentExpired = 25002,
    WBErrorCodeTournamentInvalid = 25003,
    WBErrorCodeTournamentNotATournament = 25004,
    WBErrorCodeTournamentPriceMismatch = 25005,
    WBErrorCodeTournamentEntryLimit = 25006,
    WBErrorCodeTournamentGameExpired = 25009,
    WBErrorCodeTournamentInvalidEntryCommodity = 25012,
    
    WBErrorCodeAchievementUnableToDebitCost = 26005,
    
    WBErrorCodeUnableToCreateMap = 32000,
    WBErrorCodeUnableToCreateLevel = 32001,
    WBErrorCodeUnableToQuery = 32002,
    WBErrorCodeMapDoesNotExist = 32003,
    WBErrorCodeLevelDoesNotExist = 32004,
    WBErrorCodeUnableToCreateUnlockReq = 32005,
    WBErrorCodeUnableToCreateMapAward = 32006,
    WBErrorCodeUnableToCreateLevelEntryCost = 32007,
    WBErrorCodeUnableToCreateLevelAward = 32008,
    WBErrorCodeCannotInsertTypeOfAwardTableBase = 32009,
    WBErrorCodeUnableToCreateEntryCost = 32010,
    WBErrorCodeValidationFailed = 32011,
    WBErrorCodeParentMapDoesNotExist = 32012,
    WBErrorCodeToCompleteMapDoesNotExist = 32013,
    WBErrorCodeToCompleteLevelDoesNotExist = 32013,
    WBErrorCodeValidationSubscriptionDays = 32014,
    WBErrorCodeUnableToCreateCommodityForMap = 32015,
    WBErrorCodeEntryCostDoesNotExist = 32016,
    WBErrorCodeUnableToDeleteEntryCost = 32017,
    WBErrorCodeAwardDoesNotExist = 32018,
    WBErrorCodeUnableToDeleteAward = 32019,
    WBErrorCodeUnlockRequirementeDoesNotExist = 32020,
    WBErrorCodeUnableToDeleteUnlockRequirement = 32021,
    WBErrorCodeLevelNotFound = 32101,
    WBErrorCodeInvalidLevelTransition = 32102,
    WBErrorCodeYouMustChooseAnEntryCost = 32103,
    WBErrorCodeYouDoNotHaveTheEntryFee = 32104,
    
    WBErrorCodeGamesMustStartWithPhantomContext = 34000,
    WBErrorCodeCannotLoadAlreadyPlayedPhantomGame = 34100,
    
    WBErrorCodeBlobNotFound = 38100,
    WBErrorCodeBlobConflict = 38101,   
    
    WBErrorCodeAidNotFacebookConnected = 42001,
    
    /** client errors are -10,000 and below **/
    WBErrorCodeNetworkError = -10000,
    WBErrorCodeUserCanceledDownload =	-10001,
    WBErrorCodeDownloadRequiresWifi =	-10002,
    WBErrorCodeUnsupportedDownloadUrl = -10003,
    WBErrorCodeCanceledOperation = -10004,
    
    /** deep linking errors**/
    // Calendar
	WBErrorCodeCalendarAccessDenied =	-14003,
	WBErrorCodeCalendarEventInvalid =	-14004,
	WBErrorCodeCalendarEventExists =	-14005,
    
    
    
    //** io related errors **//
    WBErrorCodeCouldNotOpenZipArchive = -11000,
    WBErrorCodeInvalidZipArchive =      -11001,
    WBErrorCodeWriteFailed =            -11002,
    
    
    //** auth errors **//
    WBErrorCodeGameCenterPlayerNotAuthenticated =   -12000,
    WBErrorUserCancelledAuthSwitch =                -12001,
    WBErrorCodeUserNotLoggedIn =                    -12002,
    WBErrorCodeInvalidUsernameStringLength =        -12003,
    WBErrorCodeInvalidUsernameStringCharacters =    -12004,
    
    //** iap errors **//
    WBErrorCodeIAPItemNotIniTunes = -13000,
    WBErrorCodeIAPMustBeOnlineToMakePurchase = -13001,
    WBErrorCodeIAPCouldNotConnectToAppStore = -13002,
    
    //** messaging errors **//
    WBErrorCodeMessagesCannotSendMessageFromThisState = -14000,
    
    //** game related errors **/
    WBErrorCodeSearchingForRandom = -15002,
    
    //** aid related errors **/
    WBErrorCodeAidNoUsers = -16000,
    WBErrorCodeAidFailedFacebookRequest = -16001,
};

extern NSString *const WBLocalizedShortDescriptionKey;

@interface NSError (WBError)

+(NSError *)errorWithRequestStatus:(WBRequestStatus)status httpStatusCode:(WBHTTPStatusCode)httpStatusCode;
+(NSError *)errorWithRequestStatus:(WBRequestStatus)status errorCode:(WBErrorCode)errorCode;
+(NSError *)errorWithRequestStatus:(WBRequestStatus)status errorCode:(WBErrorCode)errorCode context:(NSString *)context recoveryAttempter:(NSObject *)recoveryAttempter;
+(NSError *)errorWithCode:(WBErrorCode)errorCode;
+(NSError *)errorWithTitle:(NSString *)title description:(NSString *)description errorCode:(WBErrorCode)errorCode;
-(NSString *)localizedShortDescription;

-(WBHTTPStatusCode)httpStatusCode;

@end


