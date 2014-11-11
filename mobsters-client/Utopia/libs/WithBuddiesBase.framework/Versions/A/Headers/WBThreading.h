//
//  WBThreadService.h
//  WithBuddiesCore
//
//  Created by odyth on 8/19/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <WithBuddiesBase/WBService.h>

@interface WBThreading : WBService

+(dispatch_queue_t)saveDataQueue;
+(dispatch_queue_t)serialBackgroundQueue;
+(dispatch_queue_t)concurrentBackgroundQueue;

@end
