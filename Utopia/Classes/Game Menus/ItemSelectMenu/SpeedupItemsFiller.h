//
//  SpeedupItemsFiller.h
//  Utopia
//
//  Created by Ashwin on 11/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ItemSelectViewController.h"

@interface SpeedupItemsFiller : NSObject <ItemSelectDelegate>

@property (nonatomic, retain) NSMutableArray *items;

@end
