//
//  SpriteAnimationImageView.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 4/6/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpriteAnimationImageView : UIImageView
{
  NSString* _spriteName;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* spinner;

- (void) setSprite:(NSString*)spriteName;

@end
