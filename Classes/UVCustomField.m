//
//  UVCustomField.m
//  UserVoice
//
//  Created by UserVoice on 6/9/11.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import "UVCustomField.h"
#import "UVSession.h"
#import "UVClientConfig.h"

@implementation UVCustomField

@synthesize values;
@synthesize name;
@synthesize fieldId;

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.fieldId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        self.name = [self objectOrNilForDict:dict key:@"name"];
        NSArray *valueDictionaries = [self objectOrNilForDict:dict key:@"possible_values"];
        NSMutableArray *valueNames = [NSMutableArray arrayWithCapacity:[valueDictionaries count]];
        for (NSDictionary *valueAttributes in valueDictionaries) {
            [valueNames addObject:[valueAttributes valueForKey:@"value"]];
        }
        self.values = [NSArray arrayWithArray:valueNames];
    }
    return self;
}

- (BOOL)isPredefined {
    return [self.values count] > 0;
}

- (void)dealloc {
    self.name = nil;
    self.values = nil;
    [super dealloc];
}

@end
