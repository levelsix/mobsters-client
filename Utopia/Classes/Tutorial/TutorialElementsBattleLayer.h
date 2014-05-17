//
//  TutorialElementsBattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialBattleLayer.h"

@interface TutorialElementsBattleLayer : MiniTutorialBattleLayer {
  BOOL _isFirstHit;
  BOOL _allowElementsClick;
}

- (void) arrowOnMyHealthBar;
- (void) removeArrowOnMyHealthBar;
- (void) arrowOnElements;

@end
