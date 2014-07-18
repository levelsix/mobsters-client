//
//  NSNumber+AbbreviatedStringValue.h
//  WithBuddiesBase
//
//  Created by Tim Gostony on 11/10/13.
//  Copyright (c) 2013 scopely. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (AbbreviatedStringValue)

/// Truncates to the nearest thousand, if it's an even-enough number.  E.g. 1000 => 1K, 1500 => 1.5K, 63 => 63,  1938 => 1938
-(NSString*)abbreviatedStringValue;

@end
