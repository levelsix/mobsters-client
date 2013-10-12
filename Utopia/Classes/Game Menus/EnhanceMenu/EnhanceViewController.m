//
//  EnhanceViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/29/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "EnhanceViewController.h"
#import "GameState.h"

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
  
  self.noMonsterChosenView.frame = self.monsterChosenView.frame;
  [self.monsterChosenView.superview insertSubview:self.noMonsterChosenView belowSubview:self.monsterChosenView];
  self.monsterChosenView.alpha = 0.f;
  
  self.feeders = [NSMutableArray array];
  self.feederCards = [NSMutableArray array];
  
  [self.baseCard.monsterCardView.darkOverlay addTarget:self action:@selector(cardClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  
  [self positionCards];
}

- (MonsterCardView *) flyingCard {
  [[NSBundle mainBundle] loadNibNamed:@"MonsterCardView" owner:self options:nil];
  [self.view addSubview:self.monsterCardView];
  return self.monsterCardView;
}

- (void) updateLabels {
  Globals *gl = [Globals sharedGlobals];
  
  float base = [gl calculatePercentOfLevel:[gl calculateEnhancementPercentageToNextLevel:self.baseMonster.enhancementPercentage]];
  float increase = [gl calculatePercentOfLevel:[gl calculateEnhancementPercentageIncrease:self.baseMonster feeders:self.feeders]];
  self.orangeBar.percentage = base;
  self.yellowBar.percentage = base+increase;
  self.progressLabel.text = [NSString stringWithFormat:@"%d%%+%d%%", (int)(base*100), (int)(increase*100)];
  
  self.costLabel.text = [Globals cashStringForNumber:[gl calculateSilverCostForEnhancement:self.baseMonster feeders:self.feeders]];
  [Globals adjustViewForCentering:self.costLabel.superview withLabel:self.costLabel];
  
  self.enhanceButtonView.hidden = self.feeders.count == 0;
}

#pragma mark - Monster Manipulation

- (NSArray *) getMonsters {
  return nil;
}

- (void) chooseBaseMonster:(UserMonster *)monster fromCard:(MonsterCardView *)card {
  self.baseMonster = monster;
  [self positionCards];
  
  [self updateLabels];
  
  // Fly from table to base card slot, fade in stats, fade in feeder scroll view
  [self flyCardFromCard:card toCard:self.baseCard.monsterCardView withCompletionBlock:^(BOOL finished){
    self.monsterChosenView.alpha = 1.f;
    self.topLeftView.alpha = 0.f;
    self.topRightView.alpha = 0.f;
    [UIView animateWithDuration:0.3f animations:^{
      self.noMonsterChosenView.alpha = 0.f;
      self.topLeftView.alpha = 1.f;
    } completion:^(BOOL finished) {
      [UIView animateWithDuration:0.3f animations:^{
        self.topRightView.alpha = 1.f;
      }];
    }];
  }];
}

- (void) unchooseBaseMonster {
  self.baseMonster = nil;
  
  [self.feeders removeAllObjects];
  [self.feederCards enumerateObjectsUsingBlock:^(MonsterCardView *obj, NSUInteger idx, BOOL *stop) {
    [obj removeFromSuperview];
  }];
  [self.feederCards removeAllObjects];
  [self.monsterTable reloadData];
  
  [UIView animateWithDuration:0.3f animations:^{
    self.monsterChosenView.alpha = 0.f;
    self.noMonsterChosenView.alpha = 1.f;
  }];
}

- (void) addFeeder:(UserMonster *)monster fromCard:(MonsterCardView *)card {
  [self.feeders addObject:monster];
  
  [[NSBundle mainBundle] loadNibNamed:@"MonsterCardView" owner:self options:nil];
  [self.monsterCardView updateForMonster:monster];
  self.monsterCardView.frame = CGRectInset(self.blankFeederCard.frame, -3.f, -3.f);
  [self animateCardIntoLastSlot:self.monsterCardView fromCard:card];
  [self.monsterCardView.darkOverlay addTarget:self action:@selector(cardClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  [self updateLabels];
}

- (void) removeFeeder:(UserMonster *)monster {
  MonsterCardView *card = nil;
  for (MonsterCardView *aCard in self.feederCards) {
    if ([aCard.monster isEqual:monster]) {
      card = aCard;
    }
  }
  
  [self animateCardRemoval:card];
  
  [self.feeders removeObject:monster];
  
  [self updateLabels];
}

- (BOOL) monsterIsInUse:(UserMonster *)monster {
  return [monster isEqual:self.baseMonster] || [self.feeders containsObject:monster];
}

#pragma mark - Feeder Scroll View

- (void) flyCardFromCard:(MonsterCardView *)start toCard:(MonsterCardView *)end withCompletionBlock:(void(^)(BOOL))completionBlock {
  MonsterCardView *flyingCard = [self flyingCard];
  [flyingCard updateForMonster:start.monster];
  flyingCard.frame = [flyingCard.superview convertRect:start.frame fromView:start.superview];
  end.hidden = YES;
  [UIView animateWithDuration:0.3f animations:^{
    flyingCard.frame = [flyingCard.superview convertRect:end.frame fromView:end.superview];
  } completion:^(BOOL finished) {
    end.hidden = NO;
    [end updateForMonster:start.monster];
    
    if (completionBlock) {
      completionBlock(finished);
    }
    
    if (finished) {
      flyingCard.hidden = YES;
      flyingCard.monster = nil;
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
    MonsterCardView *card = [self.feederCards objectAtIndex:i];
    card.center = [self positionForIndex:i];
  }
  self.blankFeederCard.center = [self positionForIndex:i];
  self.feederScrollView.contentSize = CGSizeMake(CGRectGetMaxX(self.blankFeederCard.frame)+CARD_SPACE_IN_BETWEEN, self.feederScrollView.frame.size.height);
}

- (void) animateCardIntoLastSlot:(MonsterCardView *)card fromCard:(MonsterCardView *)startCard {
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

- (void) animateCardRemoval:(MonsterCardView *)card {
  [self animateCardRemoval:card duration:0.3f withCompletionBlock:nil];
}

- (void) animateCardRemoval:(MonsterCardView *)card duration:(float)duration withCompletionBlock:(void(^)(BOOL))completionBlock {
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
      MonsterCardView *card = [self.feederCards objectAtIndex:0];
      
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
  
  while (![sender isKindOfClass:[MonsterCardView class]]) sender = [sender superview];
  
  MonsterCardView *card = (MonsterCardView *)sender;
  UserMonster *monster = card.monster;
  BOOL isFeederCard = [self.feederCards containsObject:card];
  
  float alpha = 1.f;
  if (!self.baseMonster) {
    [self chooseBaseMonster:monster fromCard:card];
    alpha = CLICKED_CARD_ALPHA;
  } else if ([self.baseMonster isEqual:monster]) {
    [self unchooseBaseMonster];
  } else if ([self.feeders containsObject:monster]) {
    [self removeFeeder:monster];
  } else {
    [self addFeeder:monster fromCard:card];
    alpha = CLICKED_CARD_ALPHA;
  }
  
  if (isFeederCard) {
    int index = [[self getMonsters] indexOfObject:monster];
    int row = index / NUM_CARDS_PER_ROW;
    EnhanceBrowseCell *cell = (EnhanceBrowseCell *)[self.monsterTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    MonsterCardView *tableCard = [[cell.containerViews objectAtIndex:index % NUM_CARDS_PER_ROW] monsterCardView];
    tableCard.alpha = alpha;
  } else {
    card.alpha = alpha;
  }
}

- (IBAction)submitClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int silverCost = [gl calculateSilverCostForEnhancement:self.baseMonster feeders:self.feeders];
  if (silverCost > gs.silver) {
//    [[RefillMenuController sharedRefillMenuController] displayBuySilverView:silverCost];
  } else {
    [self animateEnhancement];
  }
}

# pragma mark - Table View Methods

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray *monsters = [self getMonsters];
  return monsters.count > 0 ? (monsters.count-1)/NUM_CARDS_PER_ROW+1 : 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  EnhanceBrowseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EnhanceBrowseCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"EnhanceBrowseCell" owner:self options:nil];
    cell = self.browseCell;
  }
  
  NSArray *monsters = [self getMonsters];
  NSMutableArray *ues = [NSMutableArray array];
  
  int row = indexPath.row;
  for (int i = row*NUM_CARDS_PER_ROW; i < (row+1)*NUM_CARDS_PER_ROW; i++) {
    if (monsters.count > i) {
      [ues addObject:[monsters objectAtIndex:i]];
    } else {
      [ues addObject:[NSNull null]];
    }
  }
  
  for (int i = 0; i < ues.count; i++) {
    UserMonster *ue = [ues objectAtIndex:i];
    MonsterCardView *card = [[cell.containerViews objectAtIndex:i] monsterCardView];
    if ([ue isKindOfClass:[UserMonster class]]) {
      [card updateForMonster:ue];
      card.alpha = [self monsterIsInUse:ue] ? CLICKED_CARD_ALPHA : 1.f;
    } else {
      [card updateForNoMonster];
    }
    [card.darkOverlay addTarget:self action:@selector(cardClicked:) forControlEvents:UIControlEventTouchUpInside];
  }
  
  return cell;
}

- (void) dealloc {
  self.browseCell = nil;
  self.monsterChosenView = nil;
  self.noMonsterChosenView = nil;
  self.baseMonster = nil;
  self.feeders = nil;
  self.feederCards = nil;
  self.monsterCardView = nil;
  [super dealloc];
}

@end
