//
//  UVSubdomain.m
//  UserVoice
//
//  Created by Scott Rutherford on 28/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVSubdomain.h"

@implementation UVSubdomain

@synthesize subdomainId;
@synthesize name;
@synthesize host;
@synthesize key;
@synthesize defaultSort;

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.subdomainId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        self.name = [self objectOrNilForDict:dict key:@"name"];
        self.host = [self objectOrNilForDict:dict key:@"host"];
        self.defaultSort = [self objectOrNilForDict:dict key:@"default_sort"];
    }
    return self;
}

- (NSString *)suggestionSort {
    if ([defaultSort isEqualToString:@"new"])
        return @"newest";
    else if ([defaultSort isEqualToString:@"hot"])
        return @"hot";
    else
        return @"votes";
}

- (void)dealloc {
    self.name = nil;
    self.key = nil;
    self.host = nil;
    self.defaultSort = nil;
    [super dealloc];
}

@end
