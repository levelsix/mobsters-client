//
//  MiniEventManager.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "Protocols.pb.h"

@protocol MiniEventInfoViewProtocol <NSObject>

@required

- (void) updateForUserMiniEvent:(UserMiniEventProto*)userMiniEvent;

@optional

- (void) miniEventViewWillAppear;
- (void) miniEventViewWillDisappear;

@end

@interface MiniEventManager : NSObject
{
  
}

@property (nonatomic, strong, readonly) UserMiniEventProto* currentUserMiniEvent; // Might be nil, in case of no active user mini event

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(MiniEventManager)

- (void) handleUserMiniEventReceivedOnStartup:(UserMiniEventProto*)userMiniEvent;

@end
