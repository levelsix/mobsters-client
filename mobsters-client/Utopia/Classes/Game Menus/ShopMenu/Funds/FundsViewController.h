//
//  FundsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

#import "ListCollectionView.h"
#import "FundsViews.h"
#import "NibUtils.h"
#import "InAppPurchaseData.h"

@interface FundsViewController : PopupSubViewController <ListCollectionDelegate> {
  id<InAppPurchaseData> _purchase;
  
  BOOL _isLoading;
}

@property (nonatomic, retain) IBOutlet ListCollectionView *listView;

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

@property (nonatomic, retain) NSArray *packages;

@end
