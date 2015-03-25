//
//  MiniEventManager.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MiniEventInfoViewProtocol <NSObject>

@required

- (void) updateForMiniEvent;

@end

@interface MiniEventManager : NSObject

@end
