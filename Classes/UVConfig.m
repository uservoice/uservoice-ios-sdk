//
//  UVConfig.m
//  UserVoice
//
//  Created by UserVoice on 10/19/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVConfig.h"
#import "UVSession.h"
#import "UVClientConfig.h"

@implementation UVConfig

@synthesize site;
@synthesize key;
@synthesize secret;
@synthesize ssoToken;
@synthesize email;
@synthesize displayName;
@synthesize guid;
@synthesize customFields;
@synthesize topicId;
@synthesize showForum;
@synthesize showPostIdea;
@synthesize showContactUs;
@synthesize showKnowledgeBase;

+ (UVConfig *)configWithSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret {
    return [[[UVConfig alloc] initWithSite:site andKey:key andSecret:secret] autorelease];
}

+ (UVConfig *)configWithSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret andSSOToken:(NSString *)token {
    return [[[UVConfig alloc] initWithSite:site andKey:key andSecret:secret andSSOToken:token] autorelease];
}

+ (UVConfig *)configWithSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret andEmail:(NSString *)email andDisplayName:(NSString *)displayName andGUID:(NSString *)guid {
    return [[[UVConfig alloc] initWithSite:site andKey:key andSecret:secret andEmail:email andDisplayName:displayName andGUID:guid] autorelease];
}

- (id)initWithSite:(NSString *)theSite andKey:(NSString *)theKey andSecret:(NSString *)theSecret {
    if (self = [super init]) {
        NSURL* url = [NSURL URLWithString:theSite];
        NSString* saneURL;
        if (url.host == nil) {
            saneURL = [NSString stringWithFormat:@"%@", url];
        } else {
            saneURL = [NSString stringWithFormat:@"%@", url.host];
        }

        self.key = theKey;
        self.site = saneURL;
        self.secret = theSecret;
        showForum = YES;
        showPostIdea = YES;
        showContactUs = YES;
        showKnowledgeBase = YES;
    }
    return self;
}

- (BOOL)showForum {
    if ([UVSession currentSession].clientConfig && ![UVSession currentSession].clientConfig.feedbackEnabled)
        return NO;
    else
        return showForum;
}

- (BOOL)showPostIdea {
    if ([UVSession currentSession].clientConfig && ![UVSession currentSession].clientConfig.feedbackEnabled)
        return NO;
    else
        return showPostIdea;
}

- (BOOL)showContactUs {
    if ([UVSession currentSession].clientConfig && ![UVSession currentSession].clientConfig.ticketsEnabled)
        return NO;
    else
        return showContactUs;
}

- (BOOL)showKnowledgeBase {
    if ([UVSession currentSession].clientConfig && ![UVSession currentSession].clientConfig.ticketsEnabled)
        return NO;
    else
        return showKnowledgeBase;
}

- (id)initWithSite:(NSString *)theSite andKey:(NSString *)theKey andSecret:(NSString *)theSecret andSSOToken:(NSString *)theToken {
    if (self = [self initWithSite:theSite andKey:theKey andSecret:theSecret]) {
        self.ssoToken = theToken;
    }
    return self;
}

- (id)initWithSite:(NSString *)theSite andKey:(NSString *)theKey andSecret:(NSString *)theSecret andEmail:(NSString *)theEmail andDisplayName:(NSString *)theDisplayName andGUID:(NSString *)theGuid {
    if (self = [self initWithSite:theSite andKey:theKey andSecret:theSecret]) {
        self.email = theEmail;
        self.displayName = theDisplayName;
        self.guid = theGuid;
    }
    return self;
}

- (BOOL)wasSignedInBySDK {
    return (self.ssoToken != nil || self.guid != nil);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Site: %@\nKey: %@\nSecret: %@", self.site, self.key, self.secret];
}

- (void)dealloc {
    self.site = nil;
    self.key = nil;
    self.site = nil;
    self.ssoToken = nil;
    self.email = nil;
    self.displayName = nil;
    self.guid = nil;
    [super dealloc];
}

@end
