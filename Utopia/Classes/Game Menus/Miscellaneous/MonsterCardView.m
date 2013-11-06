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
#import "OutgoingEventController.h"

@implementation MonsterCardView

- (void) awakeFromNib {
  [self addSubview:self.noMonsterView];
  [self addSubview:self.overlayView];
  [self addSubview:self.combineView];
  [self.overlayView addSubview:self.piecesView];
  
  self.qualityLabel.superview.transform = CGAffineTransformMakeRotation(M_PI_4);
}

- (void) loadOverlayMask {
  // _overlayMaskStatus: 0 = unloaded, 1 = no rarity tag, 2 = rarity tag
  int curStatus = self.qualityBgdView.superview.hidden ? 1 : 2;
  if (curStatus != _overlayMaskStatus) {
    UIView *view = self.mainView;
    
    self.overlayView.hidden = YES;
    view.hidden = NO;
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.overlayMask.image = [Globals maskImage:image withColor:[UIColor colorWithWhite:0.f alpha:0.7f]];
    self.overlayMask.frame = [self.overlayView convertRect:self.mainView.frame fromView:self];
    
    _overlayMaskStatus = curStatus;
  }
}

- (void) updateForMonster:(UserMonster *)um {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  MonsterProto *mp = [gs monsterWithId:um.monsterId];
  
  self.monster = um;
  
  NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Card.png"];
  [Globals imageNamed:fileName withView:self.monsterIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.nameLabel.text = mp.displayName;
  self.levelLabel.text = [NSString stringWithFormat:@"LVL %d", um.level];
  self.qualityLabel.text = [[Globals stringForRarity:mp.quality] lowercaseString];
  
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
  self.starView.center = ccp(self.starView.superview.frame.size.width/2, self.starView.center.y);
  
  if ([um isHealing] || [um isEnhancing] || [um isSacrificing]) {
    self.overlayLabel.text = [um isHealing] ? @"Healing" : @"Enhancing";
    
    self.overlayLabel.hidden = NO;
    self.piecesView.hidden = YES;
    self.combineView.hidden = YES;
    
    [self loadOverlayMask];
    self.overlayView.hidden = NO;
  } else if (!um.isComplete) {
    if (um.numPieces < mp.numPuzzlePieces) {
      self.piecesLabel.text = [NSString stringWithFormat:@"%d/%d", um.numPieces, mp.numPuzzlePieces];
      
      self.piecesView.hidden = NO;
      self.combineView.hidden = YES;
    } else {
      [self updateTime];
      
      self.combineView.hidden = NO;
      self.piecesView.hidden = YES;
    }
    
    self.overlayLabel.hidden = YES;
    
    self.overlayView.hidden = YES;
    [self loadOverlayMask];
    self.overlayView.hidden = NO;
  } else {
    self.overlayView.hidden = YES;
    self.combineView.hidden = YES;
  }
  
  if (self.qualityBgdView.superview.hidden) {
    self.overlayButton.superview.frame = [self.mainView convertRect:self.cardBgdView.frame fromView:self.mainView];
  } else {
    self.overlayButton.superview.frame = self.mainView.bounds;
  }
  
  self.mainView.hidden = NO;
  self.noMonsterView.hidden = YES;
}

- (void) updateForNoMonsterWithLabel:(NSString *)str {
  self.monster = nil;
  
  self.noMonsterLabel.text = str;
  
  self.mainView.hidden = YES;
  self.noMonsterView.hidden = NO;
  self.overlayView.hidden = YES;
  self.combineView.hidden = YES;
}

- (void) updateTime {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = self.monster;
  MonsterProto *mp = [gs monsterWithId:um.monsterId];
  if (!um.isComplete && um.numPieces >= mp.numPuzzlePieces) {
    int timeLeft = um.combineStartTime.timeIntervalSinceNow + mp.minutesToCombinePieces*60;
    self.combineTimeLabel.text = [Globals convertTimeToShortString:timeLeft];
    self.combineSpeedupLabel.text = [Globals commafyNumber:[gl calculateGemSpeedupCostForTimeLeft:timeLeft]];
  }
}

- (IBAction)darkOverlayClicked:(id)sender {
  [self.delegate monsterCardSelected:self];
}

- (IBAction)speedupCombineClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] combineMonsterWithSpeedup:self.monster.userMonsterId];
  if ([self.delegate respondsToSelector:@selector(combineClicked:)]) {
    [self.delegate combineClicked:self];
  }
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
