//
//  EnhanceViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/29/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "EnhanceViewController.h"
#import "GameState.h"
#import "RefillMenuController.h"

#define CLICKED_CARD_ALPHA 0.5f
#define CARD_SPACE_IN_BETWEEN 7.f
#define NUM_CARDS_PER_ROW 4

@implementation EnhanceBrowseCell

- (void) dealloc {
  self.containerViews = nil;
  [super dealloc];
}

@end

@implementation EnhanceViewController

- (void) viewDidLoad {
  self.title = @"Enhance";
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  self.noEquipChosenView.frame = self.equipChosenView.frame;
  [self.equipChosenView.superview insertSubview:self.noEquipChosenView belowSubview:self.equipChosenView];
  self.equipChosenView.alpha = 0.f;
  
  self.feeders = [NSMutableArray array];
  self.feederCards = [NSMutableArray array];
  
  [self.baseCard.equipCardView.darkOverlay addTarget:self action:@selector(cardClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  
  [self positionCards];
}

- (EquipCardView *) flyingCard {
  [[NSBundle mainBundle] loadNibNamed:@"EquipCardView" owner:self options:nil];
  [self.view addSubview:self.equipCardView];
  return self.equipCardView;
}

- (void) updateLabels {
  Globals *gl = [Globals sharedGlobals];
  
  int oldAttack = [gl calculateAttackForEquip:self.baseEquip.equipId level:self.baseEquip.level enhancePercent:self.baseEquip.enhancementPercentage];
  int oldDefense = [gl calculateDefenseForEquip:self.baseEquip.equipId level:self.baseEquip.level enhancePercent:self.baseEquip.enhancementPercentage];
  int newAttack = [gl calculateAttackForEquip:self.baseEquip.equipId level:self.baseEquip.level enhancePercent:self.baseEquip.enhancementPercentage+gl.enhancePercentPerLevel];
  int newDefense = [gl calculateDefenseForEquip:self.baseEquip.equipId level:self.baseEquip.level enhancePercent:self.baseEquip.enhancementPercentage+gl.enhancePercentPerLevel];
  self.curAttackLabel.text = [Globals commafyNumber:oldAttack];
  self.curDefenseLabel.text = [Globals commafyNumber:oldDefense];
  self.nextAttackLabel.text = [Globals commafyNumber:newAttack];
  self.nextDefenseLabel.text = [Globals commafyNumber:newDefense];
  
  float base = [gl calculatePercentOfLevel:[gl calculateEnhancementPercentageToNextLevel:self.baseEquip.enhancementPercentage]];
  float increase = [gl calculatePercentOfLevel:[gl calculateEnhancementPercentageIncrease:self.baseEquip feeders:self.feeders]];
  self.orangeBar.percentage = base;
  self.yellowBar.percentage = base+increase;
  self.progressLabel.text = [NSString stringWithFormat:@"%d%%+%d%%", (int)(base*100), (int)(increase*100)];
  
  self.costLabel.text = [Globals cashStringForNumber:[gl calculateSilverCostForEnhancement:self.baseEquip feeders:self.feeders]];
  [Globals adjustViewForCentering:self.costLabel.superview withLabel:self.costLabel];
  
  self.enhanceButtonView.hidden = self.feeders.count == 0;
}

#pragma mark - Equip Manipulation

- (NSArray *) getEquips {
  GameState *gs = [GameState sharedGameState];
  return gs.myEquips;
}

- (void) chooseBaseEquip:(UserEquip *)equip fromCard:(EquipCardView *)card {
  self.baseEquip = equip;
  [self positionCards];
  
  [self updateLabels];
  
  // Fly from table to base card slot, fade in stats, fade in feeder scroll view
  [self flyCardFromCard:card toCard:self.baseCard.equipCardView withCompletionBlock:^(BOOL finished){
    self.equipChosenView.alpha = 1.f;
    self.topLeftView.alpha = 0.f;
    self.topRightView.alpha = 0.f;
    [UIView animateWithDuration:0.3f animations:^{
      self.noEquipChosenView.alpha = 0.f;
      self.topLeftView.alpha = 1.f;
    } completion:^(BOOL finished) {
      [UIView animateWithDuration:0.3f animations:^{
        self.topRightView.alpha = 1.f;
      }];
    }];
  }];
}

- (void) unchooseBaseEquip {
  self.baseEquip = nil;
  
  [self.feeders removeAllObjects];
  [self.feederCards enumerateObjectsUsingBlock:^(EquipCardView *obj, NSUInteger idx, BOOL *stop) {
    [obj removeFromSuperview];
  }];
  [self.feederCards removeAllObjects];
  [self.equipTable reloadData];
  
  [UIView animateWithDuration:0.3f animations:^{
    self.equipChosenView.alpha = 0.f;
    self.noEquipChosenView.alpha = 1.f;
  }];
}

- (void) addFeeder:(UserEquip *)equip fromCard:(EquipCardView *)card {
  [self.feeders addObject:equip];
  
  [[NSBundle mainBundle] loadNibNamed:@"EquipCardView" owner:self options:nil];
  [self.equipCardView updateForEquip:equip];
  self.equipCardView.frame = CGRectInset(self.blankFeederCard.frame, -3.f, -3.f);
  [self animateCardIntoLastSlot:self.equipCardView fromCard:card];
  [self.equipCardView.darkOverlay addTarget:self action:@selector(cardClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  [self updateLabels];
}

- (void) removeFeeder:(UserEquip *)equip {
  EquipCardView *card = nil;
  for (EquipCardView *aCard in self.feederCards) {
    if ([aCard.equip isEqual:equip]) {
      card = aCard;
    }
  }
  
  [self animateCardRemoval:card];
  
  [self.feeders removeObject:equip];
  
  [self updateLabels];
}

- (BOOL) equipIsInUse:(UserEquip *)equip {
  return [equip isEqual:self.baseEquip] || [self.feeders containsObject:equip];
}

#pragma mark - Feeder Scroll View

- (void) flyCardFromCard:(EquipCardView *)start toCard:(EquipCardView *)end withCompletionBlock:(void(^)(BOOL))completionBlock {
  EquipCardView *flyingCard = [self flyingCard];
  [flyingCard updateForEquip:start.equip];
  flyingCard.frame = [flyingCard.superview convertRect:start.frame fromView:start.superview];
  end.hidden = YES;
  [UIView animateWithDuration:0.3f animations:^{
    flyingCard.frame = [flyingCard.superview convertRect:end.frame fromView:end.superview];
  } completion:^(BOOL finished) {
    end.hidden = NO;
    [end updateForEquip:start.equip];
    
    if (completionBlock) {
      completionBlock(finished);
    }
    
    if (finished) {
      flyingCard.hidden = YES;
      flyingCard.equip = nil;
    }
  }];
}

- (CGPoint) positionForIndex:(int)i {
  UIView *card = self.blankFeederCard;
  return ccp(CARD_SPACE_IN_BETWEEN*(i+1)+card.frame.size.width/2*(2*i+1), self.feederScrollView.frame.size.height/2);
}

- (void) positionCards {
  int i;
  for (i = 0; i < self.feederCards.count; i++) {
    EquipCardView *card = [self.feederCards objectAtIndex:i];
    card.center = [self positionForIndex:i];
  }
  self.blankFeederCard.center = [self positionForIndex:i];
  self.feederScrollView.contentSize = CGSizeMake(CGRectGetMaxX(self.blankFeederCard.frame)+CARD_SPACE_IN_BETWEEN, self.feederScrollView.frame.size.height);
}

- (void) animateCardIntoLastSlot:(EquipCardView *)card fromCard:(EquipCardView *)startCard {
  [self.feederCards addObject:card];
  [self.feederScrollView addSubview:card];
  
  // Fly card to blank slot, then fade in new blank slot (just move blank card)
  card.center = [self positionForIndex:self.feederCards.count-1];
  card.hidden = YES;
  [UIView animateWithDuration:0.1f animations:^{
    self.feederScrollView.contentOffset = ccp(MAX(0, self.feederScrollView.contentSize.width-self.feederScrollView.frame.size.width), 0);
  } completion:^(BOOL finished) {
    [self flyCardFromCard:startCard toCard:card withCompletionBlock:^(BOOL finished){
      if (finished) {
        [self positionCards];
        self.blankFeederCard.alpha = 0.f;
        [UIView animateWithDuration:0.2f animations:^{
          self.blankFeederCard.alpha = 1.f;
          self.feederScrollView.contentOffset = ccp(MAX(0, self.feederScrollView.contentSize.width-self.feederScrollView.frame.size.width), 0);
        }];
      }
    }];
  }];
}

- (void) animateCardRemoval:(EquipCardView *)card {
  [self animateCardRemoval:card duration:0.3f withCompletionBlock:nil];
}

- (void) animateCardRemoval:(EquipCardView *)card duration:(float)duration withCompletionBlock:(void(^)(BOOL))completionBlock {
  [self.feederCards removeObject:card];
  
  [UIView animateWithDuration:duration animations:^{
    [self positionCards];
    card.alpha = 0.f;
  } completion:^(BOOL finished) {
    [card removeFromSuperview];
    if (completionBlock) {
      completionBlock(finished);
    }
  }];
}

- (void) animateEnhancement {
  if (self.feederCards.count > 0) {
    _isAnimating = YES;
    [UIView animateWithDuration:0.3f animations:^{
      self.feederScrollView.contentOffset = ccp(0,0);
    } completion:^(BOOL finished) {
      EquipCardView *card = [self.feederCards objectAtIndex:0];
      
      UIImageView *bgdImgView = [[UIImageView alloc] initWithImage:[Globals maskImage:card.bgd.image withColor:[UIColor colorWithWhite:0.f alpha:0.3f]]];
      [card.mainView addSubview:bgdImgView];
      bgdImgView.alpha = 0.f;
      bgdImgView.tag = 1;
      bgdImgView.frame = card.bgd.frame;
      
      UIImageView *check = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3dcheckmark.png"]];
      [card addSubview:check];
      check.center = ccp(card.frame.size.width/2, card.frame.size.height/2);
      check.alpha = 0.f;
      check.tag = 2;
      
      [Globals bounceView:check fadeInBgdView:bgdImgView completion:^(BOOL finished) {
        [self animateCardRemoval:card duration:0.6f withCompletionBlock:^(BOOL finished) {
          [self animateEnhancement];
        }];
      }];
    }];
  } else {
    [self.feeders removeAllObjects];
    _isAnimating = NO;
  }
}

#pragma mark - Button handlers

- (IBAction)cardClicked:(id)sender {
  if (_isAnimating) return;
  
  while (![sender isKindOfClass:[EquipCardView class]]) sender = [sender superview];
  
  EquipCardView *card = (EquipCardView *)sender;
  UserEquip *equip = card.equip;
  BOOL isFeederCard = [self.feederCards containsObject:card];
  
  float alpha = 1.f;
  if (!self.baseEquip) {
    [self chooseBaseEquip:equip fromCard:card];
    alpha = CLICKED_CARD_ALPHA;
  } else if ([self.baseEquip isEqual:equip]) {
    [self unchooseBaseEquip];
  } else if ([self.feeders containsObject:equip]) {
    [self removeFeeder:equip];
  } else {
    [self addFeeder:equip fromCard:card];
    alpha = CLICKED_CARD_ALPHA;
  }
  
  if (isFeederCard) {
    int index = [[self getEquips] indexOfObject:equip];
    int row = index / NUM_CARDS_PER_ROW;
    EnhanceBrowseCell *cell = (EnhanceBrowseCell *)[self.equipTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    EquipCardView *tableCard = [[cell.containerViews objectAtIndex:index % NUM_CARDS_PER_ROW] equipCardView];
    tableCard.alpha = alpha;
  } else {
    card.alpha = alpha;
  }
}

- (IBAction)submitClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int silverCost = [gl calculateSilverCostForEnhancement:self.baseEquip feeders:self.feeders];
  if (silverCost > gs.silver) {
    [[RefillMenuController sharedRefillMenuController] displayBuySilverView:silverCost];
  } else {
    [self animateEnhancement];
  }
}

# pragma mark - Table View Methods

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray *equips = [self getEquips];
  return equips.count > 0 ? (equips.count-1)/NUM_CARDS_PER_ROW+1 : 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  EnhanceBrowseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EnhanceBrowseCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"EnhanceBrowseCell" owner:self options:nil];
    cell = self.browseCell;
  }
  
  NSArray *equips = [self getEquips];
  NSMutableArray *ues = [NSMutableArray array];
  
  int row = indexPath.row;
  for (int i = row*NUM_CARDS_PER_ROW; i < (row+1)*NUM_CARDS_PER_ROW; i++) {
    if (equips.count > i) {
      [ues addObject:[equips objectAtIndex:i]];
    } else {
      [ues addObject:[NSNull null]];
    }
  }
  
  for (int i = 0; i < ues.count; i++) {
    UserEquip *ue = [ues objectAtIndex:i];
    EquipCardView *card = [[cell.containerViews objectAtIndex:i] equipCardView];
    if ([ue isKindOfClass:[UserEquip class]]) {
      [card updateForEquip:ue];
      card.alpha = [self equipIsInUse:ue] ? CLICKED_CARD_ALPHA : 1.f;
    } else {
      [card updateForNoEquip];
    }
    [card.darkOverlay addTarget:self action:@selector(cardClicked:) forControlEvents:UIControlEventTouchUpInside];
  }
  
  return cell;
}

- (void) dealloc {
  self.browseCell = nil;
  self.equipChosenView = nil;
  self.noEquipChosenView = nil;
  self.baseEquip = nil;
  self.feeders = nil;
  self.feederCards = nil;
  self.equipCardView = nil;
  [super dealloc];
}

@end
