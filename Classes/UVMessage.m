//
//  UVMessage.m
//  UserVoice
//
//  Created by UserVoice on 2/19/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVMessage.h"
#import "UVSubject.h"
#import "UVResponseDelegate.h"


@implementation UVMessage

+ (void)initialize {
	[self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
	[self setBaseURL:[self siteURL]];
}

+ (id)createWithSubject:(UVSubject *)subject
				 text:(NSString *)text
			 delegate:(id)delegate {
	NSString *path = [self apiPath:@"/messages.json"];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							text == nil ? @"" : text, @"message[text]",
							subject == nil ? @"" : 
								[[NSNumber numberWithInteger:subject.subjectId] stringValue], @"message[message_subject_id]",
							nil];
	return [[self class] postPath:path
					   withParams:params
						   target:delegate
						 selector:@selector(didCreateMessage:)];
}

@end
