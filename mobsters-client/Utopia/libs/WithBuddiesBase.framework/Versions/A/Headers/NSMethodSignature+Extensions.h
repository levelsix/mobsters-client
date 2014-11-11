//
//  NSMethodSignature+Extensions.h
//  WithBuddiesCore
//
//  Created by odyth on 6/18/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WithBuddiesBase/WBObjectType.h>
#import <WithBuddiesBase/WBSelectorInferredType.h>

struct WBType {
    Class wbClass;
    WBObjectType type;
};
typedef struct WBType WBType;

@interface NSMethodSignature (Extensions)

@property (nonatomic, assign) WBSelectorInferredType selectorInferredType;
@property (nonatomic, assign) SEL alternateSelector;
@property (nonatomic, retain) NSString *propertyName;
@property (nonatomic, assign) WBType type;

@end
