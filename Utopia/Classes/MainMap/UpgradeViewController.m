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
#import "EmbeddedScrollingUpgradeView.h"

@implementation UpgradePrereqView

- (void) updateForPrereq:(PrereqProto *)pre isComplete:(BOOL)isComplete {
  self.prereqLabel.text = [pre prereqString];
  
  self.checkIcon.highlighted = !isComplete;
  self.prereqLabel.highlighted = !isComplete;
  self.goButtonView.hidden = isComplete;
}

- (IBAction)goClicked:(id)sender {
  //[self.delegate goClicked:self];
}

@end

@implementation UpgradeBuildingMenu

- (void) awakeFromNib {
//  [self.statBarView1.superview addSubview:self.cityHallUnlocksView];
}

- (void) loadForUserStruct:(UserStruct *)us {
  if (us == nil) {
    return;
  }
  
  id<StaticStructure> curSS = us.staticStruct;
  id<StaticStructure> nextSS = us.staticStructForNextLevel;
  id<StaticStructure> maxSS = us.maxStaticStruct;
  if (curSS == maxSS) {
    nextSS = maxSS;
  }
  
  Globals *gl = [Globals sharedGlobals];
  
  self.nameLabel.text = curSS.structInfo.name;
  self.upgradeTimeLabel.text = curSS != nextSS ? [[Globals convertTimeToMediumString:[gl calculateSecondsToBuild:nextSS.structInfo]] uppercaseString] : @"N/A";
  
  [Globals imageNamed:nextSS.structInfo.imgName withView:self.structIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  // Button view
  BOOL isOil = nextSS.structInfo.buildResourceType == ResourceTypeOil;
  self.upgradeCashLabel.text = [Globals commafyNumber:nextSS.structInfo.buildCost];
  self.upgradeOilLabel.text = [Globals commafyNumber:nextSS.structInfo.buildCost];
  [Globals adjustViewForCentering:self.upgradeOilLabel.superview withLabel:self.upgradeOilLabel];
  [Globals adjustViewForCentering:self.upgradeCashLabel.superview withLabel:self.upgradeCashLabel];
  self.oilButtonView.hidden = !isOil;
  self.cashButtonView.hidden = isOil;
  
  if (curSS == nextSS) {
    self.readyLabel.text = @"Building at Max";
    self.readySubLabel.text = [NSString stringWithFormat:@"This building cannot be upgraded anymore."];
    self.oilButtonView.superview.hidden = YES;
  }
  
  NSArray *incomplete = [us incompletePrerequisites];
  int numIncomplete = (int)incomplete.count;
  if (numIncomplete) {
    UIImage *grey = [Globals imageNamed:@"greymenuoption.png"];
    [self.oilButton setImage:grey forState:UIControlStateNormal];
    [self.cashButton setImage:grey forState:UIControlStateNormal];
    
    self.oilIcon.image = [Globals greyScaleImageWithBaseImage:self.oilIcon.image];
    self.cashIcon.image = [Globals greyScaleImageWithBaseImage:self.cashIcon.image];
    
    self.upgradeCashLabel.textColor = [UIColor colorWithWhite:0.5f alpha:1.f];
    self.upgradeCashLabel.shadowColor = [UIColor colorWithWhite:1.f alpha:0.25];
    self.upgradeOilLabel.textColor = [UIColor colorWithWhite:0.5f alpha:1.f];
    self.upgradeOilLabel.shadowColor = [UIColor colorWithWhite:1.f alpha:0.25];
    
    self.readyLabel.text = @"Woops!";
    self.readySubLabel.text = [NSString stringWithFormat:@"You are missing %d requirement%@ to upgrade.", numIncomplete, numIncomplete == 1 ? @"" : @"s"];
    
    self.bottomBgLeftCap.image = [Globals imageNamed:@"functionalhomemenubottombarredcap.png"];
    self.bottomBgRightCap.image = [Globals imageNamed:@"functionalhomemenubottombarredcap.png"];
    self.bottomBgMiddle.image = [Globals imageNamed:@"functionalhomemenubottombarredmiddle.png"];
    
    self.checkIcon.highlighted = YES;
    self.readyLabel.highlighted = YES;
    self.readySubLabel.highlighted = YES;
  }
  
  if (nextSS.structInfo.structType != StructureInfoProto_StructTypeTownHall) {
    self.cityHallUnlocksView.hidden = YES;
    [self.embeddedScrollView updateForGameTypeProto:us.staticStruct.structInfo];
  } else {
    [self loadCityHallUnlocksViewForUserStruct:us];
    self.embeddedScrollView.townHallUnlocksView = self.cityHallUnlocksView;
    [self.embeddedScrollView updateForTownHall:us.staticStruct.structInfo];
  }
}

- (NSArray *) buildingsThatChangedInQuantityWithCurTH:(TownHallProto *)curTh nextTh:(TownHallProto *)nextTh {
  NSMutableArray *arr = [NSMutableArray array];
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  for (id<StaticStructure> ss in gs.staticStructs.allValues) {
    StructureInfoProto *sip = ss.structInfo;
    
    // Don't worry abt the TH's
    if (sip.structType == StructureInfoProto_StructTypeTownHall) {
      continue;
    }
    
    // This is outside because when we check prereqs, we want to make sure that the building even has quantity to be built
    // (i.e. Lvl 2 University requires Lvl 3 Residence which requires Lvl 4 TH, but Lvl 1 University requires Lvl 9 TH. Prob shouldn't happen data-wise though..)
    int afterQuant = [gl calculateMaxQuantityOfStructId:sip.structId withTownHall:nextTh];
    if (!sip.predecessorStructId) {
      int beforeQuant = [gl calculateMaxQuantityOfStructId:sip.structId withTownHall:curTh];
      
      if (beforeQuant < afterQuant) {
        [arr addObject:sip];
      }
    } else {
      BOOL unlockBefore = [gl checkPrereqsOfStructId:sip.structId forPredecessorOfStructId:curTh.structInfo.structId];
      BOOL unlockAfter = [gl checkPrereqsOfStructId:sip.structId forPredecessorOfStructId:nextTh.structInfo.structId];
      
      if (!unlockBefore && unlockAfter && afterQuant >= 1) {
        [arr addObject:sip];
      }
    }
  }
  
  // Remove duplicates, i.e. only use the max level one, for example if lvl 6 TH unlocks lvl 4 and lvl 5 cash generator, we only should mention lvl 5 one
  NSMutableArray *toRemove = [NSMutableArray array];
  for (StructureInfoProto *sip in arr) {
    StructureInfoProto *check = sip;
    while (check.predecessorStructId) {
      check = [[gs structWithId:check.predecessorStructId] structInfo];
      if ([arr containsObject:check]) {
        // Remove the higher one only in the case that this is a new building, i.e. check has no predId
        if (!check.predecessorStructId) {
          [toRemove addObject:sip];
        } else {
          [toRemove addObject:check];
        }
      }
    }
  }
  [arr removeObjectsInArray:toRemove];
  
  [arr sortUsingComparator:^NSComparisonResult(StructureInfoProto *obj1, StructureInfoProto *obj2) {
    return [@(obj1.structId) compare:@(obj2.structId)];
  }];
  
  return arr;
}

#define UNLOCK_VIEW_SPACING 7
#define NUM_PER_ROW 5

- (void) loadCityHallUnlocksViewForUserStruct:(UserStruct *)us {
  Globals *gl = [Globals sharedGlobals];
  TownHallProto *curSS = (TownHallProto *)us.staticStruct;
  TownHallProto *nextSS = (TownHallProto *)us.staticStructForNextLevel;
  
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
    
    [self.cityHallUnlocksView addSubview:v];
    
    maxY = y+v.frame.size.height/2+UNLOCK_VIEW_SPACING;
  }
  
  self.cityHallUnlocksView.size = CGSizeMake(self.cityHallUnlocksView.frame.size.width, maxY);
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

@end

@implementation UpgradeViewController

- (id) initWithUserStruct:(UserStruct *)us {
  // Changed to [self init] for tutorial vc
  if ((self = [self init])) {
    self.userStruct = us;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [self.upgradeView loadForUserStruct:self.userStruct];
  
  int level = self.userStruct.staticStruct.structInfo.level;
  int maxLevel = self.userStruct.maxLevel;
  self.title = level != maxLevel ? [NSString stringWithFormat:@"Upgrade to Level %d?", level+1] : @"Building at Max";
  if (level == 0) self.title = [NSString stringWithFormat:@"Fix %@?", self.userStruct.staticStruct.structInfo.name];
}

#pragma mark - IBActions

- (IBAction) upgradeClicked:(id)sender {
  if ([self.userStruct satisfiesAllPrerequisites]) {
    [self.delegate bigUpgradeClicked:self.upgradeView.oilButton];
  } else {
    [Globals addAlertNotification:@"You have not yet met the requirements to upgrade."];
  }
}

- (void) goClicked:(int)prereqId {
  NSArray *prereqs = [self.userStruct allPrerequisites];
  
  
  PrereqProto *pp;
  for (PrereqProto *nextPp in prereqs) {
    if(nextPp.prereqId == prereqId) {
      pp = nextPp;
    }
  }

  GameViewController *gvc = [GameViewController baseController];
  if (pp.prereqGameType == GameTypeStructure) {
    BOOL success = [gvc pointArrowToUpgradeForStructId:pp.prereqGameEntityId quantity:pp.quantity];

    if (success) {
      [self.parentViewController close];
    }
  }
}

- (void) detailsClicked:(int)index {
  DetailViewController *dvc = [[DetailViewController alloc] initWithGameTypeProto:_userStruct.staticStruct.structInfo index:index imageNamed:_userStruct.staticStruct.structInfo.imgName columnName:@"LVL"];
  
  [self.parentViewController pushViewController:dvc animated:YES];
}

@end
