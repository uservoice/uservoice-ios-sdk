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
@synthesize templateCells;

- (id)init {
    self = [super init];
    if (self) {
        self.signinManager = [UVSigninManager manager];
        self.signinManager.delegate = self;
        self.templateCells = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dismissUserVoice {
    [[UVImageCache sharedInstance] flush];
    [[UVSession currentSession] clear];
    [[UVSession currentSession] clearFlash];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
        self.shade = [[UIView alloc] initWithFrame:self.view.bounds];
        self.shade.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.shade.backgroundColor = [UIColor blackColor];
        self.shade.alpha = 0.5;
        [self.view addSubview:shade];
    }
    if (!activityIndicatorView) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
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
    [[[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error", @"UserVoice", nil)
                                message:message
                               delegate:nil
                      cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"UserVoice", nil)
                      otherButtonTitles:nil] show];
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

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Back", @"UserVoice", nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    self.exitButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(dismissUserVoice)];
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
    
    if (!IOS7 && self.tableView) {
        [self.tableView reloadData];
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
        cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier];
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
    if (!IOS7) {
        cell.contentView.frame = CGRectMake(0, 0, [self cellWidthForStyle:self.tableView.style accessoryType:cell.accessoryType], 0);
        [cell.contentView setNeedsLayout];
        [cell.contentView layoutIfNeeded];
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                if (label.numberOfLines != 1) {
                    [label setPreferredMaxLayoutWidth:label.frame.size.width];
                }
                [label setBackgroundColor:[UIColor clearColor]];
            }
        }
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
    UINavigationController *navigationController = [UINavigationController new];
    [UVUtils applyStylesheetToNavigationController:navigationController];
    navigationController.viewControllers = @[viewController];
    if (IPAD)
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)setupGroupedTableView {
    self.tableView = [[UITableView alloc] initWithFrame:[self contentFrame] style:UITableViewStyleGrouped];
    self.tableView.delegate = (id<UITableViewDelegate>)self;
    self.tableView.dataSource = (id<UITableViewDataSource>)self;
    if (!IOS7) {
        UIView *bg = [UIView new];
        bg.backgroundColor = [UVStyleSheet backgroundColor];
        self.tableView.backgroundView = bg;
    }
    self.view = self.tableView;
}

- (void)requireUserSignedIn:(UVCallback *)callback {
    [signinManager signInWithCallback:callback];
}

- (void)requireUserAuthenticated:(NSString *)email name:(NSString *)name callback:(UVCallback *)callback {
    [self.signinManager signInWithEmail:email name:name callback:callback];
}

- (void)setUserName:(NSString *)theName {
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
    userName = [prefs stringForKey:@"uv-user-name"];
    return userName;
}

- (void)setUserEmail:(NSString *)theEmail {
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
    userEmail = [prefs stringForKey:@"uv-user-email"];
    return userEmail;
}

- (CGFloat)heightForDynamicRowWithReuseIdentifier:(NSString *)reuseIdentifier indexPath:(NSIndexPath *)indexPath {
    NSString *cacheKey = [NSString stringWithFormat:@"%@-%d", reuseIdentifier, (int)self.view.frame.size.width];
    UITableViewCell *cell = [templateCells objectForKey:cacheKey];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:reuseIdentifier];
        SEL initCellSelector = NSSelectorFromString([NSString stringWithFormat:@"initCellFor%@:indexPath:", reuseIdentifier]);
        if ([self respondsToSelector:initCellSelector]) {
            [self performSelector:initCellSelector withObject:cell withObject:nil];
        }
        cell.contentView.frame = CGRectMake(0, 0, [self cellWidthForStyle:self.tableView.style accessoryType:cell.accessoryType], 0);
        [templateCells setObject:cell forKey:cacheKey];
    }
    SEL customizeCellSelector = NSSelectorFromString([NSString stringWithFormat:@"customizeCellFor%@:indexPath:", reuseIdentifier]);
    if ([self respondsToSelector:customizeCellSelector]) {
        [self performSelector:customizeCellSelector withObject:cell withObject:indexPath];
    }
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];

    // cells are usually flat so I don't bother to iterate recursively
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            if (label.numberOfLines != 1) {
                [label setPreferredMaxLayoutWidth:label.frame.size.width];
            }
        }
    }
    return [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
}

- (CGFloat)cellWidthForStyle:(UITableViewStyle)style accessoryType:(UITableViewCellAccessoryType)accessoryType {
    CGFloat width = self.view.frame.size.width;
    CGFloat accessoryWidth = 0;
    CGFloat margin = 0;
    if (IOS7) {
        if (accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
            accessoryWidth = 33;
        }
    } else {
        if (accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
            accessoryWidth = 20;
        }
        if (width > 20) {
            if (width < 400) {
                margin = 10;
            } else {
                margin = MAX(31, MIN(45, width*0.06));
            }
        } else {
            margin = width - 10;
        }
    }
    return width - (style == UITableViewStyleGrouped ? margin * 2 : 0) - accessoryWidth;
}

- (void)configureView:(UIView *)superview subviews:(NSDictionary *)viewsDict constraints:(NSArray *)constraintStrings {
    [self configureView:superview subviews:viewsDict constraints:constraintStrings finalCondition:NO finalConstraint:nil];
}

- (void)configureView:(UIView *)superview subviews:(NSDictionary *)viewsDict constraints:(NSArray *)constraintStrings finalCondition:(BOOL)includeFinalConstraint finalConstraint:(NSString *)finalConstraint {
    for (NSString *key in [viewsDict keyEnumerator]) {
        UIView *view = viewsDict[key];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [superview addSubview:view];
    }
    for (NSString *constraintString in constraintStrings) {
        [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:viewsDict]];
    }
    if (includeFinalConstraint) {
        [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:finalConstraint options:0 metrics:nil views:viewsDict]];
    }
}

- (UITextField *)configureView:(UIView *)view label:(NSString *)labelText placeholder:(NSString *)placeholderText {
    UITextField *field = [UITextField new];
    field.placeholder = placeholderText;
    [field setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    UILabel *label = [UILabel new];
    label.text = [NSString stringWithFormat:@"%@:", labelText];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    [label setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self configureView:view
               subviews:NSDictionaryOfVariableBindings(field, label)
            constraints:@[@"|-16-[label]-[field]-|", @"V:|-12-[label]", @"V:|-12-[field]"]];
    return field;
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
}

@end
