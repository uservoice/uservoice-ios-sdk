//
//  UVStatus.m
//  UserVoice
//
//  Created by Scott Rutherford on 29/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVStatus.h"


@implementation UVStatus

@synthesize statusId;
@synthesize name;

- (id)initWithDictionary:(NSDictionary *)dict {
	if (self = [super init]) {
		self.statusId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
		self.name = [self objectOrNilForDict:dict key:@"name"];
	}
	return self;
}

- (void)dealloc {
    self.name = nil;
    [super dealloc];
}

@end
