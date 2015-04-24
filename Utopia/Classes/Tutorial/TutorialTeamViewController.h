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

@property (nonatomic, retain) NSString *clickableUserMonsterUuid;

@property (nonatomic, weak) id<TutorialTeamDelegate> delegate;

- (void) moveToMonster:(NSString *)userMonsterUuid;
- (void) unequipSlotThree;
- (void) allowEquip:(NSString *)userMonsterUuid;
- (void) allowClose;

@end
