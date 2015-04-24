//
//  BuildingViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

#import "ListCollectionView.h"
#import "BuildingViews.h"

@protocol BuildingViewDelegate <NSObject>

// Will return YES if it wants this to display loading view
- (BOOL) buildingPurchased:(int)structId;

@end

@interface BuildingViewController : PopupSubViewController <ListCollectionDelegate> {
  int _recommendedStructId;
}

@property (nonatomic, retain) IBOutlet ListCollectionView *listView;

@property (nonatomic, retain) NSArray *staticStructs;

@property (nonatomic, weak) id<BuildingViewDelegate> delegate;

- (void) displayArrowOverStructId:(int)structId;

- (void) reloadCarpenterStructs;

@end
