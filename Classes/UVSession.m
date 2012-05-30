//
//  UVSession.m
//  UserVoice
//
//  Created by UserVoice on 10/22/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVSession.h"
#import "UVConfig.h"
#import "UVStyleSheet.h"
#import "UVUser.h"
#import "YOAuth.h"
#import "UVClientConfig.h"
#import "UVForum.h"
#import "UVTopic.h"
#import "UVSubdomain.h"
#import "NSString+Base64.h"
#import "NSString+URLEncoding.h"
#import <stdlib.h>

@implementation UVSession

@synthesize isModal;
@synthesize config;
@synthesize clientConfig;
@synthesize currentToken;
@synthesize info;
@synthesize userCache, startTime;
@synthesize interactions, interactionSequence, interactionDetails, interactionId;

+ (UVSession *)currentSession {
	static UVSession *currentSession;
	@synchronized(self) {
		if (!currentSession) {
			currentSession = [[UVSession alloc] init];
			currentSession.startTime = [NSDate date];
            currentSession.interactions = [NSMutableDictionary dictionary];
            currentSession.interactionSequence = [NSMutableArray array];
            currentSession.interactionDetails = [NSMutableArray array];
            currentSession.interactionId = arc4random();
            [currentSession trackInteraction:@"o"];
		}
	}
	
	return currentSession;
}

- (BOOL)loggedIn {
	return self.user != nil;
}

- (UVUser *)user {
    return user;
}

- (void)setUser:(UVUser *)theUser {
	if (theUser != user) {
		UVUser *oldUser = [user retain];
		
		[user release];
		user = [theUser retain];
		
		// reload the topic because it owns the number of available votes for the current user
		if (oldUser != nil && clientConfig) {
			[UVClientConfig getWithDelegate:self];
		}
		[oldUser release];
	}
}

- (id)init {
	if (self = [super init]) {
		self.userCache = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void)didRetrieveClientConfig:(UVClientConfig *)config {
    // Do nothing. The UVClientConfig already sets the config on the current session.
}

- (YOAuthConsumer *)yOAuthConsumer {
	if (!yOAuthConsumer) {
		yOAuthConsumer = [[YOAuthConsumer alloc] initWithKey:self.config.key
											       andSecret:self.config.secret];
	}
	return yOAuthConsumer;
}

- (void)sendInteractions:(BOOL)isFinal {
    NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:clientConfig.subdomain.subdomainId], @"subdomain_id",
                            [[NSTimeZone localTimeZone] name], @"z",
                            @"iphone", @"channel",
                            [NSNumber numberWithInt:clientConfig.clientId], @"client_id",
                            interactions, @"happenings",
                            interactionSequence, @"sequence",
                            @"w2i", @"kind",
                            interactionDetails, @"details",
                            [NSNumber numberWithInt:interactionId], @"interaction_id",
                            [NSNumber numberWithBool:isFinal], @"is_final",
                            nil];
    NSString *payload = [[[values JSONRepresentation] base64EncodedString] URLEncodedString];
    NSString *url = [NSString stringWithFormat:@"http://%@/track.gif?%@", config.site, payload];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection connectionWithRequest:request delegate:nil];
}

- (void)flushInteractions {
    if ([interactionSequence count] > 0)
        [self sendInteractions:YES];
    [interactionSequence removeAllObjects];
    [interactions removeAllObjects];
    [interactionDetails removeAllObjects];
    self.interactionId = arc4random();
}

- (void)trackInteraction:(NSString *)interaction {
    [self trackInteraction:interaction details:NULL];
}

- (void)trackInteraction:(NSString *)interaction details:(NSDictionary *)details {
    if (![interaction isEqualToString:@"o"])
        [interactions setObject:[NSNumber numberWithBool:YES] forKey:interaction];
    NSString *last = [interactionSequence lastObject];
    NSString *secondToLast = [interactionSequence count] > 1 ? [interactionSequence objectAtIndex:[interactionSequence count] - 2] : NULL;
    if (![[NSArray arrayWithObjects:@"ali", @"lf", nil] containsObject:interaction] && !([[NSArray arrayWithObjects:@"sf", @"si", @"rfz", @"rfp", @"riz", @"rip", nil] containsObject:interaction] && ([interaction isEqualToString:last] || [interaction isEqualToString:secondToLast])))
        [interactionSequence addObject:interaction];
    if (details != NULL) {
        NSMutableDictionary *theDetails = [NSMutableDictionary dictionaryWithDictionary:details];
        [theDetails setObject:interaction forKey:@"kind"];
        [interactionDetails addObject:[NSDictionary dictionaryWithDictionary:theDetails]];
    }
    if ([interactionSequence count] > 0)
        [self sendInteractions:NO];
}

@end
