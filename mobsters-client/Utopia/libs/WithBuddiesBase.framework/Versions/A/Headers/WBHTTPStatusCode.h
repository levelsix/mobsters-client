//
//  WBHTTPStatusCode.h
//  WithBuddiesCore
//
//  Created by odyth on 7/12/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#ifndef WithBuddiesCore_WBHTTPStatusCode_h
#define WithBuddiesCore_WBHTTPStatusCode_h

typedef NS_ENUM(NSInteger, WBHTTPStatusCode)
{
    WBHTTPStatusCodeUnknown = 0,
    
    /*--------------------------------------------------
     * 1xx Informational
     *------------------------------------------------*/
    
    /**
     * 100 Continue.
     */
    WBHTTPStatusCodeContinue = 100,
    
    /**
     * 101 Switching Protocols.
     */
    WBHTTPStatusCodeSwitchingProtocols = 101,
    
    /**
     * 103 Processing (WebDAV; RFC 2518).
     */
    WBHTTPStatusCodeProcessing = 102,
    
    /*--------------------------------------------------
     * 2xx Success
     *------------------------------------------------*/
    
    /**
     * 200 OK.
     */
    WBHTTPStatusCodeOK = 200,
    
    /**
     * 201 Created.
     */
    WBHTTPStatusCodeCreated = 201,
    
    /**
     * 202 Accepted.
     */
    WBHTTPStatusCodeAccepted = 202,
    
    /**
     * 203 Non-Authoritative Information (since HTTP/1.1).
     */
    WBHTTPStatusCodeNonAuthoritativeInformation = 203,
    
    /**
     * 204 No Content.
     */
    WBHTTPStatusCodeNoContent = 204,
    
    /**
     * 205 Reset Content.
     */
    WBHTTPStatusCodeResetContent = 205,
    
    /**
     * 206 Partial Content.
     */
    WBHTTPStatusCodePartialContent = 206,
    
    /**
     * 207 Multi-Status (WebDAV; RFC 4918).
     */
    WBHTTPStatusCodeMultiStatus = 207,
    
    /**
     * 208 Already Reported (WebDAV; RFC 5842).
     */
    WBHTTPStatusCodeAlreadyReported = 208,
    
    /**
     * 226 IM Used (RFC 3229)
     */
    WBHTTPStatusCodeIMUsed = 226,
    
    /**
     * 250 Low on Storage Space (RTSP; RFC 2326).
     */
    WBHTTPStatusCodeLowOnStorageSpace = 250,
    
    
    /*--------------------------------------------------
     * 3xx Redirection
     *------------------------------------------------*/
    
    /**
     * 300 Multiple Choices.
     */
    WBHTTPStatusCodeMultipleChoices = 300,
    
    /**
     * 301 Moved Permanently.
     */
    WBHTTPStatusCodeMovedPermanently = 301,
    
    /**
     * 302 Found.
     */
    WBHTTPStatusCodeFound = 302,
    
    /**
     * 303 See Other (since HTTP/1.1).
     */
    WBHTTPStatusCodeSeeOther = 303,
    
    /**
     * 304 Not Modified.
     */
    WBHTTPStatusCodeNotModified = 304,
    
    /**
     * 305 Use Proxy (since HTTP/1.1).
     */
    WBHTTPStatusCodeUseProxy = 305,
    
    /**
     * 306 Switch Proxy.
     */
    WBHTTPStatusCodeSwitchProxy = 306,
    
    /**
     * 307 Temporary Redirect (since HTTP/1.1).
     */
    WBHTTPStatusCodeTemporaryRedirect = 307,
    
    /**
     * 308 Permanent Redirect (approved as experimental RFC).
     */
    WBHTTPStatusCodePermanentRedirect = 308,
    
    /*--------------------------------------------------
     * 4xx Client Error
     *------------------------------------------------*/
    
    /**
     * 400 Bad Request.
     */
    WBHTTPStatusCodeBadRequest = 400,
    
    /**
     * 401 Unauthorized.
     */
    WBHTTPStatusCodeUnauthorized = 401,
    
    /**
     * 402 Payment Required.
     */
    WBHTTPStatusCodePaymentRequired = 402,
    
    /**
     * 403 Forbidden.
     */
    WBHTTPStatusCodeForbidden = 403,
    
    /**
     * 404 Not Found.
     */
    WBHTTPStatusCodeNotFound = 404,
    
    /**
     * 405 Method Not Allowed.
     */
    WBHTTPStatusCodeMethodNotAllowed = 405,
    
    /**
     * 406 Not Acceptable.
     */
    WBHTTPStatusCodeNotAcceptable = 406,
    
    /**
     * 407 Proxy Authentication Required.
     */
    WBHTTPStatusCodeProxyAuthenticationRequired = 407,
    
    /**
     * 408 Request Timeout.
     */
    WBHTTPStatusCodeRequestTimeout = 408,
    
    /**
     * 409 Conflict.
     */
    WBHTTPStatusCodeConflict = 409,
    
    /**
     * 410 Gone.
     */
    WBHTTPStatusCodeGone = 410,
    
    /**
     * 411 Length Required.
     */
    WBHTTPStatusCodeLengthRequired = 411,
    
    /**
     * 412 Precondition Failed.
     */
    WBHTTPStatusCodePreconditionFailed = 412,
    
    /**
     * 413 Request Entity Too Large.
     */
    WBHTTPStatusCodeRequestEntityTooLarge = 413,
    
    /**
     * 414 Request-URI Too Long.
     */
    WBHTTPStatusCodeRequestURITooLong = 414,
    
    /**
     * 415 Unsupported Media Type.
     */
    WBHTTPStatusCodeUnsupportedMediaType = 415,
    
    /**
     * 416 Requested Range Not Satisfiable.
     */
    WBHTTPStatusCodeRequestedRangeNotSatisfiable = 416,
    
    /**
     * 417 Expectation Failed.
     */
    WBHTTPStatusCodeExpectationFailed = 417,
    
    /**
     * 418 I'm a teapot (RFC 2324).
     */
    WBHTTPStatusCodeImATeapot = 418,
    
    /**
     * 420 Enhance Your Calm (Twitter).
     */
    WBHTTPStatusCodeEnhanceYourCalm = 420,
    
    /**
     * 422 Unprocessable Entity (WebDAV; RFC 4918).
     */
    WBHTTPStatusCodeUnprocessableEntity = 422,
    
    /**
     * 423 Locked (WebDAV; RFC 4918).
     */
    WBHTTPStatusCodeLocked = 423,
    
    /**
     * 424 Failed Dependency (WebDAV; RFC 4918).
     */
    WBHTTPStatusCodeFailedDependency = 424,
    
    /**
     * 425 Unordered Collection (Internet draft).
     */
    WBHTTPStatusCodeUnorderedCollection = 425,
    
    /**
     * 426 Upgrade Required (RFC 2817).
     */
    WBHTTPStatusCodeUpgradeRequired = 426,
    
    /**
     * 428 Precondition Required (RFC 6585).
     */
    WBHTTPStatusCodePreconditionRequired = 428,
    
    /**
     * 429 Too Many Requests (RFC 6585).
     */
    WBHTTPStatusCodeTooManyRequests = 429,
    
    /**
     * 431 Request Header Fields Too Large (RFC 6585).
     */
    WBHTTPStatusCodeRequestHeaderFieldsTooLarge = 431,
    
    /**
     * 444 No Response (Nginx).
     */
    WBHTTPStatusCodeNoResponse = 444,
    
    /**
     * 449 Retry With (Microsoft).
     */
    WBHTTPStatusCodeRetryWith = 449,
    
    /**
     * 450 Blocked by Windows Parental Controls (Microsoft).
     */
    WBHTTPStatusCodeBlockedByWindowsParentalControls = 450,
    
    /**
     * 451 Parameter Not Understood (RTSP).
     */
    WBHTTPStatusCodeParameterNotUnderstood = 451,
    
    /**
     * 451 Unavailable For Legal Reasons (Internet draft).
     */
    WBHTTPStatusCodeUnavailableForLegalReasons = 451,
    
    /**
     * 451 Redirect (Microsoft).
     */
    WBHTTPStatusCodeRedirect = 451,
    
    /**
     * 452 Conference Not Found (RTSP).
     */
    WBHTTPStatusCodeConferenceNotFound = 452,
    
    /**
     * 453 Not Enough Bandwidth (RTSP).
     */
    WBHTTPStatusCodeNotEnoughBandwidth = 453,
    
    /**
     * 454 Session Not Found (RTSP).
     */
    WBHTTPStatusCodeSessionNotFound = 454,
    
    /**
     * 455 Method Not Valid in This State (RTSP).
     */
    WBHTTPStatusCodeMethodNotValidInThisState = 455,
    
    /**
     * 456 Header Field Not Valid for Resource (RTSP).
     */
    WBHTTPStatusCodeHeaderFieldNotValidForResource = 456,
    
    /**
     * 457 Invalid Range (RTSP).
     */
    WBHTTPStatusCodeInvalidRange = 457,
    
    /**
     * 458 Parameter Is Read-Only (RTSP).
     */
    WBHTTPStatusCodeParameterIsReadOnly = 458,
    
    /**
     * 459 Aggregate Operation Not Allowed (RTSP).
     */
    WBHTTPStatusCodeAggregateOperationNotAllowed = 459,
    
    /**
     * 460 Only Aggregate Operation Allowed (RTSP).
     */
    WBHTTPStatusCodeOnlyAggregateOperationAllowed = 460,
    
    /**
     * 461 Unsupported Transport (RTSP).
     */
    WBHTTPStatusCodeUnsupportedTransport = 461,
    
    /**
     * 462 Destination Unreachable (RTSP).
     */
    WBHTTPStatusCodeDestinationUnreachable = 462,
    
    /**
     * 494 Request Header Too Large (Nginx).
     */
    WBHTTPStatusCodeRequestHeaderTooLarge = 494,
    
    /**
     * 495 Cert Error (Nginx).
     */
    WBHTTPStatusCodeCertError = 495,
    
    /**
     * 496 No Cert (Nginx).
     */
    WBHTTPStatusCodeNoCert = 496,
    
    /**
     * 497 HTTP to HTTPS (Nginx).
     */
    WBHTTPStatusCodeHTTPToHTTPS = 497,
    
    /**
     * 499 Client Closed Request (Nginx).
     */
    WBHTTPStatusCodeClientClosedRequest = 499,
    
    /*--------------------------------------------------
     * 5xx Server Error
     *------------------------------------------------*/
    
    /**
     * 500 Internal Server Error.
     */
    WBHTTPStatusCodeInternalServerError = 500,
    
    /**
     * 501 Not Implemented
     */
    WBHTTPStatusCodeNotImplemented = 501,
    
    /**
     * 502 Bad Gateway.
     */
    WBHTTPStatusCodeBadGateway = 502,
    
    /**
     * 503 Service Unavailable.
     */
    WBHTTPStatusCodeServiceUnavailable = 503,
    
    /**
     * 504 Gateway Timeout.
     */
    WBHTTPStatusCodeGatewayTimeout = 504,
    
    /**
     * 505 HTTP Version Not Supported.
     */
    WBHTTPStatusCodeHTTPVersionNotSupported = 505,
    
    /**
     * 506 Variant Also Negotiates (RFC 2295).
     */
    WBHTTPStatusCodeVariantAlsoNegotiates = 506,
    
    /**
     * 507 Insufficient Storage (WebDAV; RFC 4918).
     */
    WBHTTPStatusCodeInsufficientStorage = 507,
    
    /**
     * 508 Loop Detected (WebDAV; RFC 5842).
     */
    WBHTTPStatusCodeLoopDetected = 508,
    
    /**
     * 509 Bandwidth Limit Exceeded (Apache bw/limited extension).
     */
    WBHTTPStatusCodeBandwidthLimitExceeded = 509,
    
    /**
     * 510 Not Extended (RFC 2774).
     */
    WBHTTPStatusCodeNotExtended = 510,
    
    /**
     * 511 Network Authentication Required (RFC 6585).
     */
    WBHTTPStatusCodeNetworkAuthenticationRequired = 511,
    
    /**
     * 551 Option not supported (RTSP).
     */
    WBHTTPStatusCodeOptionNotSupported = 551,
    
    /**
     * 569 internal maintenance mode code
     */
    WBHTTPStatusCodeMaintenanceMode = 569,
    
    /**
     * 598 Network read timeout error (Unknown).
     */
    WBHTTPStatusCodeNetworkReadTimeoutError = 598,
    
    /**
     * 599 Network connect timeout error (Unknown).
     */
    WBHTTPStatusCodeNetworkConnectTimeoutError = 599,
    
    /*--------------------------------------------------
     * 9xx Server Error
     *------------------------------------------------*/
    
    /**
     * 910 Dependee response failed
     */
    WBHTTPStatusCodeDependeeResponseFailed = 910
};


#endif
