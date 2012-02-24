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
#import "UVNewSuggestionViewController.h"
#import "UVSignInViewController.h"
#import "UVClientConfig.h"
#import "UVTicket.h"
#import "UVForum.h"
#import "UVSubdomain.h"
#import "UVToken.h"
#import "UVTextEditor.h"
#import "NSError+UVExtras.h"

#define UV_NEW_TICKET_SECTION_TEXT 0
#define UV_NEW_TICKET_SECTION_PROFILE 1
#define UV_NEW_TICKET_SECTION_SUBMIT 2
//#define UV_NEW_TICKET_SECTION_CUSTOM_FIELDS ??

@implementation UVNewTicketViewController

@synthesize textEditor;
@synthesize emailField;
@synthesize activeField;
@synthesize initialText;

- (id)initWithText:(NSString *)text {
    if (self = [super init]) {
        self.initialText = text;
    }
    return self;
}

// Used when deep-linking to contact form.
- (id)initWithoutNavigation {
    if (self = [super init]) {
        withoutNavigation = YES;
    }
    return self;
}

- (void)dismissKeyboard {
	[emailField resignFirstResponder];
	[textEditor resignFirstResponder];
}

- (void)createButtonTapped {
	[self dismissKeyboard];
	NSString *email = emailField.text;
	NSString *text = textEditor.text;	
	
	if ([UVSession currentSession].user || (email && [email length] > 1)) {
        [self showActivityIndicator];
        [UVTicket createWithMessage:text andEmailIfNotLoggedIn:email andDelegate:self];
	} else {
        [self alertError:NSLocalizedStringFromTable(@"Please enter your email address before submitting your ticket.", @"UserVoice", nil)];
	}
}

- (void)didCreateTicket:(UVTicket *)theTicket {
	[self hideActivityIndicator];
    [self alertSuccess:NSLocalizedStringFromTable(@"Your ticket was successfully submitted.", @"UserVoice", nil)];
    if (withoutNavigation)
        [self dismissUserVoice];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissTextView {
	[self.textEditor resignFirstResponder];
}

- (void)suggestionButtonTapped {
    NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
    [viewControllers removeLastObject];
    UVForum *forum = [UVSession currentSession].clientConfig.forum;		
    UIViewController *next = [[UVNewSuggestionViewController alloc] initWithForum:forum title:self.textEditor.text];
    [viewControllers addObject:next];
	[self.navigationController setViewControllers:viewControllers animated:YES];
    [viewControllers release];
}

#pragma mark ===== UITextFieldDelegate Methods =====

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

#pragma mark ===== UVTextEditorDelegate Methods =====

- (BOOL)textEditorShouldBeginEditing:(UVTextEditor *)theTextEditor {
	return YES;
}

- (void)textEditorDidBeginEditing:(UVTextEditor *)theTextEditor {
	// Change right bar button to Done, as there's no built-in way to dismiss the
	// text view's keyboard.
    [self hideExitButton];
    UIBarButtonItem* saveItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                               target:self
                                                                               action:@selector(dismissTextView)] autorelease];
	[self.navigationItem setRightBarButtonItem:saveItem animated:NO];
    self.activeField = theTextEditor;
}

- (void)textEditorDidEndEditing:(UVTextEditor *)theTextEditor {
    [self showExitButton];
    self.activeField = nil;
}

- (BOOL)textEditorShouldEndEditing:(UVTextEditor *)theTextEditor {
	return YES;
}

#pragma mark ===== table cells =====

- (UITextField *)customizeTextFieldCell:(UITableViewCell *)cell label:(NSString *)label placeholder:(NSString *)placeholder {
	cell.textLabel.text = label;
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(65, 11, 230, 22)];
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
	aTextEditor.placeholder = NSLocalizedStringFromTable(@"Message", @"UserVoice", nil);
    aTextEditor.text = initialText;
	
	[cell.contentView addSubview:aTextEditor];
	self.textEditor = aTextEditor;
	[aTextEditor release];
}

- (void)customizeCellForFields:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {    
	NSArray *fields = [UVSession currentSession].clientConfig.customFields;
	if (fields && [fields count] > 0) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedStringFromTable(@"Type", @"UserVoice", nil);
        
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}	
}

- (void)initCellForEmail:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	self.emailField = [self customizeTextFieldCell:cell label:NSLocalizedStringFromTable(@"Email", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"Required", @"UserVoice", nil)];
	self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
	self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
	self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

- (void)initCellForSubmit:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
    CGFloat margin = screenWidth > 480 ? 45 : 10;
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, 300, 42);
	button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
	button.titleLabel.textColor = [UIColor whiteColor];
	[button setTitle:NSLocalizedStringFromTable(@"Send", @"UserVoice", nil) forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"uv_primary_button_green.png"] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"uv_primary_button_green_active.png"] forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(createButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:button];
	button.center = CGPointMake(screenWidth/2 - margin, button.center.y);
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"";
	UITableViewCellStyle style = UITableViewCellStyleDefault;
	BOOL selectable = NO;
	
	switch (indexPath.section) {
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
			identifier = @"Email";
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == UV_NEW_TICKET_SECTION_PROFILE) {
		if ([UVSession currentSession].user!=nil) {
			return 0;
		} else {
			return 1;
		}
//	} else if (section == UV_NEW_TICKET_SECTION_CUSTOM_FIELDS) {
//        return 0;
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


# pragma mark ===== Keyboard handling =====

- (void)keyboardDidShow:(NSNotification*)notification {
    [super keyboardDidShow:notification];
    
    NSIndexPath *path;
    if (activeField == emailField)
        path = [NSIndexPath indexPathForRow:0 inSection:UV_NEW_TICKET_SECTION_PROFILE];
    else
        path = [NSIndexPath indexPathForRow:0 inSection:UV_NEW_TICKET_SECTION_TEXT];
    [tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
	[super loadView];	
	self.navigationItem.title = NSLocalizedStringFromTable(@"Contact Us", @"UserVoice", nil);
	
	CGRect frame = [self contentFrame];
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
	theTableView.dataSource = self;
	theTableView.delegate = self;
	theTableView.sectionFooterHeight = 0.0;
	theTableView.backgroundColor = [UVStyleSheet backgroundColor];
	
    if (!withoutNavigation) {
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, screenWidth, 15)];
        label.text = NSLocalizedStringFromTable(@"Want to suggest an idea instead?", @"UserVoice", nil);
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UVStyleSheet linkTextColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:13];
        [footer addSubview:label];
        [label release];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 25, 320, 15);
        NSString *buttonTitle = [[UVSession currentSession].clientConfig.forum prompt];
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [button setTitleColor:[UVStyleSheet linkTextColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        button.showsTouchWhenHighlighted = YES;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [button addTarget:self action:@selector(suggestionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        button.center = CGPointMake(footer.center.x, button.center.y);
        [footer addSubview:button];
        
        theTableView.tableFooterView = footer;
        [footer release];
    }
	
	self.tableView = theTableView;
	[theTableView release];
	
	self.view = tableView;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    [textEditor becomeFirstResponder];
}

- (void)dealloc {
	self.textEditor = nil;
	self.emailField = nil;
    self.activeField = nil;
    [super dealloc];
}

@end
