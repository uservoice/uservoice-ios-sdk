//
//  UVSession.m
//  UserVoice
//
//  Created by Mirko Froehlich on 10/22/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVSession.h"
#import "UVConfig.h"
#import "UVStyleSheet.h"
#import "UVUser.h"
#import "YOAuth.h"

@implementation UVSession

@synthesize isModal;
@synthesize config;
@synthesize clientConfig;
@synthesize user;
@synthesize currentToken;
@synthesize info;
@synthesize userCache;

+ (UVSession *)currentSession {
	static UVSession *currentSession;
	@synchronized(self) {
		if (!currentSession) {
			currentSession = [[UVSession alloc] init];
		}
	}
	
	return currentSession;
}

- (BOOL)loggedIn {
	return self.user != nil;
}

- (id)init {
	if (self = [super init]) {
		self.userCache = [NSMutableDictionary dictionary];
		// This seems like a convenient place for random UserVoice initialization
		[TTStyleSheet setGlobalStyleSheet:[[[UVStyleSheet alloc] init] autorelease]];
	}
	return self;
}

- (YOAuthConsumer *)yOAuthConsumer {
	if (!yOAuthConsumer) {
		yOAuthConsumer = [YOAuthConsumer consumerWithKey:self.config.key
											   andSecret:self.config.secret];
	}
	return yOAuthConsumer;
}

@end
