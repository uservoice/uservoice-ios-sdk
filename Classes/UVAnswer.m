//
//  UVAnswer.m
//  UserVoice
//
//  Created by Scott Rutherford on 30/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVAnswer.h"
#import "UVQuestion.h"
#import "UVResponseDelegate.h"

@implementation UVAnswer

@synthesize value;
@synthesize answerId;

- (id)initWithDictionary:(NSDictionary *)dict {
	if (self = [super init]) {
		self.answerId = [[self objectOrNilForDict:dict key:@"id"] intValue];
		self.value = [[self objectOrNilForDict:dict key:@"value"] intValue];	
	}
	return self;
}

+ (void)initialize {
	[self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
	[self setBaseURL:[self siteURL]];
}

+ (id)initWithQuestion:(UVQuestion *)theQuestion andValue:(NSInteger)theValue andDelegate:(id)delegate {
	NSString *path = [UVQuestion apiPath:[NSString stringWithFormat:@"/questions/%d/answers.json", theQuestion.questionId]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[NSNumber numberWithInteger:theValue] stringValue], @"value",
							nil];
	return [self postPath:path
			   withParams:params
				   target:delegate
				 selector:@selector(didCreateAnswer:)];
}

@end
