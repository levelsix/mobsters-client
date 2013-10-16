//
//  GameMap.h
//  IsoMap
//
//  Created by Ashwin Kamath on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "NibUtils.h"
#import "Building.h"
#import "AnimatedSprite.h"
#import "Drops.h"
#import "DecorationLayer.h"
#import "MyPlayer.h"

#define OVER_HOME_BUILDING_MENU_OFFSET 5.f

#define MAX_ZOOM 1.8f
#define MIN_ZOOM 0.3f
#define DEFAULT_ZOOM 0.8f

#define SILVER_STACK_BOUNCE_DURATION 1.f
#define DROP_LABEL_DURATION 3.f
#define PICK_UP_WAIT_TIME 2
#define DROP_ROTATION 0

@class Building;
@class SelectableSprite;

//CCMoveByCustom
@interface CCMoveByCustom : CCMoveBy

-(void) update: (ccTime) t;

@end


//CClCustom
@interface CCMoveToCustom : CCMoveTo

- (void) update: (ccTime) t;

@end

@interface EnemyPopupView : UIView

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageIcon;
@property (nonatomic, retain) IBOutlet UIView *enemyView;
@property (nonatomic, retain) IBOutlet UIView *allyView;

@end

@interface GameMap : CCTMXTiledMap {
  NSMutableArray *_mapSprites;
  NSMutableArray *_walkableData;
  
  CGPoint bottomLeftCorner;
  CGPoint topRightCorner;
  
  MyPlayer *_myPlayer;
}

@property (nonatomic, assign) SelectableSprite *selected;
@property (nonatomic, retain) NSArray *mapSprites;

@property (nonatomic, retain) DecorationLayer *decLayer;

@property (nonatomic, retain) NSMutableArray *walkableData;

@property (nonatomic, assign) CGSize tileSizeInPoints;

@property (nonatomic, assign) int silverOnMap;
@property (nonatomic, assign) int goldOnMap;

@property (nonatomic, assign) int cityId;

// This will be used to replace the chat view in the top bar
@property (nonatomic, assign) UIView *bottomOptionView;

+ (id) tiledMapWithTMXFile:(NSString*)tmxFile;
- (id) initWithTMXFile:(NSString *)tmxFile;
- (CGPoint)convertVectorToGL:(CGPoint)uiPoint;
- (void) doReorder;
- (SelectableSprite *) selectableForPt:(CGPoint)pt;
- (void) layerWillDisappear;

- (void) pickUpAllDrops;

- (void) moveToCenterAnimated:(BOOL)animated;
- (void) moveToSprite:(CCSprite *)spr animated:(BOOL)animated;
- (float) moveToSprite:(CCSprite *)spr animated:(BOOL)animated withOffset:(CGPoint)offset;

- (CGPoint) randomWalkablePosition;
- (CGPoint) nextWalkablePositionFromPoint:(CGPoint)point prevPoint:(CGPoint)prevPt;

- (void) drag:(UIGestureRecognizer*)recognizer node:(CCNode*)node;
- (void) tap:(UIGestureRecognizer*)recognizer node:(CCNode*)node;
- (void) scale:(UIGestureRecognizer*)recognizer node:(CCNode*)node;

- (CGPoint) convertTilePointToCCPoint:(CGPoint)pt;
- (CGPoint) convertCCPointToTilePoint:(CGPoint)pt;

@end