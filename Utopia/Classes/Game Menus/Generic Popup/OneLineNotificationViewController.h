//
//  OneLineNotificationViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/27/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "OmnipresentViewController.h"

@interface OneLineNotificationViewController : OmnipresentViewController

@property (nonatomic, retain) NSMutableArray *labels;

- (void) addNotification:(NSString *)string color:(UIColor *)color;

@end
