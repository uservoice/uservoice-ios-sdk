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
#import "UVRequestContext.h"

@implementation UVInitialLoadManager

@synthesize dismissed;

+ (UVInitialLoadManager *)loadWithDelegate:(id)delegate action:(SEL)action {
    UVInitialLoadManager *manager = [[UVInitialLoadManager alloc] initWithDelegate:delegate action:action];
    [manager beginLoad];
    return manager;
}

- (id)initWithDelegate:(id)theDelegate action:(SEL)theAction {
    if (self = [super init]) {
        delegate = theDelegate;
        action = theAction;
        configDone = NO;
        userDone = NO;
        topicsDone = NO;
        articlesDone = NO;
    }
    return self;
}

- (void)beginLoad {
    [UVRequestToken getRequestTokenWithDelegate:self];
}

- (void)checkComplete {
    if (configDone && userDone && topicsDone && articlesDone) {
        if ([UVSession currentSession].user) {
            [[UVSession currentSession].user updateVotesRemaining];
        }
        [delegate performSelector:action];
    }
}

- (void)didRetrieveRequestToken:(UVRequestToken *)token {
    if (dismissed) return;
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
    [self checkComplete];
}

- (void)didRetrieveClientConfig:(UVClientConfig *)clientConfig {
    if (dismissed) return;
    configDone = YES;
    if (clientConfig.ticketsEnabled) {
        if ([UVSession currentSession].config.topicId) {
            [UVHelpTopic getTopicWithId:[UVSession currentSession].config.topicId delegate:self];
            [UVArticle getArticlesWithTopicId:[UVSession currentSession].config.topicId delegate:self];
        } else {
            [UVHelpTopic getAllWithDelegate:self];
            [UVArticle getArticlesWithDelegate:self];
        }
    } else {
        topicsDone = YES;
        articlesDone = YES;
    }
    [self checkComplete];
}

- (void)didCreateUser:(UVUser *)theUser {
    if (dismissed) return;
    [UVSession currentSession].user = theUser;
    [[UVSession currentSession].accessToken persist];
    userDone = YES;
    [self checkComplete];
}

- (void)didRetrieveCurrentUser:(UVUser *)theUser {
    if (dismissed) return;
    [UVSession currentSession].user = theUser;
    [[UVSession currentSession].accessToken persist];
    userDone = YES;
    [self checkComplete];
}

- (void)didRetrieveHelpTopic:(UVHelpTopic *)topic {
    if (dismissed) return;
    [UVSession currentSession].topics = @[topic];
    topicsDone = YES;
    [self checkComplete];
}

- (void)didRetrieveHelpTopics:(NSArray *)topics {
    if (dismissed) return;
    [UVSession currentSession].topics = [topics filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"articleCount > 0"]];
    topicsDone = YES;
    [self checkComplete];
}

- (void)didRetrieveArticles:(NSArray *)articles {
    if (dismissed) return;
    [UVSession currentSession].articles = articles;
    articlesDone = YES;
    [self checkComplete];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [delegate performSelector:@selector(dismissUserVoice)];
}

- (void)didReceiveError:(NSError *)error context:(UVRequestContext *)requestContext {
    if (dismissed) return;
    NSString *message = nil;
    if ([error isAuthError]) {
        if ([requestContext.context isEqualToString:@"sso"] || [requestContext.context isEqualToString:@"local-sso"]) {
          // SSO and local SSO can fail with regard to admins. It's ok to proceed without a user.
          userDone = YES;
          return;
        }
        if ([UVAccessToken exists]) {
            [[UVSession currentSession].accessToken remove];
            [UVSession currentSession].accessToken = nil;
            articlesDone = NO;
            topicsDone = NO;
            userDone = NO;
            configDone = NO;
            [UVRequestToken getRequestTokenWithDelegate:self];
            return;
        } else {
            message = NSLocalizedStringFromTable(@"This application didn't configure UserVoice properly", @"UserVoice", nil);
        }
    } else if ([error isConnectionError]) {
        message = NSLocalizedStringFromTable(@"There appears to be a problem with your network connection, please check your connectivity and try again.", @"UserVoice", nil);
    } else {
        message = NSLocalizedStringFromTable(@"Sorry, there was an error in the application.", @"UserVoice", nil);
    }
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", @"UserVoice", nil) message:message delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"OK", @"UserVoice", nil), nil] autorelease] show];
}


@end
