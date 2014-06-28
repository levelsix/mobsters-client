
//
//  EvoViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/26/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "EvoViewController.h"
#import "cocos2d.h"
#import "GameState.h"
#import "Globals.h"
#import "MonsterTeamSlotView.h"
#import "MonsterPopUpViewController.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"

#define TABLE_CELL_WIDTH 112

@implementation EvoViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Evolution";
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  [self setupInventoryTable];
  
  self.middleView.frame = self.tableContainerView.frame;
  [self.tableContainerView.superview addSubview:self.middleView];
  
  UIView *oldBack = self.menuBackButton;
  [[NSBundle mainBundle] loadNibNamed:@"CustomNavBarButtons" owner:self options:nil];
  self.backButton = self.menuBackButton;
  self.menuBackButton = oldBack;
  
  self.menuBackLabel.text = @"Back";
  [self.menuBackMaskedButton remakeImage];
}

- (void) viewWillAppear:(BOOL)animated {
  [self reloadTableAnimated:NO];
  [self updateCurrentTeam];
  [self.bottomView updateForEvoItems];
  [self.bottomView displayScientists];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:HEAL_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:COMBINE_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:ENHANCE_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:MONSTER_SOLD_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(evoComplete) name:EVOLUTION_WAIT_COMPLETE_NOTIFICATION object:nil];
  
  GameState *gs = [GameState sharedGameState];
  if (!gs.userEvolution) {
    self.middleView.alpha = 0.f;
    self.tableContainerView.alpha = 1.f;
  } else {
    self.middleView.alpha = 1.f;
    self.tableContainerView.alpha = 0.f;
    
    [self.middleView updateForEvolution:gs.userEvolution];
  }
  
  self.updateTimer = [NSTimer timerWithTimeInterval:0.05f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  [self updateLabels];
}

- (void) viewDidAppear:(BOOL)animated {
  UIBarButtonItem *v = self.navigationItem.leftBarButtonItem;
  [v.customView.superview addSubview:self.backButton];
  self.backButton.frame = v.customView.frame;
  self.backButton.alpha = 0.f;
  self.menuBackButton.alpha = 1.f;
}

- (void) viewWillDisappear:(BOOL)animated {
  [self.backButton removeFromSuperview];
}

- (void) viewDidDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateLabels {
  [self.middleView updateTime];
}

- (void) updateCurrentTeam {
  GameState *gs = [GameState sharedGameState];
  for (MonsterTeamSlotContainerView *container in self.teamSlotsContainer.subviews) {
    [container.teamSlotView updateForEnhanceConfiguration:[gs myMonsterWithSlotNumber:container.tag]];
  }
}

- (void) evoComplete {
  [self waitTimeComplete];
  
  [UIView animateWithDuration:0.3f animations:^{
    self.middleView.alpha = 0.f;
    self.tableContainerView.alpha = 1.f;
  }];
  self.backButton.alpha = 0.f;
  self.menuBackButton.alpha = 1.f;
}

- (void) waitTimeComplete {
  [self reloadTableAnimated:YES];
  [self updateCurrentTeam];
  [self.bottomView updateForEvoItems];
}

#pragma mark - EasyTableViewDelegate and Methods

- (void)setupInventoryTable {
  self.inventoryTable = [[EasyTableView alloc] initWithFrame:self.tableContainerView.bounds numberOfColumns:0 ofWidth:TABLE_CELL_WIDTH];
  self.inventoryTable.delegate = self;
  self.inventoryTable.tableView.separatorColor = [UIColor clearColor];
  self.inventoryTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.tableContainerView addSubview:self.inventoryTable];
  
  [self.inventoryTable.tableView addSubview:self.leftHeaderUnderlay];
  self.inventoryTable.tableView.headerUnderlay = self.leftHeaderUnderlay;
  self.leftHeaderUnderlay.transform = CGAffineTransformMakeRotation(M_PI_2);
  [self easyTableView:self.inventoryTable scrolledToOffset:CGPointZero];
}

- (void) easyTableView:(EasyTableView *)easyTableView scrolledToOffset:(CGPoint)contentOffset {
  UITableView *table = easyTableView.tableView;
  // Have to do weird adjustments for rotated view
  self.leftHeaderUnderlay.center = ccp(table.frame.size.height/2, table.contentOffset.y+self.leftHeaderUnderlay.frame.size.height/2);
}

- (void) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *validMonsters = [NSMutableArray array];
  NSMutableArray *ready = [NSMutableArray array];
  NSMutableArray *missingCata = [NSMutableArray array];
  NSMutableArray *notReady = [NSMutableArray array];
  
  for (UserMonster *um in gs.myMonsters) {
    if (um.isAvailable && um.staticMonster.evolutionMonsterId) {
      [validMonsters addObject:um];
    }
  }
  
  [validMonsters sortUsingSelector:@selector(compare:)];
  
  while (validMonsters.count) {
    UserMonster *um = validMonsters[0];
    UserMonster *um2 = nil;
    UserMonster *cata = nil;
    int cataId = um.staticMonster.evolutionCatalystMonsterId;
    
    for (int i = 1; i < validMonsters.count; i++) {
      UserMonster *temp = validMonsters[i];
      if (!um2 && um.level >= um.staticMonster.maxLevel && temp.monsterId == um.monsterId && temp.level >= temp.staticMonster.maxLevel) {
        um2 = temp;
      } else if (temp.monsterId == cataId) {
        cata = temp;
      }
    }
    
    // Check if there is a cata within the already created evo items
    for (NSArray *arr in @[ready, missingCata, notReady]) {
      for (EvoItem *evo in arr) {
        if (evo.userMonster1.monsterId == cataId) {
          cata = evo.userMonster1;
        } else if (evo.userMonster2.monsterId == cataId) {
          cata = evo.userMonster2;
        }
      }
    }
    
    [validMonsters removeObject:um];
    [validMonsters removeObject:um2];
    EvoItem *evo = [[EvoItem alloc] initWithUserMonster:um andUserMonster:um2 catalystMonster:cata suggestedMonster:nil];
    if (um2 && cata) {
      [ready addObject:evo];
    } else if (um2 && !cata) {
      [missingCata addObject:evo];
    } else {
      [notReady addObject:evo];
    }
  }
  
  self.readyMonsters = ready;
  self.missingCataMonsters = missingCata;
  self.notReadyMonsters = notReady;
}

- (void) reloadTableAnimated:(BOOL)animated {
  NSArray *r = self.readyMonsters, *mc = self.missingCataMonsters, *nr = self.notReadyMonsters;
  NSMutableArray *remove = [NSMutableArray array], *add = [NSMutableArray array];
  
  [self reloadMonstersArray];
  
  if (animated) {
    [Globals calculateDifferencesBetweenOldArray:r newArray:self.readyMonsters removalIps:remove additionIps:add section:0];
    [Globals calculateDifferencesBetweenOldArray:mc newArray:self.missingCataMonsters removalIps:remove additionIps:add section:1];
    [Globals calculateDifferencesBetweenOldArray:nr newArray:self.notReadyMonsters removalIps:remove additionIps:add section:2];
    
    [self.inventoryTable.tableView beginUpdates];
    if (remove.count) {
      [self.inventoryTable.tableView deleteRowsAtIndexPaths:remove withRowAnimation:UITableViewRowAnimationFade];
    }
    if (add.count) {
      [self.inventoryTable.tableView insertRowsAtIndexPaths:add withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.inventoryTable.tableView endUpdates];
  } else {
    [self.inventoryTable reloadData];
  }
  [self easyTableView:self.inventoryTable scrolledToOffset:self.inventoryTable.contentOffset];
}

- (NSString *) easyTableView:(EasyTableView *)easyTableView stringForVerticalHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return @"Ready To Evolve";
  } else if (section == 1) {
    return @"Missing Scientist";
  } else if (section == 2) {
    return @"Not Ready";
  }
  return nil;
}

- (NSUInteger) numberOfSectionsInEasyTableView:(EasyTableView *)easyTableView {
  return 3;
}

- (NSArray *)arrayForSection:(NSInteger)section {
  if (section == 0) {
    return self.readyMonsters;
  } else if (section == 1) {
    return self.missingCataMonsters;
  } else if (section == 2) {
    return self.notReadyMonsters;
  }
  return nil;
}

- (NSUInteger) numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section {
  return [self arrayForSection:section].count;
}

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect withIndexPath:(NSIndexPath *)indexPath {
  [[NSBundle mainBundle] loadNibNamed:@"EvoCardCell" owner:self options:nil];
  return self.evoCardCell;
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(EvoCardCell *)view forIndexPath:(NSIndexPath *)indexPath {
  NSArray *arr = [self arrayForSection:indexPath.section];
  EvoItem *um = indexPath.row < arr.count ? [arr objectAtIndex:indexPath.row] : nil;
  [view updateForEvoItem:um];
}

- (IBAction)headerClicked:(id)sender {
  NSInteger section = [(UIView *)sender tag];
  [self.inventoryTable.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - EvoCardCellDelegate

- (void) infoClicked:(EvoCardCell *)cell {
  MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:cell.evoItem.userMonster1 allowSell:YES];
  UIViewController *parent = self.navigationController;
  mpvc.view.frame = parent.view.bounds;
  [parent.view addSubview:mpvc.view];
  [parent addChildViewController:mpvc];
}

- (void) cardClicked:(EvoCardCell *)cell {
  EvoItem *item = cell.evoItem;
  
  [self.middleView updateForEvoItem:item];
  self.curEvoItem = item;
  
  // Monster cards
  CGPoint orig1 = self.middleView.evoContainer1.center;
  CGPoint orig2 = self.middleView.evoContainer2.center;
  [self.view addSubview:self.middleView.evoContainer2];
  [self.view addSubview:self.middleView.evoContainer1];
  self.middleView.evoContainer1.center = [self.view convertPoint:cell.readyContainer1.center fromView:cell.readyContainer1.superview];
  self.middleView.evoContainer2.center = [self.view convertPoint:cell.readyContainer2.center fromView:cell.readyContainer2.superview];
  [UIView animateWithDuration:0.3f animations:^{
    self.middleView.alpha = 1.f;
    self.tableContainerView.alpha = 0.f;
    
    self.middleView.evoContainer1.center = [self.view convertPoint:orig1 fromView:self.middleView];
    self.middleView.evoContainer2.center = [self.view convertPoint:orig2 fromView:self.middleView];
  } completion:^(BOOL finished) {
    [self.middleView addSubview:self.middleView.evoContainer2];
    [self.middleView addSubview:self.middleView.evoContainer1];
    self.middleView.evoContainer1.center = orig1;
    self.middleView.evoContainer2.center = orig2;
  }];
  
  // Catalyst card
  if (item.catalystMonster) {
    EvoScientistView *sci = nil;
    int tag = item.catalystMonster.staticMonster.monsterElement;
    for (EvoScientistView *v in self.bottomView.scientistViews) {
      if (v.tag == tag) {
        sci = v;
      }
    }
    UIView *cata = [[UIView alloc] initWithFrame:CGRectZero];
    cata.frame = [self.view convertRect:sci.frame fromView:sci.superview];
    [self.view addSubview:cata];
    UIImageView *bgd = [[UIImageView alloc] initWithImage:sci.bgdIcon.image];
    UIImageView *main = [[UIImageView alloc] initWithImage:sci.monsterIcon.image];
    main.contentMode = sci.monsterIcon.contentMode;
    bgd.frame = [cata convertRect:sci.bgdIcon.frame fromView:sci.bgdIcon.superview];
    main.frame = [cata convertRect:sci.monsterIcon.frame fromView:sci.monsterIcon.superview];
    [cata addSubview:bgd];
    [cata addSubview:main];
    
    CGPoint origM = self.middleView.catalystContainer.center;
    self.middleView.catalystContainer.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    [self.view addSubview:self.middleView.catalystContainer];
    self.middleView.catalystContainer.center = [self.view convertPoint:sci.center fromView:sci.superview];
    self.middleView.catalystContainer.alpha = 0.f;
    [UIView animateWithDuration:0.3f animations:^{
      cata.center = [self.view convertPoint:origM fromView:self.middleView];
      
      self.middleView.catalystContainer.transform = CGAffineTransformIdentity;
      self.middleView.catalystContainer.center = [self.view convertPoint:origM fromView:self.middleView];
      
      cata.alpha = 0.f;
      self.middleView.catalystContainer.alpha = 1.f;
    } completion:^(BOOL finished) {
      [self.middleView insertSubview:self.middleView.catalystContainer atIndex:0];
      self.middleView.catalystContainer.center = origM;
      
      [cata removeFromSuperview];
    }];
  }
  
  if (!self.curEvoItem.userMonster2 || !self.curEvoItem.catalystMonster) {
    [self.bottomView displayInfoLabel:self.curEvoItem];
  }
  
  [UIView animateWithDuration:0.3f animations:^{
    self.backButton.alpha = 1.f;
    self.menuBackButton.alpha = 0.f;
  }];
}


#pragma mark - IBActions

- (IBAction)menuBackClicked:(id)sender {
  // The back button should just return to main screen if we are viewing something
  GameState *gs = [GameState sharedGameState];
  if (self.middleView.alpha > 0.f && !gs.userEvolution) {
    [UIView animateWithDuration:0.3f animations:^{
      self.middleView.alpha = 0.f;
      self.tableContainerView.alpha = 1.f;
    }];
    
    if (!self.curEvoItem.userMonster2 || !self.curEvoItem.catalystMonster) {
      [self.bottomView displayScientists];
    }
    
    [UIView animateWithDuration:0.3f animations:^{
      self.backButton.alpha = 0.f;
      self.menuBackButton.alpha = 1.f;
    }];
  } else {
    [super menuBackClicked:sender];
  }
}

- (IBAction)beginEvoClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  
  if (self.curEvoItem.userMonster2 && self.curEvoItem.catalystMonster) {
    int oilCost = self.curEvoItem.userMonster1.staticMonster.evolutionCost;
    
    if (gs.oil < oilCost) {
      [GenericPopupController displayExchangeForGemsViewWithResourceType:ResourceTypeOil amount:oilCost-gs.oil target:self selector:@selector(gemsConfirmed)];
    } else {
      [self beginEvo:NO];
    }
  }
}

- (void) gemsConfirmed {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int oilCost = self.curEvoItem.userMonster1.staticMonster.evolutionCost;
  int gemCost = [gl calculateGemConversionForResourceType:ResourceTypeOil amount:oilCost-gs.oil];
  
  if (gs.gold < gemCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [self beginEvo:YES];
  }
}

- (void) beginEvo:(BOOL)useGems {
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] evolveMonster:self.curEvoItem useGems:useGems];
  
  if (success) {
    GameState *gs = [GameState sharedGameState];
    [self.middleView updateForEvolution:gs.userEvolution];
    [self.bottomView updateForEvoItems];
    
    self.backButton.alpha = 0.f;
    self.menuBackButton.alpha = 1.f;
  }
}

- (IBAction)speedupEvoClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.userEvolution) {
    int timeLeft = gs.userEvolution.endTime.timeIntervalSinceNow;
    int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
    
    if (gs.gold < goldCost) {
      [GenericPopupController displayNotEnoughGemsView];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] finishEvolutionWithGems:YES withDelegate:self];
      
      self.middleView.speedupSpinner.hidden = NO;
      self.middleView.speedupCostLabel.superview.hidden = YES;
    }
  }
}

- (void) handleEvolutionFinishedResponseProto:(FullEvent *)fe {
  EvolutionFinishedResponseProto *proto = (EvolutionFinishedResponseProto *)fe.event;
  
  if (proto.status == EvolutionFinishedResponseProto_EvolutionFinishedStatusSuccess) {
    [self evoComplete];
    
    self.middleView.speedupSpinner.hidden = YES;
    self.middleView.speedupCostLabel.superview.hidden = NO;
  }
}

@end
