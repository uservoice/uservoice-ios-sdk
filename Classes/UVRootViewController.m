//
//  UVWelcomeViewController.m
//  UserVoice
//
//  Created by UserVoice on 12/15/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVRootViewController.h"
#import "UVClientConfig.h"
#import "UVToken.h"
#import "UVSession.h"
#import "UVUser.h"
#import "UVCustomField.h"
#import "UVWelcomeViewController.h"
#import "UVSuggestionListViewController.h"
#import "UVNetworkUtils.h"
#import "UVSuggestion.h"
#import "NSError+UVExtras.h"
#include <QuartzCore/QuartzCore.h>

@implementation UVRootViewController

@synthesize ssoToken;
@synthesize email, displayName, guid;

- (id)initWithSsoToken:(NSString *)aToken {
	if ((self = [super init])) {
		self.ssoToken = aToken;
	}
	return self;
}

- (id)initWithEmail:(NSString *)anEmail andGUID:(NSString *)aGUID andName:(NSString *)aDisplayName {
	if ((self = [super init])) {
		self.email = anEmail;
		self.guid = aGUID;
		self.displayName = aDisplayName;
	}
	return self;
}

- (void)didReceiveError:(NSError *)error {
	if ([error isAuthError]) {
		if ([UVToken exists]) {
			[[UVSession currentSession].currentToken remove];
			[UVToken getRequestTokenWithDelegate:self];
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

- (void)pushWelcomeView {
    UVSession *session = [UVSession currentSession];
    if ((![UVToken exists] || session.user) && session.clientConfig && [self.navigationController.viewControllers count] == 1) {
        self.navigationController.navigationBarHidden = NO;
        UVWelcomeViewController *welcomeView = [[UVWelcomeViewController alloc] init];
        [self.navigationController pushViewController:welcomeView animated:YES];
        [welcomeView release];
    }
}

- (void)didRetrieveRequestToken:(UVToken *)token {
	// should be storing all tokens and checking on type
	[UVSession currentSession].currentToken = token;
	
	// check if we have a sso token and if so exchange it for an access token and user
	if (self.ssoToken != nil) {
		[UVUser findOrCreateWithSsoToken:self.ssoToken delegate:self];
	} else if (self.email != nil) {
		[UVUser findOrCreateWithGUID:self.guid andEmail:self.email andName:self.displayName andDelegate:self];
	} else {
		[UVClientConfig getWithDelegate:self];
	}
}

- (void)didCreateUser:(UVUser *)theUser {
	// set the current user
	[UVSession currentSession].user = theUser;
	
	// token should have been loaded by ResponseDelegate
	[[UVSession currentSession].currentToken persist];
	
	[UVClientConfig getWithDelegate:self];
}

- (void)didRetrieveClientConfig:(UVClientConfig *)clientConfig {
	if ([UVSession currentSession].clientConfig.ticketsEnabled) {
        [UVCustomField getCustomFieldsWithDelegate:self];
    } else {
        [self pushWelcomeView];
    }
}

- (void)didRetrieveCurrentUser:(UVUser *)theUser {
	[UVSession currentSession].user = theUser;
    [UVSuggestion getWithForumAndUser:[UVSession currentSession].clientConfig.forum
								 user:theUser delegate:self];
}

- (void)didRetrieveCustomFields:(id)theFields {
    [UVSession currentSession].clientConfig.customFields = [[[NSArray alloc] initWithArray:theFields] autorelease];
    [self pushWelcomeView];
}

- (void) didRetrieveUserSuggestions:(NSArray *) theSuggestions {
    UVUser *user = [UVSession currentSession].user;
    [user didLoadSuggestions:theSuggestions];
    [self pushWelcomeView];
}

#pragma mark ===== Basic View Methods =====

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	// Hide the nav bar
	self.navigationController.navigationBarHidden = YES;

	[super loadView];
	
	CGRect frame = [self contentFrameWithNavBar:NO];
	UIView *contentView = [[UIView alloc] initWithFrame:frame];
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	CGFloat screenHeight = [UVClientConfig getScreenHeight];
	
	contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	UILabel *splashLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, (screenHeight/2)+10, screenWidth, 20)];
	splashLabel2.backgroundColor = [UIColor clearColor];
	splashLabel2.font = [UIFont systemFontOfSize:15];
	splashLabel2.textColor = [UIColor darkGrayColor];
	splashLabel2.textAlignment = UITextAlignmentCenter;
	splashLabel2.text = NSLocalizedStringFromTable(@"Connecting to UserVoice", @"UserVoice", nil);
	[contentView addSubview:splashLabel2];
	[splashLabel2 release];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth-80)/2, (screenHeight/2)+40, 80, 20)];
    [cancelButton setTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil) forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:12];
    cancelButton.titleLabel.textColor = [UIColor darkGrayColor];
    cancelButton.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    cancelButton.layer.cornerRadius = 6.0;
    [cancelButton addTarget:self action:@selector(dismissUserVoice) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:cancelButton];
    [cancelButton release];

		
	UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activity.center = CGPointMake(screenWidth/2, (screenHeight/ 2) - 60);
	[contentView addSubview:activity];
	[activity startAnimating];
	[activity release];
	
	self.view = contentView;
	[contentView release];
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"View will appear (RootView)");

	if (![UVNetworkUtils hasInternetAccess]) {
		UIImageView *serverErrorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_error_connection.png"]];
		self.navigationController.navigationBarHidden = NO;
		serverErrorImage.frame = self.view.frame;
        serverErrorImage.contentMode = UIViewContentModeCenter;
        serverErrorImage.backgroundColor = [UIColor colorWithRed:0.78f green:0.80f blue:0.83f alpha:1.0f];
        serverErrorImage.clipsToBounds = YES;
		[self.view addSubview:serverErrorImage];
		[serverErrorImage release];
	} else if (![UVToken exists]) {
		NSLog(@"No access token");
		[UVToken getRequestTokenWithDelegate:self];
	} else if (![[UVSession currentSession] clientConfig]) {
		NSLog(@"No client config");
		[UVSession currentSession].currentToken = [[[UVToken alloc] initWithExisting] autorelease];

		// get config and current user
		[UVClientConfig getWithDelegate:self];
		[UVUser retrieveCurrentUser:self];
	} else if (![UVSession currentSession].user) {
		NSLog(@"No user");
		// just get user
		[UVSession currentSession].currentToken = [[[UVToken alloc] initWithExisting] autorelease];
		[UVUser retrieveCurrentUser:self];
	} else {
		NSLog(@"Already loaded");
		// We already have a client config, because the user already logged in before during
		// this session. Skip straight to the welcome view.
		[self pushWelcomeView];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	// Re-enable the navigation bar
	self.navigationController.navigationBarHidden = NO;
}

- (void)dealloc {
	self.ssoToken = nil;
	self.email = nil;
	self.guid = nil;
	self.displayName = nil;
    [super dealloc];
}

@end
