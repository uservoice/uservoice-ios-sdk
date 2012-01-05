//
//  UVStream.m
//  UserVoice
//
//  Created by Scott Rutherford on 11/08/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVStreamEvent.h"
#import "UVToken.h"
#import "UVForum.h"
#import "UVResponseDelegate.h"

@implementation UVStreamEvent

@synthesize type, object;

+ (void)initialize {
	[self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
	[self setBaseURL:[self siteURL]];
}

+ (void)processModels:(NSArray *)models {
	// Override in subclasses if necessary
//	NSLog(@"Processing stream");
//	
//	for (int i=0; i<[models count]; i++) {
//		NSLog(@"New event of type: %@", [[models objectAtIndex:i] type]);
//	}
}

+ (id)publicForForum:(UVForum *)theForum andDelegate:(id)delegate since:(NSDate *)aDateOrNil {
	NSString *path = [self apiPath:[NSString stringWithFormat:@"/forums/%d/stream/public.json", theForum.forumId]];
	NSMutableDictionary *params = nil;
	if (aDateOrNil!=nil) {
		params = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", aDateOrNil] forKey:@"since"];
	}
	
	return [[self class] getPath:path
					  withParams:params
						  target:delegate
						selector:@selector(didRetrievePublicStream:)];
}

+ (id)privateForForum:(UVForum *)theForum andDelegate:(id)delegate since:(NSDate *)aDateOrNil {
	NSString *path = [self apiPath:[NSString stringWithFormat:@"/forums/%d/stream/private.json", theForum.forumId]];
	
	return [[self class] getPath:path
					  withParams:nil
						  target:delegate
						selector:@selector(didRetrievePrivateStream:)];
}

+ (void)didReceiveError:(NSError *)error callback:(NSInvocation *)callback {
	// do nothing
	NSLog(@"Error polling: %@", error);
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if (self = [super init]) {
		self.type = [self objectOrNilForDict:dict key:@"type"];
		self.object = [self objectOrNilForDict:dict key:@"object"];	
	}
	return self;
}

- (NSString	*)description {
	return [NSString stringWithFormat:@"[StreamEvent] type: %@, object: %@", type, object];
}

- (void)dealloc {
    self.type = nil;
	self.object = nil;
    [super dealloc];
}

@end
