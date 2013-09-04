//
//  EquipCardView.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/29/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "EquipCardView.h"
#import "Globals.h"
#import "GameState.h"

@implementation EquipCardView

static CGSize initSize;
- (void) awakeFromNib {
  self.noEquipView.frame = self.mainView.frame;
  [self addSubview:self.noEquipView];
  initSize = self.frame.size;
}

- (void) setFrame:(CGRect)frame {
  [super setFrame:frame];
  float scale = MIN(frame.size.width/initSize.width, frame.size.height/initSize.height);
//  self.mainView.frame = CGRectMake(0, 0, scale*initSize.width, scale*initSize.height);
//  self.attackLabel.font = [UIFont fontWithName:self.attackLabel.font.fontName size:self.attackLabel.font.pointSize*scale];
//  self.defenseLabel.font = [UIFont fontWithName:self.defenseLabel.font.fontName size:self.defenseLabel.font.pointSize*scale];
//  self.nameLabel.font = [UIFont fontWithName:self.nameLabel.font.fontName size:self.nameLabel.font.pointSize*scale];
  self.mainView.transform = CGAffineTransformMakeScale(scale, scale);
  
  self.mainView.center = ccp(self.frame.size.width/2, self.frame.size.height/2);
}

- (void) updateForEquip:(UserEquip *)ue {
  // This is for the browse cell
  if (!ue) {
    self.hidden = YES;
    return;
  } else {
    self.hidden = NO;
  }
  
  Globals *gl = [Globals sharedGlobals];
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:ue.equipId];
  self.attackLabel.text = [Globals commafyNumber:[gl calculateAttackForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage]];
  self.defenseLabel.text = [Globals commafyNumber:[gl calculateDefenseForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage]];
  //  wallIcon.image = [Globals imageForEquip:fuep.equipId];
  [Globals loadImageForEquip:fep.equipId toView:self.equipIcon maskedView:nil];
  self.nameLabel.text = fep.name;
  self.nameLabel.textColor = [Globals colorForRarity:fep.rarity];
  self.levelIcon.level = ue.level;
  
  NSString *base = [[[Globals stringForRarity:fep.rarity] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
  NSString *bgdFile = [base stringByAppendingString:@"card.png"];
  [Globals imageNamed:bgdFile withView:self.bgd maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [self.darkOverlay remakeImage];
  
  self.equip = ue;
  
  self.mainView.hidden = NO;
  self.noEquipView.hidden = YES;
  
  self.userInteractionEnabled = YES;
}

- (void) updateForNoEquip {
  self.bgd.image = nil;
  [self.darkOverlay remakeImage];
  
  self.equip = nil;
  
  self.mainView.hidden = YES;
  self.noEquipView.hidden = NO;
  
  self.userInteractionEnabled = NO;
}

- (void) dealloc {
  self.equip = nil;
  self.mainView = nil;
  self.noEquipView = nil;
  [super dealloc];
}

@end


@implementation EquipCardContainerView

- (void) awakeFromNib {
  [[NSBundle mainBundle] loadNibNamed:@"EquipCardView" owner:self options:nil];
  [self addSubview:self.equipCardView];
  self.equipCardView.frame = self.bounds;
  self.backgroundColor = [UIColor clearColor];
}

- (void) dealloc {
  self.equipCardView = nil;
  [super dealloc];
}

@end
