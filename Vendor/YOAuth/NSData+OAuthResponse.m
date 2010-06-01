//
//  NSData+OAuthResponse.m
//  YOAuth
//
//  Created by Zach Graves on 3/18/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//  
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import "NSData+OAuthResponse.h"

@implementation NSData(OAuthResponseAdditions)

- (NSMutableDictionary *)OAuthTokenResponse
{
	NSString *responseBody = [[NSString alloc] initWithData:self
												   encoding:NSUTF8StringEncoding];
	
	NSMutableDictionary *oauthResponse = [NSMutableDictionary dictionary];
	NSArray *pairs = [responseBody componentsSeparatedByString:@"&"];
	
	for (NSString *item in pairs) {
		NSArray *fields = [item componentsSeparatedByString:@"="];
		NSString *name = [fields objectAtIndex:0];
		NSString *value = [[fields objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		[oauthResponse setObject:value forKey:name];
	}
	
	[responseBody release];
	
	return oauthResponse;
}

@end
