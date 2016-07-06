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

static long timestampOffset = 0L;

#define OFFSET_KEY @"uv-timestamp-offset"

@implementation YOAuthUtil

+ (NSString *)oauth_nonce {
    NSString *nonce = nil;
    CFUUIDRef generatedUUID = CFUUIDCreate(kCFAllocatorDefault);
    nonce = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, generatedUUID);
    CFRelease(generatedUUID);
    return nonce;
}

+ (NSString *)oauth_timestamp {
    return [NSString stringWithFormat:@"%ld", time(NULL) + timestampOffset];
}

+ (void)setTimestampOffset:(long)offset {
    timestampOffset = offset;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:offset forKey:OFFSET_KEY];
    [prefs synchronize];
}

+ (void)loadTimestampOffset {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    timestampOffset = [prefs integerForKey:OFFSET_KEY];
}

+ (NSString *)oauth_version {
    return kOAuthVersion;
}

@end
