//
//  NSString+Sizing.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Sizing)

- (CGSize) getSizeWithFont:(UIFont *)font;
- (CGSize) getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGSize) getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)mode;

@end
