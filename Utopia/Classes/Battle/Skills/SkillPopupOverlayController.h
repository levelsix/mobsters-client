//
//  SkillPopupOverlayController.h
//  Utopia
//
//  Created by Rob Giusti on 5/11/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#include <Foundation/Foundation.h>
#include "SkillPopupOverlay.h"
#include "NewBattleLayer.h"

@interface SkillPopupOverlayController : NSObject {
  SkillPopupOverlay* _popupOverlay;
  SkillPopupData* _currentSkillPopup;
  SkillPopupBlock _currentBlock;
  BOOL _belongsToPlayer;
}

@property (nonatomic, retain) NewBattleLayer* battleLayer;

- (id) initWithBelongsToPlayer:(BOOL)belongsToPlayer;
- (void) showCurrentSkillPopup;
- (void) enqueueSkillPopup:(SkillPopupData*)data;
- (void) enqueueItemPopup:(BattleItemProto*)bip bottomText:(NSString*)bottomText;

@end
