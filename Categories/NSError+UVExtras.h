//
//  NSError+UVExtras.h
//  UserVoice
//
//  Created by Rich Collins on 4/29/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSError (UVExtras)

- (BOOL)isConnectionError;
- (BOOL)isUserVoiceError;
- (NSString *)userVoiceErrorMessage;
- (BOOL)isUVErrorWithMessage:(NSString *)message;
- (BOOL)isUVRecordInvalid;
- (BOOL)isUVRecordInvalidForField:(NSString *)field withMessage:(NSString *)message;
- (BOOL)isAuthError;
- (BOOL)isNotFoundError;
- (BOOL)isUnprocessableError;

@end
