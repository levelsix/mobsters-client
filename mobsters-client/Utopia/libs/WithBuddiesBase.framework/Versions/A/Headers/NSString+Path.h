//
//  NSString+Path.h
//  WithBuddiesCore
//
//  Created by odyth on 8/8/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Path)

-(NSURL *)path;
-(NSURL *)cachePath;
-(NSURL *)downloadPath;

@end
