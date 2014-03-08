//
//  TutorialAttackMapViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "AttackMapViewController.h"

@interface TutorialAttackMapViewController : AttackMapViewController

@property (nonatomic, assign) int clickableCityId;

- (void) allowClickOnCityId:(int)cityId;

@end
