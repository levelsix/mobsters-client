//
//  CoinBar.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "CoinBar.h"
#import "GameState.h"
#import "Globals.h"

@implementation CoinBar

- (void) awakeFromNib {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabels) name:GAMESTATE_UPDATE_NOTIFICATION object:nil];
  [self updateLabels];
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  
  self.cashLabel.text = [Globals commafyNumber:gs.silver];
  self.oilLabel.text = [Globals commafyNumber:gs.oil];
  self.gemsLabel.text = [Globals commafyNumber:gs.gold];
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
