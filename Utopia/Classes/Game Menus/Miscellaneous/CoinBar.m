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
  if ([self.cashLabel isKindOfClass:[NumTransitionLabel class]]) {
    self.cashLabel.transitionDelegate = self;
    self.oilLabel.transitionDelegate = self;
    self.gemsLabel.transitionDelegate = self;
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabels) name:GAMESTATE_UPDATE_NOTIFICATION object:nil];
  [self updateLabelsAnim:NO];
}

- (void) updateLabels {
  [self updateLabelsAnim:YES];
}

- (void) updateLabelsAnim:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  
  if (![self.cashLabel isKindOfClass:[NumTransitionLabel class]]) {
    self.cashLabel.text = [Globals cashStringForNumber:gs.cash];
    self.oilLabel.text = [Globals commafyNumber:gs.oil];
    self.gemsLabel.text = [Globals commafyNumber:gs.gems];
  } else {
    if (animated) {
      [self.cashLabel transitionToNum:gs.cash];
      [self.oilLabel transitionToNum:gs.oil];
      [self.gemsLabel transitionToNum:gs.gems];
    } else {
      [self.cashLabel instaMoveToNum:gs.cash];
      [self.oilLabel instaMoveToNum:gs.oil];
      [self.gemsLabel instaMoveToNum:gs.gems];
    }
  }
}

- (void) updateLabel:(NumTransitionLabel *)label forNumber:(int)number {
  if (label == self.cashLabel) {
    label.text = [Globals cashStringForNumber:number];
  } else {
    label.text = [Globals commafyNumber:number];
  }
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
