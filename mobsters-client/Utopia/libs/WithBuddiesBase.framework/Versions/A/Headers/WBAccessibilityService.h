//
//  WBAccessibilityService.h
//  WithBuddiesCore
//
//  Created by Shuo Chang on 2013-08-28.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark Defines

// TODO: TBD
typedef NS_ENUM(NSInteger, WBPromotionType)
{
    WBPromotionPromo,
    WBPromotionAd,
    WBPromotionTournamentPopover
};

#pragma mark - Class Declaration

@interface WBAccessibilityService : NSObject

// Detects whether voiceover is enabled on the user device
+ (BOOL)isAccessibilityEnabled;

// Determines whether promo should be shown to user
+ (BOOL)shouldShowPromotionalContentForType: (WBPromotionType)promotionType;

@end
