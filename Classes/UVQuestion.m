//
//  UVRating.m
//  UserVoice
//
//  Created by Mirko Froehlich on 2/23/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVQuestion.h"
#import "UVResponseDelegate.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVAnswer.h"

@implementation UVQuestion

@synthesize questionId;
@synthesize currentAnswer;
@synthesize text;
@synthesize flashMessage;
@synthesize flashType;

+ (void)initialize {
	[self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
	[self setBaseURL:[self siteURL]];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if (self = [super init]) {
		NSDictionary *answer = [self objectOrNilForDict:dict key:@"answer"];
		self.questionId = [[self objectOrNilForDict:dict key:@"id"] intValue];
		self.text = [self objectOrNilForDict:dict key:@"text"];		
		self.currentAnswer = [[UVAnswer alloc] initWithDictionary:answer];		
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"questionId: %d\nvalue: %d", self.questionId, self.currentAnswer.value];
}

@end
