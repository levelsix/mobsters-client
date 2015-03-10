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

#define RED_STROKE @"e0181a"
#define BLUE_STROKE @"1086de"

#define RED_BOT_COLOR @"FFE4E6"
#define BLUE_BOT_COLOR @"c9f7ff" // D2F7FE

@implementation researchSelectionBarView

-(void)updateForProto:(ResearchProto *)proto {
  _researchId = proto.researchId;
  BOOL isAvailable = [proto prereqsComplete];
  
  [Globals imageNamed:proto.iconImgName withView:self.selectionIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.rankTotal.text = [NSString stringWithFormat:@"%d/%@", proto.level, @([proto fullResearchFamily].count)];
  self.selectionTitle.text = [NSString stringWithFormat:@"%@ Rank %d", proto.name, proto.level];
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
  [rtvc barClickedWithId:_researchId];
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
  
  int index = 0;
  for(ResearchProto *rp in researches) {
    ResearchButtonView *selectView;
    selectView = [[NSBundle mainBundle] loadNibNamed:@"ResearchButtonView" owner:self options:nil][0];
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
  
  UIView *outView = _curBarView;
  [_curBarView animateOut:^{
    [outView removeFromSuperview];
  }];
  _curBarView = [[NSBundle mainBundle] loadNibNamed:@"ResearchSelectionBar" owner:self options:nil][0];
  [self.view addSubview:_curBarView];
  [_curBarView updateForProto:clickedResearch];
  [_curBarView animateIn:nil];
  _curBarView.delegate = self;
  
  if(_selectFieldViewUp) {
    [_selectFieldView animateOut:^{
      _selectFieldViewUp = NO;
      _barAnimating = NO;
    }];
  }
  
}

-(void)barClickedWithId:(int)index {
  ResearchProto *proto = [[GameState sharedGameState].staticResearch objectForKey:@(index)];
  ResearchInfoViewController *rivc = [[ResearchInfoViewController alloc] initWithResearch:proto];
  [self.parentViewController pushViewController:rivc animated:YES];
}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if(_barAnimating || _curBarView) {
    return;
  }
  if(_selectFieldViewUp) {
    if( scrollView.contentOffset.y > 100) {
      _barAnimating = YES;
      [_selectFieldView animateOut:^{
        _selectFieldViewUp = NO;
        _barAnimating = NO;
      }];
    }
  } else {
    if( scrollView.contentOffset.y < 100) {
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

@implementation ResearchButtonView

- (void)updateForProto:(ResearchProto *)research {
    _id = research.researchId;
  self.researchNameLabel.text = research.name;
  self.rankLabel.text = [NSString stringWithFormat:@"%d/%@",research.level, @([research fullResearchFamily].count)];
}

- (IBAction)researchSelected:(id)sender {
  [self.delegate researchButtonClickWithId:_id];
}

@end
