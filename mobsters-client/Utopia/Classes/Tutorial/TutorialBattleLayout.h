//
//  TutorialBattleLayout.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/25/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "BattleOrbLayout.h"

@interface TutorialBattleLayout : BattleOrbLayout

@property (nonatomic, retain) NSMutableArray *presetOrbs;

- (id) initWithGridSize:(CGSize)gridSize numColors:(int)numColors presetLayoutFile:(NSString *)presetLayoutFile;

@end
