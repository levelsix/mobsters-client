//
//  EmbeddedScrollingUpgradeView.h
//  Utopia
//
//  Created by Kenneth Cox on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "NibUtils.h"

@interface UpgradeTitleBar : UIView

@property (weak, nonatomic) IBOutlet UILabel *title;

@end

@interface StrengthDetails : UIView

@end

@interface EmbeddedScrollingUpgradeView : EmbeddedNibView

@property (retain, nonatomic) IBOutlet UIView *view;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@end
