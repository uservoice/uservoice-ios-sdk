//
//  UVWelcomeViewController.m
//  UserVoice
//
//  Created by UserVoice on 12/15/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "UVRootViewController.h"
#import "UVClientConfig.h"
#import "UVAccessToken.h"
#import "UVRequestToken.h"
#import "UVSession.h"
#import "UVUser.h"
#import "UVWelcomeViewController.h"
#import "UVSuggestionListViewController.h"
#import "UVNewTicketViewController.h"
#import "UVSuggestion.h"
#import "UVConfig.h"
#import "NSError+UVExtras.h"
#import "UVStyleSheet.h"
#import "UVHelpTopic.h"
#import "UVArticle.h"

@implementation UVRootViewController

@synthesize viewToLoad;

- (id)init {
    if (self = [super init]) {
        self.viewToLoad = @"welcome";
    }
    return self;
}

- (id)initWithViewToLoad:(NSString *)theViewToLoad {
    if (self = [super init]) {
        self.viewToLoad = theViewToLoad;
    }
    return self;
}

- (void)didReceiveError:(NSError *)error {
    if ([error isAuthError]) {
        if ([UVAccessToken exists]) {
            [[UVSession currentSession].accessToken remove];
            [UVSession currentSession].accessToken = nil;
            [UVRequestToken getRequestTokenWithDelegate:self];
        } else {
            [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", @"UserVoice", nil)
                                         message:NSLocalizedStringFromTable(@"This application didn't configure UserVoice properly", @"UserVoice", nil)
                                        delegate:self
                               cancelButtonTitle:nil
                               otherButtonTitles:NSLocalizedStringFromTable(@"OK", @"UserVoice", nil), nil] autorelease] show];
        }
    } else {
        [super didReceiveError:error];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self dismissUserVoice];
}

- (void)pushNextView {
    UVSession *session = [UVSession currentSession];
    if ((![UVAccessToken exists] || session.user) && session.clientConfig && [self.navigationController.viewControllers count] == 1) {
        CATransition* transition = [CATransition animation];
        transition.duration = 0.3;
        transition.type = kCATransitionFade;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        if (self.viewToLoad == @"welcome") {
            UVWelcomeViewController *welcomeView = [[UVWelcomeViewController alloc] init];
            welcomeView.firstController = YES;
            [self.navigationController pushViewController:welcomeView animated:NO];
            [welcomeView release];
        } else if (self.viewToLoad == @"suggestions") {
            UIViewController *welcomeViewController = [[[UVWelcomeViewController alloc] init] autorelease];
            UVBaseViewController *suggestionListViewController = [[[UVSuggestionListViewController alloc] init] autorelease];
            suggestionListViewController.firstController = YES;
            NSArray *viewControllers = [NSArray arrayWithObjects:welcomeViewController, suggestionListViewController, nil];
            [self.navigationController setViewControllers:viewControllers animated:NO];
        } else if (self.viewToLoad == @"new_ticket") {
            UIViewController *welcomeViewController = [[[UVWelcomeViewController alloc] init] autorelease];
            UVBaseViewController *newTicketViewController = [UVNewTicketViewController viewController];
            newTicketViewController.firstController = YES;
            NSArray *viewControllers = [NSArray arrayWithObjects:welcomeViewController, newTicketViewController, nil];
            [self.navigationController setViewControllers:viewControllers animated:NO];
        }
    }
}

// Initialization: request token -> client config -> user -> persist the access token -> user's suggestions -> next view
// If we don't have either a configured user, or a persisted token (which is therefore an access token) then we go straight from the client config to the next view
- (void)didRetrieveRequestToken:(UVRequestToken *)token {
    [UVSession currentSession].requestToken = token;
    [UVHelpTopic getAllWithDelegate:self];
}

- (void)didRetrieveClientConfig:(UVClientConfig *)clientConfig {
    // check if we have a sso token and if so exchange it for an access token and user
    if ([UVSession currentSession].config.ssoToken != nil) {
        [UVUser findOrCreateWithSsoToken:[UVSession currentSession].config.ssoToken delegate:self];
    } else if ([UVSession currentSession].config.email != nil) {
        [UVUser findOrCreateWithGUID:[UVSession currentSession].config.guid andEmail:[UVSession currentSession].config.email andName:[UVSession currentSession].config.displayName andDelegate:self];
    } else if ([UVAccessToken exists]) {
        [UVSession currentSession].accessToken = [[[UVAccessToken alloc] initWithExisting] autorelease];
        [UVUser retrieveCurrentUser:self];
    } else {
        [self pushNextView];
    }
}

- (void)didCreateUser:(UVUser *)theUser {
    [UVSession currentSession].user = theUser;
    [[UVSession currentSession].accessToken persist];
    [self pushNextView];
}

- (void)didRetrieveCurrentUser:(UVUser *)theUser {
    [UVSession currentSession].user = theUser;
    [[UVSession currentSession].accessToken persist];
    [self pushNextView];
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
            [UVClientConfig getWithDelegate:self];
        }
    } else if ([topics count] == 0) {
        [UVArticle getArticlesWithDelegate:self];
    } else {
        [UVSession currentSession].topics = topics;
        [UVClientConfig getWithDelegate:self];
    }
}

- (void)didRetrieveArticles:(NSArray *)articles {
    [UVSession currentSession].articles = articles;
    [UVClientConfig getWithDelegate:self];
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [super loadView];

    self.navigationItem.title = NSLocalizedStringFromTable(@"Feedback & Support", @"UserVoice", nil);
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Close", @"UserVoice", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(dismissUserVoice)] autorelease];

    self.view = [[[UIView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.view.backgroundColor = [UVStyleSheet backgroundColor];

    UIView *loading = [[[UIView alloc] initWithFrame:CGRectMake(0, 120, self.view.bounds.size.width, 100)] autorelease];
    loading.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    UIActivityIndicatorView *activity = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    if ([activity respondsToSelector:@selector(setColor:)]) {
        [activity setColor:[UIColor grayColor]];
    } else {
        [activity release];
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    activity.center = CGPointMake(loading.bounds.size.width/2, 40);
    [loading addSubview:activity];
    [activity startAnimating];
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 70, loading.frame.size.width, 20)] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor darkGrayColor];
    label.textAlignment = UITextAlignmentCenter;
    label.text = NSLocalizedStringFromTable(@"Connecting to UserVoice", @"UserVoice", nil);
    [label sizeToFit];
    label.center = CGPointMake(loading.bounds.size.width/2, 85);
    [loading addSubview:label];
    [loading sizeToFit];
    [self.view addSubview:loading];
}

- (void)viewWillAppear:(BOOL)animated {
    [UVRequestToken getRequestTokenWithDelegate:self];
}

- (void)dealloc {
    self.viewToLoad = nil;
    [super dealloc];
}

@end
