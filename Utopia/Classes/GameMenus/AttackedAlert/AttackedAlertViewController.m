//
//  AttackedAlertViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 2/6/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "AttackedAlertViewController.h"
#import "Globals.h"
#import "GameState.h"

@implementation AttackedAlertView

- (void) updateForPvpList:(NSArray *) pvpList{
  _oilLost = 0;
  _cashLost = 0;
  _rankLost = 0;
  for( PvpHistoryProto *pvp in pvpList) {
    _oilLost += pvp.defenderOilChange;
    _cashLost += pvp.defenderCashChange;
    int change = pvp.defenderBefore.rank - pvp.defenderAfter.rank;
    _rankLost += change;
  }
}

@end

@implementation AttackedAlertViewController

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  GameState *gs = [GameState sharedGameState];
  [self.alertView updateForPvpList:[gs allUnreadDefenseHistory]];
  
  [Globals bounceView:self.alertView fadeInBgdView:self.BGView];
}

- (void) close {
  [Globals popOutView:self.alertView fadeOutBgdView:self.BGView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}
- (IBAction)clickedClose:(id)sender {
}

@end
