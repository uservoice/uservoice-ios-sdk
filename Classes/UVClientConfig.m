//
//  UVClientConfig.m
//  UserVoice
//
//  Created by UserVoice on 10/21/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "HTTPRiot.h"
#import "UVClientConfig.h"
#import "UVSession.h"
#import "UVResponseDelegate.h"
#import "UVForum.h"
#import "UVSubject.h"
#import "UVQuestion.h"
#import "UVUser.h"
#import "UVSubdomain.h"

@implementation UVClientConfig

@synthesize questionsEnabled;
@synthesize forum;
@synthesize welcome;
@synthesize itunesApplicationId;
@synthesize questions;
@synthesize subdomain;

+ (void)initialize {
	[self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
	[self setBaseURL:[self siteURL]];
}

+ (id)getWithDelegate:(id)delegate {
	return [self getPath:[self apiPath:@"/client.json"]
			  withParams:nil
				  target:delegate
				selector:@selector(didRetrieveClientConfig:)];
}

+ (void)processModel:(id)model {
	[UVSession currentSession].clientConfig = model;
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if ((self = [super init])) {
        if ([dict objectForKey:@"questions_enabled"] != [NSNull null]) {
            self.questionsEnabled = [(NSNumber *)[dict objectForKey:@"questions_enabled"] boolValue];
        }
		self.welcome = [self objectOrNilForDict:dict key:@"welcome"];
		self.itunesApplicationId = [self objectOrNilForDict:dict key:@"identifier_external"];
		
		// get the forum
		NSDictionary *forumDict = [self objectOrNilForDict:dict key:@"forum"];
		UVForum *theForum = [[UVForum alloc] initWithDictionary:forumDict];
		self.forum = theForum;
		[theForum release];

		// get the subdomain
		NSDictionary *subdomainDict = [self objectOrNilForDict:dict key:@"subdomain"];
		UVSubdomain *theSubdomain = [[UVSubdomain alloc] initWithDictionary:subdomainDict];
		self.subdomain = theSubdomain;
		[theSubdomain release];
		
		// get the questions
		NSDictionary *questionsDict = [self objectOrNilForDict:dict key:@"questions"];
		if (questionsDict && [questionsDict count] > 0) {
			NSMutableArray *theQuestions = [NSMutableArray arrayWithCapacity:[questionsDict count]];
			for (NSDictionary *questionDict in questionsDict) {
				UVQuestion *question = [[UVQuestion alloc] initWithDictionary:questionDict];
				[theQuestions addObject:question];
				[question release];
			}
			self.questions = theQuestions;
		}
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"forumId: %d\nquestions_enabled: %d", self.forum.forumId, self.questionsEnabled];
}

@end
