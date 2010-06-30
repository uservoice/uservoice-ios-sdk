//
//  UVNetworkUtils.m
//  UserVoice
//
//  Created by UserVoice on 4/23/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVNetworkUtils.h"

#import <netdb.h>
#import <SystemConfiguration/SystemConfiguration.h>

@implementation UVNetworkUtils

// Checks if the device has any form of Internet access. Cobbled together from:
// https://developer.apple.com/iphone/library/samplecode/Reachability/Listings/Classes_Reachability_m.html#//apple_ref/doc/uid/DTS40007324-Classes_Reachability_m-DontLinkElementID_6
+ (BOOL)hasInternetAccess {
	struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
	SCNetworkReachabilityFlags flags = 0;
	BOOL reachable = SCNetworkReachabilityGetFlags(reachability, &flags);
	CFRelease(reachability);
	return reachable && (flags & kSCNetworkFlagsReachable);
}

@end
