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
#import "YOAuth.h"
#import "UVClientConfig.h"
#import "UVForum.h"
#import "UVSubdomain.h"
#import "UVUtils.h"
#import "UVBabayaga.h"
#import <stdlib.h>

@implementation UVSession

@synthesize isModal;
@synthesize config;
@synthesize clientConfig;
@synthesize forum;
@synthesize accessToken;
@synthesize requestToken;
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
        }
    }

    return currentSession;
}

- (BOOL)loggedIn {
    return self.user != nil;
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

- (void)setClientConfig:(UVClientConfig *)newConfig {
    [clientConfig release];
    clientConfig = [newConfig retain];
    [UVBabayaga flush];
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

// This is used when dismissing UV so that everything gets reloaded
- (void)clear {
    self.requestToken = nil;
    [user release];
    user = nil;
    [clientConfig release];
    clientConfig = nil;
}

- (YOAuthConsumer *)yOAuthConsumer {
    if (!yOAuthConsumer) {
        if (config.key != nil) {
            yOAuthConsumer = [[YOAuthConsumer alloc] initWithKey:self.config.key
                                                       andSecret:self.config.secret];
        } else if (clientConfig != nil) {
            yOAuthConsumer = [[YOAuthConsumer alloc] initWithKey:clientConfig.key
                                                       andSecret:clientConfig.secret];
        }
    }
    return yOAuthConsumer;
}

@end
