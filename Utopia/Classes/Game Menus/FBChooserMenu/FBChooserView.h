//
//  FBChooserView.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/3/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FBFriendCell : UITableViewCell

@property (nonatomic, retain) IBOutlet FBProfilePictureView *profilePic;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *checkmark;

@end

typedef enum {
  FBChooserStateAllFriends = 1,
  FBChooserStateGameFriends
} FBChooserState;

@interface FBChooserView : UIView <UITableViewDataSource, UITableViewDelegate, FBWebDialogsDelegate> {
  BOOL _retrievedFriends;
}

@property (nonatomic, retain) IBOutlet UITableView *chooserTable;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet FBFriendCell *friendCell;

@property (nonatomic, retain) IBOutlet UIImageView *selectAllCheckmark;

@property (nonatomic, retain) NSMutableArray *allFriendsData;
@property (nonatomic, retain) NSMutableArray *gameFriendsData;
@property (nonatomic, retain) NSSet *blacklistFriendIds;
@property (nonatomic, retain) NSMutableSet *selectedIds;

@property (nonatomic, retain) IBOutlet UIButton *allFriendsButton;
@property (nonatomic, retain) IBOutlet UIButton *gameFriendsButton;

@property (nonatomic, retain) IBOutlet UILabel *noFriendsLabel;

@property (nonatomic, assign) FBChooserState state;

- (void) retrieveFacebookFriends:(BOOL)openLoginUI;
- (void) sendRequestWithString:(NSString *)requestString completionBlock:(void(^)(BOOL success, NSArray *friendIds))completion;

@end
