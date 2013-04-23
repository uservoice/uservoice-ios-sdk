//
//  NSDictionary+Misc.m
//  Legislate
//
//  Created by Justin Palmer on 7/24/08.
//  Copyright 2008 Active Reload, LLC. All rights reserved.
//

#import "NSDictionary+ParamUtils.h"
#import "NSString+URLEncoding.h"

@implementation NSDictionary (UVParamUtils)

- (NSString *)toQueryString {
    NSMutableArray *pairs = [[[NSMutableArray alloc] init] autorelease];
    for (id key in [self allKeys]) {
        id value = [self objectForKey:key];
        if ([value isKindOfClass:[NSArray class]]) {
            for (id val in value) {
                [pairs addObject:[NSString stringWithFormat:@"%@=%@",key, [val URLEncodedString]]];
            }
        } else {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@",key, [value URLEncodedString]]];
        }
    }
    return [pairs componentsJoinedByString:@"&"];
}
@end
