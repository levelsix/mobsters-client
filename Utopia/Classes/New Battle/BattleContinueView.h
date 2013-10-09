//
//  BattleContinueView.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/18/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BattleContinueView : UIView

@property (nonatomic, assign) IBOutlet UIView *mainView;
@property (nonatomic, assign) IBOutlet UIView *bgdView;

@property (nonatomic, assign) IBOutlet UILabel *itemsLabel;
@property (nonatomic, assign) IBOutlet UILabel *cashLabel;

- (void) displayWithItems:(int)items cash:(int)cash;

@end
