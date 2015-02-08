//
//  TimerViewController.m
//  Utopia
//
//  Created by Ashwin on 10/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TimerViewController.h"

#import "TimerAction.h"
#import "Globals.h"
#import "GameState.h"

#import "ItemSelectViewController.h"

#define SCROLLVIEW_INSET 3
#define CELL_SPACING 3
#define MINIMIZED_CELLS_SHOWN 2
#define MIN_HEIGHT 15.5f

@implementation TimerCell

- (void) awakeFromNib {
  self.helpView.frame = self.finishView.frame;
  [self.finishView.superview addSubview:self.helpView];
}

- (void) updateForTimerAction:(id<TimerAction>)ta {
  self.titleLabel.text = [ta title];
  self.timeLabel.text = [[Globals convertTimeToShortString:[ta secondsLeft]] uppercaseString];
  
  // Use tag of the progress bar to determine what color it is
  TimerProgressBarColor color = [ta progressBarColor];
  if (self.progressBar.tag != color) {
    // Reload it
    NSString *prefix = nil;
    if (color == TimerProgressBarColorYellow) {
      prefix = @"obtimeryellow";
    } else if (color == TimerProgressBarColorGreen) {
      prefix = @"obtimergreen";
    } else if (color == TimerProgressBarColorPurple) {
      prefix = @"obtimerpurple";
    }
    
    self.progressBar.leftCap.image = [Globals imageNamed:[prefix stringByAppendingString:@"cap.png"]];
    self.progressBar.rightCap.image = [Globals imageNamed:[prefix stringByAppendingString:@"cap.png"]];
    self.progressBar.middleBar.image = [Globals imageNamed:[prefix stringByAppendingString:@"middle.png"]];
    
    self.progressBar.tag = color;
  }
  
  [self.progressBar setPercentage:(1.f-[ta secondsLeft]/(float)[ta totalSeconds])];
  
  int gemCost = [ta gemCost];
  if (gemCost) {
    self.freeLabel.hidden = YES;
    self.gemsLabel.superview.hidden = NO;
    self.speedupIcon.hidden = NO;
    
    self.gemsLabel.text = [Globals commafyNumber:gemCost];
    [Globals adjustViewForCentering:self.gemsLabel.superview withLabel:self.gemsLabel];
    
    BOOL canGetHelp = [ta canGetHelp] && ![ta hasAskedForClanHelp];
    self.helpView.hidden = !canGetHelp;
    self.finishView.hidden = canGetHelp;
  } else {
    self.freeLabel.hidden = NO;
    self.gemsLabel.superview.hidden = YES;
    self.speedupIcon.hidden = YES;
    
    self.helpView.hidden = YES;
    self.finishView.hidden = NO;
  }
}

@end


@implementation TimerViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  self.isOpen = YES;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self reloadData];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:HEAL_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:COMBINE_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:EVOLUTION_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:MINI_JOB_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:RECEIVED_CLAN_HELP_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:SPEEDUP_USED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:MONSTER_SOLD_COMPLETE_NOTIFICATION object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:STRUCT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:STRUCT_PURCHASED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:OBSTACLE_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:OBSTACLE_REMOVAL_BEGAN_NOTIFICATION object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:HEAL_QUEUE_CHANGED_NOTIFICATION object:nil];
  
  _dummyObjects = [NSMutableArray array];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearDummyObjects) name:ITEM_SELECT_CLOSED_NOTIFICATION object:nil];
  
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:EVOLUTION_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:ENHANCE_MONSTER_NOTIFICATION object:nil];
  
  self.updateTimer = [NSTimer timerWithTimeInterval:0.2f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  [self updateLabels];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self.updateTimer invalidate];
  self.updateTimer = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) waitTimeComplete {
  [self reloadDataAnimated];
}

- (void) updateLabels {
  for (int i = 0; i < self.timerActionsArray.count && i < self.timerCells.count; i++) {
    TimerAction *ta = self.timerActionsArray[i];
    TimerCell *tc = self.timerCells[i];
    
    [tc updateForTimerAction:ta];
  }
}

- (void) clearDummyObjects {
  [_dummyObjects removeAllObjects];
}

#pragma mark - Loading Table

- (void) reloadTimerActionArray {
  NSMutableArray *arr = [NSMutableArray array];
  
  GameState *gs = [GameState sharedGameState];
  
  for (UserMonster *um in gs.myMonsters) {
    if (um.isCombining) {
      TimerAction *ta = [[CombineMonsterTimerAction alloc] initWithUserMonster:um];
      [arr addObject:ta];
    }
  }
  
  for (UserMiniJob *mj in gs.myMiniJobs) {
    if (mj.timeStarted && !mj.timeCompleted) {
      TimerAction *ta = [[MiniJobTimerAction alloc] initWithMiniJob:mj];
      [arr addObject:ta];
    }
  }
  
  for (UserStruct *us in gs.myStructs) {
    if (!us.isComplete) {
      TimerAction *ta = [[BuildingTimerAction alloc] initWithUserStruct:us];
      [arr addObject:ta];
    }
  }
  
  for (UserObstacle *uo in gs.myObstacles) {
    if (uo.removalTime) {
      TimerAction *ta = [[ObstacleTimerAction alloc] initWithUserObstacle:uo];
      [arr addObject:ta];
    }
  }
  
  if (gs.userEvolution) {
    TimerAction *ta = [[EvolutionTimerAction alloc] initWithEvolution:gs.userEvolution];
    [arr addObject:ta];
  }
  
  if (gs.userEnhancement && !gs.userEnhancement.isComplete) {
    TimerAction *ta = [[EnhancementTimerAction alloc] initWithEnhancement:gs.userEnhancement];
    [arr addObject:ta];
  }
  
  for (HospitalQueue *hq in gs.monsterHealingQueues.allValues) {
    if (hq.healingItems.count) {
      TimerAction *ta = [[HealingTimerAction alloc] initWithHospitalQueue:hq];
      [arr addObject:ta];
    }
  }
  
  [arr sortUsingSelector:@selector(compare:)];
  
  self.timerActionsArray = arr;
}

- (CGPoint) positionForViewAtIndex:(int)i cellSize:(CGSize)size {
  return ccp(self.scrollView.width/2, SCROLLVIEW_INSET+(i+0.5)*size.height+CELL_SPACING*i);
}

#define ANIM_DUR 0.3

- (void) reloadDataAnimated:(BOOL)animated {
  NSArray *oldArray = self.timerActionsArray;
  [self reloadTimerActionArray];
  
  NSMutableArray *removals = [NSMutableArray array], *additions = [NSMutableArray array];
  
  [Globals calculateDifferencesBetweenOldArray:oldArray newArray:self.timerActionsArray removalIps:removals additionIps:additions section:0];
  
  NSMutableArray *oldCells = [self.timerCells mutableCopy];
  NSMutableArray *newCells = [NSMutableArray array];
  
  for (NSIndexPath *ip in removals) {
    TimerCell *cell = oldCells[ip.row];
    if (animated) {
      [UIView animateWithDuration:ANIM_DUR animations:^{
        cell.alpha = 0.f;
      } completion:^(BOOL finished) {
        [cell removeFromSuperview];
      }];
    } else {
      [cell removeFromSuperview];
    }
  }
  
  for (int i = 0; i < self.timerActionsArray.count; i++) {
    TimerAction *ta = self.timerActionsArray[i];
    if (![additions containsObject:[NSIndexPath indexPathForRow:i inSection:0]]) {
      // These are the moved ones
      NSInteger oldIdx = [oldArray indexOfObject:ta];
      
      // Transfer hasAskedFroClanHelp value
      TimerAction *oldTa = oldArray[oldIdx];
      ta.hasAskedForClanHelp = oldTa.hasAskedForClanHelp;
      
      TimerCell *cell = oldCells[oldIdx];
      CGPoint newPos = [self positionForViewAtIndex:i cellSize:cell.size];
      [cell updateForTimerAction:ta];
      
      if (animated) {
        [UIView animateWithDuration:ANIM_DUR animations:^{
          cell.center = newPos;
        }];
      } else {
        cell.center = newPos;
      }
      
      [self.scrollView bringSubviewToFront:cell];
      
      [newCells addObject:cell];
    } else {
      // Create a new one
      [[NSBundle mainBundle] loadNibNamed:@"TimerCell" owner:self options:nil];
      TimerCell *newCell = self.timerCell;
      
      [self.scrollView addSubview:newCell];
      
      [newCell updateForTimerAction:ta];
      newCell.center = [self positionForViewAtIndex:i cellSize:newCell.size];
      
      if (animated) {
        newCell.alpha = 0.f;
        [UIView animateWithDuration:ANIM_DUR animations:^{
          newCell.alpha = 1.f;
        }];
      }
      
      [newCells addObject:newCell];
    }
  }
  
  self.timerCells = newCells;
  
  dispatch_block_t block = ^{
    // Adjust scrollView's contentSize and actual height
    int maxHeight = CGRectGetMaxY([[self.timerCells lastObject] frame])+SCROLLVIEW_INSET;
    float heightDiff = (self.mainView.height-self.scrollView.superview.height);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width, maxHeight);
    self.scrollView.height = MIN(self.view.height-heightDiff, maxHeight);
  };
  
  if (animated) {
    [UIView animateWithDuration:ANIM_DUR animations:block];
  } else {
    block();
  }
  
  [self adjustViewForOpenCloseAnimated:YES];
}

- (void) reloadData {
  [self reloadDataAnimated:NO];
}

- (void) reloadDataAnimated {
  [self reloadDataAnimated:YES];
}

- (void) adjustViewForOpenCloseAnimated:(BOOL)animated {
  float heightDiff = (self.mainView.height-self.scrollView.superview.height);
  
  self.scrollView.scrollEnabled = self.isOpen;
  
  self.openLabel.text = self.isOpen ? @"Close" : [NSString stringWithFormat:@"%d More", (int)self.timerCells.count-MINIMIZED_CELLS_SHOWN];
  
  dispatch_block_t block = ^{
    BOOL moreRows = self.timerCells.count > MINIMIZED_CELLS_SHOWN;
    self.bottomBgdView.highlighted = !moreRows;
    self.openButtonView.hidden = !moreRows;
    
    // Adjust mainView's height. Try to get it as tall as we can if open.
    // If not open, strive moreRows minimized num cells.
    if (self.isOpen && moreRows) {
      self.mainView.height = MIN(self.view.height, self.scrollView.height+heightDiff);
      
      self.scrollView.alpha = 1.f;
      self.noTimersLabel.alpha = 0.f;
    } else {
      TimerCell *cell = nil;
      if (moreRows) {
        cell = self.timerCells[MINIMIZED_CELLS_SHOWN-1];
        self.scrollView.contentOffset = ccp(0,0);
      } else {
        cell = [self.timerCells lastObject];
      }
      
      if (cell) {
        self.mainView.height = CGRectGetMaxY(cell.frame)+SCROLLVIEW_INSET+heightDiff;
        
        self.scrollView.alpha = 1.f;
        self.noTimersLabel.alpha = 0.f;
      } else {
        self.mainView.height = MIN_HEIGHT+heightDiff;
        
        self.scrollView.alpha = 0.f;
        self.noTimersLabel.alpha = 1.f;
      }
    }
    
    self.openArrow.transform = self.isOpen ? CGAffineTransformMakeScale(1, -1) : CGAffineTransformIdentity;
  };
  
  if (animated) {
    [UIView animateWithDuration:ANIM_DUR animations:block];
  } else {
    block();
  }
}

- (IBAction)openCloseClicked:(id)sender {
  self.isOpen = !self.isOpen;
  [self adjustViewForOpenCloseAnimated:YES];
}

- (IBAction)speedupClicked:(UIView *)sender {
  sender = [sender getAncestorInViewHierarchyOfType:[TimerCell class]];
  
  if (sender && [ItemSelectViewController canCreateNewVc]) {
    NSInteger idx = [self.timerCells indexOfObject:sender];
    if (idx < self.timerActionsArray.count) {
      TimerAction *ta = self.timerActionsArray[idx];
      [_dummyObjects addObjectsFromArray:[ta speedupClicked:sender]];
    }
  }
}

- (IBAction)helpClicked:(UIView *)sender {
  sender = [sender getAncestorInViewHierarchyOfType:[TimerCell class]];
  
  if (sender) {
    NSInteger idx = [self.timerCells indexOfObject:sender];
    TimerAction *ta = self.timerActionsArray[idx];
    [ta helpClicked];
    
    TimerCell *tc = (TimerCell *)sender;
    [tc updateForTimerAction:ta];
  }
}

@end
