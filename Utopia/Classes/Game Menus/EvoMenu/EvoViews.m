//
//  EvoViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "EvoViews.h"
#import "Globals.h"
#import "GameState.h"

@implementation EvoCardCell

- (void) awakeFromNib {
  self.readyContainer2.monsterCardView.infoButton.hidden = YES;
  self.readyContainer2.monsterCardView.nameLabel.hidden = YES;
  
  MonsterCardView *rCard = self.readyContainer1.monsterCardView;
  MonsterCardView *nrCard = self.notReadyContainer.monsterCardView;
  rCard.nameLabel.frame = [nrCard.nameLabel.superview convertRect:nrCard.nameLabel.frame toView:rCard.nameLabel.superview];
  
  self.readyContainer1.monsterCardView.delegate = self;
  self.readyContainer2.monsterCardView.delegate = self;
  self.notReadyContainer.monsterCardView.delegate = self;
}

- (void) updateForEvoItem:(EvoItem *)item {
  // Have to reawake because cards may not have been created yet
  [self awakeFromNib];
  
  if (true) {//item.userMonster2) {
    [self.readyContainer1.monsterCardView updateForMonster:item.userMonster1];
    [self.readyContainer2.monsterCardView updateForMonster:item.userMonster2];
    
    if (item.userMonster2) {
      self.readyContainer1.monsterCardView.nameLabel.text = [@"2x " stringByAppendingString:self.readyContainer1.monsterCardView.nameLabel.text];
    }
    
    if (item.userMonster1.teamSlot || item.userMonster2.teamSlot) {
      self.readyTeamIcon.hidden = NO;
    } else {
      self.readyTeamIcon.hidden = YES;
    }
    self.notReadyView.hidden = YES;
    self.readyView.hidden = NO;
  } else {
    [self.notReadyContainer.monsterCardView updateForMonster:item.userMonster1];
    self.notReadyTeamIcon.hidden = (item.userMonster1.teamSlot == 0);
    self.notReadyView.hidden = NO;
    self.readyView.hidden = YES;
  }
  
  self.evoItem = item;
}

- (void) infoClicked:(MonsterCardView *)view {
  [self.delegate infoClicked:self];
}

- (void) monsterCardSelected:(MonsterCardView *)view {
  [self.delegate cardClicked:self];
}

@end

@implementation EvoScientistView

- (void) awakeFromNib {
  NSString *str = [NSString stringWithFormat:@"Scientist%dThumbnail.png", self.tag];
  [Globals imageNamed:str withView:self.monsterIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

- (void) updateQuantity:(int)quantity {
  self.quantityLabel.text = [NSString stringWithFormat:@"x%d", quantity];
}

@end

@implementation EvoBottomView

- (void) awakeFromNib {
  self.quantityView.alpha = 0.f;
  
  [self openView:1];
  
  self.infoLabelView.center = ccpAdd(self.infoLabelView.center, ccp(0, 40));
  self.infoLabelView.hidden = YES;
}

- (void) updateForEvoItems {
  GameState *gs = [GameState sharedGameState];
  int vals[6] = {0,0,0,0,0,0};
  
  for (UserMonster *um in gs.myMonsters) {
    MonsterProto *mp = um.staticMonster;
    if ([mp.monsterGroup rangeOfString:@"Scientist"].length > 0 && !um.isEvolving) {
      vals[mp.monsterElement]++;
    }
  }
  
  for (EvoScientistView *sci in self.scientistViews) {
    [sci updateQuantity:vals[sci.tag]];
  }
  
  [self openView:_curViewNum];
}

- (void) openView:(int)tag {
  GameState *gs = [GameState sharedGameState];
  int q1 = 0, q2 = 0, q3 = 0;
  
  for (UserMonster *um in gs.myMonsters) {
    MonsterProto *mp = um.staticMonster;
    if (mp.monsterElement == tag && [mp.monsterGroup rangeOfString:@"Scientist"].length > 0 && !um.isEvolving) {
      if (mp.evolutionLevel == 1) {
        q1++;
      } else if (mp.evolutionLevel == 2) {
        q2++;
      } else if (mp.evolutionLevel == 3) {
        q3++;
      }
    }
  }
  
  self.quantity1Label.text = [NSString stringWithFormat:@"%d", q1];
  self.quantity1Label.textColor = q1 ? [UIColor whiteColor] : [UIColor colorWithWhite:1.f alpha:0.5f];
  self.quantity2Label.text = [NSString stringWithFormat:@"%d", q2];
  self.quantity2Label.textColor = q2 ? [UIColor whiteColor] : [UIColor colorWithWhite:1.f alpha:0.5f];
  self.quantity3Label.text = [NSString stringWithFormat:@"%d", q3];
  self.quantity3Label.textColor = q3 ? [UIColor whiteColor] : [UIColor colorWithWhite:1.f alpha:0.5f];
  
  if (_curViewNum != tag) {
    float width = self.quantityView.frame.size.width;
    UIView *v1 = [self viewWithTag:1];
    float x = v1.frame.origin.x+(v1.frame.size.width+5)*tag-2;
    
    __block CGRect r = self.quantityView.frame;
    r.origin.x = _curViewNum > tag ? x : x+width;
    r.size.width = 0;
    self.quantityView.frame = r;
    self.quantityView.alpha = 1.f;
    [UIView animateWithDuration:0.3f animations:^{
      for (int i = 2; i <= 5; i++) {
        UIView *v = [self viewWithTag:i];
        
        if (v.tag <= tag) {
          v.center = ccp(v1.center.x+(v1.frame.size.width+5)*(i-1), v.center.y);
        } else {
          v.center = ccp(v1.center.x+(v1.frame.size.width+5)*(i-1)+width+3, v.center.y);
        }
      }
      
      r.origin.x = x;
      r.size.width = width;
      self.quantityView.frame = r;
    }];
    
    _curViewNum = tag;
  }
}

- (NSArray *) animationViews {
  NSMutableArray *views = [NSMutableArray arrayWithArray:self.scientistViews];
  [views addObject:self.leftLabelView];
  [views addObject:self.quantityView];
  
  [views sortUsingComparator:^NSComparisonResult(UIView *obj1, UIView *obj2) {
    return [@(obj1.frame.origin.x) compare:@(obj2.frame.origin.x)];
  }];
  
  return views;
}

- (void) updateInfoLabels:(EvoItem *)item {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *base = item.userMonster1.staticMonster;
  MonsterProto *cata = [gs monsterWithId:base.evolutionCatalystMonsterId];
  MonsterProto *evo = [gs monsterWithId:base.evolutionMonsterId];
  NSString *str1 = [NSString stringWithFormat:@"2 lvl %d %@s", base.maxLevel, base.name];
  NSString *str2 = [NSString stringWithFormat:@"1 %@ (Evo %d)", cata.name, cata.evolutionLevel];
  NSString *str3 = [NSString stringWithFormat:@"%@.", evo.name];
  
  UILabel *l1 = self.topLabels[1];
  UILabel *l2 = self.topLabels[3];
  UILabel *l3 = self.botLabels[1];
  [l1 setText:str1];
  [l2 setText:str2];
  [l3 setText:str3];
  l1.textColor = item.userMonster2 ? [Globals greenColor] : [Globals redColor];
  l2.textColor = item.catalystMonster ? [Globals greenColor] : [Globals redColor];
  l3.textColor = [Globals colorForElementOnDarkBackground:evo.monsterElement];
  
  for (NSArray *arr in @[self.topLabels, self.botLabels]) {
    UIView *sup = [arr[0] superview];
    for (int i = 1; i < arr.count; i++) {
      UILabel *cur = arr[i];
      UILabel *prev = arr[i-1];
      
      CGSize size = [prev.text sizeWithFont:prev.font];
      CGRect r = cur.frame;
      r.origin.x = prev.frame.origin.x+size.width;
      cur.frame = r;
      
      if (i == arr.count-1) {
        size = [cur.text sizeWithFont:cur.font];
        r = sup.frame;
        r.size.width = cur.frame.origin.x+size.width;
        sup.frame = r;
      }
    }
    sup.center = ccp(sup.superview.frame.size.width/2, sup.center.y);
  }
}

#define ANIMATION_TIME 0.15f
#define DELAY_TIME 0.05f

- (void) displayInfoLabel:(EvoItem *)item {
  NSArray *views = [self animationViews];
  for (int i = 0; i < views.count; i++) {
    UIView *v = views[i];
    [UIView animateWithDuration:ANIMATION_TIME delay:i*DELAY_TIME options:UIViewAnimationOptionCurveEaseOut animations:^{
      v.center = ccpAdd(v.center, ccp(0, 40));
      v.alpha = 0.f;
    } completion:nil];
  }
  
  [self updateInfoLabels:item];
  self.infoLabelView.hidden = NO;
  NSArray *labels = [self.topLabels arrayByAddingObjectsFromArray:self.botLabels];
  float baseDelay = (views.count-4)*DELAY_TIME;
  for (int i = 0; i < labels.count; i++) {
    UIView *v = labels[i];
    v.alpha = 0.f;
    [UIView animateWithDuration:ANIMATION_TIME delay:baseDelay+i*DELAY_TIME options:UIViewAnimationOptionCurveEaseIn animations:^{
      v.center = ccpAdd(v.center, ccp(0, -40));
      v.alpha = 1.f;
    } completion:nil];
  }
}

- (void) displayScientists {
  NSArray *labels = [self.topLabels arrayByAddingObjectsFromArray:self.botLabels];
  for (int i = 0; i < labels.count; i++) {
    UIView *v = labels[labels.count-i-1];
    [UIView animateWithDuration:ANIMATION_TIME delay:i*DELAY_TIME options:UIViewAnimationOptionCurveEaseOut animations:^{
      v.center = ccpAdd(v.center, ccp(0, 40));
      v.alpha = 0.f;
    } completion:nil];
  }
  
  NSArray *views = [self animationViews];
  float baseDelay = (labels.count-2)*DELAY_TIME;
  for (int i = 0; i < views.count; i++) {
    UIView *v = views[views.count-i-1];
    [UIView animateWithDuration:ANIMATION_TIME delay:baseDelay+i*DELAY_TIME options:UIViewAnimationOptionCurveEaseIn animations:^{
      v.center = ccpAdd(v.center, ccp(0, -40));
      v.alpha = 1.f;
    } completion:nil];
  }
}

- (IBAction)scientistViewSelected:(UIButton *)sender {
  [self openView:[sender tag]];
}

@end

@implementation EvoMiddleView

- (void) awakeFromNib {
  self.evolvedMonsterIcon.superview.transform = CGAffineTransformMakeScale(0.8, 0.8);
}

- (void) updateForEvoItem:(EvoItem *)evoItem {
  [self updateForUserMonster1:evoItem.userMonster1 userMonster2:evoItem.userMonster2 catalyst:evoItem.catalystMonster];
  
  self.minusButton.hidden = YES;
  // Subtract 5 from both sides to account for minus sign being bigger
  CGSize s = [self.nameLabel.text sizeWithFont:self.nameLabel.font constrainedToSize:self.nameLabel.frame.size];
  self.minusButton.center = ccp(s.width+self.minusButton.frame.size.width/2-5, self.minusButton.center.y);
  UIView *v = self.nameLabel.superview;
  CGPoint center = v.center;
  CGRect r = v.frame;
  //  r.size.width = CGRectGetMaxX(self.minusButton.frame)-5;
  r.size.width = s.width;
  r.origin.x = center.x-r.size.width/2;
  v.frame = r;
  
  self.choosingView.hidden = NO;
  self.evolvingView.hidden = YES;
}

- (void) updateForEvolution:(UserEvolution *)evo {
  GameState *gs = [GameState sharedGameState];
  UserMonster *um1 = [gs myMonsterWithUserMonsterId:evo.userMonsterId1];
  UserMonster *um2 = [gs myMonsterWithUserMonsterId:evo.userMonsterId2];
  UserMonster *cat = [gs myMonsterWithUserMonsterId:evo.catalystMonsterId];
  [self updateForUserMonster1:um1 userMonster2:um2 catalyst:cat];
  
  self.minusButton.hidden = YES;
  CGSize s = [self.nameLabel.text sizeWithFont:self.nameLabel.font constrainedToSize:self.nameLabel.frame.size];
  UIView *v = self.nameLabel.superview;
  CGPoint center = v.center;
  CGRect r = v.frame;
  r.size.width = s.width;
  r.origin.x = center.x-r.size.width/2;
  v.frame = r;
  
  self.choosingView.hidden = YES;
  self.evolvingView.hidden = NO;
  
  [self updateTime];
}

- (void) updateForUserMonster1:(UserMonster *)um1 userMonster2:(UserMonster *)um2 catalyst:(UserMonster *)cata {
  [self.evoContainer1.monsterCardView updateForMonster:um1];
  [self.evoContainer2.monsterCardView updateForMonster:um2];
  [self.catalystContainer.monsterCardView updateForMonster:cata backupString:@"Missing Scientist"];
  
  if (!cata) {
    GameState *gs = [GameState sharedGameState];
    MonsterProto *mp = [gs monsterWithId:um1.staticMonster.evolutionCatalystMonsterId];
    NSString *desc = [NSString stringWithFormat:@"%@ (Evo %d)\nRequired to Evolve", mp.name, mp.evolutionLevel];
    self.missingCataLabel.text = desc;
    self.missingCataLabel.hidden = NO;
  } else {
    self.missingCataLabel.hidden = YES;
  }
  
  NSString *fileName = [um1.staticEvolutionMonster.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamed:fileName withView:self.evolvedMonsterIcon maskedColor:[UIColor blackColor] indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.nameLabel.text = um1.staticEvolutionMonster.name;
  self.timeLabel.text = [Globals convertTimeToShortString:um1.staticMonster.minutesToEvolve*60];
  self.oilCostLabel.text = [Globals commafyNumber:um1.staticMonster.evolutionCost];
  [Globals adjustViewForCentering:self.oilCostLabel.superview withLabel:self.oilCostLabel];
  
  // Adjust labels
  MonsterCardView *rCard = self.evoContainer1.monsterCardView;
  MonsterCardView *nrCard = self.catalystContainer.monsterCardView;
  
  CGRect r = [nrCard.nameLabel.superview convertRect:nrCard.nameLabel.frame toView:rCard.nameLabel.superview];
  r.origin.x = rCard.nameLabel.frame.origin.x;
  rCard.nameLabel.frame = r;
  
  self.evoContainer2.monsterCardView.nameLabel.hidden = YES;
  self.evoContainer1.monsterCardView.infoButton.hidden = YES;
  self.evoContainer2.monsterCardView.infoButton.hidden = YES;
  self.catalystContainer.monsterCardView.infoButton.hidden = YES;
}

- (void) updateTime {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.userEvolution) {
    int timeLeft = gs.userEvolution.endTime.timeIntervalSinceNow;
    self.timeLabel.text = [Globals convertTimeToShortString:timeLeft];
    self.speedupCostLabel.text = [Globals commafyNumber:[gl calculateGemSpeedupCostForTimeLeft:timeLeft]];
  }
}

@end
