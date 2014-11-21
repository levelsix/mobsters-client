//
//  EvolveDetailsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "EvolveDetailsViewController.h"

#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"
#import "GameViewController.h"

@implementation EvolveDetailsViewController

- (id) initWithEvoItem:(EvoItem *)evoItem allowEvolution:(BOOL)allowEvolution {
  if ((self = [super init])) {
    self.evoItem = evoItem;
    _allowEvolution = allowEvolution;
  }
  return self;
}

- (id) initWithCurrentEvolution {
  GameState *gs = [GameState sharedGameState];
  return [self initWithEvoItem:gs.userEvolution.evoItem allowEvolution:YES];
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [self.middleView updateWithEvoItem:self.evoItem];
  
  [self updateButtonConfiguration];
  
  MonsterProto *mp = self.evoItem.userMonster1.staticMonster;
  MonsterProto *evo = self.evoItem.userMonster1.staticEvolutionMonster;
  self.title = [NSString stringWithFormat:@"Evolve %@ to %@", mp.monsterName, evo.monsterName];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:RECEIVED_CLAN_HELP_NOTIFICATION object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self.itemSelectViewController closeClicked:nil];
}

- (void) waitTimeComplete {
  GameState *gs = [GameState sharedGameState];
  if (!gs.userEvolution) {
    if (_allowEvolution) {
      // Waiting for evo to complete.. go back to chooser screen
      [self.itemSelectViewController closeClicked:nil];
      [self.parentViewController popViewControllerAnimated:YES];
    } else {
      _allowEvolution = YES;
    }
  }
}

#pragma mark - Updating views

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (gs.userEvolution && _allowEvolution) {
    int timeLeft = gs.userEvolution.endTime.timeIntervalSinceNow;
    int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    
    self.timeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    
    BOOL canHelp = [gs canAskForClanHelp] && [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeEvolve userDataUuid:gs.userEvolution.userMonsterUuid1] < 0;
    
    if (speedupCost > 0) {
      self.gemCostLabel.text = [Globals commafyNumber:speedupCost];
      [Globals adjustViewForCentering:self.gemCostLabel.superview withLabel:self.gemCostLabel];
      
      self.gemCostLabel.superview.hidden = NO;
      self.speedupIcon.hidden = NO;
      self.freeLabel.hidden = YES;
      
      self.helpButtonView.hidden = !canHelp;
    } else {
      self.gemCostLabel.superview.hidden = YES;
      self.speedupIcon.hidden = YES;
      self.freeLabel.hidden = NO;
      self.helpButtonView.hidden = YES;
    }
  }
}

- (void) updateButtonConfiguration {
  self.oilCostLabel.text = [Globals commafyNumber:self.evoItem.userMonster1.staticMonster.evolutionCost];
  [Globals adjustViewForCentering:self.oilCostLabel.superview withLabel:self.oilCostLabel];
  
  self.timeLabel.text = [Globals convertTimeToLongString:self.evoItem.userMonster1.staticMonster.minutesToEvolve*60];
  
  [self.greyscaleView removeFromSuperview];
  if (![self.evoItem isReadyForEvolution]) {
    UIImage *grey = [Globals greyScaleImageWithBaseImage:[Globals snapShotView:self.oilButtonView]];
    self.greyscaleView = [[UIImageView alloc] initWithImage:grey];
    self.greyscaleView.userInteractionEnabled = YES;
    [self.oilButtonView addSubview:self.greyscaleView];
  }
  
  self.oilButtonView.hidden = NO;
  self.gemButtonView.hidden = YES;
  self.descriptionLabel.hidden = NO;
  self.helpButtonView.hidden = YES;
  
  [self createAttributedLabelString];
  
  if (_allowEvolution) {
    GameState *gs = [GameState sharedGameState];
    if (gs.userEvolution) {
      [self updateLabels];
      
      self.oilButtonView.hidden = YES;
      self.gemButtonView.hidden = NO;
      self.descriptionLabel.hidden = YES;
    }
  }
}

- (void) createAttributedLabelString {
  NSMutableArray *strs = [NSMutableArray array];
  
  UIColor *greenColor = [UIColor colorWithRed:48/255.f green:144/255.f blue:0.f alpha:1.f];
  UIColor *redColor = [UIColor colorWithRed:219/255.f green:1/255.f blue:0.f alpha:1.f];
  
  MonsterProto *mp = self.evoItem.userMonster1.staticMonster;
  MonsterProto *cata = self.evoItem.userMonster1.staticEvolutionCatalystMonster;
  MonsterProto *evo = self.evoItem.userMonster1.staticEvolutionMonster;
  
  if ([self.evoItem isReadyForEvolution]) {
    NSString *str = [NSString stringWithFormat:@"You have all the pieces to create %@:\n%@ L%d, another %@, and a %@ (Evo %d).",
                     evo.monsterName, mp.monsterName, mp.maxLevel, mp.monsterName, cata.monsterName, cata.evolutionLevel];
    self.descriptionLabel.text = str;
    self.descriptionLabel.highlighted = YES;
    self.descriptionLabel.highlightedTextColor = greenColor;
  } else {
    UIColor *color;
    NSString *str = [NSString stringWithFormat:@"To create %@, you need to combine a ", evo.monsterName];
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str];
    [strs addObject:attr];
    
    str = [NSString stringWithFormat:@"%@ L%d", mp.monsterName, mp.maxLevel];
    color = self.evoItem.userMonster1.level >= mp.maxLevel ? greenColor : redColor;
    attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName: color}];
    [strs addObject:attr];
    
    attr = [[NSAttributedString alloc] initWithString:@", another "];
    [strs addObject:attr];
    
    color = self.evoItem.userMonster2 ? greenColor : redColor;
    attr = [[NSAttributedString alloc] initWithString:mp.monsterName attributes:@{NSForegroundColorAttributeName: color}];
    [strs addObject:attr];
    
    attr = [[NSAttributedString alloc] initWithString:@", and a "];
    [strs addObject:attr];
    
    color = self.evoItem.catalystMonster ? greenColor : redColor;
    str = [NSString stringWithFormat:@"%@ (Evo %d)", cata.monsterName, cata.evolutionLevel];
    attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName: color}];
    [strs addObject:attr];
    
    attr = [[NSAttributedString alloc] initWithString:@"."];
    [strs addObject:attr];
    
    NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] init];
    for (NSAttributedString *s in strs) {
      [labelText appendAttributedString:s];
    }
    
    self.descriptionLabel.attributedText = labelText;
  }
}

#pragma mark - IBActions

- (IBAction)evolveClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  
  if (!_allowEvolution) {
    [Globals addAlertNotification:[NSString stringWithFormat:@"Oops, you are already evolving a different %@.", MONSTER_NAME]];
  } else if (![self.evoItem isReadyForEvolution]) {
    [Globals addAlertNotification:[NSString stringWithFormat:@"Oops, this %@ is not yet ready to evolve.", MONSTER_NAME]];
  } else  {
    int oilCost = self.evoItem.userMonster1.staticMonster.evolutionCost;
    
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
  
  int oilCost = self.evoItem.userMonster1.staticMonster.evolutionCost;
  int gemCost = [gl calculateGemConversionForResourceType:ResourceTypeOil amount:oilCost-gs.oil];
  
  if (gs.gems < gemCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [self beginEvo:YES];
  }
}

- (void) beginEvo:(BOOL)useGems {
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] evolveMonster:self.evoItem useGems:useGems delegate:self];
  
  if (success) {
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    self.oilLabelsView.hidden = YES;
  }
}

- (void) handleEvolveMonsterResponseProto:(FullEvent *)fe {
  self.spinner.hidden = YES;
  self.gemLabelsView.hidden = NO;
  self.oilLabelsView.hidden = NO;
  
  CATransition *animation = [CATransition animation];
  animation.type = kCATransitionFade;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [self.bottomView.layer addAnimation:animation forKey:@"fade"];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:EVOLUTION_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  
  [self updateButtonConfiguration];
}

- (IBAction)helpClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  if (gs.userEvolution) {
    [[OutgoingEventController sharedOutgoingEventController] solicitEvolveHelp:gs.userEvolution];
    [self updateLabels];
  }
}

- (IBAction)speedupClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.userEvolution) {
    int timeLeft = gs.userEvolution.endTime.timeIntervalSinceNow;
    int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    
    if (goldCost <= 0) {
      [self speedupEvolution];
    } else {
      ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
      if (svc) {
        SpeedupItemsFiller *sif = [[SpeedupItemsFiller alloc] init];
        sif.delegate = self;
        svc.delegate = sif;
        self.speedupItemsFiller = sif;
        self.itemSelectViewController = svc;
        
        GameViewController *gvc = [GameViewController baseController];
        svc.view.frame = gvc.view.bounds;
        [gvc addChildViewController:svc];
        [gvc.view addSubview:svc.view];
      }
    }
  }
}

- (void) speedupEvolution {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  [self.itemSelectViewController closeClicked:nil];
  
  int timeLeft = gs.userEvolution.endTime.timeIntervalSinceNow;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  if (gs.gems < goldCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] finishEvolutionWithGems:YES withDelegate:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EVOLUTION_CHANGED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
    
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    self.gemLabelsView.hidden = YES;
  }
}

- (void) handleEvolutionFinishedResponseProto:(FullEvent *)fe {
  EvolutionFinishedResponseProto *proto = (EvolutionFinishedResponseProto *)fe.event;
  
  if (proto.status == EvolutionFinishedResponseProto_EvolutionFinishedStatusSuccess) {
    [self.parentViewController popViewControllerAnimated:YES];
    
    self.spinner.hidden = YES;
    self.gemLabelsView.hidden = NO;
    self.oilLabelsView.hidden = NO;
  }
}

#pragma mark - Speedup Items Filler

- (int) numGemsForTotalSpeedup {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = gs.userEvolution.endTime.timeIntervalSinceNow;
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  return gemCost;
}

- (void) speedupItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController *)viewController {
  if ([itemObject isKindOfClass:[GemsItemObject class]]) {
    [self speedupEvolution];
  } else if ([itemObject isKindOfClass:[UserItem class]]) {
    // Apply items
    GameState *gs = [GameState sharedGameState];
    UserItem *ui = (UserItem *)itemObject;
    ItemProto *ip = [gs itemForId:ui.itemId];
    UserEvolution *ue = gs.userEvolution;
    
    if (ip.itemType == ItemTypeSpeedUp) {
      [[OutgoingEventController sharedOutgoingEventController] tradeItemForSpeedup:ui.itemId userEvolution:ue];
      
      [self updateLabels];
    }
    
    int timeLeft = ue.endTime.timeIntervalSinceNow;
    if (timeLeft > 0) {
      [viewController reloadDataAnimated:YES];
    }
  }
}

- (int) timeLeftForSpeedup {
  GameState *gs = [GameState sharedGameState];
  int timeLeft = gs.userEvolution.endTime.timeIntervalSinceNow;
  return timeLeft;
}

- (int) totalSecondsRequired {
  return self.evoItem.userMonster1.staticMonster.minutesToEvolve*60;
}

- (void) itemSelectClosed:(id)viewController {
  self.itemSelectViewController = nil;
  self.speedupItemsFiller = nil;
}

@end
