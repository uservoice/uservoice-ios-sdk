//
//  NSString+URLEncoding.h
//  YOAuth
//
//  Created by Zach Graves on 3/4/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import "NSString+URLEncoding.h"

@implementation NSString (UVURLEncodingAdditions)

- (NSString *)URLEncodedString
{
    NSString *result = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL, CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
    return result;
}

- (NSString*)URLDecodedString
{
    NSString *result = (__bridge NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                           (CFStringRef)self,
                                                                                           CFSTR(""),
                                                                                           kCFStringEncodingUTF8);
    return result;
}

@end
