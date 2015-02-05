//
//  UIView+Superview.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/3/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "UIView+Superview.h"

@implementation UIView (Superview)

- (id) getAncestorInViewHierarchyOfType:(Class)clazz {
  UIView *sender = self;
  while (sender && ![sender isKindOfClass:clazz]) {
    sender = [sender superview];
  }
  return sender;
}

@end
