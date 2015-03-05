//
//  ResearchInfoViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 3/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchInfoViewController.h"
#import "Globals.h"
#import "GameState.h"

@implementation ResearchPrereqView

- (void) updateForPrereq:(PrereqProto *)pre isComplete:(BOOL)isComplete {
  
  if(pre.gameType == GameTypeStructure) {
    [super updateForPrereq:pre isComplete:isComplete];
    return;
  }
  
  self.prereqLabel.text = [pre prereqString];
  
  self.checkIcon.highlighted = !isComplete;
  self.prereqLabel.highlighted = !isComplete;
  self.goButtonView.hidden = YES;
}

@end

@implementation ResearchInfoView

-(void)updateWithResearch:(ResearchProto *)research {
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  //for now we assume only a single property for each research
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setMaximumFractionDigits:5];
  [formatter setMinimumFractionDigits:0];
  NSString *result = [formatter stringFromNumber:[NSNumber numberWithFloat:[research researchBenefit]]];
  self.percentIncreseLabel.text = [NSString stringWithFormat:@"%@%@", result, [research firstProperty].name];
  
  self.researchImage.image = [Globals imageNamed:research.iconImgName];
  self.researchName.text = research.name;
  self.researchTimeLabel.text = [Globals convertTimeToMediumString:research.durationMin*60];
  
  NSArray *prereqs = [gs prerequisitesForGameType:GameTypeResearch gameEntityId:research.researchId];
  
  self.prereqViewA.hidden = prereqs.count < 1;
  self.prereqViewB.hidden = prereqs.count < 2;
  self.prereqViewC.hidden = prereqs.count < 3;
  
  if(!self.prereqViewA.hidden) {
    BOOL isComplete = [gl isPrerequisiteComplete:prereqs[0]];
    [self.prereqViewA updateForPrereq:prereqs[0] isComplete:isComplete];
  }
  if(!self.prereqViewB.hidden) {
    BOOL isComplete = [gl isPrerequisiteComplete:prereqs[0]];
    [self.prereqViewB updateForPrereq:prereqs[1] isComplete:isComplete];
  }
  if(!self.prereqViewC.hidden) {
    BOOL isComplete = [gl isPrerequisiteComplete:prereqs[0]];
    [self.prereqViewC updateForPrereq:prereqs[2] isComplete:isComplete];
  }
  
  float maxPercent = (1.f + ([[research maxLevelResearch] firstProperty].researchValue / 100.f));
  float curPercent;
  if([research predecessorResearch]) {
    curPercent = (1.f + ([[research predecessorResearch] firstProperty].researchValue / 100.f)) / maxPercent;
  } else {
    curPercent = 1.f / maxPercent;
  }
  
  float nextPercent = (1.f + ([research firstProperty].researchValue / 100.f)) / maxPercent;
  
  [self.topPercentBar setPercentage:curPercent];
  [self.botPercentBar setPercentage:nextPercent];
  
}


@end

@implementation ResearchInfoViewController

- (void) viewDidLoad {
  self.title = @"info view";
}

- (id)initWithResearch:(ResearchProto *)research {
  if((self = [super init])) {
    [self.view updateWithResearch:research];
    self.title = [NSString stringWithFormat:@"Research to Rank %d",research.level];
  }
  
  return self;
}

- (IBAction)DetailsClicked:(id)sender {
  ResearchDetailViewController *rdvc = [[ResearchDetailViewController alloc] init];
  [self.parentViewController pushViewController:rdvc animated:YES];
}

@end

@implementation ResearchProto (prereqObject)

- (ResearchProto *)successorResearch {
  return [[GameState sharedGameState].staticResearch objectForKey:@(self.succId)];
}

- (ResearchProto *)predecessorResearch {
  return [[GameState sharedGameState].staticResearch objectForKey:@(self.predId)];
}

- (ResearchProto *)maxLevelResearch {
  if(self.succId) {
    return [[self successorResearch] maxLevelResearch];
  }
  return self;
}

- (ResearchProto *)minLevelResearch {
  if(self.predId) {
    return [[self predecessorResearch] minLevelResearch];
  }
  return self;
}

- (ResearchPropertyProto *)firstProperty {
  return self.propertiesList[0];
}

- (float)researchBenefit {
    return [self firstProperty].researchValue - [[self predecessorResearch] firstProperty].researchValue;
}

@end


