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
  ResearchProto *rp = userResearch.staticResearchForBenefitLevel;
  
  {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:rp.name attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : self.researchNameLabel.font}];
    self.researchNameLabel.attributedText = attr;
    
    CGRect rect = [attr boundingRectWithSize:CGSizeMake(self.researchNameLabel.width, 9999) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    self.researchNameLabel.originY = floorf(CGRectGetMaxY(self.researchNameLabel.frame) - rect.size.height);
    self.researchNameLabel.height = ceilf(rect.size.height);
  }
  
  int curLevel = rp.level;
  int maxLevel = rp.maxLevelResearch.level;
  self.researchRank.text = [NSString stringWithFormat:@"%d/%d", curLevel, maxLevel];
  [Globals imageNamed:rp.iconImgName withView:self.researchIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
}

@end

@implementation ResearchDetailViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.title = @"Ranks";
  
  [self.view updateWithResearch:_userResearch];
}

- (id) initWithUserResearch:(UserResearch *)userResearch {
  if((self = [super init])){
    _userResearch = userResearch;
    
    ResearchProto *research = userResearch.staticResearch;
    self.title = [NSString stringWithFormat:@"%@ Ranks", research.name];
  }
  return self;
}

#pragma TableView Delegates

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_userResearch.staticResearch fullResearchFamily].count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  
  ResearchProto *research = _userResearch.staticResearch;
  NSArray *researchFamily = [research fullResearchFamily];
  research = [researchFamily objectAtIndex:indexPath.row];
  ResearchController *rc = [ResearchController researchControllerWithProto:research];
  
  ResearchDetailViewCell *cell;
  cell = [tableView dequeueReusableCellWithIdentifier:@"ResearchDetailViewCell"];
  if (!cell) {
    cell = [[NSBundle mainBundle] loadNibNamed:@"ResearchDetailViewCell" owner:self options:nil][0];
  }
  
  if (research.researchId == _userResearch.staticResearchForNextLevel.researchId) {
    cell.bgView.backgroundColor = [UIColor colorWithHexString:@"FFFFDC"];
  } else {
    cell.bgView.backgroundColor = [UIColor clearColor];
  }
  
  [cell updateWithRank:[NSString stringWithFormat:@"%d",research.level] description:[rc shortImprovementString] showCheckMark:[gs.researchUtil prerequisiteFullfilledForResearch:research]];
  
  return cell;
}

@end
