//
//  UVInitialLoadManager.m
//  UserVoice
//
//  Created by Austin Taylor on 12/10/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVInitialLoadManager.h"
#import "UVHelpTopic.h"
#import "UVArticle.h"
#import "UVAccessToken.h"
#import "UVRequestToken.h"
#import "UVClientConfig.h"
#import "NSError+UVExtras.h"
#import "UVConfig.h"
#import "UVUser.h"
#import "UVSession.h"

@implementation UVInitialLoadManager

+ (void)loadWithDelegate:(id)delegate action:(SEL)action {
    UVInitialLoadManager *manager = [[UVInitialLoadManager alloc] initWithDelegate:delegate action:action];
    [manager beginLoad];
}

- (id)initWithDelegate:(id)theDelegate action:(SEL)theAction {
    if (self = [super init]) {
        delegate = theDelegate;
        action = theAction;
        configDone = NO;
        userDone = NO;
        kbDone = NO;
    }
    return self;
}

- (void)beginLoad {
    [UVRequestToken getRequestTokenWithDelegate:self];
}

- (void)checkComplete {
    if (configDone && userDone && kbDone) {
        [delegate performSelector:action];
        [self release];
    }
}

- (void)didRetrieveRequestToken:(UVRequestToken *)token {
    [UVSession currentSession].requestToken = token;
    [UVClientConfig getWithDelegate:self];
    if ([UVSession currentSession].config.ssoToken != nil) {
        [UVUser findOrCreateWithSsoToken:[UVSession currentSession].config.ssoToken delegate:self];
    } else if ([UVSession currentSession].config.email != nil) {
        [UVUser findOrCreateWithGUID:[UVSession currentSession].config.guid andEmail:[UVSession currentSession].config.email andName:[UVSession currentSession].config.displayName andDelegate:self];
    } else if ([UVAccessToken exists]) {
        [UVSession currentSession].accessToken = [[[UVAccessToken alloc] initWithExisting] autorelease];
        [UVUser retrieveCurrentUser:self];
    } else {
        userDone = YES;
    }
}

- (void)didRetrieveClientConfig:(UVClientConfig *)clientConfig {
    configDone = YES;
    if (clientConfig.ticketsEnabled) {
        [UVHelpTopic getAllWithDelegate:self];
    } else {
        kbDone = YES;
    }
    [self checkComplete];
}

- (void)didCreateUser:(UVUser *)theUser {
    [UVSession currentSession].user = theUser;
    [[UVSession currentSession].accessToken persist];
    userDone = YES;
    [self checkComplete];
}

- (void)didRetrieveCurrentUser:(UVUser *)theUser {
    [UVSession currentSession].user = theUser;
    [[UVSession currentSession].accessToken persist];
    userDone = YES;
    [self checkComplete];
}

- (void)didRetrieveHelpTopics:(NSArray *)topics {
    if ([UVSession currentSession].config.topicId) {
        UVHelpTopic *foundTopic = nil;
        for (UVHelpTopic *topic in topics) {
            if (topic.topicId == [UVSession currentSession].config.topicId) {
                foundTopic = topic;
                break;
            }
        }
        if (foundTopic) {
            [UVSession currentSession].topics = @[foundTopic];
            [UVArticle getArticlesWithTopic:foundTopic delegate:self];
        } else {
            [UVSession currentSession].topics = topics;
            kbDone = YES;
        }
    } else if ([topics count] == 0) {
        [UVArticle getArticlesWithDelegate:self];
    } else {
        [UVSession currentSession].topics = topics;
        kbDone = YES;
    }
    [self checkComplete];
}

- (void)didRetrieveArticles:(NSArray *)articles {
    [UVSession currentSession].articles = articles;
    kbDone = YES;
    [self checkComplete];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [delegate performSelector:@selector(dismissUserVoice)];
}

- (void)didReceiveError:(NSError *)error {
    if ([error isAuthError]) {
        if ([UVAccessToken exists]) {
            [[UVSession currentSession].accessToken remove];
            [UVSession currentSession].accessToken = nil;
            kbDone = NO;
            userDone = NO;
            configDone = NO;
            [UVRequestToken getRequestTokenWithDelegate:self];
        } else {
            [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", @"UserVoice", nil)
                                         message:NSLocalizedStringFromTable(@"This application didn't configure UserVoice properly", @"UserVoice", nil)
                                        delegate:self
                               cancelButtonTitle:nil
                               otherButtonTitles:NSLocalizedStringFromTable(@"OK", @"UserVoice", nil), nil] autorelease] show];
        }
    }
}


@end
