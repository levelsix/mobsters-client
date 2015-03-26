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
  int curRank = userResearch.complete ? _userResearch.research.level : _userResearch.research.level - 1;
  self.rankTotal.text = [NSString stringWithFormat:@"%d/%@", curRank, @([proto fullResearchFamily].count)];
  self.rankTotal.shadowBlur = 0.5f;
  self.selectionTitle.text = [NSString stringWithFormat:@" %@", proto.name];
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

#define AVAILABLE_OUTLINE   @"canresearchclickedborder.png"
#define UNAVAILABLE_OUTLINE @"cantresearchtapped.png"
#define DARK_GREY_OUTLINE   @"darkresearchcircle.png"
#define LIGHT_GREY_OUTLINE  @"lightresearchcircle.png"
#define LIGHT_LINE_COLOR    @"EAEAEA"
#define DARK_LINE_COLOR     @"555555"
#define LIGHT_CURVE         @"lightresearchcorner.png"
#define DARK_CURVE          @"darkresearchcorner.png"

@implementation ResearchButtonView

- (void) select {
  BOOL isAvailable = [_userResearch.research prereqsComplete];
  self.bgView.hidden = !isAvailable;
  self.outline.image = isAvailable ? [UIImage imageNamed:AVAILABLE_OUTLINE] : [UIImage imageNamed:UNAVAILABLE_OUTLINE];
  
  [self highlightPathToParentNodes:YES needsBlackOutline:NO];
}

- (void) deselect {
  self.bgView.hidden = YES;
  self.outline.image = [UIImage imageNamed:LIGHT_GREY_OUTLINE];
  
  [self highlightPathToParentNodes:NO needsBlackOutline:NO];
}

- (void) updateSelf {
  GameState *gs = [GameState sharedGameState];
  [self updateForResearch:[gs.researchUtil currentRankForResearch:_userResearch.research] parentNodes:nil];
}

- (void) dropOpacity {
  self.researchIcon.alpha = .3f;
  self.researchNameLabel.alpha = .3f;
  self.rankLabel.alpha = .3f;
  self.rankCountLabel.alpha = .3f;
}

- (void) fullOpacity {
  self.researchIcon.alpha = 1.f;
  self.researchNameLabel.alpha = 1.f;
  self.rankLabel.alpha = 1.f;
  self.rankCountLabel.alpha = 1.f;
}

- (void) updateForResearch:(UserResearch *)userResearch parentNodes:(NSSet *)parentNodes {
  ResearchProto *research = userResearch.research;
  _userResearch = userResearch;
  
  self.researchNameLabel.text = research.name;
  int curRank = userResearch.complete ? research.level : research.level - 1;
  self.rankCountLabel.text = [NSString stringWithFormat:@"%d/%@", curRank, @([research fullResearchFamily].count)];
  self.researchNameLabel.height = [self.researchNameLabel.text getSizeWithFont:self.researchNameLabel.font
                                                             constrainedToSize:CGSizeMake(self.researchNameLabel.width, MAXFLOAT)].height;
  self.rankLabel.originY = CGRectGetMaxY(self.researchNameLabel.frame);
  self.rankCountLabel.originY = self.rankLabel.originY;
  
  BOOL isAvailable = [_userResearch.research prereqsComplete];
  self.researchNameLabel.textColor = [UIColor colorWithHexString:isAvailable ? @"2AB4E8" : @"555555"];
  self.rankCountLabel.textColor = [UIColor colorWithHexString:isAvailable ? @"333333" : @"999999"];
  self.lockedIcon.hidden = isAvailable;
  
  [Globals imageNamed:research.iconImgName withView:self.researchIcon greyscale:!isAvailable indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];
  
  if (parentNodes)
    [self drawTreeHierarchyToParentNodes:parentNodes];
}

- (void) drawTreeHierarchyToParentNodes:(NSSet *)parentNodes
{
  _parentNodes = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory]; // Similar to NSSet, but can hold weak references to its members
  _connectionsToParentNodes = [NSMutableSet set];
  
  const CGFloat kLineWidth = 2.f;
  const CGSize  kCornerSize = CGSizeMake(13.f, 13.f);
  const CGFloat kMeetingPointYModifier = .25f;

  for (ResearchButtonView* parentButtonView in parentNodes)
  {
    // All coordinates in this view's local space
    const CGPoint connectionFromSelf = CGPointMake(self.width * .5f, self.outline.originY);
    const CGPoint connectionToParent = [self convertPoint:CGPointMake(parentButtonView.centerX,
                                                                      parentButtonView.originY + CGRectGetMaxY(parentButtonView.outline.frame))
                                                 fromView:parentButtonView.superview];
    
    if ((int)connectionFromSelf.x == (int)connectionToParent.x)
    {
      // Both nodes are aligned vertically
      UIView* connectingLine = [[UIView alloc] initWithFrame:CGRectMake(connectionToParent.x - kLineWidth * .5f, connectionToParent.y,
                                                                        kLineWidth, connectionFromSelf.y - connectionToParent.y + 1)];
        [connectingLine setBackgroundColor:[UIColor colorWithHexString:LIGHT_LINE_COLOR]];
        [self insertSubview:connectingLine belowSubview:self.bgView];
        [_connectionsToParentNodes addObject:connectingLine];
    }
    else
    {
      const CGPoint meetingPointFromSelf = CGPointMake(connectionFromSelf.x, (connectionFromSelf.y + connectionToParent.y) * kMeetingPointYModifier + kCornerSize.height);
      const CGPoint meetingPointToParent = CGPointMake(connectionToParent.x, (connectionFromSelf.y + connectionToParent.y) * kMeetingPointYModifier - kCornerSize.height);
      
      UIView* lineFromSelf = [[UIView alloc] initWithFrame:CGRectMake(meetingPointFromSelf.x - kLineWidth * .5f, meetingPointFromSelf.y,
                                                                      kLineWidth, connectionFromSelf.y - meetingPointFromSelf.y + 2)];
        [lineFromSelf setBackgroundColor:[UIColor colorWithHexString:LIGHT_LINE_COLOR]];
        [self insertSubview:lineFromSelf belowSubview:self.bgView];
        [_connectionsToParentNodes addObject:lineFromSelf];
      
      UIView* lineToParent = [[UIView alloc] initWithFrame:CGRectMake(meetingPointToParent.x - kLineWidth * .5f, connectionToParent.y,
                                                                      kLineWidth, meetingPointToParent.y - connectionToParent.y + 2)];
        [lineToParent setBackgroundColor:[UIColor colorWithHexString:LIGHT_LINE_COLOR]];
        [self insertSubview:lineToParent belowSubview:self.bgView];
        [_connectionsToParentNodes addObject:lineToParent];
      
      const BOOL parentToTheRight = (connectionToParent.x - connectionFromSelf.x) > 0;
      
      UIImageView* curveFromSelf = [[UIImageView alloc] initWithFrame:
                                    CGRectMake(parentToTheRight ? lineFromSelf.originX : lineFromSelf.originX + lineFromSelf.width - kCornerSize.width,
                                               lineFromSelf.originY - kCornerSize.height, kCornerSize.width, kCornerSize.height)];
        [curveFromSelf setImage:[UIImage imageNamed:LIGHT_CURVE]];
        [curveFromSelf.layer setTransform:CATransform3DMakeScale(parentToTheRight ? 1.f : -1.f, 1.f, 1.f)];
        [self insertSubview:curveFromSelf belowSubview:self.bgView];
        [_connectionsToParentNodes addObject:curveFromSelf];
      
      UIImageView* curveToParent = [[UIImageView alloc] initWithFrame:
                                    CGRectMake(parentToTheRight ? lineToParent.originX + lineToParent.width - kCornerSize.width : lineToParent.originX,
                                               lineToParent.originY + lineToParent.height, kCornerSize.width, kCornerSize.height)];
        [curveToParent setImage:[UIImage imageNamed:LIGHT_CURVE]];
        [curveToParent.layer setTransform:CATransform3DMakeScale(parentToTheRight ? -1.f : 1.f, -1.f, 1.f)];
        [self insertSubview:curveToParent belowSubview:self.bgView];
        [_connectionsToParentNodes addObject:curveToParent];
      
      UIView* connectingLine = [[UIView alloc] initWithFrame:
                                CGRectMake((parentToTheRight ? curveFromSelf.originX : curveToParent.originX) + kCornerSize.width, curveFromSelf.originY,
                                           ABS(meetingPointToParent.x - meetingPointFromSelf.x) + kLineWidth - kCornerSize.width * 2.f, kLineWidth)];
        [connectingLine setBackgroundColor:[UIColor colorWithHexString:LIGHT_LINE_COLOR]];
        [self insertSubview:connectingLine belowSubview:self.bgView];
        [_connectionsToParentNodes addObject:connectingLine];
    }
    
    [_parentNodes addObject:parentButtonView];
  }
}

- (void) highlightPathToParentNodes:(BOOL)highlight needsBlackOutline:(BOOL)needsBlackOutline
{
  if (needsBlackOutline)
    [self.outline setImage:[UIImage imageNamed:highlight ? DARK_GREY_OUTLINE : LIGHT_GREY_OUTLINE]];
  
  for (UIView* connection in _connectionsToParentNodes)
  {
    if ([connection isKindOfClass:[UIImageView class]]) // Curve
      [(UIImageView*)connection setImage:[UIImage imageNamed:highlight ? DARK_CURVE : LIGHT_CURVE]];
    else // Line
      [connection setBackgroundColor:[UIColor colorWithHexString:highlight ? DARK_LINE_COLOR : LIGHT_LINE_COLOR]];
  }
  
  for (ResearchButtonView* parentButtonView in _parentNodes)
    [parentButtonView highlightPathToParentNodes:highlight needsBlackOutline:YES];
  
  if (highlight)
  {
    [self.superview bringSubviewToFront:self]; // So that this path is displayed above all overlapping sibling connections
    [self fullOpacity];
  }
}

- (IBAction) researchSelected:(id)sender {
  [self.delegate researchButtonClickWithResearch:_userResearch sender:(id) self];
}

@end

@implementation ResearchTreeViewController

-(id)initWithDomain:(ResearchDomain)domain {
  _selectFieldViewUp = YES;
  _barAnimating = NO;
  
  if((self = [super init])){
    switch (domain) {
      case ResearchDomainBattle:
        self.title = @"Battle Research";
        break;
      case ResearchDomainResources:
        self.title = @"Resource Research";
        break;
      case ResearchDomainRestorative:
        self.title = @"Restorative Research";
        break;
      case ResearchDomainLevelup:
        self.title = @"Level Up Research";
        break;
      case ResearchDomainItems:
        self.title = @"Items Research";
        break;
      case ResearchDomainTrapsAndObstacles:
        self.title = @"Obstacles Research";
        break;
      case ResearchDomainNoDomain:
        self.title = nil;
        break;
    }
  }

  [self createResearchButtonViewsForDomain:domain];
  
  return self;
}

- (void) createResearchButtonViewsForDomain:(ResearchDomain)domain
{
  GameState* gs = [GameState sharedGameState];
  NSArray* staticResearches = [gs allStaticResearchForDomain:domain];
  ResearchTreeView* treeView = (ResearchTreeView*)self.view;
  _researchButtons = [NSMutableArray array];
  
  NSMutableDictionary* tieredResearches = [NSMutableDictionary dictionary];
  for (ResearchProto* research in staticResearches)
    if (research.level == 1)
    {
      if (![tieredResearches objectForKey:@( research.tier )])
        [tieredResearches setObject:[NSMutableArray array] forKey:@( research.tier )];
      [(NSMutableArray*)[tieredResearches objectForKey:@( research.tier )] addObject:research];
    }
  
  const CGSize  kResearchButtonViewSize = CGSizeMake(80.f, 135.f);
  const CGFloat kResearchTreeTopPadding = 0.f;
  const CGFloat kResearchTreeBottomPadding = 0.f;
  
  NSMutableDictionary* researchButtonViews = [NSMutableDictionary dictionary];
  for (int tier = 1; tier < tieredResearches.count + 1; ++tier)
  {
    NSArray* sortedResearches = [(NSArray*)[tieredResearches objectForKey:@( tier )] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      return [(ResearchProto*)obj1 priority] > [(ResearchProto*)obj2 priority];
    }];
    
    float minPriority = 0.f, maxPriority = 0.f;
    for (ResearchProto* research in sortedResearches)
      maxPriority = MAX(maxPriority, research.priority);
    
    TouchableSubviewsView* tierContainer = [[TouchableSubviewsView alloc] initWithFrame:
                                            CGRectMake(0.f, kResearchTreeTopPadding + (tier - 1) * kResearchButtonViewSize.height,
                                                       treeView.mainView.width, kResearchButtonViewSize.height)];
    [treeView.mainView insertSubview:tierContainer atIndex:0]; // Insert underneath the tier positioned above
    
    for (ResearchProto* research in sortedResearches)
    {
      UserResearch* userResearch = [gs.researchUtil currentRankForResearch:research];
      
      NSMutableSet* parentResearchButtonViews = [NSMutableSet set];
      NSArray* parentResearches = [gs prerequisitesForGameType:GameTypeResearch gameEntityId:research.researchId];
      for (PrereqProto *pp in parentResearches)
        if (pp.prereqGameType == GameTypeResearch && [researchButtonViews objectForKey:@( pp.prereqGameEntityId )])
          [parentResearchButtonViews addObject:[researchButtonViews objectForKey:@( pp.prereqGameEntityId )]];
      
      ResearchButtonView *researchButtonView = [[NSBundle mainBundle] loadNibNamed:@"ResearchButtonView" owner:self options:nil][0];
      {
        [researchButtonView setCenter:
         CGPointMake(tierContainer.width * .5f + (research.priority - (maxPriority - minPriority) * .5f) * kResearchButtonViewSize.width,
                     tierContainer.height * .5f)];
        [tierContainer addSubview:researchButtonView];
        [researchButtonView updateForResearch:userResearch parentNodes:parentResearchButtonViews];
        [researchButtonView setDelegate:self];
      }
      
      [_researchButtons addObject:researchButtonView];
      [researchButtonViews setObject:researchButtonView forKey:@( research.researchId )];
    }
  }
  
  _contentSize = CGSizeMake(treeView.mainView.size.width, tieredResearches.count * kResearchButtonViewSize.height + kResearchTreeBottomPadding);
  treeView.scrollView.contentSize = _contentSize;
  
  [treeView.mainView sendSubviewToBack:self.bgButton];
  [Globals alignSubviewsToPixelsBoundaries:treeView.mainView];
}

-(void)viewDidLoad {
  self.titleImageName = @"researchtoons.png";
}

-(void)researchButtonClickWithResearch:(UserResearch *)userResearch sender:(id)sender {
  
  ResearchButtonView *clicked = (ResearchButtonView *)sender;
  if (clicked != _lastClicked) {
    [_lastClicked deselect];
    [_researchButtons makeObjectsPerformSelector:@selector(dropOpacity)];
    [clicked select];
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
    
    ResearchTreeView *treeView = (ResearchTreeView *)self.view;
    treeView.scrollView.contentSize = CGSizeMake(_contentSize.width, _contentSize.height + _curBarView.height);
    [UIView animateWithDuration:0.3f animations:^{
      const CGFloat yOffset = [treeView.mainView convertPoint:_lastClicked.center fromView:_lastClicked.superview].y - treeView.scrollView.contentOffset.y - treeView.height * .5f;
      treeView.scrollView.contentOffset = CGPointMake(treeView.scrollView.contentOffset.x, clampf(treeView.scrollView.contentOffset.y + yOffset, 0.f, treeView.scrollView.contentSize.height));
    }];
    
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
  
}

-(IBAction)deselectTree:(id)sender {
  [_lastClicked deselect];
  [_researchButtons makeObjectsPerformSelector:@selector(fullOpacity)];
  
  ResearchTreeView *treeView = (ResearchTreeView *)self.view;
  [UIView animateWithDuration:0.3f animations:^{
    treeView.scrollView.contentSize = _contentSize;
  }];
  
  UIView *outView = _curBarView;
  [_curBarView animateOut:^{
    [outView removeFromSuperview];
  }];
  _curBarView = nil;
  
  [self scrollViewDidScroll:treeView.scrollView];
  
  _lastClicked = nil;
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
    if( scrollView.contentOffset.y > 20) {
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
    if( scrollView.contentOffset.y < 20) {
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


