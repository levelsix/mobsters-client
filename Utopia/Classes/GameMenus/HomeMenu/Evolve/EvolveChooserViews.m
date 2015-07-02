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

#define SCIENTIST_SPACING ([Globals isiPad] ? 18.f : 5.f)

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
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int reqEvoChamberLevel = [gl evoChamberLevelToEvolveMonster:evoItem.userMonster1.monsterId];
  EvoChamberProto *ecp = (EvoChamberProto *)gs.myEvoChamber.staticStructForCurrentConstructionLevel;
  BOOL evoChamberHighEnough = reqEvoChamberLevel <= ecp.structInfo.level;
  
  [self.topContainer.monsterCardView updateForMonster:evoItem.userMonster1 backupString:nil greyscale:!evoChamberHighEnough];
  [self.botContainer.monsterCardView updateForMonster:evoItem.userMonster2 backupString:nil greyscale:!evoChamberHighEnough];
  
  if (evoChamberHighEnough) {
    BOOL lvl1 = evoItem.userMonster1.level >= evoItem.userMonster1.staticMonster.maxLevel;
    if (evoItem.userMonster2 && evoItem.catalystMonster && lvl1) {
      self.statusLabel.text = @"Ready!";
      self.statusLabel.textColor = [UIColor colorWithRed:106/255.f green:180/255.f blue:0.f alpha:1.f];
    } else {
      self.statusLabel.text = @"Tap For Info";
      self.statusLabel.textColor = [UIColor colorWithRed:255/255.f green:0.f blue:10/255.f alpha:1.f];
    }
    
    self.statusLabel.superview.hidden = NO;
    self.reqEvoChamberLabel.hidden = YES;
  } else {
    self.reqEvoChamberLabel.text = [NSString stringWithFormat:@"Req. LVL %d\n%@", reqEvoChamberLevel, ecp.structInfo.name];
    
    self.statusLabel.superview.hidden = YES;
    self.reqEvoChamberLabel.hidden = NO;
  }
}

- (void) monsterCardSelected:(MonsterCardView *)view {
  [self.delegate cardClicked:self];
}

- (void) infoClicked:(MonsterCardView *)view {
  [self.delegate infoClicked:self];
}

@end

@implementation EvolveScientistView

- (void) awakeFromNib {
  self.quantityLabel.strokeSize = 1.f;
}

- (void) updateForMonsterId:(int)monsterId quantity:(int)quantity {
  [self.monsterView updateForMonsterId:monsterId greyscale:quantity <= 0];
  self.quantityLabel.text = [NSString stringWithFormat:@"x%d", quantity];
}

- (IBAction)cardClicked:(id)sender {
  [self.delegate scientistViewClicked:self];
}

@end

@implementation EvolveChooserBottomView

- (void) awakeFromNib {
  [self openView:1];
}

- (void) updateWithUserMonsters:(NSArray *)userMonsters {
  // Clear current counters
  memset(_quantityVals, 0, sizeof(_quantityVals[0][0]) * EVO_NUM_ELEMENTS * EVO_NUM_LEVELS);
  
  for (UserMonster *um in userMonsters) {
    MonsterProto *mp = um.staticMonster;
    if ([mp.monsterGroup rangeOfString:@"Scientist"].length > 0) {
      int x = mp.monsterElement-1;
      int y = mp.evolutionLevel-1;
      if (x < EVO_NUM_ELEMENTS && y < EVO_NUM_LEVELS) {
        _quantityVals[x][y]++;
      }
    }
  }
  
  [self updateLabels];
}

- (void) updateLabels {
  int x = _currentSelection-1;
  if (x < EVO_NUM_ELEMENTS) {
    for (UILabel *label in self.quantityLabels) {
      if (label.tag <= EVO_NUM_LEVELS) {
        label.text = [NSString stringWithFormat:@"%d", _quantityVals[x][label.tag-1]];
      }
    }
  }
  
  // Update the scientist views
  GameState *gs = [GameState sharedGameState];
  for (EvolveScientistView *sci in self.scientistViews) {
    for (MonsterProto *mp in gs.staticMonsters.allValues) {
      if (mp.monsterElement == sci.tag && [mp.monsterGroup rangeOfString:@"Scientist"].length > 0 && mp.evolutionLevel == 1) {
        // Found..
        
        // Add up quantities
        int x = mp.monsterElement-1;
        int quantity = 0;
        for (int i = 0; i < EVO_NUM_LEVELS; i++) {
          quantity += _quantityVals[x][i];
        }
        
        [sci updateForMonsterId:mp.monsterId quantity:quantity];
      }
    }
  }
}

- (void) openView:(int)tag {
  if (_currentSelection != tag) {
    float width = self.quantityView.frame.size.width;
    UIView *v1 = [self viewWithTag:1];
    float x = v1.frame.origin.x+(v1.frame.size.width+SCIENTIST_SPACING)*tag-2;
    
    __block CGRect r = self.quantityView.frame;
    r.origin.x = _currentSelection > tag ? x : x+width;
    r.size.width = 0;
    self.quantityView.frame = r;
    self.quantityView.alpha = 1.f;
    [UIView animateWithDuration:0.3f animations:^{
      for (UIView *v in self.scientistViews) {
        if (v.tag > 1) {
          if (v.tag <= tag) {
            v.center = ccp(v1.center.x+(v1.frame.size.width+SCIENTIST_SPACING)*(v.tag-1), v.center.y);
          } else {
            v.center = ccp(v1.center.x+(v1.frame.size.width+SCIENTIST_SPACING)*(v.tag-1)+width+3, v.center.y);
          }
        }
      }
      
      r.origin.x = x;
      r.size.width = width;
      self.quantityView.frame = r;
    }];
    
    _currentSelection = tag;
  }
}

- (void) scientistViewClicked:(UIView *)sender {
  // Do this order so current selection is set before updating labels
  [self openView:(int)sender.tag];
  [self updateLabels];
}

@end
