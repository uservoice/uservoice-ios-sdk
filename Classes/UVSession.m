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
#import "UVSubdomain.h"
#import "UVUtils.h"
#import <stdlib.h>

@implementation UVSession

@synthesize isModal;
@synthesize config;
@synthesize clientConfig;
@synthesize accessToken;
@synthesize requestToken;
@synthesize interactions, interactionSequence, interactionDetails, interactionId;
@synthesize externalIds;
@synthesize topics;
@synthesize articles;
@synthesize flashTitle;
@synthesize flashMessage;
@synthesize flashSuggestion;

+ (UVSession *)currentSession {
    static UVSession *currentSession;
    @synchronized(self) {
        if (!currentSession) {
            currentSession = [[UVSession alloc] init];
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

- (void)didRetrieveClientConfig:(UVClientConfig *)config {
    // Do nothing. The UVClientConfig already sets the config on the current session.
}

- (void)clearFlash {
    self.flashTitle = nil;
    self.flashMessage = nil;
    self.flashSuggestion = nil;
}

- (void)flash:(NSString *)message title:(NSString *)title suggestion:(UVSuggestion *)suggestion {
    self.flashTitle = title;
    self.flashMessage = message;
    self.flashSuggestion = suggestion;
}

- (UVUser *)user {
    return user;
}

- (void)setUser:(UVUser *)newUser {
    [newUser retain];
    [user release];
    user = newUser;
    if (user && externalIds) {
        for (NSString *scope in externalIds) {
            NSString *identifier = [externalIds valueForKey:scope];
            [user identify:identifier withScope:scope delegate:self];
        }
    }
}

- (void)setExternalId:(NSString *)identifier forScope:(NSString *)scope {
    if (externalIds == nil) {
        self.externalIds = [NSMutableDictionary dictionary];
    }
    [externalIds setObject:identifier forKey:scope];
    if (user) {
        [user identify:identifier withScope:scope delegate:self];
    }
}

- (void)didIdentifyUser:(UVUser *)user {
}

- (void)didReceiveError:(NSError *)error {
    // identify failed
}

// This is used when dismissing UV so that everything gets reloaded
- (void)clear {
    self.user = nil;
    self.clientConfig = nil;
    self.requestToken = nil;
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
    NSString *payload = [UVUtils URLEncode:[UVUtils encode64:[UVUtils encodeJSON:values]]];
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
