//
//  UVCustomField.m
//  UserVoice
//
//  Created by UserVoice on 6/9/11.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import "UVCustomField.h"
#import "UVResponseDelegate.h"
#import "UVSession.h"
#import "UVClientConfig.h"

@implementation UVCustomField

@synthesize subjectId;
@synthesize name;

+ (void)initialize {
	[self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
	[self setBaseURL:[self siteURL]];
}

+ (id)getCustomFieldsWithDelegate:(id)delegate {
	return [self getPath:[self apiPath:@"/custom_fields/public.json"]
			  withParams:nil
				  target:delegate
				selector:@selector(didRetrieveCustomFields:)];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if (self = [super init]) {
		self.subjectId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
		self.name = [self objectOrNilForDict:dict key:@"name"];
	}
	return self;
}

@end
