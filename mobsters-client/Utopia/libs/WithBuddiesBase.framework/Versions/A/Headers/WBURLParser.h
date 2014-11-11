//
//  WBURLParser.h
//  WithBuddiesCore
//
//  Created by justin stofle on 7/31/12.
//  Copyright (c) 2012 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBURLParser : NSObject {

}

@property  (nonatomic, strong, readonly) NSString *url;
@property  (nonatomic, strong, readonly) NSDictionary *parameters;
@property  (nonatomic, strong, readonly) NSString *scheme;
@property  (nonatomic, strong, readonly) NSString *host;
@property  (nonatomic, strong, readonly) NSArray *paths;

-(id)initWithURL:(NSURL *)url;
-(id)initWithURLString:(NSString *)url;

-(void)parse;


@end
