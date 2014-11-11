//
//  GachaChooserViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/30/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

#import "ListCollectionView.h"

@interface GachaChooserViewController : PopupSubViewController <ListCollectionDelegate>

@property (nonatomic, retain) IBOutlet ListCollectionView *listView;

@property (nonatomic, retain) NSArray *boosterPacks;

@end
