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
  if ([self.cashLabel isKindOfClass:[NumTransitionLabel class]])
    self.cashLabel.transitionDelegate = self;
  
  if ([self.oilLabel isKindOfClass:[NumTransitionLabel class]])
    self.oilLabel.transitionDelegate = self;
  
  if ([self.gemsLabel isKindOfClass:[NumTransitionLabel class]])
    self.gemsLabel.transitionDelegate = self;
  
  if ([self.tokensLabel isKindOfClass:[NumTransitionLabel class]])
    self.tokensLabel.transitionDelegate = self;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabels) name:GAMESTATE_UPDATE_NOTIFICATION object:nil];
  
  [self updateLabelsAnim:NO];
}

- (void) updateLabels {
  [self updateLabelsAnim:YES];
}

- (void) updateLabelsAnim:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  
  if (![self.cashLabel isKindOfClass:[NumTransitionLabel class]])
    self.cashLabel.text = [Globals cashStringForNumber:gs.cash];
  else {
    if (animated)
      [self.cashLabel transitionToNum:gs.cash];
    else
      [self.cashLabel instaMoveToNum:gs.cash];
  }
  
  if (![self.oilLabel isKindOfClass:[NumTransitionLabel class]])
    self.oilLabel.text = [Globals commafyNumber:gs.oil];
  else {
    if (animated)
      [self.oilLabel transitionToNum:gs.oil];
    else
      [self.oilLabel instaMoveToNum:gs.oil];
  }
  
  if (![self.gemsLabel isKindOfClass:[NumTransitionLabel class]])
    self.gemsLabel.text = [Globals commafyNumber:gs.gems];
  else {
    if (animated)
      [self.gemsLabel transitionToNum:gs.gems];
    else
      [self.gemsLabel instaMoveToNum:gs.gems];
  }
  
  if (![self.tokensLabel isKindOfClass:[NumTransitionLabel class]])
    self.tokensLabel.text = [Globals commafyNumber:gs.tokens];
  else {
    if (animated)
      [self.tokensLabel transitionToNum:gs.tokens];
    else
      [self.tokensLabel instaMoveToNum:gs.tokens];
  }
}

- (void) updateLabel:(NumTransitionLabel *)label forNumber:(uint64_t)number {
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
