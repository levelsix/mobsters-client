//
//  WBDictionaryRepresentation.h
//  WithBuddiesCore
//
//  Created by odyth on 12/27/12.
//  Copyright (c) 2012 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WBDictionaryRepresentation <NSObject>

@required
-(NSDictionary *)dictionaryValue;

@optional
-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
