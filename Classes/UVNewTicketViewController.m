//
//  UVNewTicketViewController.m
//  UserVoice
//
//  Created by UserVoice on 2/19/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVNewTicketViewController.h"
#import "UVStyleSheet.h"
#import "UVCustomField.h"
#import "UVSession.h"
#import "UVUser.h"
#import "UVClientConfig.h"
#import "UVSubjectSelectViewController.h"
#import "UVSuggestionListViewController.h"
#import "UVSignInViewController.h"
#import "UVClientConfig.h"
#import "UVTicket.h"
#import "UVForum.h"
#import "UVSubdomain.h"
#import "UVToken.h"
#import "UVTextEditor.h"
#import "NSError+UVExtras.h"

#define UV_NEW_TICKET_SECTION_PROFILE 0
#define UV_NEW_TICKET_SECTION_SUBJECT 2
#define UV_NEW_TICKET_SECTION_CUSTOM_FIELDS 1
#define UV_NEW_TICKET_SECTION_TEXT 3
#define UV_NEW_TICKET_SECTION_SUBMIT 4

@implementation UVNewTicketViewController

@synthesize text;
@synthesize name;
@synthesize email;
@synthesize subject;
@synthesize textEditor;
@synthesize nameField;
@synthesize emailField;
@synthesize subjectField;
@synthesize prevBarButton;

- (void)createTicket 
{
	[self showActivityIndicator];
	[UVTicket createWithSubject:self.subject andMessage:self.text andDelegate:self];
}

- (void)dismissKeyboard {
	// shouldResizeForKeyboard = YES;
	
	[nameField resignFirstResponder];
	[emailField resignFirstResponder];
    [subjectField resignFirstResponder];
	[textEditor resignFirstResponder];
	// shouldResizeForKeyboard = NO;
}

- (void)updateFromControls {
	self.name = nameField.text;
	self.email = emailField.text;
	self.text = textEditor.text;
    self.subject = subjectField.text;
	
	[self dismissKeyboard];
}

- (void)createButtonTapped {
	[self updateFromControls];
	
	if ([UVSession currentSession].user) {
		[self createTicket];
		
	} else {
		if (self.email && [self.email length] > 1) {
			[self showActivityIndicator];
			[UVUser findOrCreateWithEmail:self.email andName:self.name andDelegate:self];
			
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Error",@"UserVoice",nil)
															message:NSLocalizedString(@"Please enter your email address before submitting your ticket.", nil) 
														   delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
			[alert show];
			[alert release];
		}
	}
}

- (void)didDiscoverUser:(UVUser *)theUser {
	[self hideActivityIndicator];
	
	// add email to user as won't of been returned
	theUser.email = self.emailField.text;
	UVSignInViewController *signinView = [[UVSignInViewController alloc] initWithUVUser:theUser];
	[self.navigationController pushViewController:signinView animated:YES];
	[signinView release];
}

- (void)didCreateUser:(UVUser *)theUser {
	[UVSession currentSession].user = theUser;
	
	// token should have been loaded by ResponseDelegate
	[[UVSession currentSession].currentToken persist];
	
	[self createTicket];
}

- (void)didReceiveError:(NSError *)error {
	[self hideActivityIndicator];
	
	if ([error isNotFoundError]) {
		NSLog(@"No user");
		// shouldResizeForKeyboard = YES;
		[self.tableView reloadData];
		// shouldResizeForKeyboard = NO;
		
	} else {
		[super didReceiveError:error];
	}
}

- (void)didCreateTicket:(UVTicket *)theTicket {
	[self hideActivityIndicator];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Success",@"UserVoice",nil)
													message:NSLocalizedStringFromTable(@"Your ticket was successfully submitted.",@"UserVoice",nil)
												   delegate:nil
										  cancelButtonTitle:nil
										  otherButtonTitles:NSLocalizedStringFromTable(@"OK",@"UserVoice",nil), nil];
	[alert show];
	[alert release];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissTextView {
	// shouldResizeForKeyboard = YES;
	[self.textEditor resignFirstResponder];
	// shouldResizeForKeyboard = NO;
}

- (void)checkEmail {		
	if (self.emailField.text.length > 0) {
		[self showActivityIndicatorWithText:NSLocalizedString(@"Checking...", nil)];
		[UVUser discoverWithEmail:emailField.text delegate:self];
	}
}

- (void)suggestionButtonTapped {
	NSArray *viewControllers = self.navigationController.viewControllers;
	UIViewController *prev = [viewControllers objectAtIndex:([viewControllers count] - 2)];
	UINavigationController *navController = self.navigationController;
	if ([prev class] == [UVSuggestionListViewController class]) {
		// Previous view was already a suggestion list => simply pop view
		[navController popViewControllerAnimated:YES];
	} else {
		// Previous view was something else => pop current view, then push suggestion list
		[navController popViewControllerAnimated:NO];
		UVForum *forum = [UVSession currentSession].clientConfig.forum;		
		UIViewController *next = [[UVSuggestionListViewController alloc] initWithForum:forum];
		[navController pushViewController:next animated:YES];
		[next release];
	}
}

//- (void) moveTextViewForKeyboard:(NSNotification*)aNotification up: (BOOL) up {
- (void) moveTextViewForKeyboard:(BOOL) up {
	// Animate up or down
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	CGRect newFrame = self.tableView.frame;
	newFrame.size.height -= 216 * (up? 1 : -1);
	self.tableView.frame = newFrame;
	if (up) {	
		// Scroll to the active text editor	
		NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:UV_NEW_TICKET_SECTION_TEXT];
		[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
	[UIView commitAnimations];
}

#pragma mark ===== UITextFieldDelegate Methods =====

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	// Scroll to the active text field
	NSLog(@"textFieldDidBeginEditing");	
    
    NSIndexPath *path = nil;
    
    if (textField==subjectField) {
        path = [NSIndexPath indexPathForRow:0 inSection:UV_NEW_TICKET_SECTION_SUBJECT];
    } else {
        path = [NSIndexPath indexPathForRow:0 inSection:UV_NEW_TICKET_SECTION_PROFILE];
    }
	[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	NSLog(@"textFieldShouldEndEditing");
	
	if (textField==emailField) {
		NSLog(@"Check email");
		[self checkEmail];
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	return YES;
}

#pragma mark ===== UVTextEditorDelegate Methods =====

- (BOOL)textEditorShouldBeginEditing:(UVTextEditor *)theTextEditor {
	return YES;
}

- (void)textEditorDidBeginEditing:(UVTextEditor *)theTextEditor {
	NSLog(@"textEditorDidBeginEditing");
	// Change right bar button to Done, as there's no built-in way to dismiss the
	// text view's keyboard.
	UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self action:@selector(dismissTextView)];
	self.prevBarButton = self.navigationItem.leftBarButtonItem;
	[self.navigationItem setLeftBarButtonItem:saveItem animated:YES];
	[saveItem release];
	
	[self moveTextViewForKeyboard:YES];
}

- (void)textEditorDidEndEditing:(UVTextEditor *)theTextEditor {
	[self.navigationItem setLeftBarButtonItem:self.prevBarButton animated:YES];
}

- (BOOL)textEditorShouldEndEditing:(UVTextEditor *)theTextEditor {
	NSLog(@"textEditorShouldEndEditing");
	[self moveTextViewForKeyboard:NO];
	
	return YES;
}

#pragma mark ===== table cells =====

- (UITextField *)customizeTextFieldCell:(UITableViewCell *)cell label:(NSString *)label placeholder:(NSString *)placeholder {
	cell.textLabel.text = label;
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(65, 12, 230, 20)];
	textField.placeholder = placeholder;
	textField.returnKeyType = UIReturnKeyDone;
	textField.borderStyle = UITextBorderStyleNone;
	textField.backgroundColor = [UIColor clearColor];
	textField.delegate = self;
	[cell.contentView addSubview:textField];
	return [textField autorelease];
}

- (void)initCellForText:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath 
{
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	CGRect frame = CGRectMake(0, 0, (screenWidth-20), 144);
	UVTextEditor *aTextEditor = [[UVTextEditor alloc] initWithFrame:frame];
	aTextEditor.delegate = self;
	aTextEditor.autocorrectionType = UITextAutocorrectionTypeYes;
	aTextEditor.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	aTextEditor.minNumberOfLines = 6;
	aTextEditor.maxNumberOfLines = 6;
	aTextEditor.autoresizesToText = YES;
	aTextEditor.backgroundColor = [UIColor clearColor];
	aTextEditor.placeholder = NSLocalizedStringFromTable(@"Message",@"UserVoice",nil);
	
	[cell.contentView addSubview:aTextEditor];
	self.textEditor = aTextEditor;
	[aTextEditor release];
}

- (void)customizeCellForFields:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {    
	NSArray *fields = [UVSession currentSession].clientConfig.customFields;
	if (fields && [fields count] > 0) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedStringFromTable(@"Type",@"UserVoice",nil);
        
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}	
}

- (void)initCellForSubject:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = @"";
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 12, 230, 20)];
	textField.placeholder = NSLocalizedStringFromTable(@"Subject",@"UserVoice",nil);
	textField.returnKeyType = UIReturnKeyDone;
	textField.borderStyle = UITextBorderStyleNone;
	textField.backgroundColor = [UIColor clearColor];
	textField.delegate = self;
	[cell.contentView addSubview:textField];
	self.subjectField = [textField autorelease];
}

- (void)initCellForName:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	self.nameField = [self customizeTextFieldCell:cell label:NSLocalizedStringFromTable(@"Name",@"UserVoice",nil) placeholder:NSLocalizedStringFromTable(@"Anonymous",@"UserVoice",nil)];
}

- (void)initCellForEmail:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	self.emailField = [self customizeTextFieldCell:cell label:NSLocalizedStringFromTable(@"Email",@"UserVoice",nil) placeholder:NSLocalizedStringFromTable(@"Required",@"UserVoice",nil)];
	self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
	self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
	self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

- (void)initCellForSubmit:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, 300, 42);
	button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
	button.titleLabel.textColor = [UIColor whiteColor];
	[button setTitle:NSLocalizedStringFromTable(@"Send",@"UserVoice",nil) forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"uv_primary_button_green.png"] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"uv_primary_button_green_active.png"] forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(createButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:button];
	button.center = CGPointMake(screenWidth/2 - 10, button.center.y);
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"";
	UITableViewCellStyle style = UITableViewCellStyleDefault;
	BOOL selectable = NO;
	
	switch (indexPath.section) {
		case UV_NEW_TICKET_SECTION_SUBJECT:
			identifier = @"Subject";
			break;
//        case UV_NEW_TICKET_SECTION_CUSTOM_FIELDS
//            identifier = 
//            style = UITableViewCellStyleValue1;
//			NSArray *subjects = [UVSession currentSession].clientConfig.customFields;                        
//			selectable = subjects && [subjects count] > 1;
//            break;
		case UV_NEW_TICKET_SECTION_TEXT:
			identifier = @"Text";
			break;
		case UV_NEW_TICKET_SECTION_PROFILE:
			identifier = indexPath.row == 0 ? @"Email" : @"Name";
			break;
		case UV_NEW_TICKET_SECTION_SUBMIT:
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
//    NSArray *customFields = [UVSession currentSession].clientConfig.customFields;
//    
//    if (customFields && [customFields count] >= 1) {
//        return 5;
//    } else {
//        return 4;
//    }
    return 5;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == UV_NEW_TICKET_SECTION_PROFILE) {
		if ([UVSession currentSession].user!=nil) {
			return 0;
		} else {
			return 2;
		}
	} else if (section == UV_NEW_TICKET_SECTION_CUSTOM_FIELDS) {        
        return 0;
//		NSArray *subjects = [UVSession currentSession].clientConfig.customFields;
//        
//        NSLog(@"Custom Fields: %@", subjects);
//		if (subjects && [subjects count] > 1) {
//			return 1;
//            
//		} else {
//			if (subjects && [subjects count] > 0)
//				self.subject = [subjects objectAtIndex:0];
//			
//			return [subjects count];
//		}
	} else {
		return 1;
	}
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case UV_NEW_TICKET_SECTION_TEXT:
			return 144;
		case UV_NEW_TICKET_SECTION_SUBMIT:
			return 42;
		default:
			return 44;
	}
}

- (CGFloat)tableView:(UITableView *)theTableView heightForHeaderInSection:(NSInteger)section {
	switch (section) {
		case UV_NEW_TICKET_SECTION_SUBJECT:
			return 10.0;
		case UV_NEW_TICKET_SECTION_PROFILE:
			return 0.0;
		default:
			return 0.0;
	}
}

- (UIView *)tableView:(UITableView *)theTableView viewForHeaderInSection:(NSInteger)section 
{
	CGFloat height = [self tableView:theTableView heightForHeaderInSection:section];
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, height)] autorelease];
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
//	NSArray *subjects = [UVSession currentSession].clientConfig.customFields;
//	if (indexPath.section == UV_NEW_TICKET_SECTION_CUSTOM_FIELDS && subjects && [subjects count] > 1) {
//		[self dismissTextView];
//		UIViewController *next = [[UVSubjectSelectViewController alloc] initWithSelectedSubject:self.subject];
//		[self.navigationController pushViewController:next animated:YES];
//		[next release];
//	}
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
	[super loadView];	
	self.navigationItem.title = NSLocalizedString(@"Contact Us", nil);
	
	CGRect frame = [self contentFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:frame];
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	CGFloat screenHeight = [UVClientConfig getScreenHeight];
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-44) style:UITableViewStyleGrouped];
	theTableView.dataSource = self;
	theTableView.delegate = self;
	theTableView.sectionFooterHeight = 0.0;
	theTableView.backgroundColor = [UVStyleSheet lightBgColor];
	
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, screenWidth, 15)];
	label.text = NSLocalizedStringFromTable(@"Want to suggest an idea instead?",@"UserVoice",nil);
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UVStyleSheet dimBlueColor];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont systemFontOfSize:13];
	[footer addSubview:label];
	[label release];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 25, 320, 15);
	NSString *buttonTitle = [[UVSession currentSession].clientConfig.forum prompt];
	[button setTitle:buttonTitle forState:UIControlStateNormal];
	[button setTitleColor:[UVStyleSheet dimBlueColor] forState:UIControlStateNormal];
	button.backgroundColor = [UIColor clearColor];
	button.showsTouchWhenHighlighted = YES;
	button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	[button addTarget:self action:@selector(suggestionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	button.center = CGPointMake(footer.center.x, button.center.y);
	[footer addSubview:button];
	
	theTableView.tableFooterView = footer;
	[footer release];
	
	self.tableView = theTableView;
	[contentView addSubview:theTableView];
	[theTableView release];
	
	self.view = contentView;
	[contentView release];
	
	//[self addGradientBackground];
}

- (void)viewWillAppear:(BOOL)animated {
	// Listen for keyboard hide/show notifications
	[super viewWillAppear:animated];
	if (self.needsReload) {
		[self.tableView reloadData];
		self.needsReload = NO;
		
		NSArray *viewControllers = [self.navigationController viewControllers];
		UVBaseViewController *prev = (UVBaseViewController *)[viewControllers objectAtIndex:[viewControllers count] - 2];
		prev.needsReload = YES;	
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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
	self.nameField = nil;
	self.emailField = nil;
	self.prevBarButton = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end
