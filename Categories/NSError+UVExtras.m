//
//  NSError+UVExtras.m
//  UserVoice
//
//  Created by Rich Collins on 4/29/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "NSError+UVExtras.h"


@implementation NSError (UVExtras)

- (BOOL)isConnectionError {
	return ([self domain] == NSURLErrorDomain) && (
		[self code] == -1001 ||
		[self code] == -1004 ||
		[self code] == -1009);
}

- (BOOL)isUserVoiceError {
	return [self domain] == @"uservoice";
}

- (NSString *)userVoiceErrorMessage {
	return [[self userInfo] objectForKey:@"message"];
}

- (BOOL)isUVErrorWithMessage:(NSString *)message {
	return [self isUserVoiceError] && [[self userVoiceErrorMessage] isEqualToString:message];
}

- (BOOL)isUVRecordInvalid {
	return [self isUserVoiceError] && [[[self userInfo] objectForKey:@"type"] isEqualToString:@"record_invalid"];
}

- (BOOL)isUVRecordInvalidForField:(NSString *)field withMessage:(NSString *)message {
	if (![self isUVRecordInvalid])
		return NO;
	
	NSString *errorStr = [[self userInfo] objectForKey:field];
    if (!errorStr)
        return NO;
	return [errorStr rangeOfString:message].location != NSNotFound;
}

- (BOOL)isAuthError {
	return [self code] == 401;
}

- (BOOL)isNotFoundError {
	return [self code] == 404;
}

- (BOOL)isUnprocessableError {
	return [self code] == 422;
}

@end
