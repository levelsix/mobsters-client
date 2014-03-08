//
//  TutorialCarpenterViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "CarpenterViewController.h"

@protocol TutorialCarpenterDelegate <NSObject>

- (void) buildingPurchased:(int)structId;

@end

@interface TutorialCarpenterViewController : CarpenterViewController

@property (nonatomic, assign) id<TutorialCarpenterDelegate> delegate;

@property (nonatomic, retain) StartupResponseProto_TutorialConstants *constants;
@property (nonatomic, retain) NSArray *curStructs;

@property (nonatomic, assign) int clickableStructId;

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants curStructs:(NSArray *)curStructs;

- (void) allowPurchaseOfStructId:(int)structId;

@end
