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

#define TABLE_CELL_WIDTH 54

@implementation EnhanceCardCell

- (void) awakeFromNib {
  self.enhanceBarView.frame = self.feederLabelView.frame;
  [self.feederLabelView.superview addSubview:self.enhanceBarView];
}

- (void) updateForUserMonster:(UserMonster *)monster withUserEnhancement:(UserEnhancement *)ue {
  Globals *gl = [Globals sharedGlobals];
  
  self.monster = monster;
  
  [self.cardContainer.monsterCardView updateForMonster:monster];
  
  if (!ue.baseMonster) {
    self.enhanceBarView.hidden = NO;
    self.feederLabelView.hidden = YES;
    
    float baseLevel = [gl calculateLevelForMonster:monster.monsterId experience:monster.experience];
    float curPerc = baseLevel-(int)baseLevel;
    
    if (monster.level >= monster.staticMonster.maxLevel) {
      self.percentageLabel.text = @"MAX";
      self.orangeBar.percentage = 1.f;
    } else {
      self.percentageLabel.text = [NSString stringWithFormat:@"%d%%", (int)roundf(curPerc*100)];
      self.orangeBar.percentage = curPerc;
    }
  } else {
    self.enhanceBarView.hidden = YES;
    self.feederLabelView.hidden = NO;
    
    float curPerc = [ue finalPercentageFromCurrentLevel];
    
    // add this item to UserEnhancement
    EnhancementItem *item = [[EnhancementItem alloc] init];
    item.userMonsterId = monster.userMonsterId;
    [ue.feeders addObject:item];
    
    float newPerc = [ue finalPercentageFromCurrentLevel];
    
    [ue.feeders removeObject:item];
    
    float percIncrease = newPerc-curPerc;
    int cost = [gl calculateOilCostForEnhancement:ue.baseMonster feeder:item];
    self.feederLabel.text = [NSString stringWithFormat:@"%@%% for %@ oil", [Globals commafyNumber:(int)roundf(percIncrease*100)], [Globals commafyNumber:cost]];
  }
  
  self.onTeamIcon.hidden = monster.teamSlot == 0;
  
  self.cardContainer.monsterCardView.delegate = self;
}

#pragma mark - IBAction methods

- (void) infoClicked:(MonsterCardView *)view {
  [self.delegate infoClicked:self];
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
  
  fileName = [Globals imageNameForElement:mp.monsterElement suffix:@"team.png"];
  [Globals imageNamed:fileName withView:self.bgdIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
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
  [self.queueTable reloadData];
  [self updateTimes];
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
  self.queueTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.tableContainerView addSubview:self.queueTable];
}

- (NSUInteger) numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  self.enhancingQueue = [gs.userEnhancement.feeders copy];
  if (self.enhancingQueue.count == 0) {
    if (self.alpha == 1.f) {
      [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0.f;
        self.instructionLabel.alpha = 1.f;
      }];
    }
    
    if (!gs.userEnhancement.baseMonster) {
      self.instructionLabel.text = @"Select a mobster to enhance";
    } else {
      self.instructionLabel.text = @"Select a mobster to sacrifice";
    }
  } else {
    if (self.alpha == 0.f) {
      [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 1.f;
        self.instructionLabel.alpha = 0.f;
      }];
    } else if (self.instructionLabel.alpha == 1.f) {
      // Have to do this in case queue starts with items
      self.instructionLabel.alpha = 0.f;
    }
  }
  return self.enhancingQueue.count;
}

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect withIndexPath:(NSIndexPath *)indexPath {
  [[NSBundle mainBundle] loadNibNamed:@"EnhanceQueueCell" owner:self options:nil];
  self.queueCell.transform = CGAffineTransformMakeScale(-1, 1);
  self.queueCell.center = ccp(rect.size.width/2, rect.size.height/2);
  return self.queueCell;
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(EnhanceQueueCell *)view forIndexPath:(NSIndexPath *)indexPath {
  EnhancementItem *item = [self.enhancingQueue objectAtIndex:indexPath.row];
  [view updateForEnhanceItem:item];
  
  if (indexPath.row == 0) {
    [view updateForTime];
  }
}

@end

@implementation EnhanceBaseView

- (void) updateForUserEnhancement:(UserEnhancement *)ue {
  if (ue.baseMonster) {
    UserMonster *um = ue.baseMonster.userMonster;
    MonsterProto *mp = um.staticMonster;
    
    int curPerc = roundf([ue currentPercentageOfLevel]*100);
    int newPerc = roundf([ue finalPercentageFromCurrentLevel]*100);
    int delta = newPerc-curPerc;
    
    int additionalLevel = (int)(curPerc/100.f);
    curPerc = curPerc-additionalLevel*100;
    newPerc = newPerc-additionalLevel*100;
    
    self.orangeBar.percentage = curPerc/100.f;
    self.yellowBar.percentage = newPerc/100.f;
    NSString *deltaString = delta > 0 ? [NSString stringWithFormat:@" + %@%%", [Globals commafyNumber:delta]] : @"";
    self.percentageLabel.text = [NSString stringWithFormat:@"%d%%%@", curPerc, deltaString];
    
    [self.cardContainer.monsterCardView updateForMonster:um];
    self.cardContainer.monsterCardView.nameLabel.text = [NSString stringWithFormat:@"%@ (LVL %d)", mp.displayName, um.level+additionalLevel];
    
    self.onTeamIcon.hidden = um.teamSlot == 0;
  }
  self.cardContainer.monsterCardView.overlayButton.userInteractionEnabled = NO;
  self.monster = ue.baseMonster.userMonster;
}

@end
