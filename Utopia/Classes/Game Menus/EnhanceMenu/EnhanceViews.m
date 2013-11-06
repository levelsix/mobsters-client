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
#import "OutgoingEventController.h"

#define TABLE_CELL_WIDTH 72

@implementation EnhanceCardCell

- (void) updateForUserMonster:(UserMonster *)monster withBaseMonster:(EnhancementItem *)base {
  Globals *gl = [Globals sharedGlobals];
  
  self.monster = monster;
  
  if (self.monster) {
    [self.cardContainer.monsterCardView updateForMonster:monster];
  }
  
  if ([monster isHealing]) {
    self.cashButtonView.hidden = YES;
  } else {
    if ([monster isEnhancing] || [monster isSacrificing]) {
      self.cashButtonView.hidden = YES;
    } else {
      if (!base) {
        self.cashButtonView.hidden = YES;
      } else {
        self.cashButtonView.hidden = NO;
        
        EnhancementItem *ei = [[EnhancementItem alloc] init];
        ei.userMonsterId = monster.userMonsterId;
        
        self.cashButtonLabel.text = [Globals cashStringForNumber:[gl calculateSilverCostForEnhancement:base feeder:ei]];
      }
    }
  }
  
  self.cardContainer.monsterCardView.delegate = self;
}

#pragma mark - IBAction methods

- (IBAction)enhanceClicked:(id)sender {
  [self.delegate enhanceClicked:self];
}

- (void) monsterCardSelected:(MonsterCardView *)view {
  [self.delegate cardClicked:self];
}

@end

@implementation EnhanceQueueCell

- (void) updateForEnhanceItem:(EnhancementItem *)item {
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = item.userMonster;
  MonsterProto *mp = [gs monsterWithId:um.monsterId];
  
  NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Thumbnail.png"];
  [Globals imageNamed:fileName withView:self.monsterIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
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
  int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  self.totalTimeLabel.text = [Globals convertTimeToShortString:timeLeft];
  self.speedupCostLabel.text = [Globals commafyNumber:speedupCost];
  
  EnhanceQueueCell *cell = (EnhanceQueueCell *)[self.queueTable viewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  [cell updateForTime];
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
    
    float curPerc = [ue currentPercentageOfLevel];
    float newPerc = [ue finalPercentageFromCurrentLevel];
    float delta = newPerc-curPerc;
    
    int additionalLevel = (int)curPerc;
    curPerc = curPerc-additionalLevel;
    newPerc = newPerc-additionalLevel;
    
    self.nameLabel.text = mp.displayName;
    self.levelLabel.text = [NSString stringWithFormat:@"Lvl %d", um.level+additionalLevel];
    
    self.orangeBar.percentage = curPerc;
    self.yellowBar.percentage = newPerc;
    NSString *deltaString = delta > 0 ? [NSString stringWithFormat:@" + %@%%", [Globals commafyNumber:(int)ceilf(delta*100)]] : @"";
    self.percentLabel.text = [NSString stringWithFormat:@"%d%%%@", (int)floorf(curPerc*100), deltaString];
    
    NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Thumbnail.png"];
    [Globals imageNamed:fileName withView:self.monsterIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    CGPoint oldCenter = self.starView.center;
    float width = [[self.starView.subviews objectAtIndex:1] frame].origin.x;
    CGRect r = self.starView.frame;
    r.size.width = width*mp.evolutionLevel;
    self.starView.frame = r;
    self.starView.center = oldCenter;
    
    self.mainView.hidden = NO;
    self.noMonsterView.hidden = YES;
  }
}

@end
