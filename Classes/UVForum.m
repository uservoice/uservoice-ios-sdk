//
//  UVForum.m
//  UserVoice
//
//  Created by UserVoice on 11/23/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVForum.h"
#import "UVResponseDelegate.h"
#import "UVCategory.h"

@implementation UVForum

@synthesize forumId;
@synthesize isPrivate;
@synthesize name;
@synthesize example;
@synthesize prompt;
@synthesize votesAllowed;
@synthesize categories;
@synthesize suggestions;
@synthesize suggestionsNeedReload;
@synthesize suggestionsCount;

+ (void)initialize {
    [self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
    [self setBaseURL:[self siteURL]];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.forumId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        self.name = [self objectOrNilForDict:dict key:@"name"];

        NSDictionary *topic = [[self objectOrNilForDict:dict key:@"topics"] objectAtIndex:0];
        
        self.suggestionsNeedReload = YES;
        self.example = [topic objectForKey:@"example"];
        self.prompt = [topic objectForKey:@"prompt"];
        self.votesAllowed = [(NSNumber *)[topic objectForKey:@"votes_allowed"] integerValue];
        self.suggestionsCount = [(NSNumber *)[topic objectForKey:@"open_suggestions_count"] integerValue];

        self.categories = [NSMutableArray array];
        NSMutableArray *categoryDicts = [self objectOrNilForDict:topic key:@"categories"];
        for (NSDictionary *categoryDict in categoryDicts) {
            [self.categories addObject:[[[UVCategory alloc] initWithDictionary:categoryDict] autorelease]];
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"forumId: %d\nname: %@", self.forumId, self.name];
}

- (void)dealloc {
    self.name = nil;
    self.example = nil;
    self.prompt = nil;
    self.categories = nil;
    self.suggestions = nil;
    [super dealloc];
}

@end
