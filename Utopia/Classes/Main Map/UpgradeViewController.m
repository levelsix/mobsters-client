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

@implementation UpgradeBuildingMenu

- (void) awakeFromNib {
  [self.statBarView1.superview addSubview:self.cityHallUnlocksView];
}

- (void) loadForUserStruct:(UserStruct *)us {
  if (us == nil) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  
  id<StaticStructure> curSS = us.staticStruct;
  id<StaticStructure> nextSS = us.staticStructForNextLevel;
  id<StaticStructure> maxSS = us.maxStaticStruct;
  if (curSS == maxSS) {
    nextSS = maxSS;
  }
  
  self.nameLabel.text = curSS.structInfo.name;
  self.upgradeTimeLabel.text = curSS != nextSS ? [[Globals convertTimeToLongString:nextSS.structInfo.minutesToBuild*60] uppercaseString] : @"N/A";
  
  [Globals imageNamed:nextSS.structInfo.imgName withView:self.structIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  // Button view
  BOOL isOil = nextSS.structInfo.buildResourceType == ResourceTypeOil;
  self.upgradeCashLabel.text = curSS != nextSS ? [Globals commafyNumber:nextSS.structInfo.buildCost] : @"N/A";
  self.upgradeOilLabel.text = curSS != nextSS ? [Globals commafyNumber:nextSS.structInfo.buildCost] : @"N/A";
  [Globals adjustViewForCentering:self.upgradeOilLabel.superview withLabel:self.upgradeOilLabel];
  [Globals adjustViewForCentering:self.upgradeCashLabel.superview withLabel:self.upgradeCashLabel];
  self.oilButtonView.hidden = !isOil;
  self.cashButtonView.hidden = isOil;
  
  // Town hall too low
  [self.greyscaleView removeFromSuperview];
  self.greyscaleView = nil;
  UserStruct *th = [gs myTownHall];
  TownHallProto *thp = (TownHallProto *)(th.isComplete ? th.staticStruct : th.staticStructForPrevLevel);
  int thLevel = thp.structInfo.level;
  if (nextSS.structInfo.prerequisiteTownHallLvl > thLevel) {
    UIImage *grey = [Globals greyScaleImageWithBaseImage:[Globals snapShotView:self.oilButtonView.superview]];
    self.greyscaleView = [[UIImageView alloc] initWithImage:grey];
    [self.oilButtonView.superview addSubview:self.greyscaleView];
    
    self.oilButtonView.hidden = YES;
    self.cashButtonView.hidden = YES;
    
    self.tooLowLevelLabel.text = [NSString stringWithFormat:@"Requires Lvl %d %@", nextSS.structInfo.prerequisiteTownHallLvl, thp.structInfo.name];
    
    self.tooLowLevelView.hidden = NO;
  } else {
    self.tooLowLevelView.hidden = YES;
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
    if (sip.level == 1) {
      int before = [gl calculateMaxQuantityOfStructId:sip.structId withTownHall:curTh];
      int after = [gl calculateMaxQuantityOfStructId:sip.structId withTownHall:nextTh];
      
      if (before < after) {
        [arr addObject:sip];
      }
    } else {
      if (sip.prerequisiteTownHallLvl != curTh.structInfo.level && sip.prerequisiteTownHallLvl == nextTh.structInfo.level) {
        // Make sure a lower lvl one isn't in the array already
        
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
  [Globals imageNamed:imgName withView:self.nibUnlocksStructIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
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
  float curStat1 = 0, newStat1 = 0, maxStat1 = 0;
  float curStat2 = 0, newStat2 = 0, maxStat2 = 0;
  NSString *statName1 = nil, *statName2 = nil;
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
    suffix1 = @"Per Hour";
    
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
    suffix2 = @"Health Per Sec";
  } else if (structType == StructureInfoProto_StructTypeLab) {
    LabProto *cur = (LabProto *)curSS;
    LabProto *next = (LabProto *)nextSS;
    LabProto *max = (LabProto *)maxSS;
    
    curStat1 = cur.queueSize;
    newStat1 = next.queueSize;
    maxStat1 = max.queueSize;
    statName1 = @"Queue Size:";
    
//    requiresTwoBars = YES;
//    
//    curStat2 = cur.pointsPerSecond;
//    newStat2 = next.pointsPerSecond;
//    maxStat2 = max.pointsPerSecond;
//    statName2 = @"Rate:";
//    suffix2 = @"Points Per Sec";
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
    
    curStat1 = cur.generatedJobLimit;
    newStat1 = next.generatedJobLimit;
    maxStat1 = max.generatedJobLimit;
    
    statName1 = @"Mini Jobs:";
  }
  
  NSString *dollarSign = showsCashSymbol1 ? @"$" : @"";
  NSString *increase = newStat1 > curStat1 ? [NSString stringWithFormat:@" + %@%@", dollarSign, [Globals commafyNumber:newStat1-curStat1]] : @"";
  self.statNameLabel1.text = statName1;
  self.statDescriptionLabel1.text = [NSString stringWithFormat:@"%@%@%@ %@", dollarSign, [Globals commafyNumber:curStat1], increase, suffix1];
  
  float powVal = 0.75;
  if (useSqrt1) {
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
    self.statDescriptionLabel2.text = [NSString stringWithFormat:@"%@%@%@ %@", dollarSign, [Globals commafyNumber:curStat2], increase, suffix2];
    
    if (useSqrt2) {
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
  [self.delegate bigUpgradeClicked];
  [self closeClicked:nil];
}

- (IBAction) closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
