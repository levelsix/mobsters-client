//
//  ResearchDetailViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 3/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchDetailViewController.h"

#import "GameState.h"

@implementation ResearchDetailViewCell

-(void)updateWithRank:(NSString *)rank description:(NSString *)description {
  self.rankLabel.text = rank;
  self.improvementLabel.text = description;
}

@end

@implementation ResearchDetailView

- (void)updateWith:(ResearchProto *)research {
  self.researchName.text = research.name;
}

@end

@implementation ResearchDetailViewController

- (void) viewDidLoad {
  self.title = @"Details";
}

- (id)initWithResearchId:(int)researchId {
  _researchId = researchId;
  GameState *gs = [GameState sharedGameState];
  if((self = [super init])){
    ResearchProto *research = [gs.staticResearch objectForKey:@(researchId)];
    [self.view updateWith:research];
  }
  return self;
}

#pragma TableView Delegates

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  ResearchProto *research = [gs.staticResearch objectForKey:@(_researchId)];
  NSArray *researchFamily = [research fullResearchFamily];
  research = [researchFamily objectAtIndex:indexPath.row];
  
  ResearchDetailViewCell *cell;
  cell = [tableView dequeueReusableCellWithIdentifier:@"ResearchDetailViewCell"];
  if (!cell) {
    cell = [[NSBundle mainBundle] loadNibNamed:@"ResearchDetailViewCell" owner:self options:nil][0];
  }
  
  if (research.researchId == _researchId) {
    cell.bgView.backgroundColor = [UIColor colorWithHexString:@"FFFFDC"];
  } else {
    cell.bgView.backgroundColor = [UIColor whiteColor];
  }
  
  [cell updateWithRank:[NSString stringWithFormat:@"%d",research.level] description:[NSString stringWithFormat:@"%@%@", [research description], [research firstProperty].name]];
  
  return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  ResearchProto *research = [gs.staticResearch objectForKey:@(_researchId)];
  return [research fullResearchFamily].count;
}

@end
