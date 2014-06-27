//
//  EvolveChooserViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "EvolveChooserViews.h"
#import "GameState.h"
#import "Globals.h"

@implementation EvolveCardCell

- (void) awakeFromNib {
  [self.topContainer.monsterCardView.nameLabel removeFromSuperview];
  UILabel *nameLabel = self.botContainer.monsterCardView.nameLabel;
  nameLabel.center = ccp(self.frame.size.width/2-self.botContainer.frame.origin.x, nameLabel.center.y);
  self.topContainer.monsterCardView.nameLabel = nameLabel;
  self.botContainer.monsterCardView.nameLabel = nil;
  
  self.topContainer.monsterCardView.delegate = self;
}

- (void) updateForEvoItem:(EvoItem *)evoItem {
  [self.topContainer.monsterCardView updateForMonster:evoItem.userMonster1];
  [self.botContainer.monsterCardView updateForMonster:evoItem.userMonster2];
  
  if (evoItem.userMonster2 && evoItem.catalystMonster) {
    self.statusLabel.text = @"Ready!";
    self.statusLabel.textColor = [UIColor colorWithRed:106/255.f green:180/255.f blue:0.f alpha:1.f];
  } else {
    self.statusLabel.text = @"Tap For Info";
    self.statusLabel.textColor = [UIColor colorWithRed:255/255.f green:0.f blue:10/255.f alpha:1.f];
  }
}

- (void) monsterCardSelected:(MonsterCardView *)view {
  [self.delegate cardClicked:self];
}

- (void) infoClicked:(MonsterCardView *)view {
  [self.delegate infoClicked:self];
}

@end
