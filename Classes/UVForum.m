//
//  UVForum.m
//  UserVoice
//
//  Created by UserVoice on 11/23/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVForum.h"
#import "UVResponseDelegate.h"


@implementation UVForum

@synthesize forumId;
@synthesize isPrivate;
@synthesize name;
@synthesize topics;
@synthesize currentTopic;

+ (void)initialize {
	[self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
	[self setBaseURL:[self siteURL]];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if (self = [super init]) {
		self.forumId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
		self.name = [self objectOrNilForDict:dict key:@"name"];
		
		self.topics = [NSMutableArray array];
		NSMutableArray *topicDicts = [self objectOrNilForDict:dict key:@"topics"];
		if (topicDicts) {
			for (NSDictionary *topicDict in topicDicts) {
				[topics addObject:[[[UVTopic alloc] initWithDictionary:topicDict] autorelease]];
			}
		}
		
		if ([topics count])
		{
			self.currentTopic = [topics objectAtIndex:0];
		}
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"forumId: %d\nname: %@", self.forumId, self.name];
}

- (NSArray *)availableCategories {
	return currentTopic ? [currentTopic categories] : [NSArray array];
}

- (NSString *)prompt {
	return currentTopic.prompt;
}

- (NSString *)example {
	return currentTopic.example;
}

- (void)dealloc {
	self.name = nil;
	self.topics = nil;
	self.currentTopic = nil;	
	[super dealloc];
}

@end
