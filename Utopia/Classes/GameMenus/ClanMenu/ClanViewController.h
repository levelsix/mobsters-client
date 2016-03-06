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
@class ClanHelpViewController;

@protocol ClanViewControllerDelegate <NSObject>

- (void) clanViewControllerDidClose:(id)cvc;

@end

@interface ClanViewController : PopupNavViewController {
  BOOL _isEditing;
  
  ButtonTabBar *_activeTopBar;
}

@property (nonatomic, retain) ClanBrowseViewController *clanBrowseViewController;
@property (nonatomic, retain) ClanCreateViewController *clanCreateViewController;
@property (nonatomic, retain) ClanInfoViewController *clanInfoViewController;
@property (nonatomic, retain) ClanRaidListViewController *clanRaidViewController;
@property (nonatomic, retain) ClanHelpViewController *clanHelpViewController;

@property (nonatomic, retain) IBOutlet ButtonTabBar *noClanTopBar;
@property (nonatomic, retain) IBOutlet ButtonTabBar *inClanTopBar;
@property (nonatomic, retain) IBOutlet BadgeIcon *helpBadge;

@property (nonatomic, retain) IBOutlet UIImageView *bgdImgView;

@property (nonatomic, retain) NSArray *myClanMembersList;
@property (nonatomic, assign) int canStartRaidStage;

@property (nonatomic, weak) id<ClanViewControllerDelegate> delegate;

- (void) loadForClanUuid:(NSString *)clanUuid;

@end
