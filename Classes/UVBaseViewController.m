//
//  UVBaseViewController.m
//  UserVoice
//
//  Created by UserVoice on 10/19/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVBaseViewController.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVSuggestion.h"
#import "UVUser.h"
#import "UVStyleSheet.h"
#import "UVActivityIndicator.h"
#import "UVNetworkUtils.h"
#import "NSError+UVExtras.h"
#import "UVStreamPoller.h"
#import "UVImageCache.h"
#import "UserVoice.h"
#import "UVSignInViewController.h"

@implementation UVBaseViewController

@synthesize activityIndicator;
@synthesize needsReload;
@synthesize tableView;
@synthesize exitButton;

- (void)dismissUserVoice {
    if ([UVStreamPoller instance].timerIsRunning)
		[[UVStreamPoller instance] stopTimer];
    [[UVImageCache sharedInstance] flush];

	[self dismissModalViewControllerAnimated:YES];
    if ([[UserVoice delegate] respondsToSelector:@selector(userVoiceWasDismissed)])
        [[UserVoice delegate] userVoiceWasDismissed];
}

- (CGRect)contentFrameWithNavBar:(BOOL)navBarEnabled {
	CGRect barFrame = CGRectZero;
	if (navBarEnabled) {
		barFrame = self.navigationController.navigationBar.frame;
	}
	CGRect appFrame = [UIScreen mainScreen].applicationFrame;
//	NSLog(@"appFrame: %@", NSStringFromCGRect(appFrame));
	CGFloat yStart = barFrame.origin.y + barFrame.size.height;
	
	
//	NSLog(@"%@", [UVSession currentSession].clientConfig);
	
	//return CGRectMake(0, yStart, appFrame.size.width, appFrame.size.height - barFrame.size.height);
	return CGRectMake(0, yStart, appFrame.size.width, appFrame.size.height - barFrame.size.height);
}


- (CGRect)contentFrame {
	return [self contentFrameWithNavBar:YES];
}

- (void)showActivityIndicatorWithText: (NSString *)text {
	if (!self.activityIndicator) {
		self.activityIndicator = [UVActivityIndicator activityIndicatorWithText:text];
	}
	
	[self.activityIndicator show];
}

- (void)showActivityIndicator {
	if (!self.activityIndicator) {
		self.activityIndicator = [UVActivityIndicator activityIndicator];
	}
	
	[self.activityIndicator show];
}

- (void)hideActivityIndicator {
	[self.activityIndicator hide];
}

- (void)setVoteLabelTextAndColorForVotesRemaining:(NSInteger)votesRemaining label:(UILabel *)label {
	if ([UVSession currentSession].user) {
		if (votesRemaining == 0) {
			label.text = NSLocalizedStringFromTable(@"Sorry, you have no more votes remaining in this forum.", @"UserVoice", nil);
			label.textColor = [UVStyleSheet alertTextColor];
		} else {
			label.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"You have %d %@ remaining in this forum", @"UserVoice", @"%d for number of votes, %@ for pluralization of 'votes'"),
						  votesRemaining,
						  votesRemaining == 1 ? NSLocalizedStringFromTable(@"vote", @"UserVoice", nil) : NSLocalizedStringFromTable(@"votes", @"UserVoice", nil)];
			label.textColor = [UVStyleSheet linkTextColor];
		}
	} else {
		label.font = [UIFont boldSystemFontOfSize:14];
		label.text = NSLocalizedStringFromTable(@"You will need to sign in to vote.", @"UserVoice", nil);
		label.textColor = [UVStyleSheet alertTextColor];
    }
}

- (void)alertError:(NSString *)message {
	[[[[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", @"UserVoice", nil)
                                message:message
                               delegate:nil
                      cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"UserVoice", nil)
                      otherButtonTitles:nil] autorelease] show];
}

- (void)alertSuccess:(NSString *)message {
	[[[[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Success", @"UserVoice", nil)
                                 message:message
                                delegate:nil
                       cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"UserVoice", nil)
                       otherButtonTitles:nil] autorelease] show];
}

- (void)didReceiveError:(NSError *)error {
	[self hideActivityIndicator];
	NSString *msg = nil;
	if ([UVNetworkUtils hasInternetAccess] && ![error isConnectionError]) {
        NSDictionary *userInfo = [error userInfo];
        for (NSString *key in [userInfo allKeys]) {
            if ([key isEqualToString:@"message"] || [key isEqualToString:@"type"])
                continue;
            NSString *displayKey = nil;
            if ([key isEqualToString:@"display_name"])
                displayKey = NSLocalizedStringFromTable(@"User name", @"UserVoice", nil);
            else
                displayKey = [[key stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];

            // Suggestion title has custom messages
            if ([key isEqualToString:@"title"])
                msg = [userInfo valueForKey:key];
            else
                msg = [NSString stringWithFormat:@"%@ %@", displayKey, [userInfo valueForKey:key], nil];
        }
        if (!msg)
            msg = NSLocalizedStringFromTable(@"Sorry, there was an error in the application.", @"UserVoice", nil);
	} else {
		msg = NSLocalizedStringFromTable(@"There appears to be a problem with your network connection, please check your connectivity and try again.", @"UserVoice", nil);
	}
	[self alertError:msg];
}

- (NSString *)backButtonTitle {
	return NSLocalizedStringFromTable(@"Back", @"UserVoice", nil);
}

- (void)initNavigationItem {
	self.navigationItem.title = NSLocalizedStringFromTable(@"Feedback", @"UserVoice", nil);
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
								   initWithTitle:[self backButtonTitle]
								   style:UIBarButtonItemStylePlain
								   target:nil
								   action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
	
	if ([UVSession currentSession].isModal) {
		self.exitButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Close", @"UserVoice", nil)
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(dismissUserVoice)] autorelease];
		self.navigationItem.rightBarButtonItem = exitButton;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	UIDeviceOrientation deviceOrientation = [UVClientConfig getOrientation];
	return (interfaceOrientation == deviceOrientation);
}

#pragma mark ===== helper methods for table views =====

- (void)removeBackgroundFromCell:(UITableViewCell *)cell {
	UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	backView.backgroundColor = [UIColor clearColor];
	cell.backgroundView = backView;
	cell.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)createCellForIdentifier:(NSString *)identifier
								   tableView:(UITableView *)theTableView
								   indexPath:(NSIndexPath *)indexPath
									   style:(UITableViewCellStyle)style
								  selectable:(BOOL)selectable {
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier] autorelease];
		cell.selectionStyle = selectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		
		SEL initCellSelector = NSSelectorFromString([NSString stringWithFormat:@"initCellFor%@:indexPath:", identifier]);
		if ([self respondsToSelector:initCellSelector]) {
			[self performSelector:initCellSelector withObject:cell withObject:indexPath];
		}
	}
	
	SEL customizeCellSelector = NSSelectorFromString([NSString stringWithFormat:@"customizeCellFor%@:indexPath:", identifier]);
	if ([self respondsToSelector:customizeCellSelector]) {
		[self performSelector:customizeCellSelector withObject:cell withObject:indexPath];
	}
	return cell;
}

// Add a highlight row at the top. You need to separately add a dark shadow via
// the table separator.
- (void)addHighlightToCell:(UITableViewCell *)cell {
	
	//CGRect screenRect = [[UIScreen mainScreen] bounds];
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	
	UIView *highlight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
	highlight.backgroundColor = [UVStyleSheet topSeparatorColor];
	highlight.opaque = YES;
	[cell.contentView addSubview:highlight];
	[highlight release];
}

- (void)addShadowSeparatorToTableView:(UITableView *)theTableView {
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	theTableView.separatorColor = [UVStyleSheet bottomSeparatorColor];
}

#pragma mark ===== Keyboard Notifications =====

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    
}

- (void)keyboardDidShow:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    CGRect rect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    // Convert from window space to view space to account for orientation
    kbHeight = [self.view convertRect:rect fromView:nil].size.height;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbHeight, 0.0);
    tableView.contentInset = contentInsets;
    tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardDidHide:(NSNotification*)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    tableView.contentInset = contentInsets;
    tableView.scrollIndicatorInsets = contentInsets;
}

- (void)hideExitButton {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)showExitButton {
    if (exitButton)
        self.navigationItem.rightBarButtonItem = exitButton;
}

- (void)promptUserToSignIn {
    UVSignInViewController *signInView = [[[UVSignInViewController alloc] init] autorelease];
    [self.navigationController pushViewController:signInView animated:YES];
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
	[self initNavigationItem];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    // Fix background color on iPad
    if ([self.view respondsToSelector:@selector(setBackgroundView:)])
        [self.view performSelector:@selector(setBackgroundView:) withObject:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	self.activityIndicator = nil;
}

- (void)dealloc {
    self.activityIndicator = nil;
    self.tableView = nil;
    self.exitButton = nil;
    [super dealloc];
}

@end
