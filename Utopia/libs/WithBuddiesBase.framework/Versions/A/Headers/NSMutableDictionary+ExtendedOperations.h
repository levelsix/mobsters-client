//
//  NSMutableDictionary+ExtendedOperations.h
//
//  Created by Tim Gostony on 3/20/14.
//  Copyright (c) 2014 Tim Gostony. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (ExtendedOperations)


/// Changes the name of a key.  The object remains unchanged.  Anything stored at the new key's location will be removed.  The old key will no longer be set.
-(void)replaceKey:(id)oldKey
          withKey:(id <NSCopying>)newKey;

/// Returns an item from the dictionary and then removes it.
-(id)popObjectForKey:(id)key;

@end
