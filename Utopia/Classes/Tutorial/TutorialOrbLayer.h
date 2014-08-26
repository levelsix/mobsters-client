//
//  TutorialOrbLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "OrbMainLayer.h"

@interface TutorialOrbLayer : OrbMainLayer

@property (nonatomic, retain) NSMutableArray *presetOrbs;
@property (nonatomic, retain) NSMutableArray *presetOrbIndices;

@property (nonatomic, retain) CCNode *forcedMoveLayer;
@property (nonatomic, retain) CCSprite *handSprite;
@property (nonatomic, retain) NSArray *shownGems;
@property (nonatomic, retain) NSArray *forcedMove;

- (id) initWithGridSize:(CGSize)gridSize numColors:(int)numColors presetLayoutFile:(NSString *)presetLayoutFile;

- (void) createOverlayAvoidingPositions:(NSArray *)shownGems withForcedMove:(NSArray *)forcedMove;

@end
