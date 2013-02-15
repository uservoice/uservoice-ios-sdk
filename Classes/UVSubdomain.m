//
//  UVSubdomain.m
//  UserVoice
//
//  Created by Scott Rutherford on 28/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVSubdomain.h"
#import "UVSubject.h"
#import "UVStatus.h"

@implementation UVSubdomain

@synthesize subdomainId;
@synthesize name;
@synthesize host;
@synthesize key;
@synthesize statuses;
@synthesize defaultSort;

+ (void)initialize {
    [self initModel];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        // get statuses
        NSArray *statusDicts = [self objectOrNilForDict:dict key:@"statuses"];
        if (statusDicts && [statusDicts count] > 0) {
            NSMutableArray *theStatuses = [NSMutableArray arrayWithCapacity:[statusDicts count]];
            for (NSDictionary *statusDict in statusDicts) {
                UVStatus *status = [[UVStatus alloc] initWithDictionary:statusDict];
                [theStatuses addObject:status];
                [status release];
            }
            self.statuses = theStatuses;
        }
        self.subdomainId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        self.name = [self objectOrNilForDict:dict key:@"name"];
        self.host = [self objectOrNilForDict:dict key:@"host"];
        self.defaultSort = [self objectOrNilForDict:dict key:@"default_sort"];
    }
    return self;
}

- (NSString *)ideasHeading {
    if ([defaultSort isEqualToString:@"new"])
        return NSLocalizedStringFromTable(@"New Ideas", @"UserVoice", nil);
    else if ([defaultSort isEqualToString:@"hot"])
        return NSLocalizedStringFromTable(@"Hot Ideas", @"UserVoice", nil);
    else
        return NSLocalizedStringFromTable(@"Top Ideas", @"UserVoice", nil);
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
    self.statuses = nil;
    self.defaultSort = nil;
    [super dealloc];
}

@end
