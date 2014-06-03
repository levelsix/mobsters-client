//
//  CoinBar.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NibUtils.h"

@interface CoinBar : UIView <NumTransitionLabelDelegate>

@property (nonatomic, retain) IBOutlet NumTransitionLabel *cashLabel;
@property (nonatomic, retain) IBOutlet NumTransitionLabel *oilLabel;
@property (nonatomic, retain) IBOutlet NumTransitionLabel *gemsLabel;

- (void) updateLabels;

@end
