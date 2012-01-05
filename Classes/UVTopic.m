//
//  UVTopic.m
//  UserVoice
//
//  Created by Rich Collins on 4/28/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVTopic.h"
#import "UVCategory.h"

@implementation UVTopic

@synthesize example,
	prompt,
	votesAllowed,
	votesRemaining,
	categories,
	suggestions,
	suggestionsNeedReload,
	suggestionsCount;

- (id)initWithDictionary:(NSDictionary *)dict {
	if ((self = [super init])) {
		self.suggestionsNeedReload = YES;
		
//        NSLog(@"TOPIC: %@", dict);
		self.example = [dict objectForKey:@"example"];
		self.prompt = [dict objectForKey:@"prompt"];
		self.votesRemaining = [(NSNumber *)[dict objectForKey:@"votes_remaining"] integerValue];
		self.votesAllowed = [(NSNumber *)[dict objectForKey:@"votes_allowed"] integerValue];
		self.suggestionsCount = [(NSNumber *)[dict objectForKey:@"open_suggestions_count"] integerValue];

		self.categories = [NSMutableArray array];
		NSMutableArray *categoryDicts = [self objectOrNilForDict:dict key:@"categories"];
		if (categoryDicts) {
			for (NSDictionary *categoryDict in categoryDicts) {
				[categories addObject:[[[UVCategory alloc] initWithDictionary:categoryDict] autorelease]];
			}
		}
	}
	
	return self;
}

- (void)dealloc {
	self.example = nil;
	self.prompt = nil;
	self.categories = nil;
    self.suggestions = nil;
	[super dealloc];
}

@end