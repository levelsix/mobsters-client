//
//  NSString+Validation.h
//  WithBuddiesCore
//
//  Created by Tim Gostony on 6/26/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const int WBMinUsernameLength;
extern const int WBMaxUsernameLength;
extern const int WBMinPasswordLength;
extern const int WBMaxPasswordLength;
extern const int WBMaxEmailLength;

@interface NSString (Validation)

-(BOOL)isValidUsername;
-(BOOL)isValidUsernameWithError:(NSError**)error;
-(BOOL)isValidUsernameChange:(NSRange)range replacementString:(NSString*)replacementString;

-(BOOL)isValidPassword;
-(BOOL)isValidPasswordWithError:(NSError**)error;

-(BOOL)isValidEmail;
-(BOOL)isValidEmailWithError:(NSError**)error;

@end
