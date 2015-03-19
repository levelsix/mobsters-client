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
#import "ResearchController.h"

#define RED_STROKE @"940500"
#define BLUE_STROKE @"0A7194"

#define RED_BOT_COLOR @"FFE4E6"
#define BLUE_BOT_COLOR @"c9f7ff"

@implementation researchSelectionBarView

-(void)updateForProto:(UserResearch *)userResearch {
  _userResearch = userResearch;
  ResearchProto *proto = userResearch.research;
  BOOL isAvailable = [userResearch.research prereqsComplete];
  
  [Globals imageNamed:userResearch.research.iconImgName withView:self.selectionIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.rankTotal.text = [NSString stringWithFormat:@"%d/%@", proto.level, @([proto fullResearchFamily].count)];
  self.rankTotal.shadowBlur = 0.5f;
  self.selectionTitle.text = [NSString stringWithFormat:@" %@ Rank %d", proto.name, proto.level];
  self.selectionDescription.text = proto.desc;
  
  self.nextArrowButton.image = [UIImage imageWithCGImage:self.nextArrowButton.image.CGImage
                                                   scale:self.nextArrowButton.image.scale
                                             orientation:UIImageOrientationUpMirrored];
  
  self.rankTotal.shadowBlur = 0.5f;
  
  self.selectionTitle.gradientStartColor = [UIColor whiteColor];
  self.selectionTitle.strokeSize = 1.f;
  self.selectionTitle.shadowBlur = 0.5f;
  self.selectionTitle.strokeColor = isAvailable ? [UIColor colorWithHexString:BLUE_STROKE] : [UIColor colorWithHexString:RED_STROKE];
  self.selectionTitle.gradientEndColor = isAvailable ? [UIColor colorWithHexString:BLUE_BOT_COLOR] : [UIColor colorWithHexString:RED_BOT_COLOR];
  
  NSString *barBGImage = isAvailable ? @"enhancenextbg.png" : @"researchmissingrequirements.png";
  [self.barButton setImage:[Globals imageNamed:barBGImage] forState:UIControlStateNormal];
  NSString *barClickedImageName = isAvailable ? @"enhancenextbgpressed.png" : @"researchmissingrequirementspressed.png";
  [self.barButton setImage:[Globals imageNamed:barClickedImageName] forState:UIControlStateHighlighted];
}

- (void) animateIn:(dispatch_block_t)completion {
  CGPoint pt = ccp(self.superview.center.x, self.superview.frame.size.height - (self.frame.size.height/2) - 3);
  self.center = ccp(pt.x, self.superview.frame.size.height + (self.frame.size.height/2));
  
  [UIView animateWithDuration:0.3f animations:^{
    self.center = pt;
  } completion:^(BOOL finished) {
    if (completion) {
      completion();
    }
  }];
}

- (void) animateOut:(dispatch_block_t)completion {
  [UIView animateWithDuration:0.3f animations:^{
    self.center = ccp(self.center.x, self.center.y + self.frame.size.height + 10);
  } completion:^(BOOL finished) {
    if (completion) {
      completion();
    }
  }];
}
- (IBAction)clicked:(id)sender {
  ResearchTreeViewController *rtvc = (ResearchTreeViewController *)self.delegate;
  [rtvc barClickedWithResearch:_userResearch];
}

-(void)updateSelf {
  if(_userResearch) {
    [self updateForProto:[[GameState sharedGameState].researchUtil currentRankForResearch:_userResearch.research]];
  }
}

@end

#define AVAILABLE_OUTLINE @"canresearchclickedborder.png"
#define UNAVAILABLE_OUTLINE @"cantresearchtapped.png"
#define DARK_GREY_OUTLINE @"darkresearchcircle.png"
#define GREY_OUTLINE @"lightresearchcirclepressed.png"
#define LIGHT_GREY_OUTLINE @"lightresearchcircle.png"

@implementation ResearchButtonView

- (void) select {
  BOOL isAvailable = [_userResearch.research prereqsComplete];
  self.bgView.hidden = !isAvailable;
  self.outline.image = isAvailable ? [Globals imageNamed:AVAILABLE_OUTLINE] : [Globals imageNamed:UNAVAILABLE_OUTLINE];
}

- (void) deselect {
  self.bgView.hidden = YES;
  self.outline.image = [Globals imageNamed:LIGHT_GREY_OUTLINE];
}

- (void) updateSelf {
  GameState *gs = [GameState sharedGameState];
  [self updateForResearch:[gs.researchUtil currentRankForResearch:_userResearch.research]];
}

- (void)updateForResearch:(UserResearch *)userResearch {
  ResearchProto *research = userResearch.research;
  _userResearch = userResearch;
  self.researchNameLabel.text = research.name;
  int curRank = userResearch.complete ? research.level : research.level - 1;
  self.rankLabel.text = [NSString stringWithFormat:@"%d/%@",curRank, @([research fullResearchFamily].count)];
}

- (IBAction)researchSelected:(id)sender {
  [self.delegate researchButtonClickWithResearch:_userResearch sender:(id) self];
}

@end

@implementation ResearchTreeViewController

-(id)initWithDomain:(ResearchDomain)domain {
  _selectFieldViewUp = YES;
  _barAnimating = NO;
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
  
  _researchButtons = [[NSMutableArray alloc] init];
  int index = 0;
  for(ResearchProto *research in researches) {
    
    if(research.level == 1) {
      UserResearch *userResearch = [gs.researchUtil currentRankForResearch:research];
      
      ResearchButtonView *selectView;
      selectView = [[NSBundle mainBundle] loadNibNamed:@"ResearchButtonView" owner:self options:nil][0];
      [treeView.mainView addSubview:selectView];
      [_researchButtons addObject:selectView];
      
      selectView.origin = CGPointMake(0.f, 100.f*index);
      selectView.delegate = self;
      [selectView updateForResearch:userResearch];
      index++;
    }
  }
  
  return self;
}

-(void)viewDidLoad {
  self.titleImageName = @"researchtoons.png";
}

-(void)researchButtonClickWithResearch:(UserResearch *)userResearch sender:(id)sender {
  
  ResearchButtonView *clicked = (ResearchButtonView *)sender;
  [clicked select];
  [_lastClicked deselect];
  _lastClicked = clicked;
  
  UIView *outView = _curBarView;
  [_curBarView animateOut:^{
    [outView removeFromSuperview];
  }];
  _curBarView = [[NSBundle mainBundle] loadNibNamed:@"ResearchSelectionBar" owner:self options:nil][0];
  [self.view addSubview:_curBarView];
  [_curBarView updateForProto:userResearch];
  [_curBarView animateIn:nil];
  _curBarView.delegate = self;
  
  if(_selectFieldViewUp) {
    [UIView animateWithDuration:0.3f animations:^{
      _selectFieldView.alpha = 0.f;
    }];
    [_selectFieldView animateOut:^{
      _selectFieldViewUp = NO;
      _barAnimating = NO;
    }];
  }
  
}

-(void)barClickedWithResearch:(UserResearch *)research{
  ResearchInfoViewController *rivc = [[ResearchInfoViewController alloc] initWithResearch:research];
  [self.parentViewController pushViewController:rivc animated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
  for (ResearchButtonView *rbv in _researchButtons) {
    [rbv updateSelf];
  }
  if(_curBarView) {
    [_curBarView updateSelf];
  }
//needs code for updating the _curBarBased on the last clicked research
}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if(_barAnimating || _curBarView) {
    return;
  }
  if(_selectFieldViewUp) {
    if( scrollView.contentOffset.y > 100) {
      [UIView animateWithDuration:0.3f animations:^{
        _selectFieldView.alpha = 0.f;
      }];
      _barAnimating = YES;
      [_selectFieldView animateOut:^{
        _selectFieldViewUp = NO;
        _barAnimating = NO;
      }];
    }
  } else {
    if( scrollView.contentOffset.y < 100) {
      [UIView animateWithDuration:0.3f animations:^{
        _selectFieldView.alpha = 1.f;
      }];
      _barAnimating = YES;
      [_selectFieldView animateIn:^{
        _selectFieldViewUp = YES;
        _barAnimating = NO;
      }];
    }
  }
}

@end

@implementation ResearchTreeView

@end


