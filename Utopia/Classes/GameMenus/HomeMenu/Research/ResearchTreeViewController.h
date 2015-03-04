//
//  RearchTreeViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 3/3/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSubViewController.h"

@interface ResearchTreeViewController : PopupSubViewController
-(id)initWithDomain:(ResearchDomain)domain;
-(void)researchButtonClickWithIndex:(NSInteger) index;

@end

@interface ResearchButtonView : UIView

@property (weak, nonatomic) IBOutlet UILabel *researchNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;

@property (weak, nonatomic) IBOutlet UIImageView *selectedOutline;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;

@property (nonatomic, assign) ResearchTreeViewController* delegate;

@end
