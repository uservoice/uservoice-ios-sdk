//
//  UVSubdomain.m
//  UserVoice
//
//  Created by Scott Rutherford on 28/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVSubdomain.h"
#import "UVResponseDelegate.h"
#import "UVSubject.h"
#import "UVStatus.h"

@implementation UVSubdomain

@synthesize subdomainId;
@synthesize name;
@synthesize host;
@synthesize key;
@synthesize statuses;

+ (void)initialize {
	[self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
	[self setBaseURL:[self siteURL]];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if (self = [super init]) {
		// get statuses
		NSArray *statusDicts = [self objectOrNilForDict:dict key:@"statuses"];
		if (statusDicts && [statusDicts count] > 0) {
			NSMutableArray *theStatuses = [NSMutableArray arrayWithCapacity:[statusDicts count]];
			for (NSDictionary *statusDict in statusDicts) {
				UVStatus *status = [[UVStatus alloc] initWithDictionary:statusDict];
				[theStatuses addObject:status];
				[status release];
			}
			self.statuses = theStatuses;
		}
		self.subdomainId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
		self.name = [self objectOrNilForDict:dict key:@"name"];
		self.host = [self objectOrNilForDict:dict key:@"host"]; 
	}
	return self;
}

- (void)dealloc {
	self.name = nil;
	self.key = nil;
	self.host = nil;
	self.statuses = nil;
	
	[super dealloc];
}

@end
