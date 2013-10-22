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

@implementation ElementDisplayView

- (void) updateStatsWithElementType:(MonsterProto_MonsterElement)element andDamage:(int)damage {
  NSString *name = [Globals imageNameForElement:element suffix:@"element.png"];
  [Globals imageNamed:name withView:self.elementIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.statLabel.text = [Globals commafyNumber:damage];
}

@end

@implementation MonsterPopUpViewController

- (id)initWithMonsterProto:(UserMonster *)monster {
  if (self == [super init]) {
    self.monster = monster;
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
  self.enhanceLabel.text = [NSString stringWithFormat:@"%d", (int)self.monster.enhancementPercentage];
  //self.monsterDescription.text = proto.monsterDescription;
  
  self.attackLabel.text = [NSString stringWithFormat:@"%d", [gl calculateTotalDamageForMonster:self.monster]];
  CGSize size = [self.attackLabel.text sizeWithFont:self.attackLabel.font];
  self.infoButton.center = CGPointMake(self.attackLabel.frame.origin.x+size.width+self.infoButton.frame.size.width/2, self.infoButton.center.y);
  
  int maxHealth = [gl calculateMaxHealthForMonster:self.monster];
  self.hpLabel.text = [NSString stringWithFormat:@"%d/%d", self.monster.curHealth, maxHealth];
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

  //[Globals imageNamed:proto.imageName withView:self.monsterImageView maskedColor:Nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  //[Globals imageNamed:[self getElementImageName:proto.element] withView:self.elementType maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
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

- (IBAction)close:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
