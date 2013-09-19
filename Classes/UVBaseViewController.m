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

- (id)init {
    self = [super init];
    if (self) {
        self.signinManager = [UVSigninManager manager];
        self.signinManager.delegate = self;
    }
    return self;
}

- (void)dismissUserVoice {
    [[UVImageCache sharedInstance] flush];
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
    [self enableSubmitButton];
    [activityIndicatorView stopAnimating];
    activityIndicatorView.hidden = YES;
    shade.hidden = YES;
}

- (void)setSubmitButtonEnabled:(BOOL)enabled {
    if (!self.navigationItem) {
        return;
    }
    
    if (self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem.enabled = enabled;
    }
}

- (void)disableSubmitButton {
    [self setSubmitButtonEnabled:NO];
}

- (void)enableSubmitButton {
    [self enableSubmitButtonForce:NO];
}

- (void)enableSubmitButtonForce:(BOOL)force {
    BOOL shouldEnableButton = [self shouldEnableSubmitButton];

    if (shouldEnableButton || force) {
        [self setSubmitButtonEnabled:YES];
    }
}

- (BOOL)shouldEnableSubmitButton {
    return YES;
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

- (BOOL)needNestedModalHack {
    return [UIDevice currentDevice].systemVersion.floatValue >= 6;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {

    // We are the top modal, make to sure that parent modals use our size
    if (self.needNestedModalHack && self.presentedViewController == nil && self.presentingViewController) {
        for (UIViewController* parent = self.presentingViewController;
             parent.presentingViewController;
             parent = parent.presentingViewController) {
            parent.view.superview.frame = parent.presentedViewController.view.superview.frame;
        }
    }

    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    // We are the top modal, make to sure that parent modals are hidden during transition
    if (self.needNestedModalHack && self.presentedViewController == nil && self.presentingViewController) {
        for (UIViewController* parent = self.presentingViewController;
             parent.presentingViewController;
             parent = parent.presentingViewController) {
            parent.view.superview.hidden = YES;
        }
    }

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // We are the top modal, make to sure that parent modals are shown after animation
    if (self.needNestedModalHack && self.presentedViewController == nil && self.presentingViewController) {
        for (UIViewController* parent = self.presentingViewController;
             parent.presentingViewController;
             parent = parent.presentingViewController) {
            parent.view.superview.hidden = NO;
        }
    }

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
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
    UIEdgeInsets contentInsets = UIEdgeInsetsMake([self scrollView].contentInset.top, 0.0, kbHeight, 0.0);
    [self scrollView].contentInset = contentInsets;
    [self scrollView].scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)notification {
}

- (void)keyboardDidHide:(NSNotification*)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake([self scrollView].contentInset.top, 0.0, 0.0, 0.0);
    [self scrollView].contentInset = contentInsets;
    [self scrollView].scrollIndicatorInsets = contentInsets;
}

- (void)presentModalViewController:(UIViewController *)viewController {
    UINavigationController *navigationController = [[[UINavigationController alloc] init] autorelease];
    [UVUtils applyStylesheetToNavigationController:navigationController];
    navigationController.viewControllers = @[viewController];
    if (IPAD)
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];
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

- (void)requireUserSignedIn:(UVCallback *)callback {
    [signinManager signInWithCallback:callback];
}

- (void)requireUserAuthenticated:(NSString *)email name:(NSString *)name callback:(UVCallback *)callback {
    [self.signinManager signInWithEmail:email name:name callback:callback];
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

- (CGRect)cellLabelRect:(UIView *)container {
    CGFloat offset = 14 + (IOS7 ? 0 : (IPAD ? 27 : 2));
    return CGRectMake(offset, 12, container.frame.size.width - offset - (IOS7 ? 2 : offset), 16);
}

- (CGRect)cellValueRect:(UIView *)container {
    CGFloat offset = 14 + (IOS7 ? 0 : (IPAD ? 27 : 2));
    return CGRectMake(offset, 28, container.frame.size.width - offset - (IOS7 ? 2 : offset), 30);
}

- (UILabel *)addCellLabel:(UIView *)container {
    UILabel *label = [[[UILabel alloc] initWithFrame:[self cellLabelRect:container]] autorelease];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont systemFontOfSize:13];
    if (IOS7){
        label.textColor = [self.view valueForKey:@"tintColor"];
    } else {
        label.textColor = [UIColor grayColor];
    }
    label.backgroundColor = [UIColor clearColor];
    [container addSubview:label];
    return label;
}

- (UILabel *)addCellValueLabel:(UIView *)container {
    UILabel *label = [[[UILabel alloc] initWithFrame:[self cellValueRect:container]] autorelease];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont systemFontOfSize:16];
    label.backgroundColor = [UIColor clearColor];
    [container addSubview:label];
    return label;
}

- (UITextField *)addCellValueTextField:(UIView *)container {
    UITextField *textField = [[[UITextField alloc] initWithFrame:[self cellValueRect:container]] autorelease];
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField.borderStyle = UITextBorderStyleNone;
    textField.backgroundColor = [UIColor clearColor];
    textField.returnKeyType = UIReturnKeyDone;
    textField.placeholder = NSLocalizedStringFromTable(@"enter value", @"UserVoice", nil);
    [container addSubview:textField];
    return textField;
}

- (UITextField *)customizeTextFieldCell:(UITableViewCell *)cell label:(NSString *)labelText placeholder:(NSString *)placeholder {
    UILabel *label = [self addCellLabel:cell];
    label.text = labelText;
    UITextField *textField = [self addCellValueTextField:cell];
    textField.placeholder = placeholder;
    textField.delegate = self;
    return textField;
}

#pragma mark - UVSigninManageDelegate

- (void)signinManagerDidSignIn:(UVUser *)user {
    [self hideActivityIndicator];
}

- (void)signinManagerDidFail {
    [self hideActivityIndicator];
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
    self.signinManager.delegate = nil;
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
