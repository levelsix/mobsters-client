//
//  EquipCardView.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/29/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "MonsterCardView.h"
#import "Globals.h"
#import "GameState.h"

@implementation MonsterCardView

- (void) awakeFromNib {
  [self addSubview:self.noMonsterView];
  
  self.qualityLabel.superview.transform = CGAffineTransformMakeRotation(M_PI_4);
}

- (void) updateForMonster:(UserMonster *)um {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  MonsterProto *mp = [gs monsterWithId:um.monsterId];
  
//  [Globals loadImageForMonster:mp.monsterId toView:self.monsterIcon];
  self.nameLabel.text = mp.displayName;
  self.levelLabel.text = [NSString stringWithFormat:@"LVL %d", (int)um.enhancementPercentage];
  self.qualityLabel.text = [Globals stringForRarity:mp.quality];
  
  NSString *bgdImgName = [Globals imageNameForElement:mp.element suffix:@"card.png"];
  [Globals imageNamed:bgdImgName withView:self.cardBgdView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  NSString *borderName = [Globals imageNameForElement:mp.element suffix:@"border.png"];
  [Globals imageNamed:borderName withView:self.borderView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  NSString *starsName = [Globals imageNameForElement:mp.element suffix:@"stars.png"];
  [Globals imageNamed:starsName withView:self.levelBgdView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  if (mp.quality != MonsterProto_MonsterQualityCommon) {
    NSString *tagName = [Globals imageNameForRarity:mp.quality suffix:@"tag.png"];
    [Globals imageNamed:tagName withView:self.qualityBgdView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    self.qualityBgdView.superview.hidden = NO;
  } else {
    self.qualityBgdView.superview.hidden = YES;
  }
  
  self.healthBar.percentage = ((float)um.curHealth)/[gl calculateMaxHealthForMonster:um];
  
  float width = [[self.starView.subviews objectAtIndex:1] frame].origin.x;
  CGRect r = self.starView.frame;
  r.size.width = width*mp.evolutionLevel;
  self.starView.frame = r;
  
  [self.darkOverlay remakeImage];
  
  self.monster = um;
  
  self.mainView.hidden = NO;
  self.noMonsterView.hidden = YES;
}

- (void) updateForNoMonsterWithLabel:(NSString *)str {
  [self.darkOverlay remakeImage];
  
  self.monster = nil;
  
  self.noMonsterLabel.text = str;
  
  self.mainView.hidden = YES;
  self.noMonsterView.hidden = NO;
}

- (IBAction)darkOverlayClicked:(id)sender {
  [self.delegate equipViewSelected:self];
}

@end


@implementation MonsterCardContainerView

- (void) awakeFromNib {
  [[NSBundle mainBundle] loadNibNamed:@"MonsterCardView" owner:self options:nil];
  [self addSubview:self.monsterCardView];
  self.monsterCardView.frame = self.bounds;
  self.backgroundColor = [UIColor clearColor];
}

@end
