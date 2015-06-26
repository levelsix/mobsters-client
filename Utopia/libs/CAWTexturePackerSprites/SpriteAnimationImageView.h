//
//  SpriteAnimationImageView.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 4/6/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SpriteAnimationImageViewDelegate <NSObject>

- (void) playingAnimation:(id)animImageView;

@end

@interface SpriteAnimationImageView : UIImageView
{
  NSString* _spriteName;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* spinner;

@property (nonatomic, weak) id<SpriteAnimationImageViewDelegate> delegate;

- (void) setSprite:(NSString*)spriteName secsBetweenReplay:(float)secsBetweenReplay fps:(float)fps;
- (void) setSprite:(NSString*)spriteName secsBetweenReplay:(float)secsBetweenReplay fps:(float)fps useiPhone6Prefix:(BOOL)useiPhone6Prefix useiPadSuffix:(BOOL)iPadSuffix;

@end
