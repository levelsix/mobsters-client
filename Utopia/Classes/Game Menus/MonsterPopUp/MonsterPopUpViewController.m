//
//  MonsterPopUpViewController.m
//  Utopia
//
//  Created by Danny on 10/11/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "MonsterPopUpViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "QuestUtil.h"
#import "GenericPopupController.h"

@implementation ElementDisplayView

- (void) updateStatsWithElementType:(MonsterProto_MonsterElement)element andDamage:(int)damage {
  NSString *name = [Globals imageNameForElement:element suffix:@"orb.png"];
  [Globals imageNamed:name withView:self.elementIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.statLabel.text = [Globals commafyNumber:damage];
}

@end

@implementation MonsterPopUpViewController

- (id)initWithMonsterProto:(UserMonster *)monster {
  if ((self = [super init])) {
    self.monster = monster;
  }
  return self;
}

- (id)initWithMonsterProto:(UserMonster *)monster allowSell:(BOOL)allowSell {
  if ((self = [self initWithMonsterProto:monster])) {
    _allowSell = allowSell;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self updateMonster];
  
  self.backButtonView.hidden = YES;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) updateMonster {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  MonsterProto *proto = [gs monsterWithId:self.monster.monsterId];
  self.monsterNameLabel.text = proto.displayName;
  self.rarityLabel.text = [Globals stringForRarity:proto.quality];
  self.rarityLabel.textColor = [Globals colorForRarity:proto.quality];
  self.enhanceLabel.text = [NSString stringWithFormat:@"Lvl %d", self.monster.level];
  self.monsterDescription.text = proto.description;
  
  if (!_allowSell) {
    self.sellButtonView.hidden = YES;
    
    CGRect r = self.monsterDescription.frame;
    int maxX = CGRectGetMaxX(r);
    r.origin.x = self.monsterDescription.superview.frame.size.width-maxX;
    r.size.width = maxX-r.origin.x;
    self.monsterDescription.frame = r;
  } else {
    self.sellLabel.text = [Globals cashStringForNumber:self.monster.sellPrice];
  }
  
  self.attackLabel.text = [Globals commafyNumber:[gl calculateTotalDamageForMonster:self.monster]];
  CGSize size = [self.attackLabel.text sizeWithFont:self.attackLabel.font];
  self.infoButton.center = CGPointMake(self.attackLabel.frame.origin.x+size.width+self.infoButton.frame.size.width/2, self.infoButton.center.y);
  
  int maxHealth = [gl calculateMaxHealthForMonster:self.monster];
  self.hpLabel.text = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:self.monster.curHealth], [Globals commafyNumber:maxHealth]];
  self.progressBar.percentage = ((float)self.monster.curHealth)/maxHealth;
  
  MonsterProto_MonsterElement elem = MonsterProto_MonsterElementFire;
  [self.fireView updateStatsWithElementType:elem andDamage:[gl calculateElementalDamageForMonster:self.monster element:elem]];
  elem = MonsterProto_MonsterElementWater;
  [self.waterView updateStatsWithElementType:elem andDamage:[gl calculateElementalDamageForMonster:self.monster element:elem]];
  elem = MonsterProto_MonsterElementGrass;
  [self.earthView updateStatsWithElementType:elem andDamage:[gl calculateElementalDamageForMonster:self.monster element:elem]];
  elem = MonsterProto_MonsterElementLightning;
  [self.lightView updateStatsWithElementType:elem andDamage:[gl calculateElementalDamageForMonster:self.monster element:elem]];
  elem = MonsterProto_MonsterElementDarkness;
  [self.nightView updateStatsWithElementType:elem andDamage:[gl calculateElementalDamageForMonster:self.monster element:elem]];

  NSString *fileName = [proto.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamed:fileName withView:self.monsterImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:[Globals imageNameForElement:proto.monsterElement suffix:@"orb.png"] withView:self.elementType maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

- (IBAction)infoClicked:(id)sender {
  [self.container addSubview:self.elementView];
  self.elementView.center = CGPointMake(self.descriptionView.center.x+self.elementView.frame.size.height, self.descriptionView.center.y);
  self.backButtonView.hidden = NO;
  CGPoint mainViewCenter = self.descriptionView.center;
  [UIView animateWithDuration:0.3f animations:^{
    self.descriptionView.center = CGPointMake(self.descriptionView.center.x-self.descriptionView.frame.size.width, self.descriptionView.center.y);
    self.elementView.center = mainViewCenter;
    self.backButtonView.alpha = 1.0f;
  }completion:^(BOOL finished) {
    self.descriptionView.hidden = YES;
  }];
}

- (IBAction)backClicked:(id)sender {
  CGPoint mainViewCenter = self.elementView.center;
  self.descriptionView.hidden = NO;
  [UIView animateWithDuration:0.3f animations:^{
    self.descriptionView.center = mainViewCenter;
    self.elementView.center = CGPointMake(self.elementView.center.x+self.elementView.frame.size.width, self.elementView.center.y);
    self.backButtonView.alpha = 0.0f;
  } completion:^(BOOL finished) {
    [self.elementView removeFromSuperview];
    self.backButtonView.hidden = YES;
  }];
}

- (IBAction)sellClicked:(id)sender {
  if (self.monster.teamSlot > 0) {
    [GenericPopupController displayConfirmationWithDescription:@"This monster is currently on your team. Would you still like to sell it?" title:@"Sell?" okayButton:@"Sell" cancelButton:@"Cancel" target:self selector:@selector(sell)];
  } else {
    [self sell];
  }
}

- (void) sell {
  [[OutgoingEventController sharedOutgoingEventController] sellUserMonster:self.monster.userMonsterId];
  [self close:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:MONSTER_SOLD_COMPLETE_NOTIFICATION object:nil];
  [QuestUtil checkAllDonateQuests];
}

- (IBAction)close:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
