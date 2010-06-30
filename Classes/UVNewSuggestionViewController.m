//
//  UVNewSuggestionViewController.m
//  UserVoice
//
//  Created by UserVoice on 11/17/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVNewSuggestionViewController.h"
#import "UVStyleSheet.h"
#import "UVSuggestion.h"
#import "UVForum.h"
#import "UVCategory.h"
#import "UVSession.h"
#import "UVUser.h"
#import "UVClientConfig.h"
#import "UVSubdomain.h"
#import "UVToken.h"
#import "UVCategorySelectViewController.h"
#import "UVNewMessageViewController.h"
#import "UVSignInViewController.h"
#import "UVTextEditor.h"
#import "NSError+UVExtras.h"

#define UV_NEW_SUGGESTION_SECTION_PROFILE 0
#define UV_NEW_SUGGESTION_SECTION_TITLE 1
#define UV_NEW_SUGGESTION_SECTION_TEXT 2
#define UV_NEW_SUGGESTION_SECTION_CATEGORY 3
#define UV_NEW_SUGGESTION_SECTION_VOTE 4
#define UV_NEW_SUGGESTION_SECTION_SUBMIT 5

@implementation UVNewSuggestionViewController

@synthesize forum;
@synthesize title;
@synthesize text;
@synthesize name;
@synthesize email;
@synthesize textEditor;
@synthesize titleField;
@synthesize nameField;
@synthesize emailField;
@synthesize prevLeftBarButton;
@synthesize numVotes;
@synthesize category;
@synthesize shouldShowCategories;

- (id)initWithForum:(UVForum *)theForum title:(NSString *)theTitle {
	if (self = [super init]) {
		self.forum = theForum;
		self.title = theTitle;
		self.shouldShowCategories = self.forum.availableCategories && [self.forum.availableCategories count] > 0;
	}
	return self;
}

- (void)didReceiveError:(NSError *)error {
	NSLog(@"Got error: %@", [error userInfo]);
	if ([error isNotFoundError]) {
		[self hideActivityIndicator];
		NSLog(@"No user");
		
	} else if ([error isUVRecordInvalidForField:@"title" withMessage:@"is not allowed."]) {
		[self hideActivityIndicator];
		
		[[[[UIAlertView alloc]
		  initWithTitle:@"Error"
		  message:@"A suggestion with this title already exists.  Please change the title."
		  delegate:nil
		  cancelButtonTitle:@"OK"
		  otherButtonTitles:nil] autorelease]
		 show];
	}
	else
	{
		[super didReceiveError:error];
	}
}

- (void)createSuggestion {
	[self showActivityIndicator];
	[UVSuggestion createWithForum:self.forum
						 category:self.category
							title:self.title
							 text:self.text
							votes:self.numVotes
						 delegate:self];
}

- (void)dismissKeyboard {
	shouldResizeForKeyboard = YES;
	
	[nameField resignFirstResponder];
	[emailField resignFirstResponder];
	[textEditor resignFirstResponder];
}

- (void)updateFromTextFields {
	self.title = titleField.text;
	self.name = nameField.text;
	self.email = emailField.text;
	
	[self dismissKeyboard];
}

- (void)createButtonTapped {
	[self updateFromTextFields];
	
	if ([UVSession currentSession].user) {
		[self createSuggestion];
		
	} else {
		if (self.email && [self.email length] > 1) {
			[self showActivityIndicator];
			[UVUser findOrCreateWithEmail:self.email andName:self.name andDelegate:self];
			
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
															message:@"Please enter your email address before submitting your suggestion." 
														   delegate:nil 
												  cancelButtonTitle:nil 
												  otherButtonTitles:@"OK", nil];
			[alert show];
			[alert release];
		}
	}
}

- (void)didCreateUser:(UVUser *)theUser {
	[UVSession currentSession].user = theUser;
	
	// token should have been loaded by ResponseDelegate
	[[UVSession currentSession].currentToken persist];
	
	[self createSuggestion];
}

- (void)didCreateSuggestion:(UVSuggestion *)theSuggestion {
	[self hideActivityIndicator];
	
	NSString *msg = [NSString stringWithFormat:@"Your idea \"%@\" was successfully created.", self.title];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" 
													message:msg 
												   delegate:nil 
										  cancelButtonTitle:nil 
										  otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
	// increment the created suggestions and supported suggestions counts
	[UVSession currentSession].user.supportedSuggestionsCount += 1;
	[UVSession currentSession].user.createdSuggestionsCount += 1;	
	// add to this users created suggestions, unless they have never been loaded or are going to be
	if (![UVSession currentSession].user.suggestionsNeedReload) {
		[[UVSession currentSession].user.createdSuggestions addObject:theSuggestion];
	}
	// update the remaining votes
	[UVSession currentSession].clientConfig.forum.currentTopic.votesRemaining = theSuggestion.votesRemaining;
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)didDiscoverUser:(UVUser *)theUser {
	[self hideActivityIndicator];
	
	// add email to user as won't of been returned
	theUser.email = self.emailField.text;
	UVSignInViewController *signinView = [[UVSignInViewController alloc] initWithUVUser:theUser];
	[self.navigationController pushViewController:signinView animated:YES];
	[signinView release];
}

- (void)checkEmail {		
	if (self.emailField.text.length > 0) {
		[self showActivityIndicatorWithText:@"Checking..."];
		[UVUser discoverWithEmail:emailField.text delegate:self];
	}
}

- (void)dismissTextView {
	shouldResizeForKeyboard = YES;
	[self.textEditor resignFirstResponder];
}

- (void)voteSegmentChanged:(id)sender {
	UISegmentedControl *segments = (UISegmentedControl *)sender;
	self.numVotes = segments.selectedSegmentIndex + 1;
	[self dismissTextView];
}

- (void)contactButtonTapped {
	// This is a bit of a hack... We need to first dismiss the modal idea creation view
	// (which brings us back to the idea list), and then push the message creation view.
	// Therefore we need to first get a hold of the parent view's navigation view controller.
	UINavigationController *navController = (UINavigationController *)self.parentViewController.parentViewController;
	[self dismissModalViewControllerAnimated:NO];
	UIViewController *next = [[UVNewMessageViewController alloc] init];
	[navController pushViewController:next animated:YES];
	[next release];
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
	if (shouldResizeForKeyboard) {
		// Resize the table to account for the keyboard
		CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
		NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		CGRect frame = self.tableView.frame;
		frame.size.height -= keyboardRect.size.height;
		[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
		[UIView setAnimationDuration:animationDuration];
		self.tableView.frame = frame;
		[UIView commitAnimations];
	}
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
	if (shouldResizeForKeyboard) {
		// Resize the table back to the original height
		CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
		NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		CGRect frame = self.tableView.frame;
		frame.size.height += keyboardRect.size.height;
		[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
		[UIView setAnimationDuration:animationDuration];
		self.tableView.frame = frame;
		[UIView commitAnimations];
	}
}

#pragma mark ===== UITextFieldDelegate Methods =====

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	// Reset didReturn flag. This allows us to distinguish later between the user dismissing the
	// keyboard (by tapping on the return key) or tapping on a different text field. In the
	// latter case we don't want to grow and re-shrink the table view.
	shouldResizeForKeyboard = NO;
	
	// Scroll to the active text field
	NSIndexPath *path;
	if (textField == self.titleField) {
		path = [NSIndexPath indexPathForRow:0 inSection:UV_NEW_SUGGESTION_SECTION_TITLE];
	} else {
		path = [NSIndexPath indexPathForRow:0 inSection:UV_NEW_SUGGESTION_SECTION_PROFILE];
	}
	[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	if (textField==emailField) {
		NSLog(@"Check email");
		[nameField resignFirstResponder];
		[textEditor resignFirstResponder];
		[self checkEmail];
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	shouldResizeForKeyboard = YES;
	[textField resignFirstResponder];
	return YES;
}

#pragma mark ===== UVTextEditorDelegate Methods =====

- (void)textEditorDidBeginEditing:(UVTextEditor *)theTextEditor {
	shouldResizeForKeyboard = NO;

	// Change right bar button to Done, as there's no built-in way to dismiss the
	// text view's keyboard.
	UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self
																			  action:@selector(dismissTextView)];
	self.prevLeftBarButton = self.navigationItem.leftBarButtonItem;
	[self.navigationItem setLeftBarButtonItem:saveItem animated:YES];
	[saveItem release];

	// Scroll to the active text editor
	NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:UV_NEW_SUGGESTION_SECTION_TEXT];
	[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textEditorDidEndEditing:(UVTextEditor *)theTextEditor {
	self.text = theTextEditor.text;
	[self.navigationItem setLeftBarButtonItem:self.prevLeftBarButton animated:YES];
}

- (BOOL)textEditorShouldEndEditing:(UVTextEditor *)theTextEditor {
	return YES;
}

#pragma mark ===== table cells =====

- (UITextField *)customizeTextFieldCell:(UITableViewCell *)cell label:(NSString *)label placeholder:(NSString *)placeholder {
	cell.textLabel.text = label;
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(65, 12, 230, 20)];
	textField.placeholder = placeholder;
	textField.returnKeyType = UIReturnKeyDone;
	textField.borderStyle = UITextBorderStyleNone;
	textField.delegate = self;
	[cell.contentView addSubview:textField];
	[textField release];
	return textField;
}

- (void)initCellForTitle:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];
	
	CGRect frame = CGRectMake(0, 0, 300, 31);
	UITextField *theTitleField = [[UITextField alloc] initWithFrame:frame];
	theTitleField.delegate = self;
	theTitleField.returnKeyType = UIReturnKeyDone;
	theTitleField.autocorrectionType = UITextAutocorrectionTypeYes;
	theTitleField.text = self.title;
	theTitleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	theTitleField.clearButtonMode = UITextFieldViewModeWhileEditing;
	theTitleField.borderStyle = UITextBorderStyleRoundedRect;
	[cell.contentView addSubview:theTitleField];
	self.titleField = theTitleField;
	[theTitleField release];
}

- (void)initCellForText:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	CGRect frame = CGRectMake(0, 0, 300, 102);
	UVTextEditor *aTextEditor = [[UVTextEditor alloc] initWithFrame:frame];
	aTextEditor.delegate = self;
	aTextEditor.autocorrectionType = UITextAutocorrectionTypeYes;
	aTextEditor.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	aTextEditor.minNumberOfLines = 4;
	aTextEditor.maxNumberOfLines = 4;
	aTextEditor.autoresizesToText = YES;
	aTextEditor.backgroundColor = [UIColor clearColor];
	aTextEditor.placeholder = @"Description (optional)";
	
	[cell.contentView addSubview:aTextEditor];
	self.textEditor = aTextEditor;
	[aTextEditor release];
}

- (void)customizeCellForCategory:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	cell.textLabel.text = @"Category";
	cell.detailTextLabel.text = self.category.name;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)initCellForVote:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];
	
	self.numVotes = 1;
	NSArray *items = [NSArray arrayWithObjects:@"1 vote", @"2 votes", @"3 votes", nil];
	UISegmentedControl *segments = [[UISegmentedControl alloc] initWithItems:items];
	segments.frame = CGRectMake(0, 0, 300, 44);
	segments.selectedSegmentIndex = 0;
	NSInteger votesRemaining = 10;
	if ([UVSession currentSession].user)
		votesRemaining = [UVSession currentSession].clientConfig.forum.currentTopic.votesRemaining;

	for (int i = 0; i < segments.numberOfSegments; i++) {
		BOOL enabled = (i + 1) <= votesRemaining;
		[segments setEnabled:enabled forSegmentAtIndex:i];
	}
	if (votesRemaining==0) {
		[cell.contentView addSubview:segments];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 66, 300, 15)];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:12];
		label.text = @"Sorry, you have run out of votes.";		
		label.textColor = [UVStyleSheet darkRedColor];
		
		[cell.contentView addSubview:label];
		[label release];
	} else {
		[segments addTarget:self action:@selector(voteSegmentChanged:) forControlEvents:UIControlEventValueChanged];
		[cell.contentView addSubview:segments];
	}	
	[segments release];
}

- (void)initCellForName:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	self.nameField = [self customizeTextFieldCell:cell label:@"Name" placeholder:@"Anonymous"];
}

- (void)initCellForEmail:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	self.emailField = [self customizeTextFieldCell:cell label:@"Email" placeholder:@"Required"];
	self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
	self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
	self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

- (void)initCellForSubmit:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];
	NSInteger votesRemaining = 10;
	if ([UVSession currentSession].user)
		votesRemaining = [UVSession currentSession].clientConfig.forum.currentTopic.votesRemaining;
	
	if (votesRemaining!=0) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(0, 0, 300, 42);
		button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
		button.titleLabel.textColor = [UIColor whiteColor];
		[button setTitle:@"Create idea" forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"uv_primary_button_green.png"] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"uv_primary_button_green_active.png"] forState:UIControlStateHighlighted];
		[button addTarget:self action:@selector(createButtonTapped) forControlEvents:UIControlEventTouchUpInside];
		[cell.contentView addSubview:button];
	}
}

#pragma mark ===== UITableViewDataSource Methods =====

- (NSInteger)section:(NSIndexPath *)indexPath {
	if (self.shouldShowCategories) {
		return indexPath.section;
	} else {		
		return indexPath.section >= UV_NEW_SUGGESTION_SECTION_CATEGORY ? indexPath.section + 1 : indexPath.section;
	}	
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"";
	UITableViewCellStyle style = UITableViewCellStyleDefault;
	BOOL selectable = NO;
	
	switch ([self section:indexPath]) {
		case UV_NEW_SUGGESTION_SECTION_TITLE:
			identifier = @"Title";
			break;
		case UV_NEW_SUGGESTION_SECTION_TEXT:
			identifier = @"Text";
			break;
		case UV_NEW_SUGGESTION_SECTION_CATEGORY:
			identifier = @"Category";
			style = UITableViewCellStyleValue1;
			selectable = self.forum.availableCategories && [self.forum.availableCategories count] > 0;
			break;
		case UV_NEW_SUGGESTION_SECTION_VOTE:
			identifier = @"Vote";
			break;
		case UV_NEW_SUGGESTION_SECTION_PROFILE:
			identifier = indexPath.row == 0 ? @"Email" : @"Name";
			break;
		case UV_NEW_SUGGESTION_SECTION_SUBMIT:
			identifier = @"Submit";
			break;
	}
	
	return [self createCellForIdentifier:identifier
							   tableView:theTableView
							   indexPath:indexPath
								   style:style
							  selectable:selectable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return self.shouldShowCategories ? 6 : 5;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == UV_NEW_SUGGESTION_SECTION_PROFILE) {
		return [[UVSession currentSession].user hasEmail] ? 0 : 2;
	} else {
		return 1;
	}
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch ([self section:indexPath]) {
		case UV_NEW_SUGGESTION_SECTION_TITLE:
			return 31;
		case UV_NEW_SUGGESTION_SECTION_TEXT:
			return 102;
		case UV_NEW_SUGGESTION_SECTION_VOTE:
			return 61;
		case UV_NEW_SUGGESTION_SECTION_SUBMIT:
			return 42;
		default:
			return 44;
	}
}

- (CGFloat)tableView:(UITableView *)theTableView heightForHeaderInSection:(NSInteger)section {
	switch (section) {
		case UV_NEW_SUGGESTION_SECTION_TITLE:
			return 10.0;
		case UV_NEW_SUGGESTION_SECTION_PROFILE:
			return 20.0;
		default:
			return 0.0;
	}
}

- (UIView *)tableView:(UITableView *)theTableView viewForHeaderInSection:(NSInteger)section {
	CGFloat height = [self tableView:theTableView heightForHeaderInSection:section];
	return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height)] autorelease];
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == UV_NEW_SUGGESTION_SECTION_CATEGORY && self.shouldShowCategories) {
		[self dismissTextView];
		UIViewController *next = [[UVCategorySelectViewController alloc] initWithForum:self.forum andSelectedCategory:self.category];
		[self.navigationController pushViewController:next animated:YES];
		[next release];
	}
}

#pragma mark ===== Basic View Methods =====

- (void)dismissController {
	// reset nav
	[self.navigationItem setLeftBarButtonItem:self.prevLeftBarButton animated:YES];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)loadView {
	[super loadView];
	
	self.navigationItem.title = @"New Suggestion";		
	CGRect frame = [self contentFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:frame];
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStyleGrouped];
	theTableView.dataSource = self;
	theTableView.delegate = self;
	theTableView.sectionFooterHeight = 0.0;
	theTableView.backgroundColor = [UIColor clearColor];
	
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 15)];
	label.text = @"Want to send a private message instead?";
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UVStyleSheet dimBlueColor];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont systemFontOfSize:13];
	[footer addSubview:label];
	[label release];

	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 25, 320, 15);
	NSString *buttonTitle = [NSString stringWithFormat:@"Contact %@", [UVSession currentSession].clientConfig.subdomain.name];
	[button setTitle:buttonTitle forState:UIControlStateNormal];
	[button setTitleColor:[UVStyleSheet dimBlueColor] forState:UIControlStateNormal];
	button.backgroundColor = [UIColor clearColor];
	button.showsTouchWhenHighlighted = YES;
	button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	[button addTarget:self action:@selector(contactButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[footer addSubview:button];
	
	theTableView.tableFooterView = footer;
	[footer release];

	self.tableView = theTableView;
	[contentView addSubview:theTableView];
	[theTableView release];
	
	self.view = contentView;
	[contentView release];
	
	[self addGradientBackground];
}

- (void)viewDidAppear:(BOOL)animated {	
	shouldResizeForKeyboard = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	// Listen for keyboard hide/show notifications
	[super viewWillAppear:animated];
	if (self.needsReload) {
		[self.tableView reloadData];
		self.needsReload = NO;
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.tableView = nil;
	self.textEditor = nil;
	self.titleField = nil;
	self.nameField = nil;
	self.emailField = nil;
	self.prevLeftBarButton = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
