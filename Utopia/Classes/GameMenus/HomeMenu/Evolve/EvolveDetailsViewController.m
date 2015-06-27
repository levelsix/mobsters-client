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
  Globals *gl = [Globals sharedGlobals];
  MonsterProto *mp = self.evoItem.userMonster1.staticMonster;
  
  self.oilCostLabel.text = [Globals commafyNumber:mp.evolutionCost];
  [Globals adjustViewForCentering:self.oilCostLabel.superview withLabel:self.oilCostLabel];
  
  self.timeLabel.text = [Globals convertTimeToLongString:mp.minutesToEvolve*60];
  
  UserMonster *um = [[UserMonster alloc] init];
  um.monsterId = mp.evolutionMonsterId;
  um.level = 1;
  um.isComplete = YES;
  
  int evoStrength = [gl calculateStrengthForMonster:um];
  
  um.monsterId = mp.monsterId;
  um.level = mp.maxLevel;
  
  int newStrength = [gl calculateStrengthForMonster:um];
  
  self.strengthLabel.text = [NSString stringWithFormat:@"+%d", evoStrength-newStrength];
  
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
  UIFont *boldFont = [UIFont fontWithName:@"GothamBlack" size:self.descriptionLabel.font.pointSize];
  
  MonsterProto *mp = self.evoItem.userMonster1.staticMonster;
  MonsterProto *cata = self.evoItem.userMonster1.staticEvolutionCatalystMonster;
//  MonsterProto *evo = self.evoItem.userMonster1.staticEvolutionMonster;
  
  NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
  style.lineSpacing = 2.f;
  
//  if ([self.evoItem isReadyForEvolution]) {
//    
//    NSString *str = [NSString stringWithFormat:@"You can create %@:%@ L%d, another %@, and a %@ (Evo %d).",
//                     evo.monsterName, mp.monsterName, mp.maxLevel, mp.monsterName, cata.monsterName, cata.evolutionLevel];
//    NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSParagraphStyleAttributeName : style}];
//    self.descriptionLabel.attributedText = labelText;
//    
//    self.descriptionLabel.highlighted = YES;
//    self.descriptionLabel.highlightedTextColor = greenColor;
//  
//  } else {
  
    UIColor *color;
    NSString *str = [NSString stringWithFormat:@"To Evolve, you need a "];
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str];
    [strs addObject:attr];
    
    str = [NSString stringWithFormat:@"%@ L%d", mp.monsterName, mp.maxLevel];
    color = self.evoItem.userMonster1.level >= mp.maxLevel ? greenColor : redColor;
    attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: boldFont}];
    [strs addObject:attr];
    
    attr = [[NSAttributedString alloc] initWithString:@", another "];
    [strs addObject:attr];
    
    color = self.evoItem.userMonster2 ? greenColor : redColor;
    attr = [[NSAttributedString alloc] initWithString:mp.monsterName attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: boldFont}];
    [strs addObject:attr];
    
    attr = [[NSAttributedString alloc] initWithString:@", and a "];
    [strs addObject:attr];
    
    color = self.evoItem.catalystMonster ? greenColor : redColor;
    str = [NSString stringWithFormat:@"%@ (Evo %d)", cata.monsterName, cata.evolutionLevel];
    attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: boldFont}];
    [strs addObject:attr];
    
    attr = [[NSAttributedString alloc] initWithString:@"."];
    [strs addObject:attr];
    
    NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] init];
    for (NSAttributedString *s in strs) {
      [labelText appendAttributedString:s];
    }
    [labelText addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, labelText.string.length)];
    
    self.descriptionLabel.attributedText = labelText;
  
//  }
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
      ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
      if (svc) {
        ResourceItemsFiller *rif = [[ResourceItemsFiller alloc] initWithResourceType:ResourceTypeOil requiredAmount:oilCost shouldAccumulate:YES];
        rif.delegate = self;
        svc.delegate = rif;
        self.itemSelectViewController = svc;
        self.resourceItemsFiller = rif;
        
        GameViewController *gvc = [GameViewController baseController];
        svc.view.frame = gvc.view.bounds;
        [gvc addChildViewController:svc];
        [gvc.view addSubview:svc.view];
        
        if (sender == nil)
        {
          [svc showCenteredOnScreen];
        }
        else
        {
          if ([sender isKindOfClass:[UIButton class]]) // Evolve mobster
          {
            UIButton* invokingButton = (UIButton*)sender;
            [svc showAnchoredToInvokingView:invokingButton withDirection:ViewAnchoringPreferTopPlacement inkovingViewImage:invokingButton.currentImage];
          }
        }
      }
    } else {
      [self beginEvoWithItemsDict:nil useGems:NO];
    }
  }
}

- (void) evolveWithItemsDict:(NSDictionary *)itemIdsToQuantity {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  BOOL allowGems = [itemIdsToQuantity[@0] boolValue];
  
  int cost = self.evoItem.userMonster1.staticMonster.evolutionCost;
  ResourceType resType = ResourceTypeOil;
  
  int curAmount = [gl calculateTotalResourcesForResourceType:resType itemIdsToQuantity:itemIdsToQuantity];
  int gemCost = [gl calculateGemConversionForResourceType:resType amount:cost-curAmount];
  
  if (allowGems && gemCost > gs.gems) {
    [GenericPopupController displayNotEnoughGemsView];
  } else if (allowGems || cost <= curAmount) {
    [self beginEvoWithItemsDict:itemIdsToQuantity useGems:allowGems];
  }
}

- (void) beginEvoWithItemsDict:(NSDictionary *)itemIdsToQuantity useGems:(BOOL)useGems {
  [[OutgoingEventController sharedOutgoingEventController] tradeItemIdsForResources:itemIdsToQuantity];
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
        SpeedupItemsFiller *sif = [[SpeedupItemsFiller alloc] initWithGameActionType:GameActionTypeEvolve];
        sif.delegate = self;
        svc.delegate = sif;
        self.speedupItemsFiller = sif;
        self.itemSelectViewController = svc;
        
        GameViewController *gvc = [GameViewController baseController];
        svc.view.frame = gvc.view.bounds;
        [gvc addChildViewController:svc];
        [gvc.view addSubview:svc.view];
        
        if (sender == nil)
        {
          [svc showCenteredOnScreen];
        }
        else
        {
          if ([sender isKindOfClass:[TimerCell class]]) // Invoked from TimerAction
          {
            UIButton* invokingButton = ((TimerCell*)sender).speedupButton;
            const CGPoint invokingViewAbsolutePosition = [Globals convertPointToWindowCoordinates:invokingButton.frame.origin fromViewCoordinates:invokingButton.superview];
            [svc showAnchoredToInvokingView:invokingButton
                              withDirection:invokingViewAbsolutePosition.y < [Globals screenSize].height * .25f ? ViewAnchoringPreferBottomPlacement : ViewAnchoringPreferLeftPlacement
                          inkovingViewImage:[invokingButton backgroundImageForState:invokingButton.state]];
          }
          else if ([sender isKindOfClass:[UIButton class]]) // Speed up evolving mobster
          {
            UIButton* invokingButton = (UIButton*)sender;
            [svc showAnchoredToInvokingView:invokingButton
                              withDirection:ViewAnchoringPreferTopPlacement
                          inkovingViewImage:[invokingButton backgroundImageForState:invokingButton.state]];
          }
        }
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
  
  if (proto.status == ResponseStatusSuccess) {
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

- (void) resourceItemsUsed:(NSDictionary *)itemUsages {
  [self evolveWithItemsDict:itemUsages];
}

- (void) itemSelectClosed:(id)viewController {
  self.itemSelectViewController = nil;
  self.speedupItemsFiller = nil;
  self.resourceItemsFiller = nil;
}

@end
