//
//  NSData+OAuthResponse.h
//  YOAuth
//
//  Created by Zach Graves on 3/18/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//  
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import <Foundation/Foundation.h>

/**
 * Adds methods to parse NSData objects representing an OAuth response
 * into a dictionary of key=value pairs.
 */
@interface NSData (OAuthResponseAdditions)


/**
 * Parses a response query-string represented as NSData into a mutable dictionary.
 */
- (NSMutableDictionary *)OAuthTokenResponse;

@end
