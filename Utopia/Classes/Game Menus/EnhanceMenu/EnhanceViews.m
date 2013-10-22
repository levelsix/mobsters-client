//
//  EnhanceViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "EnhanceViews.h"
#import "Globals.h"
#import "GameState.h"

#define TABLE_CELL_WIDTH 72

@implementation EnhanceCardCell

- (void) awakeFromNib {
  self.overlayView.center = self.cardContainer.center;
  [self.cardContainer.superview addSubview:self.overlayView];
}

- (void) loadOverlayMask {
  UIView *view = self.cardContainer.monsterCardView.mainView;
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  self.overlayMask.image = [Globals maskImage:image withColor:[UIColor colorWithWhite:0.f alpha:0.5f]];
  
  self.overlayMask.frame = [self.overlayView convertRect:self.cardContainer.monsterCardView.mainView.frame fromView:self.cardContainer.monsterCardView];
}

- (void) updateForUserMonster:(UserMonster *)monster withBaseMonster:(EnhancementItem *)base {
  Globals *gl = [Globals sharedGlobals];
  
  self.monster = monster;
  
  if (self.monster) {
    [self.cardContainer.monsterCardView updateForMonster:monster];
  }
  
  if ([monster isHealing]) {
    [self loadOverlayMask];
    self.overlayLabel.text = @"Healing";
    self.overlayView.hidden = NO;
    self.cashButtonView.hidden = YES;
  } else {
    if ([monster isEnhancing] || [monster isSacrificing]) {
      [self loadOverlayMask];
      self.overlayLabel.text = @"Enhancing";
      self.overlayView.hidden = NO;
      self.cashButtonView.hidden = YES;
    } else {
      if (!base) {
        self.overlayView.hidden = YES;
        self.cashButtonView.hidden = YES;
      } else {
        self.overlayView.hidden = YES;
        self.cashButtonView.hidden = NO;
        
        EnhancementItem *ei = [[EnhancementItem alloc] init];
        ei.userMonsterId = monster.userMonsterId;
        
        self.cashButtonLabel.text = [Globals cashStringForNumber:[gl calculateSilverCostForEnhancement:base feeder:ei]];
        [Globals adjustViewForCentering:self.cashButtonLabel.superview withLabel:self.cashButtonLabel];
      }
    }
  }
  
  self.cardContainer.monsterCardView.delegate = self;
}

#pragma mark - IBAction methods

- (IBAction)enhanceClicked:(id)sender {
  [self.delegate enhanceClicked:self];
}

- (void) equipViewSelected:(MonsterCardView *)view {
  [self.delegate cardClicked:self];
}

@end

@implementation EnhanceQueueCell

- (void) updateForEnhanceItem:(EnhancementItem *)item {
  //  GameState *gs = [GameState sharedGameState];
  //  UserMonster *um = [gs myMonsterWithUserMonsterId:item.userMonsterId];
  //  [Globals loadImageForMonster:um.monsterId toView:self.monsterIcon];
  self.timerView.hidden = YES;
  
  self.enhanceItem = item;
}

- (void) updateForTime {
  int timeLeft = [self.enhanceItem.expectedEndTime timeIntervalSinceNow];
  
  self.timeLabel.text = [Globals convertTimeToShortString:timeLeft];
  self.progressBar.percentage = self.enhanceItem.currentPercentage;
  
  self.timerView.hidden = NO;
}

@end

@implementation EnhanceQueueView

- (void) awakeFromNib {
  [self setupInventoryTable];
}

- (void) reloadTable {
  GameState *gs = [GameState sharedGameState];
  if (gs.userEnhancement.feeders.count == 0) {
    self.hidden = YES;
  } else {
    self.hidden = NO;
    [self.queueTable reloadData];
    [self updateTimes];
  }
}

- (void) updateTimes {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = [gl calculateTimeLeftForEnhancement:gs.userEnhancement];
  int speedupCost = [gl calculateCostToSpeedupEnhancement:gs.userEnhancement];
  
  self.totalTimeLabel.text = [Globals convertTimeToShortString:timeLeft];
  self.speedupCostLabel.text = [Globals commafyNumber:speedupCost];
  
  EnhanceQueueCell *cell = (EnhanceQueueCell *)[self.queueTable viewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  [cell updateForTime];
  for (EnhanceQueueCell *cell in self.queueTable.visibleViews) {
    [cell updateForTime];
  }
}

- (IBAction)minusClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[EnhanceQueueCell class]]) {
    sender = [sender superview];
  }
  
  if (sender) {
    [self.delegate cellRequestsRemovalFromQueue:sender];
  }
}

- (IBAction)speedupClicked:(id)sender {
  [self.delegate speedupButtonClicked];
}

#pragma mark - EasyTableViewDelegate and Methods

- (void)setupInventoryTable {
  self.queueTable = [[EasyTableView alloc] initWithFrame:self.tableContainerView.bounds numberOfColumns:0 ofWidth:TABLE_CELL_WIDTH];
  self.queueTable.delegate = self;
  self.queueTable.tableView.separatorColor = [UIColor clearColor];
  self.queueTable.transform = CGAffineTransformMakeScale(-1, 1);
  self.queueTable.tableView.bounces = NO;
  [self.tableContainerView addSubview:self.queueTable];
}

- (NSUInteger) numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  return gs.userEnhancement.feeders.count;
}

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect withIndexPath:(NSIndexPath *)indexPath {
  [[NSBundle mainBundle] loadNibNamed:@"EnhanceQueueCell" owner:self options:nil];
  self.queueCell.transform = CGAffineTransformMakeScale(-1, 1);
  return self.queueCell;
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(EnhanceQueueCell *)view forIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  EnhancementItem *item = [gs.userEnhancement.feeders objectAtIndex:indexPath.row];
  [view updateForEnhanceItem:item];
  
  if (indexPath.row == 0) {
    [view updateForTime];
  }
}

@end

@implementation EnhanceBaseView

- (void) awakeFromNib {
  [self addSubview:self.noMonsterView];
}

- (void) updateForUserEnhancement:(UserEnhancement *)ue {
  GameState *gs = [GameState sharedGameState];
  
  if (!ue.baseMonster) {
    self.mainView.hidden = YES;
    self.noMonsterView.hidden = NO;
  } else {
    UserMonster *um = [gs myMonsterWithUserMonsterId:ue.baseMonster.userMonsterId];
    MonsterProto *mp = [gs monsterWithId:um.monsterId];
    
    self.nameLabel.text = mp.displayName;
    self.levelLabel.text = [NSString stringWithFormat:@"Lvl %d", (int)um.enhancementPercentage];
    
    float curPerc = [ue currentPercentageOfLevel];
    float newPerc = [ue finalPercentageFromCurrentLevel];
    float delta = newPerc-curPerc;
    
    self.orangeBar.percentage = curPerc;
    self.yellowBar.percentage = newPerc;
    NSString *deltaString = delta > 0 ? [NSString stringWithFormat:@" + %d%%", (int)ceilf(delta*100)] : @"";
    self.percentLabel.text = [NSString stringWithFormat:@"%d%%%@", (int)floorf(curPerc*100), deltaString];
    
    self.mainView.hidden = NO;
    self.noMonsterView.hidden = YES;
  }
}

@end
