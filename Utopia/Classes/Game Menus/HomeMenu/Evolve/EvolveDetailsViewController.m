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
}

- (void) waitTimeComplete {
  GameState *gs = [GameState sharedGameState];
  if (!gs.userEnhancement) {
    if (_allowEvolution) {
      // Waiting for evo to complete.. go back to chooser screen
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
    int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
    
    self.timeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    
    self.gemCostLabel.text = [Globals commafyNumber:speedupCost];
    [Globals adjustViewForCentering:self.gemCostLabel.superview withLabel:self.gemCostLabel];
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
    NSString *str = [NSString stringWithFormat:@"You have all the pieces to create %@:\n%@ L%d, another %@ %d, and a %@ (Evo %d).",
                     evo.monsterName, mp.monsterName, mp.maxLevel, mp.monsterName, mp.maxLevel, cata.monsterName, cata.evolutionLevel];
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
    
    color = self.evoItem.userMonster2.level >= mp.maxLevel ? greenColor : redColor;
    attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName: color}];
    [strs addObject:attr];
    
    attr = [[NSAttributedString alloc] initWithString:@", and a "];
    [strs addObject:attr];
    
    color = self.evoItem.catalystMonster.level >= cata.maxLevel ? greenColor : redColor;
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
    [Globals addAlertNotification:@"Oops, you are already evolving a different mobster."];
  } else if (![self.evoItem isReadyForEvolution]) {
    [Globals addAlertNotification:@"Oops, this mobster is not yet ready to evolve."];
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
  
  if (gs.gold < gemCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [self beginEvo:YES];
  }
}

- (void) beginEvo:(BOOL)useGems {
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] evolveMonster:self.evoItem useGems:useGems];
  
  if (success) {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.bottomView.layer addAnimation:animation forKey:@"fade"];
    
    [self updateButtonConfiguration];
  }
}

- (IBAction)speedupClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.userEvolution) {
    int timeLeft = gs.userEvolution.endTime.timeIntervalSinceNow;
    int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
    
    if (gs.gold < goldCost) {
      [GenericPopupController displayNotEnoughGemsView];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] finishEvolutionWithGems:YES withDelegate:self];
      
      self.spinner.hidden = NO;
      [self.spinner startAnimating];
      self.gemLabelsView.hidden = YES;
    }
  }
}

- (void) handleEvolutionFinishedResponseProto:(FullEvent *)fe {
  EvolutionFinishedResponseProto *proto = (EvolutionFinishedResponseProto *)fe.event;
  
  if (proto.status == EvolutionFinishedResponseProto_EvolutionFinishedStatusSuccess) {
    [self.parentViewController popViewControllerAnimated:YES];
    
    self.spinner.hidden = YES;
    self.gemLabelsView.hidden = NO;
  }
}

@end
