//
//  ResearchDetailViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 3/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchDetailViewController.h"
#import "ResearchController.h"
#import "GameState.h"

@implementation ResearchDetailViewCell

- (void) updateWithRank:(NSString *)rank description:(NSString *)description showCheckMark:(BOOL)show {
  self.rankLabel.text = rank;
  self.improvementLabel.text = description;
  self.checkMark.hidden = !show;
}

@end

@implementation ResearchDetailView

- (void) updateWithResearch:(UserResearch *)userResearch {
  self.researchName.text = userResearch.research.name;
  int curLevel = userResearch.researchForBenefitLevel.level;
  self.researchRank.text = [NSString stringWithFormat:@"%d/%@",curLevel, @([userResearch.research fullResearchFamily].count)];
  [Globals imageNamed:userResearch.research.iconImgName withView:self.researchIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
}

@end

@implementation ResearchDetailViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.title = @"Ranks";
  
  [self.view updateWithResearch:_userResearch];
}

- (id)initWithUserResearch:(UserResearch *)userResearch {
  _userResearch = userResearch;
  GameState *gs = [GameState sharedGameState];
  if((self = [super init])){
    ResearchProto *research = [gs researchWithId:userResearch.researchId];
    self.title = [NSString stringWithFormat:@"%@ Ranks", research.name];
  }
  return self;
}

#pragma TableView Delegates

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_userResearch.research fullResearchFamily].count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  
  ResearchProto *research = _userResearch.research;
  NSArray *researchFamily = [research fullResearchFamily];
  research = [researchFamily objectAtIndex:indexPath.row];
  ResearchController *rc = [ResearchController researchControllerWithProto:research];
  
  ResearchDetailViewCell *cell;
  cell = [tableView dequeueReusableCellWithIdentifier:@"ResearchDetailViewCell"];
  if (!cell) {
    cell = [[NSBundle mainBundle] loadNibNamed:@"ResearchDetailViewCell" owner:self options:nil][0];
  }
  
  if (research.researchId == _userResearch.researchId) {
    cell.bgView.backgroundColor = [UIColor colorWithHexString:@"FFFFDC"];
  } else {
    cell.bgView.backgroundColor = [UIColor clearColor];
  }
  
  [cell updateWithRank:[NSString stringWithFormat:@"%d",research.level] description:[rc shortImprovementString] showCheckMark:[gs.researchUtil prerequisiteFullfilledForResearch:research]];
  
  return cell;
}

@end
