//
//  WBSettingService.h
//  WithBuddiesBase
//
//  Created by odyth on 9/23/13.
//  Copyright (c) 2013 scopely. All rights reserved.
//

#import <WithBuddiesBase/WBService.h>

@interface WBSettingService : WBService

+(NSString *)serverPathForZone:(NSString *)zone;

+(id)bundleSettingForKey:(NSString *)key;
+(id)settingForKey:(NSString *)key;

@end
