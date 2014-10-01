//
//  EvolveDetailsViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "EvolveDetailsViews.h"

#import "GameState.h"
#import "Globals.h"

@implementation EvolveDetailsMonsterView

- (void) awakeFromNib {
  self.monsterImage.superview.transform = CGAffineTransformMakeScale(0.8, 0.8);
}

- (void) updateBaseMonsterWithMonsterId:(int)monsterId level:(int)level requireMax:(BOOL)requireMax {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:monsterId];
  
  UIColor *masked;
  BOOL showNonMasked = level > 0;
  if ((!requireMax && level > 0) || level >= mp.maxLevel) {
    masked = nil;
  } else if (level > 0) {
    masked = [UIColor colorWithWhite:1.f alpha:0.8f];
  } else {
    masked = [UIColor colorWithWhite:213/255.f alpha:1.f];
  }
  
  NSString *p1 = [NSString stringWithFormat:@"%@", mp.monsterName];
  NSString *p2 = level ? [NSString stringWithFormat:@" L%d", level] : @"";
  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[p1 stringByAppendingString:p2]];
  [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:48/255.f green:124/255.f blue:238/255.f alpha:1.f] range:NSMakeRange(p1.length, p2.length)];
  
  [self updateWithMonsterImagePrefix:mp.imagePrefix maskedColor:masked showNonMaskedImage:showNonMasked labelText:attr];
}

- (void) updateCatalystMonsterWithMonsterId:(int)monsterId ownsMonster:(BOOL)ownsMonster {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:monsterId];
  
  UIColor *masked = ownsMonster ? nil : [UIColor colorWithWhite:213/255.f alpha:1.f];
  
  NSString *labelText = [NSString stringWithFormat:@"%@ (Evo %d)", mp.monsterName, mp.evolutionLevel];
  [self updateWithMonsterImagePrefix:mp.imagePrefix maskedColor:masked showNonMaskedImage:ownsMonster labelText:labelText];
}

- (void) updateEvolutionMonsterWithMonsterId:(int)monsterId {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:monsterId];
  
  UIColor *masked = [UIColor colorWithWhite:102/255.f alpha:1.f];
  
  NSString *p1 = [NSString stringWithFormat:@"%@ ", mp.monsterName];
  NSString *p2 = [NSString stringWithFormat:@"L%d", 1];
  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[p1 stringByAppendingString:p2]];
  [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:48/255.f green:124/255.f blue:238/255.f alpha:1.f] range:NSMakeRange(p1.length, p2.length)];
  
  [self updateWithMonsterImagePrefix:mp.imagePrefix maskedColor:masked showNonMaskedImage:NO labelText:attr];
}

- (void) updateWithMonsterImagePrefix:(NSString *)imgPrefix maskedColor:(UIColor *)maskedColor showNonMaskedImage:(BOOL)showNonMaskedImage labelText:(id)labelText {
  NSString *fileName = [imgPrefix stringByAppendingString:@"Character.png"];
  
  if (showNonMaskedImage) {
    [Globals imageNamedWithiPhone6Prefix:fileName withView:self.monsterImage maskedColor:nil indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
    self.monsterImage.hidden = NO;
  } else {
    self.monsterImage.hidden = YES;
  }
  
  if (maskedColor) {
    [Globals imageNamedWithiPhone6Prefix:fileName withView:self.monsterImageOverlay maskedColor:maskedColor indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
    self.monsterImageOverlay.hidden = NO;
  } else {
    self.monsterImageOverlay.hidden = YES;
  }
  
  if ([labelText isKindOfClass:[NSAttributedString class]]) {
    self.nameLabel.attributedText = labelText;
  } else {
    self.nameLabel.text = labelText;
  }
}

@end

@implementation EvolveDetailsMiddleView

- (void) updateWithEvoItem:(EvoItem *)evoItem {
  UserMonster *um1 = evoItem.userMonster1, *um2 = evoItem.userMonster2, *cata = evoItem.catalystMonster;
  [self.baseMonsterView1 updateBaseMonsterWithMonsterId:um1.monsterId level:um1.level requireMax:YES];
  
  if (um2) {
    [self.baseMonsterView2 updateBaseMonsterWithMonsterId:um2.monsterId level:um2.level requireMax:NO];
  } else {
    [self.baseMonsterView2 updateBaseMonsterWithMonsterId:um1.monsterId level:0 requireMax:NO];
  }
  
  if (cata) {
    [self.cataMonsterView updateCatalystMonsterWithMonsterId:cata.monsterId ownsMonster:YES];
  } else {
    [self.cataMonsterView updateCatalystMonsterWithMonsterId:um1.staticMonster.evolutionCatalystMonsterId ownsMonster:NO];
  }
  
  [self.evoMonsterView updateEvolutionMonsterWithMonsterId:um1.staticMonster.evolutionMonsterId];
}

@end
