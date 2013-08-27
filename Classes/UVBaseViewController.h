//
//  UVBaseViewController.h
//  UserVoice
//
//  Created by UserVoice on 10/19/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVCallback.h"
#import "UVSigninManager.h"
#import "UVDefines.h"

@class UVActivityIndicator;

// Base class for UserVoice content view controllers. Will handle things like
// the search box, help bar, etc.
@interface UVBaseViewController : UIViewController<UIAlertViewDelegate, UITextFieldDelegate, UVSigninManagerDelegate> {
    BOOL needsReload;
    BOOL firstController;
    UITableView *tableView;
    NSInteger kbHeight;
    UIBarButtonItem *exitButton;
    UVSigninManager *signinManager;
    NSString *userEmail;
    NSString *userName;
    UIView *shade;
    UIActivityIndicatorView *activityIndicatorView;
}

@property (assign) BOOL needsReload;
@property (assign) BOOL firstController;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIBarButtonItem *exitButton;
@property (nonatomic, retain) UVSigninManager *signinManager;
@property (nonatomic,retain) NSString *userEmail;
@property (nonatomic,retain) NSString *userName;
@property (nonatomic, retain) UIView *shade;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

- (void)dismissUserVoice;

// Calculates the content view frame, based on the size and position of the
// navigation bar.
- (CGRect)contentFrame;

// activity indicator
- (void)showActivityIndicator;
- (void)hideActivityIndicator;

// navigation buttons
- (void)disableSubmitButton;
- (void)enableSubmitButton;
- (void)enableSubmitButtonForce:(BOOL)force;
- (BOOL)shouldEnableSubmitButton;

- (void)addTopBorder:(UIView *)view;
- (void)addTopBorder:(UIView *)view alpha:(CGFloat)alpha;

- (void)initNavigationItem;
- (void)presentModalViewController:(UIViewController *)viewController;

// Callback for HTTP errors. The default implementation hides the activity indicator
// and displays an error alert. Can be overridden in subclasses that require
// specialized behavior.
- (void)didReceiveError:(NSError *)error;

- (void)requireUserSignedIn:(UVCallback *)callback;
- (void)requireUserAuthenticated:(NSString *)email name:(NSString *)name callback:(UVCallback *)callback;

// Keyboard handling
- (void)registerForKeyboardNotifications;
- (void)keyboardWillShow:(NSNotification*)notification;
- (void)keyboardDidShow:(NSNotification*)notification;
- (void)keyboardDidHide:(NSNotification*)notification;

// Returns a cell for the specified identifier. Either reuses an existing cell,
// or creates a new cell if necessary. Uses reflection to delegate cell initialization
// and customization to identifier specific methods. This allows us to remove the
// redundant boilerplate code from the individual cell customization / initialization.
- (UITableViewCell *)createCellForIdentifier:(NSString *)identifier
                                   tableView:(UITableView *)tableView
                                   indexPath:(NSIndexPath *)indexPath
                                       style:(UITableViewCellStyle)style
                                  selectable:(BOOL)selectable;

- (void)alertError:(NSString *)message;
- (void)setupGroupedTableView;
- (UIScrollView *)scrollView;

- (CGRect)cellValueRect:(UIView *)container;
- (CGRect)cellLabelRect:(UIView *)container;
- (UILabel *)addCellLabel:(UIView *)container;
- (UILabel *)addCellValueLabel:(UIView *)container;
- (UITextField *)addCellValueTextField:(UIView *)container;
- (UITextField *)customizeTextFieldCell:(UITableViewCell *)cell label:(NSString *)labelText placeholder:(NSString *)placeholder;

@end
