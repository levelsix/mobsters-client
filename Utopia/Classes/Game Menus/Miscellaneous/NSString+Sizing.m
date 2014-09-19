//
//  NSString+Sizing.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "NSString+Sizing.h"

@implementation NSString (Sizing)

- (CGSize) getSizeWithFont:(UIFont *)font {
  return [self getSizeWithFont:font constrainedToSize:CGSizeZero];
}

- (CGSize) getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
  return [self getSizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize) getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)mode {
  NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.lineBreakMode = mode;
  CGRect r = [self boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                             attributes:@{NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle} context:NULL];
  return r.size;
}

@end
