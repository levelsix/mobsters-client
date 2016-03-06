//
//  BoardDesignerObstacleView.m
//  Utopia
//
//  Created by Behrouz N. on 3/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BoardDesignerObstacleView.h"
#import "GameState.h"
#import "Globals.h"

@interface PvpBoardObstacleProto (Prereqs)

- (NSArray *) allPrerequisites;
- (NSArray *) incompletePrerequisites;
- (BOOL) satisfiesAllPrerequisites;

@end

@implementation PvpBoardObstacleProto (Prereqs)

- (NSArray *) allPrerequisites {
  GameState *gs = [GameState sharedGameState];
  NSArray *arr = [gs prerequisitesForGameType:GameTypeBoardObstacle gameEntityId:self.pvpBoardId];
  
  arr = [arr sortedArrayUsingComparator:^NSComparisonResult(PrereqProto *obj1, PrereqProto *obj2) {
    return [@(obj1.prereqId) compare:@(obj2.prereqId)];
  }];
  
  return arr;
}

- (NSArray *) incompletePrerequisites {
  NSMutableArray *arr = [NSMutableArray array];
  NSArray *allPrereqs = [self allPrerequisites];
  Globals *gl = [Globals sharedGlobals];
  
  for (PrereqProto *pp in allPrereqs) {
    if (![gl isPrerequisiteComplete:pp]) {
      [arr addObject:pp];
    }
  }
  
  return arr;
}

- (BOOL) satisfiesAllPrerequisites {
  return [self incompletePrerequisites].count == 0;
}

@end

@implementation BoardDesignerObstacleView

+ (instancetype) viewWithObstacleProto:(PvpBoardObstacleProto*)proto
{
  if (proto)
  {
    BoardDesignerObstacleView* obstacleView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil][0];
    [obstacleView updateWithObstacleProto:proto];
    return obstacleView;
  }
  return nil;
}

+ (NSString*) imageForObstacleProto:(PvpBoardObstacleProto*)proto
{
  switch (proto.obstacleType)
  {
    case BoardObstacleTypeCloud: return @"cloudobstacle.png";
    case BoardObstacleTypeLock:  return @"lockobstacle.png";
    case BoardObstacleTypeHole:  return @"holeobstacle.png";
    case BoardObstacleTypeVine:  return @"vineobstacle.png";
    default:
      return nil;
  }
}

- (void) updateWithObstacleProto:(PvpBoardObstacleProto*)proto
{
  _obstacleProto = proto;
  _obstacleImage = [BoardDesignerObstacleView imageForObstacleProto:proto];
  
  [self.obstacleImageView setImage:[Globals imageNamed:_obstacleImage]];
  [self.obstacleNameLabel setText:proto.name];
  [self.obstaclePowerCostLabel setText:[NSString stringWithFormat:@"%ld", (long)proto.powerAmt]];
  
  _isEnabled = YES;
  _isLocked = NO;
  
  if (!proto.initiallyAvailable && ![proto satisfiesAllPrerequisites])
    [self lockObstacle];
}

- (void) disableObstacle
{
  if (self.isEnabled && !self.isLocked)
  {
    [Globals imageNamed:_obstacleImage withView:self.obstacleImageView maskedColor:[UIColor colorWithWhite:.85f alpha:1.f] indicator:0 clearImageDuringDownload:NO];
    [self.obstacleNameLabel setTextColor:[UIColor colorWithHexString:@"B2B2B2"]];
    [self.obstaclePowerLabel setTextColor:[UIColor colorWithHexString:@"B2B2B2"]];
    [self.obstaclePowerCostLabel setTextColor:[UIColor colorWithHexString:@"DB2C2C"]];
    
    _isEnabled = NO;
  }
}

- (void) enableObstacle
{
  if (!self.isEnabled && !self.isLocked)
  {
    [self.obstacleImageView setImage:[Globals imageNamed:_obstacleImage]];
    [self.obstacleNameLabel setTextColor:[UIColor colorWithHexString:@"00C2FF"]];
    [self.obstaclePowerLabel setTextColor:[UIColor colorWithHexString:@"6F9F11"]];
    [self.obstaclePowerCostLabel setTextColor:[UIColor colorWithHexString:@"6F9F11"]];
    
    _isEnabled = YES;
  }
}

- (void) lockObstacle
{
  if (!self.isLocked)
  {
    [Globals imageNamed:_obstacleImage withView:self.obstacleImageView maskedColor:[UIColor colorWithWhite:.85f alpha:1.f] indicator:0 clearImageDuringDownload:NO];
    [self.obstacleNameLabel setTextColor:[UIColor colorWithHexString:@"B2B2B2"]];
    
    [self.lockImageView setHidden:NO];
    [self.lockLabel setHidden:NO];
    [self.obstaclePowerLabel setHidden:YES];
    [self.obstaclePowerCostLabel setHidden:YES];
    
    _isLocked = YES;
  }
}

- (void) unlockObstacle
{
  if (self.isLocked)
  {
    [self.obstacleImageView setImage:[Globals imageNamed:_obstacleImage]];
    [self.obstacleNameLabel setTextColor:[UIColor colorWithHexString:@"00C2FF"]];
    
    [self.lockImageView setHidden:YES];
    [self.lockLabel setHidden:YES];
    [self.obstaclePowerLabel setHidden:NO];
    [self.obstaclePowerCostLabel setHidden:NO];
    
    _isLocked = NO;
  }
}

@end
