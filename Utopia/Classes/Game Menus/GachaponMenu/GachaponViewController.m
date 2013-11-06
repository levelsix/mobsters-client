//
//  GachaponViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/31/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "GachaponViewController.h"
#import "cocos2d.h"
#import "Globals.h"

@interface GachaponViewController ()

@end

@implementation GachaponItemCell

- (void) awakeFromNib {
  self.containerView.layer.cornerRadius = 5.f;
}

- (void) update:(int)val {
  self.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"fakepiece%d.png", val%3+1]];
//  self.label.text = [Globals commafyNumber:val];
}

@end

@implementation GachaponViewController

#define NUM_ROWS INT_MAX/10000

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = @"Goonie Grab";
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  [self.gachaTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NUM_ROWS/2 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (CGPoint) nearestCellMiddleFromPoint:(CGPoint)pt {
  // Input and output will be relative to contentOffset
  float nearest = roundf((pt.y+self.gachaTable.frame.size.height/2)/self.gachaTable.rowHeight+0.5)-0.5;
  pt.y = nearest*self.gachaTable.rowHeight-self.gachaTable.frame.size.height/2;
  return pt;
}

- (IBAction)spinClicked:(id)sender {
  if (self.gachaTable.isDragging || _isSpinning) {
    return;
  }
  
  CGPoint pt = self.gachaTable.contentOffset;
  pt = [self nearestCellMiddleFromPoint:ccp(pt.x, pt.y+5000)];
  [self.gachaTable setContentOffset:pt withTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0 :.51 :0 :.99] duration:5.f];
  
  self.gachaTable.userInteractionEnabled = NO;
  _isSpinning = YES;
  
  // Doesn't matter which bool you send in
  [self beginMachineIconPulsing:YES];
}

- (void) beginMachineIconPulsing:(BOOL)isFatter {
  // Basically using a formula similar to y = mx+b but using (1,1) as origin
  float x = isFatter ? 0.15 : -0.03;
  float m = 0.8f;
  CGAffineTransform t1 = CGAffineTransformMakeScale(1+x, 1-m*x);
  
#define ANIMATION_TIME 3.f
  
  [UIView animateWithDuration:ABS(x)*ANIMATION_TIME delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
    self.machineIcon.transform = t1;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:ABS(x)*ANIMATION_TIME delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
      self.machineIcon.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
      if (_isSpinning) {
        [self beginMachineIconPulsing:!isFatter];
      }
    }];
  }];
}

#pragma mark - UITableViewDelegate/DataSource methods

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return NUM_ROWS;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GachaponItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GachaponItemCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"GachaponItemCell" owner:self options:nil];
    cell = self.itemCell;
  }
  
  [cell update:indexPath.row];
  
  return cell;
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
  CGPoint pt = *targetContentOffset;
  pt = [self nearestCellMiddleFromPoint:pt];
  targetContentOffset->y = pt.y;
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  self.gachaTable.userInteractionEnabled = YES;
  _isSpinning = NO;
}

@end
