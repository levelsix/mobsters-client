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

static UIImage *img = nil;

- (void) awakeFromNib {
  [self addSubview:self.noMonsterView];
  
  self.qualityLabel.superview.transform = CGAffineTransformMakeRotation(-M_PI_4);
  
  if (!img) {
    [self.overlayButton setBaseImage:self.cardBgdView];
    [self.overlayButton remakeImage];
    img = [self.overlayButton imageForState:UIControlStateHighlighted];
  } else {
    [self.overlayButton setImage:img forState:UIControlStateHighlighted];
  }
}

- (void) setDelegate:(id<MonsterCardViewDelegate>)delegate {
  if ([delegate respondsToSelector:@selector(monsterCardSelected:)]) {
    self.overlayButton.userInteractionEnabled = YES;
  } else {
    self.overlayButton.userInteractionEnabled = NO;
  }
  _delegate = delegate;
}

- (void) updateForMonster:(UserMonster *)um {
  [self updateForMonster:um backupString:@"Slot Empty"];
}

- (void) updateForMonster:(UserMonster *)um backupString:(NSString *)str {
  if (!um) {
    [self updateForNoMonsterWithLabel:str];
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:um.monsterId];
  self.monster = um;
  
  NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Card.png"];
  [Globals imageNamed:fileName withView:self.monsterIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.nameLabel.text = [NSString stringWithFormat:@"%@ (LVL %d)", mp.displayName, um.level];
  self.qualityLabel.text = [[Globals stringForRarity:mp.quality] lowercaseString];
  
  NSString *bgdImgName = [Globals imageNameForElement:mp.monsterElement suffix:@"card.png"];
  [Globals imageNamed:bgdImgName withView:self.cardBgdView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  NSString *tagName = [Globals imageNameForRarity:mp.quality suffix:@"tag.png"];
  [Globals imageNamed:tagName withView:self.qualityBgdView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  float width = [[self.starView.subviews objectAtIndex:1] frame].origin.x;
  CGRect r = self.starView.frame;
  r.size.width = width*mp.evolutionLevel;
  self.starView.frame = r;
  self.starView.center = ccp(self.starView.superview.frame.size.width/2, self.starView.center.y);
  
  self.mainView.hidden = NO;
  self.noMonsterView.hidden = YES;
}

- (void) updateForNoMonsterWithLabel:(NSString *)str {
  self.monster = nil;
  
  self.nameLabel.text = str;
  
  self.mainView.hidden = YES;
  self.noMonsterView.hidden = NO;
}

- (IBAction)darkOverlayClicked:(id)sender {
  [self.delegate monsterCardSelected:self];
}

- (IBAction)infoClicked:(id)sender {
  [self.delegate infoClicked:self];
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
