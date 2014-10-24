//
//  UpgradeViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "UpgradeViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"
#import "GameViewController.h"

@implementation UpgradePrereqView

- (void) updateForPrereq:(PrereqProto *)pre isComplete:(BOOL)isComplete {
  self.prereqLabel.text = [pre prereqString];
  
  self.checkIcon.highlighted = !isComplete;
  self.prereqLabel.highlighted = !isComplete;
  self.goButtonView.hidden = isComplete;
}

- (IBAction)goClicked:(id)sender {
  [self.delegate goClicked:self];
}

@end

@implementation UpgradeBuildingMenu

- (void) awakeFromNib {
  [self.statBarView1.superview addSubview:self.cityHallUnlocksView];
}

- (void) loadForUserStruct:(UserStruct *)us {
  Globals *gl = [Globals sharedGlobals];
  
  if (us == nil) {
    return;
  }
  
  id<StaticStructure> curSS = us.staticStruct;
  id<StaticStructure> nextSS = us.staticStructForNextLevel;
  id<StaticStructure> maxSS = us.maxStaticStruct;
  if (curSS == maxSS) {
    nextSS = maxSS;
  }
  
  self.nameLabel.text = curSS.structInfo.name;
  self.upgradeTimeLabel.text = curSS != nextSS ? [[Globals convertTimeToMediumString:nextSS.structInfo.minutesToBuild*60] uppercaseString] : @"N/A";
  
  // We want to download the image and then adjust size accordingly (only shrink images that are too big. leave small ones alone).
  // Put our own spinner in for now
  UIActivityIndicatorView *iv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  [iv startAnimating];
  iv.center = self.structIcon.center;
  [self.structIcon.superview addSubview:iv];
  
  NSString *imgName = nextSS.structInfo.imgName;
  [Globals checkAndLoadFile:imgName useiPhone6Prefix:NO completion:^(BOOL success) {
    if (success) {
      self.structIcon.image = [Globals imageNamed:imgName];
      
      CGSize s = self.structIcon.image.size;
      if (s.height < self.structIcon.height && s.width < self.structIcon.width) {
        CGPoint center = self.structIcon.center;
        self.structIcon.size = s;
        self.structIcon.center = center;
      }
    }
    
    [iv removeFromSuperview];
  }];
  
  // Button view
  BOOL isOil = nextSS.structInfo.buildResourceType == ResourceTypeOil;
  self.upgradeCashLabel.text = curSS != nextSS ? [Globals commafyNumber:nextSS.structInfo.buildCost] : @"N/A";
  self.upgradeOilLabel.text = curSS != nextSS ? [Globals commafyNumber:nextSS.structInfo.buildCost] : @"N/A";
  [Globals adjustViewForCentering:self.upgradeOilLabel.superview withLabel:self.upgradeOilLabel];
  [Globals adjustViewForCentering:self.upgradeCashLabel.superview withLabel:self.upgradeCashLabel];
  self.oilButtonView.hidden = !isOil;
  self.cashButtonView.hidden = isOil;
  
  // Town hall too low
  
  NSArray *allPrereqs = [us allPrerequisites];
  for (int i = 0; i < self.prereqViews.count; i++) {
    UpgradePrereqView *preView = self.prereqViews[i];
    
    if (i < allPrereqs.count) {
      PrereqProto *pre = allPrereqs[i];
      BOOL isComplete = [gl isPrerequisiteComplete:pre];
      [preView updateForPrereq:pre isComplete:isComplete];
    } else {
      preView.hidden = YES;
    }
  }
  
  NSArray *incomplete = [us incompletePrerequisites];
  int numIncomplete = (int)incomplete.count;
  if (numIncomplete) {
    UIImage *grey = [Globals imageNamed:@"greymenuoption.png"];
    [self.oilButton setImage:grey forState:UIControlStateNormal];
    [self.cashButton setImage:grey forState:UIControlStateNormal];
    
    self.oilIcon.image = [Globals greyScaleImageWithBaseImage:self.oilIcon.image];
    self.cashIcon.image = [Globals greyScaleImageWithBaseImage:self.oilIcon.image];
    
    self.upgradeCashLabel.textColor = [UIColor colorWithWhite:0.5f alpha:1.f];
    self.upgradeCashLabel.shadowColor = [UIColor colorWithWhite:1.f alpha:0.25];
    self.upgradeOilLabel.textColor = [UIColor colorWithWhite:0.5f alpha:1.f];
    self.upgradeOilLabel.shadowColor = [UIColor colorWithWhite:1.f alpha:0.25];
    
    self.readyLabel.text = @"Woops!";
    self.readySubLabel.text = [NSString stringWithFormat:@"You are missing %d requirement%@ to upgrade.", numIncomplete, numIncomplete == 1 ? @"" : @"s"];
    
    self.bottomBgdView.highlighted = YES;
    self.checkIcon.highlighted = YES;
    self.readyLabel.highlighted = YES;
    self.readySubLabel.highlighted = YES;
  }
  
  if (nextSS.structInfo.structType != StructureInfoProto_StructTypeTownHall) {
    [self loadStatBarsForUserStruct:us];
    self.cityHallUnlocksView.hidden = YES;
  } else {
    [self loadCityHallUnlocksViewForUserStruct:us];
    [self.statBarView1 removeFromSuperview];
    [self.statBarView2 removeFromSuperview];
  }
}

- (NSArray *) buildingsThatChangedInQuantityWithCurTH:(TownHallProto *)curTh nextTh:(TownHallProto *)nextTh {
  NSMutableArray *arr = [NSMutableArray array];
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  for (id<StaticStructure> ss in gs.staticStructs.allValues) {
    StructureInfoProto *sip = ss.structInfo;
    if (!sip.predecessorStructId) {
      int before = [gl calculateMaxQuantityOfStructId:sip.structId withTownHall:curTh];
      int after = [gl calculateMaxQuantityOfStructId:sip.structId withTownHall:nextTh];
      
      if (before < after) {
        [arr addObject:sip];
      }
    } else {
      NSArray *prereqs = [gs prerequisitesForGameType:GameTypeStructure gameEntityId:sip.structId];
      BOOL unlocks = NO;
      
      for (PrereqProto *pp in prereqs) {
        if (pp.prereqGameType == GameTypeStructure && pp.prereqGameEntityId == nextTh.structInfo.structId) {
          unlocks = YES;
        }
      }
      
      if (unlocks) {
        [arr addObject:sip];
      }
    }
  }
  
  NSMutableArray *toRemove = [NSMutableArray array];
  for (StructureInfoProto *sip in arr) {
    StructureInfoProto *check = sip;
    while (check.predecessorStructId) {
      check = [[gs structWithId:check.predecessorStructId] structInfo];
      if ([arr containsObject:check]) {
        [toRemove addObject:check];
      }
    }
  }
  [arr removeObjectsInArray:toRemove];
  
  return arr;
}

#define UNLOCK_VIEW_SPACING 7
#define NUM_PER_ROW 4

- (void) loadCityHallUnlocksViewForUserStruct:(UserStruct *)us {
  Globals *gl = [Globals sharedGlobals];
  TownHallProto *curSS = (TownHallProto *)us.staticStruct;
  TownHallProto *nextSS = (TownHallProto *)us.staticStructForNextLevel;
  
  self.cityHallUnlocksLabel.text = [NSString stringWithFormat:@"Level %d %@ Unlocks", curSS.structInfo.level+1, curSS.structInfo.name];
  
  // Find new buildings, then find buildings that increase in quantity, then level
  NSMutableArray *unlockViews = [NSMutableArray array];
  
  NSArray *changedQuant = [self buildingsThatChangedInQuantityWithCurTH:curSS nextTh:nextSS];
  for (StructureInfoProto *sip in changedQuant) {
    int before = [gl calculateMaxQuantityOfStructId:sip.structId withTownHall:curSS];
    if (sip.level == 1 && before == 0) {
      [unlockViews addObject:[self unlockViewWithImageName:sip.imgName text:@"NEW!" useBigTextBgd:YES]];
    }
  }
  for (StructureInfoProto *sip in changedQuant) {
    int before = [gl calculateMaxQuantityOfStructId:sip.structId withTownHall:curSS];
    int after = [gl calculateMaxQuantityOfStructId:sip.structId withTownHall:nextSS];
    if (sip.level == 1 && before != 0) {
      [unlockViews addObject:[self unlockViewWithImageName:sip.imgName text:[NSString stringWithFormat:@"x%d", after-before] useBigTextBgd:NO]];
    }
  }
  for (StructureInfoProto *sip in changedQuant) {
    if (sip.level > 1) {
      [unlockViews addObject:[self unlockViewWithImageName:sip.imgName text:[NSString stringWithFormat:@"LVL %d", sip.level] useBigTextBgd:YES]];
    }
  }
  
  int maxY = 0;
  for (int i = 0; i < unlockViews.count; i++) {
    UIView *v = unlockViews[i];
    float x = (i%NUM_PER_ROW)*(v.frame.size.width+UNLOCK_VIEW_SPACING)+v.frame.size.width/2;
    float y = (i/NUM_PER_ROW)*(v.frame.size.height+UNLOCK_VIEW_SPACING)+v.frame.size.height/2;
    v.center = ccp(x, y);
    
    [self.cityHallUnlocksScrollView addSubview:v];
    
    maxY = y+v.frame.size.height/2+UNLOCK_VIEW_SPACING;
  }
  
  self.cityHallUnlocksScrollView.contentSize = CGSizeMake(self.cityHallUnlocksScrollView.frame.size.width, maxY);
}

- (UIView *) unlockViewWithImageName:(NSString *)imgName text:(NSString *)text useBigTextBgd:(BOOL)bigTextBgd {
  [[NSBundle mainBundle] loadNibNamed:@"UpgradeUnlockView" owner:self options:nil];
  
  self.nibUnlocksLabelBgd.highlighted = !bigTextBgd;
  [Globals imageNamed:imgName withView:self.nibUnlocksStructIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  self.nibUnlocksLabel.text = text;
  
  UIImage *img = bigTextBgd ? self.nibUnlocksLabelBgd.image : self.nibUnlocksLabelBgd.highlightedImage;
  self.nibUnlocksLabel.center = ccp(self.nibUnlocksLabelBgd.frame.origin.x+img.size.width/2, self.nibUnlocksLabel.center.y);
  
  return self.nibUnlocksView;
}

- (void) loadStatBarsForUserStruct:(UserStruct *)us {
  id<StaticStructure> curSS = us.staticStruct;
  id<StaticStructure> nextSS = us.staticStructForNextLevel;
  id<StaticStructure> maxSS = us.maxStaticStruct;
  if (curSS == maxSS) {
    nextSS = maxSS;
  }
  
  // The stat bars
  StructureInfoProto_StructType structType = nextSS.structInfo.structType;
  BOOL requiresTwoBars = NO;
  BOOL showsCashSymbol1 = NO, showsCashSymbol2 = NO;
  BOOL useSqrt1 = NO, useSqrt2 = NO;
  BOOL usePow1 = NO, usePow2 = NO;
  float curStat1 = 0, newStat1 = 0, maxStat1 = 0;
  float curStat2 = 0, newStat2 = 0, maxStat2 = 0;
  NSString *statName1 = nil, *statName2 = nil;
  NSString *statString1 = nil, *statString2 = nil;
  NSString *suffix1 = @"", *suffix2 = @"";
  if (structType == StructureInfoProto_StructTypeResourceGenerator) {
    ResourceGeneratorProto *cur = (ResourceGeneratorProto *)curSS;
    ResourceGeneratorProto *next = (ResourceGeneratorProto *)nextSS;
    ResourceGeneratorProto *max = (ResourceGeneratorProto *)maxSS;
    
    requiresTwoBars = YES;
    
    curStat1 = cur.productionRate;
    newStat1 = next.productionRate;
    maxStat1 = max.productionRate;
    statName1 = @"Rate:";
    suffix1 = @" Per Hour";
    
    curStat2 = cur.capacity;
    newStat2 = next.capacity;
    maxStat2 = max.capacity;
    statName2 = @"Capacity:";
    
    useSqrt2 = YES;
    showsCashSymbol1 = showsCashSymbol2 = (cur.resourceType == ResourceTypeCash);
  } else if (structType == StructureInfoProto_StructTypeResourceStorage) {
    ResourceStorageProto *cur = (ResourceStorageProto *)curSS;
    ResourceStorageProto *next = (ResourceStorageProto *)nextSS;
    ResourceStorageProto *max = (ResourceStorageProto *)maxSS;
    
    curStat1 = cur.capacity;
    newStat1 = next.capacity;
    maxStat1 = max.capacity;
    statName1 = @"Capacity:";
    
    useSqrt1 = YES;
    showsCashSymbol1 = (cur.resourceType == ResourceTypeCash);
  } else if (structType == StructureInfoProto_StructTypeHospital) {
    HospitalProto *cur = (HospitalProto *)curSS;
    HospitalProto *next = (HospitalProto *)nextSS;
    HospitalProto *max = (HospitalProto *)maxSS;
    
    requiresTwoBars = YES;
    
    curStat1 = cur.queueSize;
    newStat1 = next.queueSize;
    maxStat1 = max.queueSize;
    statName1 = @"Queue Size:";
    
    curStat2 = cur.healthPerSecond;
    newStat2 = next.healthPerSecond;
    maxStat2 = max.healthPerSecond;
    statName2 = @"Rate:";
    suffix2 = @" Health Per Sec";
    
    usePow2 = YES;
  } else if (structType == StructureInfoProto_StructTypeLab) {
    LabProto *cur = (LabProto *)curSS;
    LabProto *next = (LabProto *)nextSS;
    LabProto *max = (LabProto *)maxSS;
    
    curStat1 = cur.queueSize;
    newStat1 = next.queueSize;
    maxStat1 = max.queueSize;
    statName1 = @"Queue Size:";
    
    requiresTwoBars = YES;
    
    curStat2 = roundf(cur.pointsMultiplier*100);
    newStat2 = roundf(next.pointsMultiplier*100);
    maxStat2 = roundf(max.pointsMultiplier*100);
    statName2 = @"Multiplier:";
    suffix2 = @"%";
  } else if (structType == StructureInfoProto_StructTypeResidence) {
    ResidenceProto *cur = (ResidenceProto *)curSS;
    ResidenceProto *next = (ResidenceProto *)nextSS;
    ResidenceProto *max = (ResidenceProto *)maxSS;
    
    curStat1 = cur.numMonsterSlots;
    newStat1 = next.numMonsterSlots;
    maxStat1 = max.numMonsterSlots;
    statName1 = @"Slots:";
  } else if (structType == StructureInfoProto_StructTypeMiniJob) {
    MiniJobCenterProto *cur = (MiniJobCenterProto *)curSS;
    MiniJobCenterProto *next = (MiniJobCenterProto *)nextSS;
    MiniJobCenterProto *max = (MiniJobCenterProto *)maxSS;
    
    curStat1 = cur.structInfo.level;
    newStat1 = next.structInfo.level;
    maxStat1 = max.structInfo.level;
    
    statName1 = @"Reward Tier:";
  } else if (structType == StructureInfoProto_StructTypeTeamCenter) {
    TeamCenterProto *cur = (TeamCenterProto *)curSS;
    TeamCenterProto *next = (TeamCenterProto *)nextSS;
    TeamCenterProto *max = (TeamCenterProto *)maxSS;
    
    curStat1 = cur.teamCostLimit;
    newStat1 = next.teamCostLimit;
    maxStat1 = max.teamCostLimit;
    
    statName1 = @"Team Power:";
  } else if (structType == StructureInfoProto_StructTypeClan) {
    ClanHouseProto *cur = (ClanHouseProto *)curSS;
    ClanHouseProto *next = (ClanHouseProto *)nextSS;
    ClanHouseProto *max = (ClanHouseProto *)maxSS;
    
    curStat1 = cur.maxHelpersPerSolicitation;
    newStat1 = next.maxHelpersPerSolicitation;
    maxStat1 = max.maxHelpersPerSolicitation;
    
    statName1 = @"Help Limit:";
  } else if (structType == StructureInfoProto_StructTypeEvo) {
    EvoChamberProto *cur = (EvoChamberProto *)curSS;
    EvoChamberProto *next = (EvoChamberProto *)nextSS;
    EvoChamberProto *max = (EvoChamberProto *)maxSS;
    
    curStat1 = cur.structInfo.level;
    newStat1 = next.structInfo.level;
    maxStat1 = max.structInfo.level;
    
    statString1 = [NSString stringWithFormat:@"%@ Evo %d", [Globals stringForRarity:next.qualityUnlocked], next.evoTierUnlocked];
    
    statName1 = @"Unlocks:";
  }
  
  NSString *dollarSign = showsCashSymbol1 ? @"$" : @"";
  NSString *increase = newStat1 > curStat1 ? [NSString stringWithFormat:@" + %@%@", dollarSign, [Globals commafyNumber:newStat1-curStat1]] : @"";
  self.statNameLabel1.text = statName1;
  self.statDescriptionLabel1.text = statString1 ?: [NSString stringWithFormat:@"%@%@%@%@", dollarSign, [Globals commafyNumber:curStat1], increase, suffix1];
  
  float sqrtVal = 0.75;
  float sqPowVal = 1.5;
  
  float powVal = useSqrt1 ? sqrtVal : usePow1 ? sqPowVal : 1;
  if (powVal) {
    self.statNewBar1.percentage = powf(newStat1/maxStat1, powVal);
    self.statCurrentBar1.percentage = powf(curStat1/maxStat1, powVal);
  } else {
    self.statNewBar1.percentage = newStat1/maxStat1;
    self.statCurrentBar1.percentage = curStat1/maxStat1;
  }
  
  if (requiresTwoBars) {
    dollarSign = showsCashSymbol2 ? @"$" : @"";
    increase = newStat2 > curStat2 ? [NSString stringWithFormat:@" + %@%@", dollarSign, [Globals commafyNumber:newStat2-curStat2]] : @"";
    self.statNameLabel2.text = statName2;
    self.statDescriptionLabel2.text = statString2 ?: [NSString stringWithFormat:@"%@%@%@%@", dollarSign, [Globals commafyNumber:curStat2], increase, suffix2];
    
    powVal = useSqrt2 ? sqrtVal : usePow2 ? sqPowVal : 1;
    if (powVal) {
      self.statNewBar2.percentage = powf(newStat2/maxStat2, powVal);
      self.statCurrentBar2.percentage = powf(curStat2/maxStat2, powVal);
    } else {
      self.statNewBar2.percentage = newStat2/maxStat2;
      self.statCurrentBar2.percentage = curStat2/maxStat2;
    }
    
    self.statBarView2.hidden = NO;
  } else {
    self.statBarView2.hidden = YES;
  }
}

@end

@implementation UpgradeViewController

- (id) initWithUserStruct:(UserStruct *)us {
  if ((self = [super init])) {
    self.userStruct = us;
  }
  return self;
}

- (void) viewDidLoad {
  [self.upgradeView loadForUserStruct:self.userStruct];
  
  int level = self.userStruct.staticStruct.structInfo.level;
  int maxLevel = self.userStruct.maxLevel;
  self.titleLabel.text = level != maxLevel ? [NSString stringWithFormat:@"Upgrade to Level %d?", level+1] : @"Building at Max";
  if (level == 0) self.titleLabel.text = [NSString stringWithFormat:@"Fix %@?", self.userStruct.staticStruct.structInfo.name];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

#pragma mark - IBActions

- (IBAction) upgradeClicked:(id)sender {
  if ([self.userStruct satisfiesAllPrerequisites]) {
    [self.delegate bigUpgradeClicked];
    [self closeClicked:nil];
  } else {
    [Globals addAlertNotification:@"You have not yet met the requirements to upgrade."];
  }
}

- (void) goClicked:(UpgradePrereqView *)pre {
  NSArray *prereqs = [self.userStruct allPrerequisites];
  NSInteger i = [self.upgradeView.prereqViews indexOfObject:pre];
  
  if (i != NSNotFound && i < prereqs.count) {
    PrereqProto *pp = prereqs[i];
    
    GameViewController *gvc = [GameViewController baseController];
    if (pp.prereqGameType == GameTypeStructure) {
      BOOL success = [gvc pointArrowToUpgradeForStructId:pp.prereqGameEntityId quantity:pp.quantity];
      
      if (success) {
        [self closeClicked:nil];
      }
    }
  }
  
}

- (IBAction) closeClicked:(id)sender {
  // Check that no other animations are happenings
  if (self.mainView.layer.animationKeys.count == 0) {
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
      [self.view removeFromSuperview];
      [self removeFromParentViewController];
    }];
  }
}

@end
