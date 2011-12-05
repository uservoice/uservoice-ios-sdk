//
//  UVInfo.m
//  UserVoice
//
//  Created by Scott Rutherford on 27/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVInfo.h"
#import "UVResponseDelegate.h"

@implementation UVInfo

@synthesize about_title;
@synthesize about_body;
@synthesize motivation_title;
@synthesize motivation_body;
@synthesize management;
@synthesize contacts;

+ (void)initialize {
	[self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
	[self setBaseURL:[self siteURL]];
}

+ (id)getWithDelegate:(id)delegate {
	return [self getPath:[self apiPath:@"/info.json"]
			  withParams:nil
				  target:delegate
				selector:@selector(didRetrieveInfo:)];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if (self = [self init]) {
		NSDictionary *aboutDict = [self objectOrNilForDict:dict key:@"about"];
		self.about_title = [self objectOrNilForDict:aboutDict key:@"title"];
		self.about_body = [self objectOrNilForDict:aboutDict key:@"body"];	
		
		NSDictionary *motDict = [self objectOrNilForDict:dict key:@"motivation"];
		self.motivation_title = [self objectOrNilForDict:motDict key:@"title"];
		self.motivation_body = [self objectOrNilForDict:motDict key:@"body"];	
	}
	return self;
}

- (void)dealloc {
	self.about_body = nil;
	self.about_title = nil;
	self.motivation_body = nil;
	self.motivation_title = nil;
	self.management = nil;
	self.contacts = nil;
	
	[super dealloc];
}

@end
