//
//  YOAuthUtil.m
//  YOAuth
//
//  Created by Zach Graves on 2/14/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//  
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import "YOAuthUtil.h"

static NSString *const kOAuthVersion= @"1.0";

@implementation YOAuthUtil

+ (NSString *)oauth_nonce
{	
	NSString *nonce = nil;
	CFUUIDRef generatedUUID = CFUUIDCreate(kCFAllocatorDefault);
	nonce = (NSString*)CFUUIDCreateString(kCFAllocatorDefault, generatedUUID);
	CFRelease(generatedUUID);
	
	return [nonce autorelease];
}

+ (NSString *)oauth_timestamp
{
	return [[NSString stringWithFormat:@"%d", time(NULL)] autorelease];
}

+ (NSString *)oauth_version
{
	return [kOAuthVersion autorelease];
}

@end
