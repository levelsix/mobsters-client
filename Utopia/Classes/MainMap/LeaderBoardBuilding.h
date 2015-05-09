//
//  LeaderBoardBuilding.h
//  Utopia
//
//  Created by Kenneth Cox on 5/7/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "Building.h"

@interface LeaderBoardBuilding : Building

@property (nonatomic, retain) CCSprite *firstMonsterSprite;
@property (nonatomic, retain) CCSprite *secondMonsterSprite;
@property (nonatomic, retain) CCSprite *thirdMonsterSprite;

- (void) reloadCharacterSprites;

@end
