//
//  MonsterSelectViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "PopoverViewController.h"

#import "NibUtils.h"
#import "ListCollectionView.h"

@protocol MonsterSelectDelegate <NSObject>

- (NSString *) titleName;
- (NSString *) cellClassName;

- (NSString *) footerTitle;
- (NSString *) footerDescription;

- (void) updateCell:(id)cell monster:(id)monster;
- (void) monsterSelected:(id)monster viewController:(id)viewController;
- (void) monsterSelectClosed;

- (NSArray *) reloadMonstersArray;

@end

@interface MonsterSelectViewController : PopoverViewController <ListCollectionDelegate>

@property (nonatomic, retain) IBOutlet ListCollectionView *listView;

@property (nonatomic, retain) IBOutlet UILabel *footerTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *footerDescLabel;

@property (nonatomic, retain) NSArray *monsters;

@property (nonatomic, weak) id<MonsterSelectDelegate> delegate;

- (void) reloadDataAnimated:(BOOL)animated;
- (void) reloadData;

@end
