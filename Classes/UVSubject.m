//
//  UVSubject.m
//  UserVoice
//
//  Created by UserVoice on 2/19/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVSubject.h"


@implementation UVSubject

@synthesize subjectId;
@synthesize text;

- (id)initWithDictionary:(NSDictionary *)dict {
	if (self = [super init]) {
		self.subjectId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
		self.text = [self objectOrNilForDict:dict key:@"text"];
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"subjectId: %d\ntext: %@", self.subjectId, self.text];
}

- (void)dealloc {
    self.text = nil;
    [super dealloc];
}

@end
