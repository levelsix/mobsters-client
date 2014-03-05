//
//  MissionMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameMap.h"
#import "Protocols.pb.h"

#define ASSET_TAG @"Asset%d"

#define DRAGON_TAG 5456

@interface MissionMap : GameMap <MapBotViewDelegate> {
  NSMutableArray *_jobs;
  
  BOOL _allowSelection;
  BOOL _enteringDungeon;
}

@property (nonatomic, retain) IBOutlet MapBotView *missionBotView;
@property (nonatomic, assign) IBOutlet UILabel *missionNameLabel;
@property (nonatomic, assign) IBOutlet UILabel *missionDescriptionLabel;

- (id) initWithProto:(LoadCityResponseProto *)proto;
- (id) assetWithId:(int)assetId;
- (void) moveToAssetId:(int)a animated:(BOOL)animated;
- (void) changeTiles: (CGRect) buildBlock canWalk:(BOOL)canWalk;
- (void) setAllLocksAndArrowsForBuildings;
- (IBAction) performCurrentTask:(id)sender;

@end
