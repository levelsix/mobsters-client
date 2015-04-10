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

@implementation ResearchSelectionBarView

- (void) updateForUserResearch:(UserResearch *)userResearch {
  ResearchProto *proto = userResearch.staticResearch;
  BOOL isAvailable = [proto prereqsComplete];
  
  [Globals imageNamed:userResearch.staticResearch.iconImgName withView:self.selectionIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  int curRank = userResearch.staticResearchForBenefitLevel.level;
  int maxRank = userResearch.staticResearch.maxLevelResearch.level;
  self.rankTotal.text = [NSString stringWithFormat:@"%d/%d", curRank, maxRank];
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

- (IBAction) clicked:(id)sender {
  [self.delegate researchBarClicked:self];
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


int x = 0;
- (void) select {
  x = 0;
  self.bgView.hidden = !_isAvailable;
  self.outline.image = _isAvailable ? [Globals imageNamed:AVAILABLE_OUTLINE] : [Globals imageNamed:UNAVAILABLE_OUTLINE];
  
  [self highlightPathToParentNodes:YES needsBlackOutline:NO ignoreNodes:[NSMutableArray array]];
}

- (void) deselect {
  self.bgView.hidden = YES;
  self.outline.image = [Globals imageNamed:LIGHT_GREY_OUTLINE];
  
  [self highlightPathToParentNodes:NO needsBlackOutline:NO ignoreNodes:[NSMutableArray array]];
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
  ResearchProto *research = userResearch.staticResearch;
  
  self.researchNameLabel.text = research.name;
  int curRank = userResearch.staticResearchForBenefitLevel.level;
  int maxRank = userResearch.staticResearch.maxLevelResearch.level;
  self.rankCountLabel.text = [NSString stringWithFormat:@"%d/%d", curRank, maxRank];
  self.researchNameLabel.height = [self.researchNameLabel.text getSizeWithFont:self.researchNameLabel.font
                                                             constrainedToSize:CGSizeMake(self.researchNameLabel.width, MAXFLOAT)].height;
  self.rankLabel.originY = CGRectGetMaxY(self.researchNameLabel.frame);
  self.rankCountLabel.originY = self.rankLabel.originY;
  self.researchingTimeLeftLabel.originY = self.rankLabel.originY;
  
  _isAvailable = [userResearch.staticResearch prereqsComplete];
  self.researchNameLabel.textColor = [UIColor colorWithHexString:_isAvailable ? @"2AB4E8" : @"555555"];
  self.rankCountLabel.textColor = [UIColor colorWithHexString:_isAvailable ? @"333333" : @"999999"];
  self.lockedIcon.hidden = _isAvailable;
  
  [Globals imageNamed:research.iconImgName withView:self.researchIcon greyscale:!_isAvailable indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];
  
  if (!userResearch.complete)
  {
    self.rankLabel.hidden = YES;
    self.rankCountLabel.hidden = YES;
    self.researchingCircle.hidden = NO;
    self.researchingTimeLeftLabel.hidden = NO;
    
    [self updateTimeLeftLabelForResearch:userResearch];
    
    CABasicAnimation* spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    spinAnimation.fromValue = @(0.f);
    spinAnimation.toValue = @(-M_PI * 2.f);
    spinAnimation.duration = 2.f;
    spinAnimation.repeatCount = INFINITY;
    [self.researchingCircle.layer addAnimation:spinAnimation forKey:@"ResearchingCircleSpinAnimation"];
  }
  else
  {
    [self.researchingCircle.layer removeAllAnimations];
    
    self.rankLabel.hidden = NO;
    self.rankCountLabel.hidden = NO;
    self.researchingTimeLeftLabel.hidden = YES;
    self.researchingCircle.hidden = YES;
  }
  
  if (parentNodes)
    [self drawTreeHierarchyToParentNodes:parentNodes];
}

- (void) updateTimeLeftLabelForResearch:(UserResearch *)userResearch
{
  if (!self.researchingTimeLeftLabel.hidden)
  {
    const NSTimeInterval timeLeft = [[userResearch tentativeCompletionDate] timeIntervalSinceNow];
    self.researchingTimeLeftLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
  }
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
      [curveFromSelf setImage:[Globals imageNamed:LIGHT_CURVE]];
      [curveFromSelf.layer setTransform:CATransform3DMakeScale(parentToTheRight ? 1.f : -1.f, 1.f, 1.f)];
      [self insertSubview:curveFromSelf belowSubview:self.bgView];
      [_connectionsToParentNodes addObject:curveFromSelf];
      
      UIImageView* curveToParent = [[UIImageView alloc] initWithFrame:
                                    CGRectMake(parentToTheRight ? lineToParent.originX + lineToParent.width - kCornerSize.width : lineToParent.originX,
                                               lineToParent.originY + lineToParent.height, kCornerSize.width, kCornerSize.height)];
      [curveToParent setImage:[Globals imageNamed:LIGHT_CURVE]];
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

- (void) highlightPathToParentNodes:(BOOL)highlight needsBlackOutline:(BOOL)needsBlackOutline ignoreNodes:(NSMutableArray *)ignoreNodes
{
  if (needsBlackOutline)
    [self.outline setImage:[Globals imageNamed:highlight ? DARK_GREY_OUTLINE : LIGHT_GREY_OUTLINE]];
  
  for (UIView* connection in _connectionsToParentNodes)
  {
    if ([connection isKindOfClass:[UIImageView class]]) // Curve
      [(UIImageView*)connection setImage:[Globals imageNamed:highlight ? DARK_CURVE : LIGHT_CURVE]];
    else // Line
      [connection setBackgroundColor:[UIColor colorWithHexString:highlight ? DARK_LINE_COLOR : LIGHT_LINE_COLOR]];
  }
  
  for (ResearchButtonView* parentButtonView in _parentNodes) {
    if (![ignoreNodes containsObject:parentButtonView]) {
      [ignoreNodes addObject:parentButtonView];
      [parentButtonView highlightPathToParentNodes:highlight needsBlackOutline:YES ignoreNodes:ignoreNodes];
    }
  }
  
  if (highlight)
  {
    [self.superview bringSubviewToFront:self]; // So that this path is displayed above all overlapping sibling connections
    [self fullOpacity];
  }
}

- (IBAction) researchSelected:(id)sender {
  [self.delegate researchButtonClicked:self];
}

@end

@implementation ResearchTreeViewController

- (id) initWithDomain:(ResearchDomain)domain {
  if ((self = [super init])){
    _selectFieldViewUp = YES;
    _barAnimating = NO;
    
    _domain = domain;
  }
  
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.title = [NSString stringWithFormat:@"%@ Research", [Globals stringForResearchDomain:_domain]];
  
  [self createResearchButtonViewsForDomain:_domain];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self waitTimeComplete];
}

- (void) updateLabels {
  for (int i = 0; i < _researchButtons.count && i < _userResearches.count; i++) {
    ResearchButtonView *rbv = _researchButtons[i];
    UserResearch *ur = _userResearches[i];
    
    if (!ur.complete)
      [rbv updateTimeLeftLabelForResearch:ur];
  }
}

- (void) waitTimeComplete {
  for (int i = 0; i < _researchButtons.count && i < _userResearches.count; i++) {
    ResearchButtonView *rbv = _researchButtons[i];
    UserResearch *ur = _userResearches[i];
    
    // They will use the old parent nodes
    [rbv updateForResearch:ur parentNodes:nil];
  }
  
  [_curBarView updateForUserResearch:_selectedResearch];
}

- (void) createResearchButtonViewsForDomain:(ResearchDomain)domain
{
  // Clear out previous version if necessary
  if (_researchButtons) {
    for (UIView *v in _researchButtons) {
      [v removeFromSuperview];
    }
    _researchButtons = nil;
    _userResearches = nil;
  }
  
  GameState* gs = [GameState sharedGameState];
  NSArray* staticResearches = [gs allStaticResearchForDomain:domain];
  _researchButtons = [NSMutableArray array];
  _userResearches = [NSMutableArray array];
  
  NSMutableDictionary *tieredResearches = [NSMutableDictionary dictionary];
  for (ResearchProto *research in staticResearches) {
    if (research.level == 1)
    {
      if (![tieredResearches objectForKey:@( research.tier )])
        [tieredResearches setObject:[NSMutableArray array] forKey:@( research.tier )];
      [(NSMutableArray*)[tieredResearches objectForKey:@( research.tier )] addObject:research];
    }
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
                                                       self.contentView.width, kResearchButtonViewSize.height)];
    [self.contentView insertSubview:tierContainer atIndex:0]; // Insert underneath the tier positioned above
    
    for (ResearchProto* research in sortedResearches)
    {
      UserResearch* userResearch = [gs.researchUtil currentRankForResearch:research];
      
      NSMutableSet* parentResearchButtonViews = [NSMutableSet set];
      NSArray* parentResearches = [gs prerequisitesForGameType:GameTypeResearch gameEntityId:research.researchId];
      for (PrereqProto *pp in parentResearches) {
        if (pp.prereqGameType == GameTypeResearch) {
          // Get the base research for the prereq
          ResearchProto *rp = [[gs researchWithId:pp.prereqGameEntityId] minLevelResearch];
          if ([researchButtonViews objectForKey:@( rp.researchId )]) {
            [parentResearchButtonViews addObject:[researchButtonViews objectForKey:@( rp.researchId )]];
          }
        }
      }
      
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
      [_userResearches addObject:userResearch];
      [researchButtonViews setObject:researchButtonView forKey:@( research.researchId )];
    }
  }
  
  _contentSize = CGSizeMake(self.contentView.size.width, tieredResearches.count * kResearchButtonViewSize.height + kResearchTreeBottomPadding);
  self.scrollView.contentSize = _contentSize;
  
  self.contentView.height = _contentSize.height;
  self.bgButton.height = _contentSize.height;
  
  [self.contentView sendSubviewToBack:self.bgButton];
  [Globals alignSubviewsToPixelsBoundaries:self.contentView];
}

- (void) researchButtonClicked:(id)sender {
  
  ResearchButtonView *clicked = (ResearchButtonView *)sender;
  if (clicked != _lastClicked) {
    [_lastClicked deselect];
    [_researchButtons makeObjectsPerformSelector:@selector(dropOpacity)];
    [clicked select];
    _lastClicked = clicked;
    
    // Figure out which research it is
    NSInteger idx = [_researchButtons indexOfObject:clicked];
    _selectedResearch = _userResearches[idx];
    
    UIView *outView = _curBarView;
    [_curBarView animateOut:^{
      [outView removeFromSuperview];
    }];
    _curBarView = [[NSBundle mainBundle] loadNibNamed:@"ResearchSelectionBar" owner:self options:nil][0];
    [self.view addSubview:_curBarView];
    [_curBarView updateForUserResearch:_selectedResearch];
    [_curBarView animateIn:nil];
    _curBarView.delegate = self;
    
    self.scrollView.contentSize = CGSizeMake(_contentSize.width, _contentSize.height + _curBarView.height);
    [UIView animateWithDuration:0.3f animations:^{
      const CGFloat yOffset = [self.contentView convertPoint:_lastClicked.center fromView:_lastClicked.superview].y - self.scrollView.contentOffset.y - (self.view.height - _curBarView.height) * .5f;
      self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, clampf(self.scrollView.contentOffset.y + yOffset, 0.f, self.scrollView.contentSize.height - self.scrollView.height));
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

- (IBAction) deselectTree:(id)sender {
  [_lastClicked deselect];
  [_researchButtons makeObjectsPerformSelector:@selector(fullOpacity)];
  
  [UIView animateWithDuration:0.3f animations:^{
    self.scrollView.contentSize = _contentSize;
  }];
  
  UIView *outView = _curBarView;
  [_curBarView animateOut:^{
    [outView removeFromSuperview];
  }];
  _curBarView = nil;
  
  [self scrollViewDidScroll:self.scrollView];
  
  _lastClicked = nil;
  _selectedResearch = nil;
}

- (void) researchBarClicked:(id)sender {
  ResearchInfoViewController *rivc = [[ResearchInfoViewController alloc] initWithResearch:_selectedResearch];
  [self.parentViewController pushViewController:rivc animated:YES];
  
}

#pragma mark - UIScrollView Delegate Methods

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
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
