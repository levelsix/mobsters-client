//
//  BattleContinueView.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/18/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "BattleContinueView.h"
#import "Globals.h"

@implementation BattleContinueView

- (void) displayWithItems:(int)items cash:(int)cash {
  [Globals displayUIView:self];
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

@end
