//
//  NSString+CurrencyName.h
//  WithBuddiesCore
//
//  Created by Tim Gostony on 8/30/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CurrencyName)

+(NSString*)currencyNameWithAmount:(NSInteger)amount;

+(NSString*)currencyNamePlural;
+(NSString*)currencyNameSingular;


@end
