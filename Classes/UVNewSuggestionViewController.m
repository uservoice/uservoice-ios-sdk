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
#import "UVNewTicketViewController.h"
#import "UVSignInViewController.h"
#import "UVTextEditor.h"
#import "NSError+UVExtras.h"

#define UV_NEW_SUGGESTION_SECTION_TITLE 0
#define UV_NEW_SUGGESTION_SECTION_TEXT 1
#define UV_NEW_SUGGESTION_SECTION_CATEGORY 2
#define UV_NEW_SUGGESTION_SECTION_PROFILE 3
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
		[self alertError:NSLocalizedStringFromTable(@"A suggestion with this title already exists. Please change the title.", @"UserVoice", nil)];
	} else {
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
            [self alertError:NSLocalizedStringFromTable(@"Please enter your email address before submitting your suggestion.", @"UserVoice", nil)];
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
	[self alertSuccess:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Your idea \"%@\" was successfully created.", @"UserVoice", nil), self.title]];

	// increment the created suggestions and supported suggestions counts
	[[UVSession currentSession].user didCreateSuggestion:theSuggestion];

	[UVSession currentSession].clientConfig.forum.currentTopic.suggestionsNeedReload = YES;

	// update the remaining votes
	[UVSession currentSession].clientConfig.forum.currentTopic.votesRemaining = theSuggestion.votesRemaining;
	
    // Back out to the welcome screen
    NSMutableArray *viewControllers = [[self.navigationController.viewControllers mutableCopy] autorelease];
    [viewControllers removeLastObject];
    if ([viewControllers count] > 2)
        [viewControllers removeLastObject];
    [self.navigationController setViewControllers:viewControllers animated:YES];
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
		[self showActivityIndicatorWithText:NSLocalizedStringFromTable(@"Checking...", @"UserVoice", nil)];
		[UVUser discoverWithEmail:emailField.text delegate:self];
	}
}

- (void)dismissTextView {
	[self.textEditor resignFirstResponder];
}

- (void)voteSegmentChanged:(id)sender {
	UISegmentedControl *segments = (UISegmentedControl *)sender;
	self.numVotes = segments.selectedSegmentIndex + 1;
	[self dismissTextView];
}

- (void)contactButtonTapped {
    UIViewController *next = [[[UVNewTicketViewController alloc] initWithText:titleField.text] autorelease];
    NSMutableArray *viewControllers = [[self.navigationController.viewControllers mutableCopy] autorelease];
    [viewControllers removeLastObject];
    if ([viewControllers count] > 2)
        [viewControllers removeLastObject];
    [viewControllers addObject:next];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

#pragma mark ===== UITextFieldDelegate Methods =====

- (void)textFieldDidBeginEditing:(UITextField *)textField {
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
	[textField resignFirstResponder];
	return YES;
}

#pragma mark ===== UVTextEditorDelegate Methods =====

- (void)textEditorDidBeginEditing:(UVTextEditor *)theTextEditor {
	// Change right bar button to Done, as there's no built-in way to dismiss the
	// text view's keyboard.
	UIBarButtonItem* saveItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self
																			  action:@selector(dismissTextView)] autorelease];
	[self.navigationItem setRightBarButtonItem:saveItem animated:NO];

	// Scroll to the active text editor
	NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:UV_NEW_SUGGESTION_SECTION_TEXT];
	[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textEditorDidEndEditing:(UVTextEditor *)theTextEditor {
	self.text = theTextEditor.text;
	[self.navigationItem setRightBarButtonItem:nil animated:NO];
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
	
	CGRect frame = CGRectMake(0, 0, cell.contentView.bounds.size.width, 31);
	UITextField *theTitleField = [[UITextField alloc] initWithFrame:frame];
	theTitleField.delegate = self;
	theTitleField.returnKeyType = UIReturnKeyDone;
	theTitleField.autocorrectionType = UITextAutocorrectionTypeYes;
	theTitleField.text = self.title;
	theTitleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	theTitleField.clearButtonMode = UITextFieldViewModeWhileEditing;
    theTitleField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
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
	aTextEditor.placeholder = NSLocalizedStringFromTable(@"Description (optional)", @"UserVoice", nil);
	
	[cell.contentView addSubview:aTextEditor];
	self.textEditor = aTextEditor;
	[aTextEditor release];
}

- (void)customizeCellForCategory:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	cell.textLabel.text = NSLocalizedStringFromTable(@"Category", @"UserVoice", nil);
	cell.detailTextLabel.text = self.category.name;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)initCellForVote:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];
	
	self.numVotes = 1;
	NSArray *items = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"1 vote", @"UserVoice", nil), NSLocalizedStringFromTable(@"2 votes", @"UserVoice", nil), NSLocalizedStringFromTable(@"3 votes", @"UserVoice", nil), nil];
	UISegmentedControl *segments = [[UISegmentedControl alloc] initWithItems:items];
	segments.frame = CGRectMake(10, 0, 300, 44);
    segments.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
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
		label.text = NSLocalizedStringFromTable(@"Sorry, you have run out of votes.", @"UserVoice", nil);
		label.textColor = [UVStyleSheet alertTextColor];
		
		[cell.contentView addSubview:label];
		[label release];
	} else {
		[segments addTarget:self action:@selector(voteSegmentChanged:) forControlEvents:UIControlEventValueChanged];
		[cell.contentView addSubview:segments];
	}	
	[segments release];
}

- (void)initCellForName:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	self.nameField = [self customizeTextFieldCell:cell label:NSLocalizedStringFromTable(@"Name", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"Required", @"UserVoice", nil)];
}

- (void)initCellForEmail:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	self.emailField = [self customizeTextFieldCell:cell label:NSLocalizedStringFromTable(@"Email", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"Required", @"UserVoice", nil)];
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
		button.frame = CGRectMake(10, 0, 300, 42);
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
		button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
		button.titleLabel.textColor = [UIColor whiteColor];
		[button setTitle:NSLocalizedStringFromTable(@"Create idea", @"UserVoice", nil) forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"uv_primary_button_green.png"] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"uv_primary_button_green_active.png"] forState:UIControlStateHighlighted];
		[button addTarget:self action:@selector(createButtonTapped) forControlEvents:UIControlEventTouchUpInside];
		[cell.contentView addSubview:button];
	}
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"";
	UITableViewCellStyle style = UITableViewCellStyleDefault;
	BOOL selectable = NO;
	
	switch (indexPath.section) {
		case UV_NEW_SUGGESTION_SECTION_TITLE:
			identifier = @"Title";
			break;
		case UV_NEW_SUGGESTION_SECTION_TEXT:
			identifier = @"Text";
			break;
		case UV_NEW_SUGGESTION_SECTION_CATEGORY:
			identifier = @"Category";
			style = UITableViewCellStyleValue1;
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
	return 6;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == UV_NEW_SUGGESTION_SECTION_PROFILE)
		return [[UVSession currentSession].user hasEmail] ? 0 : 2;
    else if (section == UV_NEW_SUGGESTION_SECTION_CATEGORY)
        return self.shouldShowCategories ? 1 : 0;
    else
        return 1;
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case UV_NEW_SUGGESTION_SECTION_TITLE:
			return 31;
		case UV_NEW_SUGGESTION_SECTION_TEXT:
			return 102;
		case UV_NEW_SUGGESTION_SECTION_VOTE:
			return 44;
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
			return 10.0;
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

- (void)loadView {
	[super loadView];
    [self hideExitButton];
	
	self.navigationItem.title = NSLocalizedStringFromTable(@"New Suggestion", @"UserVoice", nil);		
	CGRect frame = [self contentFrame];
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
	theTableView.dataSource = self;
	theTableView.delegate = self;
	theTableView.sectionFooterHeight = 0.0;
    theTableView.backgroundColor = [UVStyleSheet backgroundColor];
	
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 50)];
    footer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 15)];
	label.text = NSLocalizedStringFromTable(@"Want to send a private message instead?", @"UserVoice", nil);
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UVStyleSheet linkTextColor];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont systemFontOfSize:13];
	[footer addSubview:label];
	[label release];

	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 25, frame.size.width, 15);
	NSString *buttonTitle = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Contact %@", @"UserVoice", nil), [UVSession currentSession].clientConfig.subdomain.name];
	[button setTitle:buttonTitle forState:UIControlStateNormal];
	[button setTitleColor:[UVStyleSheet linkTextColor] forState:UIControlStateNormal];
	button.backgroundColor = [UIColor clearColor];
	button.showsTouchWhenHighlighted = YES;
	button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	[button addTarget:self action:@selector(contactButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[footer addSubview:button];
	
	theTableView.tableFooterView = footer;
	[footer release];

	self.tableView = theTableView;
    self.view = theTableView;
	[theTableView release];
}

- (void)viewDidAppear:(BOOL)animated {	
	[super viewDidAppear:animated];
	if (self.needsReload) {
		[self.tableView reloadData];
		self.needsReload = NO;
	}
}

- (void)dealloc {
    self.forum = nil;
    self.title = nil;
    self.text = nil;
    self.name = nil;
    self.email = nil;
    self.textEditor = nil;
    self.titleField = nil;
    self.nameField = nil;
    self.emailField = nil;
    self.category = nil;
    [super dealloc];
}

@end
