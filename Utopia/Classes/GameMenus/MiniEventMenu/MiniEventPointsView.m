//
//  MiniEventPointsView.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MiniEventPointsView.h"
#import "MiniEventPointsActionCell.h"
#import "NibUtils.h"

@implementation MiniEventPointsView

- (void) awakeFromNib
{
  [super awakeFromNib];
  
  UIImageView* backgroundLeftCap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventblueheadercap.png"]];
  {
    backgroundLeftCap.frame = CGRectMake(self.eventInfoBackground.originX - 7, self.eventInfoBackground.originY, 7, self.eventInfoBackground.height);
    [self insertSubview:backgroundLeftCap belowSubview:self.eventInfoBackground];
  }
  UIImageView* backgroundRightCap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventblueheadercap.png"]];
  {
    backgroundRightCap.frame = CGRectMake(self.eventInfoBackground.originX + self.eventInfoBackground.width, self.eventInfoBackground.originY, 7, self.eventInfoBackground.height);
    backgroundRightCap.layer.transform = CATransform3DMakeScale(-1, 1, 1);
    [self insertSubview:backgroundRightCap belowSubview:self.eventInfoBackground];
  }
  
  self.eventInfoName.gradientStartColor = [UIColor whiteColor];
  self.eventInfoName.gradientEndColor   = [UIColor colorWithHexString:@"DCF8FF"];
  self.eventInfoName.shadowColor  = [UIColor colorWithWhite:.25 alpha:1.f];
  self.eventInfoName.shadowOffset = CGSizeMake(0, 1);
  self.eventInfoName.shadowBlur   = 1.2f;
  
  self.eventInfoDesc.shadowColor  = [UIColor colorWithWhite:.6 alpha:1.f];
  self.eventInfoDesc.shadowOffset = CGSizeMake(0, .5);
  self.eventInfoDesc.shadowBlur   = 1.2f;
  
  self.eventInfoEndsIn.shadowColor  = [UIColor colorWithWhite:.6 alpha:1.f];
  self.eventInfoEndsIn.shadowOffset = CGSizeMake(0, .5);
  self.eventInfoEndsIn.shadowBlur   = 1.2f;
  
  self.eventInfoTimeLeft.shadowColor  = [UIColor colorWithWhite:.25 alpha:1.f];
  self.eventInfoTimeLeft.shadowOffset = CGSizeMake(0, .5);
  self.eventInfoTimeLeft.shadowBlur   = 1.2f;
  
  self.eventInfoMyPoints.shadowColor  = [UIColor colorWithWhite:.6 alpha:1.f];
  self.eventInfoMyPoints.shadowOffset = CGSizeMake(0, .5);
  self.eventInfoMyPoints.shadowBlur   = 1.2f;
  
  self.eventInfoPointsEearned.gradientStartColor = [UIColor colorWithHexString:@"CAF45A"];
  self.eventInfoPointsEearned.gradientEndColor   = [UIColor colorWithHexString:@"AEEE3A"];
  self.eventInfoPointsEearned.shadowColor  = [UIColor colorWithWhite:.25 alpha:1.f];
  self.eventInfoPointsEearned.shadowOffset = CGSizeMake(0, 1);
  self.eventInfoPointsEearned.shadowBlur   = 1.2f;
  
  self.eventActionsList.contentInset = UIEdgeInsetsMake(4, 0, 0, 0);
  
  [self.eventActionsList registerNib:[UINib nibWithNibName:@"MiniEventPointsActionCell" bundle:nil] forCellReuseIdentifier:@"ReusablePointsActionCell"];
}

- (void) updateForMiniEvent
{
  
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
  return 1;
}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
  return 5;
}

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
  MiniEventPointsActionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ReusablePointsActionCell" forIndexPath:indexPath];
  return cell;
}

@end
