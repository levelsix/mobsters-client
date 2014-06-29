//
//  ClanViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "NibUtils.h"
#import "Globals.h"
#import "PopupNavViewController.h"

@class ClanBrowseViewController;
@class ClanCreateViewController;
@class ClanInfoViewController;
@class ClanRaidListViewController;
@class ClanSubViewController;

@protocol ClanViewControllerDelegate <NSObject>

- (void) clanViewControllerDidClose:(id)cvc;

@end

@interface ClanViewController : PopupNavViewController {
  BOOL _isEditing;
}

@property (nonatomic, retain) ClanBrowseViewController *clanBrowseViewController;
@property (nonatomic, retain) ClanCreateViewController *clanCreateViewController;
@property (nonatomic, retain) ClanInfoViewController *clanInfoViewController;
@property (nonatomic, retain) ClanRaidListViewController *clanRaidViewController;

@property (nonatomic, retain) IBOutlet ButtonTabBar *topBar;

@property (nonatomic, retain) NSArray *myClanMembersList;
@property (nonatomic, assign) int canStartRaidStage;

@property (nonatomic, assign) id<ClanViewControllerDelegate> delegate;

- (void) loadForClanId:(int)clanId;

@end
