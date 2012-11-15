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
#import "UVImageCache.h"
#import "UserVoice.h"
#import "UVSignInViewController.h"
#import "UVAccessToken.h"

@implementation UVBaseViewController

@synthesize activityIndicator;
@synthesize needsReload;
@synthesize firstController;
@synthesize tableView;
@synthesize exitButton;
@synthesize signinEmail;
@synthesize signinAlertView;

- (void)dismissUserVoice {
    [[UVImageCache sharedInstance] flush];
    [[UVSession currentSession] flushInteractions];
    [[UVSession currentSession] clear];
    
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
    CGFloat yStart = barFrame.origin.y + barFrame.size.height;

    return CGRectMake(0, yStart, appFrame.size.width, appFrame.size.height - barFrame.size.height);
}

- (CGRect)contentFrame {
    return [self contentFrameWithNavBar:YES];
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
    if (signinState == SIGNIN_STATE_EMAIL && [error isNotFoundError]) {
        [UVUser findOrCreateWithEmail:self.signinEmail andName:nil andDelegate:self];
    } else if (signinState != SIGNIN_STATE_NONE && ([error isAuthError] || [error isNotFoundError])) {
        [self hideActivityIndicator];
        NSString *msg = NSLocalizedStringFromTable(@"There was a problem logging you in, please check your password and try again.", @"UserVoice", nil);
        [self alertError:msg];
    } else {
        NSString *msg = nil;
        [self hideActivityIndicator];
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
                    msg = [NSString stringWithFormat:@"%@ %@", displayKey, [userInfo valueForKey:key]];
            }
            if (!msg)
                msg = NSLocalizedStringFromTable(@"Sorry, there was an error in the application.", @"UserVoice", nil);
        } else {
            msg = NSLocalizedStringFromTable(@"There appears to be a problem with your network connection, please check your connectivity and try again.", @"UserVoice", nil);
        }
        [self alertError:msg];
    }
}

- (NSString *)backButtonTitle {
    return NSLocalizedStringFromTable(@"Back", @"UserVoice", nil);
}

- (void)initNavigationItem {
    self.navigationItem.title = NSLocalizedStringFromTable(@"Feedback", @"UserVoice", nil);

    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Back", @"UserVoice", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:nil
                                                                             action:nil] autorelease];

    self.exitButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(dismissUserVoice)] autorelease];
    if ([UVSession currentSession].isModal && firstController) {
        self.navigationItem.leftBarButtonItem = exitButton;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
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
    highlight.autoresizingMask = UIViewAutoresizingFlexibleWidth;
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
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];

}

- (void)keyboardWillShow:(NSNotification*)notification {
    if (IPAD) {
        CGFloat formSheetHeight = 576;
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            kbHeight = formSheetHeight - 352;
        } else {
            kbHeight = formSheetHeight - 504;
        }
    } else {
        NSDictionary* info = [notification userInfo];
        CGRect rect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        // Convert from window space to view space to account for orientation
        kbHeight = [self.view convertRect:rect fromView:nil].size.height;
    }
}

- (UIScrollView *)scrollView {
    return tableView;
}

- (void)keyboardDidShow:(NSNotification*)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbHeight, 0.0);
    [self scrollView].contentInset = contentInsets;
    [self scrollView].scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)notification {
}

- (void)keyboardDidHide:(NSNotification*)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [self scrollView].contentInset = contentInsets;
    [self scrollView].scrollIndicatorInsets = contentInsets;
}

- (void)showExitButton {
    self.navigationItem.leftBarButtonItem = exitButton;
}

- (void)promptUserToSignIn {
    UVSignInViewController *signInView = [[[UVSignInViewController alloc] init] autorelease];
    [self.navigationController pushViewController:signInView animated:YES];
}

- (void)setupGroupedTableView {
    self.view = [[[UIView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.view.backgroundColor = [UVStyleSheet backgroundColor];
    self.view.autoresizesSubviews = YES;
    self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped] autorelease];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
}

- (void)pushViewControllerFromWelcome:(UIViewController *)viewController {
    NSMutableArray *viewControllers = [[self.navigationController.viewControllers mutableCopy] autorelease];
    [viewControllers removeLastObject];
    if ([viewControllers count] > 2)
        [viewControllers removeLastObject];
    [viewControllers addObject:viewController];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

- (void)addTopBorder:(UIView *)view {
    [self addTopBorder:view alpha:1.0];
}

- (void)addTopBorder:(UIView *)view alpha:(CGFloat)alpha {
    UIView *border = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)] autorelease];
    border.backgroundColor = [UIColor colorWithRed:0.86f green:0.88f blue:0.89f alpha:1.0f];
    border.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [view addSubview:border];
    border = [[[UIView alloc] initWithFrame:CGRectMake(0, 1, 320, 1)] autorelease];
    border.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    border.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [view addSubview:border];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *text = [alertView textFieldAtIndex:0].text;
    if (signinState == SIGNIN_STATE_EMAIL) {
        if (text.length == 0) {
            signinState = SIGNIN_STATE_NONE;
            return;
        }
        [self showActivityIndicator];
        self.signinEmail = text;
        [UVUser discoverWithEmail:text delegate:self];
    } else if (signinState == SIGNIN_STATE_PASSWORD) {
        if (text.length == 0) {
            signinState = SIGNIN_STATE_NONE;
            return;
        }
        [self showActivityIndicator];
        [UVAccessToken getAccessTokenWithDelegate:self andEmail:self.signinEmail andPassword:text];
    }
}

- (void)didRetrieveAccessToken:(UVAccessToken *)token {
    [self hideActivityIndicator];
    [token persist];
    [UVSession currentSession].accessToken = token;
    [UVUser retrieveCurrentUser:self];
}

- (void)didRetrieveCurrentUser:(UVUser *)theUser {
    [self hideActivityIndicator];
    [UVSession currentSession].user = theUser;
    signinState = SIGNIN_STATE_NONE;
    [self performSelector:signinCallback];
}

- (void)didDiscoverUser:(UVUser *)theUser {
    [self hideActivityIndicator];
    signinState = SIGNIN_STATE_PASSWORD;
    self.signinAlertView = [[[UIAlertView alloc] init] autorelease];
    signinAlertView.title = NSLocalizedStringFromTable(@"Enter your password", @"UserVoice", nil);
    signinAlertView.delegate = self;
    signinAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [signinAlertView addButtonWithTitle:NSLocalizedStringFromTable(@"Sign in", @"UserVoice", nil)];
    UITextField *textField = [signinAlertView textFieldAtIndex:0];
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    [signinAlertView show];
}

- (void)didCreateUser:(UVUser *)theUser {
    [self hideActivityIndicator];
    [UVSession currentSession].user = theUser;

    // token should have been loaded by ResponseDelegate
    [[UVSession currentSession].accessToken persist];

    [self performSelector:signinCallback];
}

- (void)requireUserSignedIn:(SEL)action {
    if ([UVSession currentSession].user) {
        [self performSelector:action];
    } else {
        signinCallback = action;
        signinState = SIGNIN_STATE_EMAIL;
        self.signinAlertView = [[[UIAlertView alloc] init] autorelease];
        signinAlertView.title = NSLocalizedStringFromTable(@"Enter your email", @"UserVoice", nil);
        signinAlertView.delegate = self;
        signinAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [signinAlertView addButtonWithTitle:NSLocalizedStringFromTable(@"Done", @"UserVoice", nil)];
        UITextField *textField = [signinAlertView textFieldAtIndex:0];
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        [signinAlertView show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (signinState != SIGNIN_STATE_NONE) {
        [signinAlertView dismissWithClickedButtonIndex:signinAlertView.firstOtherButtonIndex animated:YES];
    }
    return YES;
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [self initNavigationItem];
    signinState = SIGNIN_STATE_NONE;
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
    self.signinEmail = nil;
    self.signinAlertView = nil;
    [super dealloc];
}

@end
