//
//  CoinBar.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoinBar : UIView

@property (nonatomic, retain) IBOutlet UILabel *cashLabel;
@property (nonatomic, retain) IBOutlet UILabel *oilLabel;
@property (nonatomic, retain) IBOutlet UILabel *gemsLabel;

- (void) updateLabels;

@end
