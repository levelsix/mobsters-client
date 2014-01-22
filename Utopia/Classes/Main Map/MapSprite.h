//
//  MapSprite.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/8/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "CCSprite.h"
#import "Protocols.pb.h"

#define GLOW_ACTION_TAG 3021

@class GameMap;

@interface MapSprite : CCSprite {
  GameMap *_map;
  CGRect _location;
}

@property (nonatomic, assign) CGRect location;
@property (nonatomic, assign) BOOL isFlying;

-(id) initWithFile: (NSString *) file  location: (CGRect)loc map: (GameMap *) map;

- (BOOL) isExemptFromReorder;

@end

@interface SelectableSprite : MapSprite {
  BOOL _isSelected;
  CCSprite *_glow;
}

@property (nonatomic, retain) CCSprite *arrow;

- (BOOL) select;
- (void) unselect;

- (void) displayArrow;
- (void) removeArrowAnimated:(BOOL)animated;
- (void) displayCheck;

@end

@protocol TaskElement <NSObject>

@required

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) FullTaskProto *ftp;

// So we can access these
@property (nonatomic, assign) CGRect location;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) BOOL isLocked;

- (void) displayArrow;
- (void) removeArrowAnimated:(BOOL)animated;
- (void) displayCheck;

@end