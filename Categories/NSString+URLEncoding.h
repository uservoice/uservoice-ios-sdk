//
//  NSString+URLEncoding.h
//  YOAuth
//
//  Created by Zach Graves on 3/4/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//  
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import <Foundation/Foundation.h>

/**
 * Adds methods to URL encode/decode strings.
 */
@interface NSString (UVURLEncodingAdditions)

/**
 * Encodes the string.
 * @return		A url encoded string.
 */
- (NSString *)URLEncodedString;

/**
 * Decodes an encoded string.
 * @return		A decoded string.
 */
- (NSString *)URLDecodedString;

@end
