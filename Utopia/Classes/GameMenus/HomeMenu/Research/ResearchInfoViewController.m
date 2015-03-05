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
  
}


@end

@implementation ResearchInfoViewController

- (void) viewDidLoad {
  self.title = @"info view";
}

- (id)initWithResearch:(ResearchProto *)research {
  if((self = [super init])) {
    [self.view updateWithResearch:research];
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

@end


