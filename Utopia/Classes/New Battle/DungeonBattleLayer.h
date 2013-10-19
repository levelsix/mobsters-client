//
//  DungeonBattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/3/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "NewBattleLayer.h"
#import "Protocols.pb.h"

@interface DungeonBattleLayer : NewBattleLayer

@property (nonatomic, retain) BeginDungeonResponseProto *dungeonInfo;

+ (CCScene *) sceneWithBeginDungeonResponseProto:(BeginDungeonResponseProto *)dungeonInfo delegate:(id<BattleLayerDelegate>)delegate;
- (id) initWithBeginDungeonResponseProto:(BeginDungeonResponseProto *)dungeonInfo;

@end
