//
//  UIView+Superview.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/3/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Superview)

- (id) getAncestorInViewHierarchyOfType:(Class)class;

@end
