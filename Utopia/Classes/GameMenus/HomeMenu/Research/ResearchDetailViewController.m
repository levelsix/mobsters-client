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

-(void)updateWithRank:(NSString *)rank description:(NSString *)description showCheckMark:(BOOL)show {
  self.rankLabel.text = rank;
  self.improvementLabel.text = description;
  self.checkMark.hidden = !show;
}

@end

@implementation ResearchDetailView

- (void)updateWithResearch:(UserResearch *)userResearch {
  self.researchName.text = userResearch.research.name;
  int curLevel = userResearch.complete ? userResearch.research.level : userResearch.research.level - 1;
  self.researchRank.text = [NSString stringWithFormat:@"%d/%@",curLevel, @([userResearch.research fullResearchFamily].count)];
  [Globals imageNamed:userResearch.research.iconImgName withView:self.researchIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
}

@end

@implementation ResearchDetailViewController

- (void) viewDidLoad {
  self.title = @"Ranks";
}

- (id)initWithResearchResearch:(UserResearch *)userResearch {
  _userResearch = userResearch;
  GameState *gs = [GameState sharedGameState];
  if((self = [super init])){
    ResearchProto *research = [gs researchWithId:userResearch.researchId];
    [self.view updateWithResearch:userResearch];
    self.title = [NSString stringWithFormat:@"%@ Ranks", research.name];
  }
  return self;
}

#pragma TableView Delegates

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  ResearchProto *research = _userResearch.research;
  ResearchController *rc = [ResearchController researchControllerWithProto:research];
  NSArray *researchFamily = [research fullResearchFamily];
  research = [researchFamily objectAtIndex:indexPath.row];
  
  ResearchDetailViewCell *cell;
  cell = [tableView dequeueReusableCellWithIdentifier:@"ResearchDetailViewCell"];
  if (!cell) {
    cell = [[NSBundle mainBundle] loadNibNamed:@"ResearchDetailViewCell" owner:self options:nil][0];
//    cell.line = [UIImage imageWithCGImage:cell.line.CGImage
//                                    scale:cell.line.scale
//                              orientation:UIImageOrientationDownMirrored];
  }
  
  if (research.researchId == _userResearch.researchId) {
    cell.bgView.backgroundColor = [UIColor colorWithHexString:@"FFFFDC"];
  } else {
    cell.bgView.backgroundColor = [UIColor clearColor];
  }
  
  [cell updateWithRank:[NSString stringWithFormat:@"%d",research.level] description:[rc shortImprovementString] showCheckMark:[gs.researchUtil prerequisiteFullfilledForResearch:research]];
  
  return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_userResearch.research fullResearchFamily].count;
}

@end
