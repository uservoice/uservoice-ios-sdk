//
//  UVBaseViewController.h
//  UserVoice
//
//  Created by UserVoice on 10/19/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UVActivityIndicator;

// Base class for UserVoice content view controllers. Will handle things like
// the search box, help bar, etc.
@interface UVBaseViewController : UIViewController {
	UVActivityIndicator *activityIndicator;
	BOOL needsReload;
	UITableView *tableView;
    NSInteger kbHeight;
    UIBarButtonItem *exitButton;
}

@property (nonatomic, retain) UVActivityIndicator *activityIndicator;
@property (assign) BOOL needsReload;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIBarButtonItem *exitButton;

- (void)dismissUserVoice;

// Calculates the content view frame, based on the size and position of the
// navigation bar.
- (CGRect)contentFrameWithNavBar:(BOOL)navBarEnabled;
- (CGRect)contentFrame;

// Shows the activity indicator.
- (void)showActivityIndicator;
- (void)showActivityIndicatorWithText:(NSString *)text;

// Hides the activity indivator.
- (void)hideActivityIndicator;

- (void)setVoteLabelTextAndColorForVotesRemaining:(NSInteger)votesRemaining label:(UILabel *)label;

- (void)initNavigationItem;

// Callback for HTTP errors. The default implementation hides the activity indicator
// and displays an error alert. Can be overridden in subclasses that require
// specialized behavior.
- (void)didReceiveError:(NSError *)error;

// Override this to use a title other than "Back".
- (NSString *)backButtonTitle;

// Adds a background gradient from dark to light gray
//- (void)addGradientBackground;

// Magic incantation to remove the white cell background, border, and rounded corners.
- (void)removeBackgroundFromCell:(UITableViewCell *)cell;

// Adds a highlight row at the top. You need to separately add a dark shadow via
// the table separator.
- (void)addHighlightToCell:(UITableViewCell *)cell;

- (void)addShadowSeparatorToTableView:(UITableView *)tableView;

// Keyboard handling
- (void)registerForKeyboardNotifications;
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
- (void)alertSuccess:(NSString *)message;
- (void)hideExitButton;
- (void)showExitButton;
- (void)promptUserToSignIn;

@end
