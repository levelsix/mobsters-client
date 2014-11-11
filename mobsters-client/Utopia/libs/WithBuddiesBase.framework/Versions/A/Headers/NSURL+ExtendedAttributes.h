//
//  NSURL+ExtendedAttributes.h
//  WithBuddiesBase
//
//  Created by odyth on 3/20/14.
//  Copyright (c) 2014 scopely. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (ExtendedAttributes)

-(BOOL)removeExtendedAttributeForKey:(NSString *)key;
-(BOOL)setExtendedAttributeValue:(NSString *)value forKey:(NSString *)key;
-(BOOL)getExtendedAttributeValue:(out NSString **)value forKey:(NSString *)key;

@end
