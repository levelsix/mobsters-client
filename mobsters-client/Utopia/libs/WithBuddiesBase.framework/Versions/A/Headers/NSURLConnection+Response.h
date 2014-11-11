//
//  NSURLConnection+StatusCode.h
//  WithBuddiesCore
//
//  Created by odyth on 7/11/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WithBuddiesBase/WBHTTPStatusCode.h>

@interface NSURLConnection (Response)

@property (nonatomic, assign) WBHTTPStatusCode statusCode;
@property (nonatomic, retain) NSDictionary *responseHeaders;

@end
