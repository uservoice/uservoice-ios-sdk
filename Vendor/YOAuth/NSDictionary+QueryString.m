//
//  NSDictionary+QueryString.m
//  YOAuth
//
//  Created by Zach Graves on 3/4/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//  
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import "NSDictionary+QueryString.h"
#import "NSString+URLEncoding.h"

@implementation NSDictionary (QueryStringAdditions)

- (NSString *)QueryString 
{
    NSMutableArray *queryParameters = [[NSMutableArray alloc] init];
	
	for (NSString *aKey in [self allKeys]) {
		NSString *keyValuePair = [NSString stringWithFormat:@"%@=%@", aKey, [[self objectForKey:aKey] URLEncodedString]];
		[queryParameters addObject:keyValuePair];
	}
	
	NSString *queryString = [queryParameters componentsJoinedByString:@"&"];
	[queryParameters release];
	
	return queryString;
}

@end