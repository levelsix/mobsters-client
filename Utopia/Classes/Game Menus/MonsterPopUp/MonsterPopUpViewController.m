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

- (void) updateStatsWithElementType:(Element)element andDamage:(int)damage {
  NSString *name = [Globals imageNameForElement:element suffix:@"orb.png"];
  [Globals imageNamed:name withView:self.elementIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.statLabel.text = [Globals commafyNumber:damage];
  self.elementLabel.text = [Globals stringForElement:element];
  self.elementLabel.textColor = [Globals colorForElementOnLightBackground:element];
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
  
  self.mainView.layer.cornerRadius = 6.f;
  self.container.layer.cornerRadius = 6.f;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) updateMonster {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  MonsterProto *proto = [gs monsterWithId:self.monster.monsterId];
  self.monsterNameLabel.text = proto.displayName;
  self.enhanceLabel.text = [NSString stringWithFormat:@"%d", self.monster.level];
  [self setDescriptionLabelString:proto.description];
  
  self.rarityTag.image = [Globals imageNamed:[@"battle" stringByAppendingString:[Globals imageNameForRarity:proto.quality suffix:@"tag.png"]]];
  
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
  
  self.attackLabel.text = [NSString stringWithFormat:@"%@  ", [Globals commafyNumber:[gl calculateTotalDamageForMonster:self.monster]]];
  self.speedLabel.text = [Globals commafyNumber:[gl calculateSpeedForMonster:self.monster]];
  CGSize size = [self.attackLabel.text sizeWithFont:self.attackLabel.font];
  self.infoButton.center = CGPointMake(self.attackLabel.frame.origin.x+size.width+self.infoButton.frame.size.width/2, self.infoButton.center.y);
  
  int maxHealth = [gl calculateMaxHealthForMonster:self.monster];
  self.hpLabel.text = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:self.monster.curHealth], [Globals commafyNumber:maxHealth]];
  self.progressBar.percentage = ((float)self.monster.curHealth)/maxHealth;
  
  Element elem = ElementFire;
  [self.fireView updateStatsWithElementType:elem andDamage:[gl calculateElementalDamageForMonster:self.monster element:elem]];
  elem = ElementWater;
  [self.waterView updateStatsWithElementType:elem andDamage:[gl calculateElementalDamageForMonster:self.monster element:elem]];
  elem = ElementEarth;
  [self.earthView updateStatsWithElementType:elem andDamage:[gl calculateElementalDamageForMonster:self.monster element:elem]];
  elem = ElementLight;
  [self.lightView updateStatsWithElementType:elem andDamage:[gl calculateElementalDamageForMonster:self.monster element:elem]];
  elem = ElementDark;
  [self.nightView updateStatsWithElementType:elem andDamage:[gl calculateElementalDamageForMonster:self.monster element:elem]];
  elem = ElementRock;
  [self.rockView updateStatsWithElementType:elem andDamage:[gl calculateElementalDamageForMonster:self.monster element:elem]];
  
  self.elementLabel.text = [Globals stringForElement:proto.monsterElement];
  self.elementLabel.textColor = [Globals colorForElementOnLightBackground:proto.monsterElement];
  
  NSString *fileName = [proto.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamed:fileName withView:self.monsterImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:[Globals imageNameForElement:proto.monsterElement suffix:@"orb.png"] withView:self.elementType maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

- (void) setDescriptionLabelString:(NSString *)labelText {
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineSpacing:3];
  [paragraphStyle setAlignment:NSTextAlignmentCenter];
  [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
  self.monsterDescription.attributedText = attributedString;
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
  
  CATransition *animation = [CATransition animation];
  animation.duration = 0.3;
  animation.type = kCATransitionFade;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [self.monsterDescription.layer addAnimation:animation forKey:@"changeTextTransition"];
  [self setDescriptionLabelString:@"Attack numbers represent the damage done by each orb destroyed in battle."];
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
  
  CATransition *animation = [CATransition animation];
  animation.duration = 0.3;
  animation.type = kCATransitionFade;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [self.monsterDescription.layer addAnimation:animation forKey:@"changeTextTransition"];
  
  GameState *gs = [GameState sharedGameState];
  MonsterProto *proto = [gs monsterWithId:self.monster.monsterId];
  [self setDescriptionLabelString:proto.description];
}

- (IBAction)sellClicked:(id)sender {
  [GenericPopupController displayConfirmationWithDescription:[NSString stringWithFormat:@"Are you sure you would like to sell %@?", self.monster.staticMonster.name] title:@"Sell?" okayButton:@"Sell" cancelButton:@"Cancel" target:self selector:@selector(sell)];
}

- (void) sell {
  [[OutgoingEventController sharedOutgoingEventController] sellUserMonster:self.monster.userMonsterId];
  [self close:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:MONSTER_SOLD_COMPLETE_NOTIFICATION object:nil];
  [QuestUtil checkAllDonateQuests];
  
  if (self.monster.teamSlot > 0) {
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  }
}

- (IBAction)close:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
