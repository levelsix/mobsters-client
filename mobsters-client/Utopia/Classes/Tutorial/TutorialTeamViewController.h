//
//  TutorialTeamViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 7/9/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TeamViewController.h"

@protocol TutorialTeamDelegate <NSObject>

- (void) addedMobsterToTeam;
- (void) teamOpened;
- (void) teamClosed;

@end

@interface TutorialTeamViewController : TeamViewController {
  BOOL _arrowOverPlusCreated;
  
  BOOL _allowClose;
}

@property (nonatomic, assign) uint64_t clickableUserMonsterId;

@property (nonatomic, assign) id<TutorialTeamDelegate> delegate;

- (void) moveToMonster:(uint64_t)userMonsterId;
- (void) unequipSlotThree;
- (void) allowEquip:(uint64_t)userMonsterId;
- (void) allowClose;

@end
