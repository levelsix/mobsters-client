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

@property (nonatomic, retain) IBOutlet UIView* cashView;
@property (nonatomic, retain) IBOutlet UIView* oilView;
@property (nonatomic, retain) IBOutlet UIView* gemsView;
@property (nonatomic, retain) IBOutlet UIView* tokensView;

@property (nonatomic, retain) IBOutlet NumTransitionLabel *cashLabel;
@property (nonatomic, retain) IBOutlet NumTransitionLabel *oilLabel;
@property (nonatomic, retain) IBOutlet NumTransitionLabel *gemsLabel;
@property (nonatomic, retain) IBOutlet NumTransitionLabel *tokensLabel;

@property (nonatomic, retain) IBOutlet UIImageView* cashIcon;
@property (nonatomic, retain) IBOutlet UIImageView* oilIcon;
@property (nonatomic, retain) IBOutlet UIImageView* gemIcon;
@property (nonatomic, retain) IBOutlet UIImageView* tokenIcon;

- (void) updateLabels;

@end
