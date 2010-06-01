//
//  UVWelcomeViewController.m
//  UserVoice
//
//  Created by Mirko Froehlich on 12/15/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVRootViewController.h"
#import "UVClientConfig.h"
#import "UVToken.h"
#import "UVSession.h"
#import "UVUser.h"
#import "UVWelcomeViewController.h"
#import "UVSuggestionListViewController.h"
#import "UVNetworkUtils.h"
#import "NSError+UVExtras.h"

@implementation UVRootViewController

- (void)setupErrorAlertViewDelegate
{
	errorAlertView.delegate = self;
}

- (void)didReceiveError:(NSError *)error {
	if ([error isAuthError]) {
		if ([UVToken exists]) {
			[[UVSession currentSession].currentToken remove];
			[UVToken getRequestTokenWithDelegate:self];
			
		} else {
			[self showErrorAlertViewWithMessage:@"This application didn't configure UserVoice properly"];
		}
	} else {
		[super didReceiveError:error];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self dismissUserVoice];
}

- (void)pushWelcomeView {
	// Note: We used to bring the user straight to the suggestions list view, while
	//       allowing them to pop back up to the forum list. Commenting this code
	//       out but leaving it around in case we decide to revert back to this approach.
	// We're swapping the current view controller out for two new ones:
	// A forum list and a suggestion list for the default forum. This way,
	// the user will first see the suggestion list, but will be able to use
	// the Back button to go up to the forum list.
	UVWelcomeViewController *forumsView = [[UVWelcomeViewController alloc] init];
	//UVSuggestionListViewController *suggestionsView = [[UVSuggestionListViewController alloc]
	//												   initWithForum:[UVSession currentSession].clientConfig.defaultForum];
	//NSArray *viewControllers = [NSArray arrayWithObjects:forumsView, suggestionsView, nil];
	//[self.navigationController setViewControllers:viewControllers animated:YES];
	
	[self.navigationController pushViewController:forumsView animated:YES];
}


- (void)didRetrieveRequestToken:(UVToken *)token {
	// should be storing all tokens and checking on type
	//	token.type = @"request";
	//	[token persist];
	[UVSession currentSession].currentToken = token;
	
	[UVClientConfig getWithDelegate:self];
}

- (void)didRetrieveClientConfig:(UVClientConfig *)clientConfig {	
	// no reason for this and user to be sent sequentially
	if ([UVToken exists] && ![UVSession currentSession].user) {
		// have config and access token		
		[UVUser retrieveCurrentUser:self];
		
	} else {
		[self hideActivityIndicator];
		[self pushWelcomeView];
	}
}

- (void)didRetrieveCurrentUser:(UVUser *)theUser {
	[UVSession currentSession].user = theUser;
	
	[self hideActivityIndicator];
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
	
	UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_splash.png"]];
	[contentView addSubview:image];
	[image release];
	
	UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activity.center = CGPointMake(frame.size.width / 2, (frame.size.height / 2) - 20);
	[contentView addSubview:activity];
	[activity startAnimating];
	[activity release];
	
	UILabel *activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height / 2, 320, 20)];
	activityLabel.text = @"Logging In...";
	activityLabel.textColor = [UIColor whiteColor];
	activityLabel.backgroundColor = nil;
	activityLabel.opaque = NO;
	activityLabel.textAlignment = UITextAlignmentCenter;
	activityLabel.font = [UIFont systemFontOfSize:18];
	[contentView addSubview:activityLabel];
	[activityLabel release];
	
	self.view = contentView;
	[contentView release];
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"View will appear (RootView)");
	[super viewWillAppear:animated];
	
	if (![UVNetworkUtils hasInternetAccess]) {
		//NSLog(@"No Internet access!");
		UIImageView *serverErrorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_error_connection.png"]];
		self.navigationController.navigationBarHidden = NO;
		serverErrorImage.frame = self.view.frame;
		[self.view addSubview:serverErrorImage];
		
	} else if (![UVToken exists]) {
		// no access token
		NSLog(@"No access token");
		[UVToken getRequestTokenWithDelegate:self];
		
	} else if (![[UVSession currentSession] clientConfig]) {
		// no client config
		NSLog(@"No client");
		[UVSession currentSession].currentToken = [[UVToken alloc]initWithExisting];
		[UVClientConfig getWithDelegate:self];

	} else if (![UVSession currentSession].user) {
		NSLog(@"No user");
		[UVSession currentSession].currentToken = [[UVToken alloc]initWithExisting];
		[UVUser retrieveCurrentUser:self];
		
	} else {
		NSLog(@"Pushing welcome");
		// Re-enable the navigation bar
		self.navigationController.navigationBarHidden = NO;

		// We already have a client config, because the user already logged in before during
		// this session. Skip straight to the welcome view.
		[self pushWelcomeView];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	// Re-enable the navigation bar
	self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
