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
#import "UVCustomFieldValueSelectViewController.h"
#import "UVNewSuggestionViewController.h"
#import "UVSignInViewController.h"
#import "UVClientConfig.h"
#import "UVTicket.h"
#import "UVForum.h"
#import "UVSubdomain.h"
#import "UVToken.h"
#import "UVTextEditor.h"
#import "NSError+UVExtras.h"
#import "UVArticle.h"
#import "UVSuggestion.h"
#import "UVArticleViewController.h"
#import "UVSuggestionDetailsViewController.h"

#define UV_NEW_TICKET_SECTION_TEXT 0
#define UV_NEW_TICKET_SECTION_INSTANT_ANSWERS 1
#define UV_NEW_TICKET_SECTION_CUSTOM_FIELDS 2
#define UV_NEW_TICKET_SECTION_PROFILE 3
#define UV_NEW_TICKET_SECTION_SUBMIT 4

#define UV_CUSTOM_FIELD_CELL_LABEL_TAG 100
#define UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG 101
#define UV_CUSTOM_FIELD_CELL_VALUE_LABEL_TAG 102

@implementation UVNewTicketViewController

@synthesize textEditor;
@synthesize emailField;
@synthesize activeField;
@synthesize text;
@synthesize selectedCustomFieldValues;
@synthesize timer;
@synthesize instantAnswers;
@synthesize loadingInstantAnswers;

- (id)initWithText:(NSString *)initialText {
    if (self = [self init]) {
        self.text = initialText;
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        self.selectedCustomFieldValues = [NSMutableDictionary dictionaryWithCapacity:[[UVSession currentSession].clientConfig.customFields count]];
    }
    return self;
}

- (NSString *)backButtonTitle {
    return @"Contact";
}

- (void)dismissKeyboard {
	[emailField resignFirstResponder];
	[textEditor resignFirstResponder];
}

- (void)createButtonTapped {
	[self dismissKeyboard];
	NSString *email = emailField.text;
    self.text = textEditor.text;
	
	if ([UVSession currentSession].user || (email && [email length] > 1)) {
        [self showActivityIndicator];
        [UVTicket createWithMessage:self.text andEmailIfNotLoggedIn:email andCustomFields:selectedCustomFieldValues andDelegate:self];
        [[UVSession currentSession] trackInteraction:@"pt"];
	} else {
        [self alertError:NSLocalizedStringFromTable(@"Please enter your email address before submitting your ticket.", @"UserVoice", nil)];
	}
}

- (void)didCreateTicket:(UVTicket *)theTicket {
	[self hideActivityIndicator];
    [self alertSuccess:NSLocalizedStringFromTable(@"Your ticket was successfully submitted.", @"UserVoice", nil)];
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
	[next release];
	
	[self.navigationController setViewControllers:viewControllers animated:YES];
    [viewControllers release];
}

- (void)nonPredefinedValueChanged:(NSNotification *)notification {
    UITextField *textField = (UITextField *)[notification object];
    UITableViewCell *cell = (UITableViewCell *)[textField superview];
    UITableView *table = (UITableView *)[cell superview];
    NSIndexPath *path = [table indexPathForCell:cell];
    UVCustomField *field = (UVCustomField *)[[UVSession currentSession].clientConfig.customFields objectAtIndex:path.row];
    [selectedCustomFieldValues setObject:textField.text forKey:field.name];
}

- (void)loadInstantAnswers:(NSTimer *)timer {
    self.loadingInstantAnswers = YES;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:UV_NEW_TICKET_SECTION_INSTANT_ANSWERS] withRowAnimation:UITableViewRowAnimationFade];
    // It's a combined search, remember?
    [[UVSession currentSession] trackInteraction:@"sf"];
    [[UVSession currentSession] trackInteraction:@"si"];
    [UVArticle getInstantAnswers:self.textEditor.text delegate:self];
}

- (void)didRetrieveInstantAnswers:(NSArray *)theInstantAnswers {
    self.instantAnswers = theInstantAnswers;
    self.loadingInstantAnswers = NO;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:UV_NEW_TICKET_SECTION_INSTANT_ANSWERS] withRowAnimation:UITableViewRowAnimationFade];

    // This seems like the only way to do justice to tracking the number of results from the combined search
    NSMutableArray *articleIds = [NSMutableArray arrayWithCapacity:[theInstantAnswers count]];
    for (id answer in theInstantAnswers) {
        if ([answer isKindOfClass:[UVArticle class]]) {
            [articleIds addObject:[NSNumber numberWithInt:[((UVArticle *)answer) articleId]]];
        }
    }
    [[UVSession currentSession] trackInteraction:[articleIds count] > 0 ? @"rfp" : @"rfz" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[articleIds count]], @"count", articleIds, @"ids", nil]];

    NSMutableArray *suggestionIds = [NSMutableArray arrayWithCapacity:[theInstantAnswers count]];
    for (id answer in theInstantAnswers) {
        if ([answer isKindOfClass:[UVSuggestion class]]) {
            [suggestionIds addObject:[NSNumber numberWithInt:[((UVSuggestion *)answer) suggestionId]]];
        }
    }
    [[UVSession currentSession] trackInteraction:[suggestionIds count] > 0 ? @"rip" : @"riz" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[suggestionIds count]], @"count", suggestionIds, @"ids", nil]];
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

- (void)textEditorDidChange:(UVTextEditor *)theTextEditor {
    self.text = theTextEditor.text;
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(loadInstantAnswers:) userInfo:nil repeats:NO];
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

- (void)initCellForText:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
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
    aTextEditor.text = self.text;
    
    [cell.contentView addSubview:aTextEditor];
	self.textEditor = aTextEditor;
    [textEditor becomeFirstResponder];
	[aTextEditor release];
}

- (void)initCellForCustomField:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    BOOL iPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(iPad ? 60 : 16, 0, cell.frame.size.width / 2 - 20, cell.frame.size.height)] autorelease];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    label.font = [UIFont boldSystemFontOfSize:16];
    label.tag = UV_CUSTOM_FIELD_CELL_LABEL_TAG;
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.adjustsFontSizeToFitWidth = YES;
    [cell addSubview:label];
    
    UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width / 2 + 10, 10, cell.frame.size.width / 2 - (iPad ? 64 : 20), cell.frame.size.height - 10)] autorelease];
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    textField.borderStyle = UITextBorderStyleNone;
    textField.tag = UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG;
    textField.delegate = self;
    [cell addSubview:textField];
    
    UILabel *valueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width / 2 + 10, 4, cell.frame.size.width / 2 - (iPad ? 64 : 20), cell.frame.size.height - 10)] autorelease];
    valueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    valueLabel.font = [UIFont systemFontOfSize:16];
    valueLabel.tag = UV_CUSTOM_FIELD_CELL_VALUE_LABEL_TAG;
    valueLabel.textColor = [UIColor blackColor];
    valueLabel.backgroundColor = [UIColor clearColor];
    valueLabel.adjustsFontSizeToFitWidth = YES;
    [cell addSubview:valueLabel];
}

- (void)customizeCellForCustomField:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UVCustomField *field = [[UVSession currentSession].clientConfig.customFields objectAtIndex:indexPath.row];
    UILabel *label = (UILabel *)[cell viewWithTag:UV_CUSTOM_FIELD_CELL_LABEL_TAG];
    UITextField *textField = (UITextField *)[cell viewWithTag:UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG];
    UILabel *valueLabel = (UILabel *)[cell viewWithTag:UV_CUSTOM_FIELD_CELL_VALUE_LABEL_TAG];
    label.text = field.name;
    cell.accessoryType = [field isPredefined] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    textField.enabled = [field isPredefined] ? NO : YES;
    cell.selectionStyle = [field isPredefined] ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
    valueLabel.hidden = ![field isPredefined];
    valueLabel.text = [selectedCustomFieldValues objectForKey:field.name];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nonPredefinedValueChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:textField];
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
        case UV_NEW_TICKET_SECTION_CUSTOM_FIELDS:
            identifier = @"CustomField";
            style = UITableViewCellStyleValue1;
            break;
        case UV_NEW_TICKET_SECTION_INSTANT_ANSWERS:
            identifier = @"InstantAnswer";
            selectable = YES;
            break;
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
    return 5;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == UV_NEW_TICKET_SECTION_PROFILE) {
		if ([UVSession currentSession].user!=nil) {
			return 0;
		} else {
			return 1;
		}
    } else if (section == UV_NEW_TICKET_SECTION_INSTANT_ANSWERS) {
        return [self.instantAnswers count];
	} else if (section == UV_NEW_TICKET_SECTION_CUSTOM_FIELDS) {
		return [[UVSession currentSession].clientConfig.customFields count];
	} else {
		return 1;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == UV_NEW_TICKET_SECTION_INSTANT_ANSWERS) {
        if (loadingInstantAnswers && [self.instantAnswers count] > 0) {
            return NSLocalizedStringFromTable(@"Loading Instant Answers...", @"UserVoice", nil);
        } else if (!loadingInstantAnswers && [self.instantAnswers count] > 0) {
            return NSLocalizedStringFromTable(@"Instant Answers", @"UserVoice", nil);
        }
    }
    return nil;
}

- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    id model = [self.instantAnswers objectAtIndex:indexPath.row];
    if ([model isMemberOfClass:[UVArticle class]]) {
        UVArticle *article = (UVArticle *)model;
        cell.textLabel.text = article.question;
        cell.imageView.image = [UIImage imageNamed:@"uv_article.png"];
    } else {
        UVSuggestion *suggestion = (UVSuggestion *)model;
        cell.textLabel.text = suggestion.title;
        cell.imageView.image = [UIImage imageNamed:@"uv_idea.png"];
    }
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
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
	
	if (indexPath.section == UV_NEW_TICKET_SECTION_CUSTOM_FIELDS) {
        UVCustomField *field = [[UVSession currentSession].clientConfig.customFields objectAtIndex:indexPath.row];
        if ([field isPredefined]) {
            UIViewController *next = [[[UVCustomFieldValueSelectViewController alloc] initWithCustomField:field valueDictionary:selectedCustomFieldValues] autorelease];
            self.navigationItem.backBarButtonItem.title = NSLocalizedStringFromTable(@"Back", @"UserVoice", nil);
            [self.navigationController pushViewController:next animated:YES];
        } else {
            UITableViewCell *cell = [theTableView cellForRowAtIndexPath:indexPath];
            UITextField *textField = (UITextField *)[cell viewWithTag:UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG];
            [textField becomeFirstResponder];
        }
	} else if (indexPath.section == UV_NEW_TICKET_SECTION_INSTANT_ANSWERS) {
        id model = [self.instantAnswers objectAtIndex:indexPath.row];
        if ([model isMemberOfClass:[UVArticle class]]) {
            UVArticle *article = (UVArticle *)model;
            [[UVSession currentSession] trackInteraction:@"cf" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:article.articleId], @"id", self.textEditor.text, @"t", nil]];
            UVArticleViewController *next = [[[UVArticleViewController alloc] initWithArticle:article] autorelease];
            [self.navigationController pushViewController:next animated:YES];
        } else {
            UVSuggestion *suggestion = (UVSuggestion *)model;
            [[UVSession currentSession] trackInteraction:@"ci" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:suggestion.suggestionId], @"id", self.textEditor.text, @"t", nil]];
            UVSuggestionDetailsViewController *next = [[[UVSuggestionDetailsViewController alloc] initWithSuggestion:suggestion] autorelease];
            [self.navigationController pushViewController:next animated:YES];
        }
    }
}


# pragma mark ===== Keyboard handling =====

- (void)keyboardDidShow:(NSNotification*)notification {
    [super keyboardDidShow:notification];
    if (activeField == nil)
        return;
    
    NSIndexPath *path;
    if (activeField == emailField)
        path = [NSIndexPath indexPathForRow:0 inSection:UV_NEW_TICKET_SECTION_PROFILE];
    else if (activeField == textEditor)
        path = [NSIndexPath indexPathForRow:0 inSection:UV_NEW_TICKET_SECTION_TEXT];
    else {
        UITableViewCell *cell = (UITableViewCell *)[activeField superview];
        UITableView *table = (UITableView *)[cell superview];
        path = [table indexPathForCell:cell];
    }
    [tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
	[super loadView];
	self.navigationItem.title = NSLocalizedStringFromTable(@"Contact Us", @"UserVoice", nil);
    
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	
    [self setupGroupedTableView];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	self.tableView.sectionFooterHeight = 0.0;
	
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
    
    self.tableView.tableFooterView = footer;
    [footer release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [textEditor becomeFirstResponder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	self.textEditor = nil;
	self.emailField = nil;
    self.activeField = nil;
    self.selectedCustomFieldValues = nil;
    [self.timer invalidate];
    self.timer = nil;
    self.instantAnswers = nil;
    [super dealloc];
}

@end
