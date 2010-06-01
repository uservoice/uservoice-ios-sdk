//
//  UVConfig.m
//  UserVoice
//
//  Created by Mirko Froehlich on 10/19/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVConfig.h"


@implementation UVConfig

@synthesize site;
@synthesize key;
@synthesize secret;

- (id)initWithSite:(NSString *)theSite andKey:(NSString *)theKey andSecret:(NSString *)theSecret {
	if (self = [super init]) {
		self.key = theKey;
		self.site = theSite;
		self.secret = theSecret;
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Site: %@\nKey: %@\nSecret: %@", self.site, self.key, self.secret];
}

- (void)dealloc {
	self.site = nil;
	self.key = nil;
	self.site = nil;
	
	[super dealloc];
}

@end
