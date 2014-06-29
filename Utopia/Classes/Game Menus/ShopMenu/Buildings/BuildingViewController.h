//
//  BuildingViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

#import "MonsterListView.h"

@interface BuildingViewController : PopupSubViewController <MonsterListDelegate>

@property (nonatomic, retain) IBOutlet MonsterListView *listView;

@end
