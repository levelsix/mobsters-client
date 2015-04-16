//
//  SalesMenuDelegate.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/14/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InAppPurchaseData.h"

#define DARKEN_VIEW_TAG 123
#define DARKEN_VIEW_COLOR [UIColor colorWithWhite:0.f alpha:0.7f]

@protocol SalesMenuDelegate <NSObject>

- (void) iapClicked:(id<InAppPurchaseData>)iap;

@end
