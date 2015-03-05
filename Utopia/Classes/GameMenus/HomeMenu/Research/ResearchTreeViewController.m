//
//  RearchTreeViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 3/3/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchTreeViewController.h"
#import "GameState.h"

#import "ResearchInfoViewController.h"

@implementation ResearchTreeViewController

-(id)initWithDomain:(ResearchDomain)domain {
  ResearchTreeView *treeView = (ResearchTreeView *)self.view;
  treeView.scrollView.contentSize = treeView.mainView.size;
  
  if((self = [super init])){
    switch (domain) {
      case ResearchDomainBattle:
        self.titleImageName = @"researchbattle.png";
        self.title = @"Battle Research";
        break;
      case ResearchDomainResources:
        self.titleImageName = @"researchresources.png";
        self.title = @"Resource Research";
        break;
      case ResearchDomainRestorative:
        self.titleImageName = @"researchtoons.png";
        self.title = @"Restorarion Research";
        break;
      case ResearchDomainLevelup:
        self.title = @"Level Up Research";
      default:
        self.title = @"Research";
        break;
    }
  }
  GameState *gs = [GameState sharedGameState];
  NSArray *researches = [gs allStaticResearchForDomain:domain];
  
  int index = 0;
  for(ResearchProto *rp in researches) {
    ResearchSelectionView *selectView;
    selectView = [[NSBundle mainBundle] loadNibNamed:@"ResearchSelectionView" owner:self options:nil][0];
    [treeView.mainView addSubview:selectView];
    
    selectView.origin = CGPointMake(0.f, 100.f*index);
    selectView.delegate = self;
    [selectView updateForProto:rp];
    index++;
  }
  
  return self;
}

-(void)viewDidLoad {
  self.titleImageName = @"researchtoons.png";
}

-(void)researchButtonClickWithId:(int) index {
  GameState *gs = [GameState sharedGameState];
  ResearchProto *clickedResearch = [gs.staticResearch objectForKey:@(index)];
  ResearchInfoViewController *rivc = [[ResearchInfoViewController alloc] initWithResearch:clickedResearch];
  [self.parentViewController pushViewController:rivc animated:YES];
}

@end

@implementation ResearchTreeView

@end

@implementation ResearchSelectionView

- (void)updateForProto:(ResearchProto *)research {
    _id = research.researchId;
  self.researchNameLabel.text = research.name;
}

- (IBAction)researchSelected:(id)sender {
  [self.delegate researchButtonClickWithId:_id];
  
}

@end
