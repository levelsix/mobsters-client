//
//  WBObject.h
//  WithBuddiesCore
//
//  Created by odyth on 6/17/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WBServerCase)
{
    WBServerCasePascal,
    WBServerCaseLower,
    WBServerCaseCamel
};

@interface NSObject (Object)

/// Returns a new, autoreleased instance of this class, initialized with <code>init</code>. 
+(instancetype)object;

+(instancetype)objectWithDictionary:(NSDictionary *)dictionary;
+(instancetype)objectWithDictionary:(NSDictionary *)dictionary serverCase:(WBServerCase)serverCase;
-(NSDictionary *)dictionaryWithObject;
-(NSDictionary *)dictionaryWithObjectAndServerCase:(WBServerCase)serverCase;

+(NSArray *)objectsWithDictionaries:(NSArray*)dictionaries;
+(NSArray *)objectsWithDictionaries:(NSArray*)dictionaries serverCase:(WBServerCase)serverCase;

@end

@protocol WBObject <NSObject>


@end

@interface WBPersistedObject : NSObject <NSCoding, NSCopying>

-(id)objectForPost;

@end

@interface WBObjectArray : NSMutableArray <WBObject>

@end

@interface WBObject : NSMutableDictionary <WBObject>

@property (nonatomic, assign) WBServerCase serverCase;

+(id)wbObjectWithJsonObject:(id)jsonObject;
+(id)wbObjectWithObject:(id)object;
+(id)wbObject;

+(WBObjectArray *)objectifyObjects:(NSArray *)objects;

-(id)objectForPost;
-(void)objectify;

@end


