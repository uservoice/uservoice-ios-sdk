//
//  NSDictionary+QueryString.h
//  YOAuth
//
//  Created by Zach Graves on 3/4/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//  
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import <Foundation/Foundation.h>

/**
 * Adds a query string creation method to NSDictionary.
 */
@interface NSDictionary (QueryStringAdditions)

/**
 * Returns a query string containing the key=value pairs from the dictionary.
 */
- (NSString *)QueryString;

@end
