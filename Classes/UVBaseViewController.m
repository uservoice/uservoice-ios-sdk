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
#import "UVImageCache.h"
#import "UserVoice.h"
#import "UVAccessToken.h"
#import "UVSigninManager.h"
#import "UVKeyboardUtils.h"
#import "UVUtils.h"

@implementation UVBaseViewController

@synthesize needsReload;
@synthesize firstController;
@synthesize tableView;
@synthesize exitButton;
@synthesize signinManager;
@synthesize shade;
@synthesize activityIndicatorView;

- (void)dismissUserVoice {
    [[UVImageCache sharedInstance] flush];
    [[UVSession currentSession] flushInteractions];
    [[UVSession currentSession] clear];
    [[UVSession currentSession] clearFlash];
    
    [self dismissModalViewControllerAnimated:YES];
    if ([[UserVoice delegate] respondsToSelector:@selector(userVoiceWasDismissed)])
        [[UserVoice delegate] userVoiceWasDismissed];
}

- (CGRect)contentFrame {
    CGRect barFrame = CGRectZero;
    barFrame = self.navigationController.navigationBar.frame;
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    CGFloat yStart = barFrame.origin.y + barFrame.size.height;
    
    return CGRectMake(0, yStart, appFrame.size.width, appFrame.size.height - barFrame.size.height);
}

- (void)showActivityIndicator {
    if (!shade) {
        self.shade = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
        self.shade.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.shade.backgroundColor = [UIColor blackColor];
        self.shade.alpha = 0.5;
        [self.view addSubview:shade];
    }
    if (!activityIndicatorView) {
        self.activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        self.activityIndicatorView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4);
        self.activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        [self.view addSubview:activityIndicatorView];
    }
    shade.hidden = NO;
    activityIndicatorView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/([UVKeyboardUtils visible] ? 4 : 2));
    activityIndicatorView.hidden = NO;
    [activityIndicatorView startAnimating];
}

- (void)hideActivityIndicator {
    [activityIndicatorView stopAnimating];
    activityIndicatorView.hidden = YES;
    shade.hidden = YES;
}

- (void)alertError:(NSString *)message {
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", @"UserVoice", nil)
                                message:message
                               delegate:nil
                      cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"UserVoice", nil)
                      otherButtonTitles:nil] autorelease] show];
}

- (void)didReceiveError:(NSError *)error {
    NSString *msg = nil;
    [self hideActivityIndicator];
    if ([UVUtils isConnectionError:error]) {
        msg = NSLocalizedStringFromTable(@"There appears to be a problem with your network connection, please check your connectivity and try again.", @"UserVoice", nil);
    } else {
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
    }
    [self alertError:msg];
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

- (void)presentModalViewController:(UIViewController *)viewController {
    UINavigationController *navigationController = [[[UINavigationController alloc] init] autorelease];
    navigationController.navigationBar.tintColor = [UVStyleSheet navigationBarTintColor];
    [navigationController.navigationBar setBackgroundImage:[UVStyleSheet navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    
    NSMutableDictionary *navbarTitleTextAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset, nil];
    if ([UVStyleSheet navigationBarTextColor]) {
        [navbarTitleTextAttributes setObject:[UVStyleSheet navigationBarTextColor] forKey:UITextAttributeTextColor];
    }
    if ([UVStyleSheet navigationBarTextShadowColor]) {
        [navbarTitleTextAttributes setObject:[UVStyleSheet navigationBarTextShadowColor] forKey:UITextAttributeTextShadowColor];\
    }
    [navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    navigationController.viewControllers = @[viewController];
    if (IPAD)
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];
    if (IPAD)
        navigationController.modalPresentationStyle = UIModalPresentationPageSheet;
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

- (void)requireUserSignedIn:(SEL)action {
    if (!signinManager)
        self.signinManager = [UVSigninManager manager];
    [signinManager signInWithDelegate:self action:action];
}

- (void)requireUserAuthenticated:(NSString *)email name:(NSString *)name action:(SEL)action {
    if (!signinManager)
        self.signinManager = [UVSigninManager manager];
    [signinManager signInWithEmail:email name:name delegate:self action:action];
}

- (void)setUserName:(NSString *)theName {
    [theName retain];
    [userName release];
    userName = theName;

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:userName forKey:@"uv-user-name"];
    [prefs synchronize];
}

- (NSString *)userName {
    if ([UVSession currentSession].user)
        return [UVSession currentSession].user.name;
    if (userName)
        return userName;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    userName = [[prefs stringForKey:@"uv-user-name"] retain];
    return userName;
}

- (void)setUserEmail:(NSString *)theEmail {
    [theEmail retain];
    [userEmail release];
    userEmail = theEmail;

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:userEmail forKey:@"uv-user-email"];
    [prefs synchronize];
}

- (NSString *)userEmail {
    if ([UVSession currentSession].user)
        return [UVSession currentSession].user.email;
    if (userEmail)
        return userEmail;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    userEmail = [[prefs stringForKey:@"uv-user-email"] retain];
    return userEmail;
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [self initNavigationItem];
    [self registerForKeyboardNotifications];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tableView = nil;
    self.exitButton = nil;
    self.signinManager = nil;
    self.shade = nil;
    self.activityIndicatorView = nil;
    [userEmail release];
    userEmail = nil;
    [userName release];
    userName = nil;
    [super dealloc];
}

@end
