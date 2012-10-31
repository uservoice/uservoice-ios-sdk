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
#import "UVTextView.h"
#import "NSError+UVExtras.h"
#import "UVArticle.h"
#import "UVSuggestion.h"
#import "UVArticleViewController.h"
#import "UVSuggestionDetailsViewController.h"
#import "UVConfig.h"
#import "UVNewTicketTextViewController.h"

#define UV_NEW_TICKET_SECTION_INSTANT_ANSWERS 0
#define UV_NEW_TICKET_SECTION_CUSTOM_FIELDS 1
#define UV_NEW_TICKET_SECTION_PROFILE 2

#define UV_CUSTOM_FIELD_CELL_LABEL_TAG 100
#define UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG 101
#define UV_CUSTOM_FIELD_CELL_VALUE_LABEL_TAG 102

@implementation UVNewTicketViewController

@synthesize emailField;
@synthesize activeField;
@synthesize selectedCustomFieldValues;

+ (UIViewController *)viewController {
    return [self viewControllerWithText:@""];
}

+ (UIViewController *)viewControllerWithText:(NSString *)text {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [[[UVNewTicketViewController alloc] initWithText:text] autorelease];
    } else {
        return [[[UVNewTicketTextViewController alloc] initWithText:text] autorelease];
    }
}

- (id)init {
    if (self = [super init]) {
        self.selectedCustomFieldValues = [NSMutableDictionary dictionaryWithDictionary:[UVSession currentSession].config.customFields];
    }
    return self;
}

- (NSString *)backButtonTitle {
    return @"Contact";
}

- (void)dismissKeyboard {
    [textView becomeFirstResponder];
    [textView resignFirstResponder];
}

- (void)sendButtonTapped {
    [self dismissKeyboard];
    NSString *email = emailField.text;
    self.text = textView.text;

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
    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [viewControllers removeLastObject];
    [viewControllers removeLastObject];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

- (void)dismissTextView {
    [self.textView resignFirstResponder];
}

- (void)suggestionButtonTapped {
    UIViewController *next = [[UVNewSuggestionViewController alloc] initWithForum:[UVSession currentSession].clientConfig.forum title:self.textView.text];
    [self pushViewControllerFromWelcome:next];
}

- (void)nonPredefinedValueChanged:(NSNotification *)notification {
    UITextField *textField = (UITextField *)[notification object];
    UITableViewCell *cell = (UITableViewCell *)[textField superview];
    UITableView *table = (UITableView *)[cell superview];
    NSIndexPath *path = [table indexPathForCell:cell];
    UVCustomField *field = (UVCustomField *)[[UVSession currentSession].clientConfig.customFields objectAtIndex:path.row];
    [selectedCustomFieldValues setObject:textField.text forKey:field.name];
}

- (void)willLoadInstantAnswers {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:UV_NEW_TICKET_SECTION_INSTANT_ANSWERS] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)didLoadInstantAnswers {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:UV_NEW_TICKET_SECTION_INSTANT_ANSWERS] withRowAnimation:UITableViewRowAnimationFade];
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

- (void)textViewDidBeginEditing:(UVTextView *)theTextEditor {
    self.activeField = theTextEditor;
}

- (void)textViewDidEndEditing:(UVTextView *)theTextEditor {
    self.activeField = nil;
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
    UVTextView *aTextEditor = [[UVTextView alloc] initWithFrame:frame];
    aTextEditor.delegate = self;
    aTextEditor.autocorrectionType = UITextAutocorrectionTypeYes;
    aTextEditor.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    aTextEditor.backgroundColor = [UIColor clearColor];
    aTextEditor.placeholder = NSLocalizedStringFromTable(@"Message", @"UserVoice", nil);
    aTextEditor.text = self.text;

    [cell.contentView addSubview:aTextEditor];
    self.textView = aTextEditor;
    [textView becomeFirstResponder];
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

    UILabel *valueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width / 2 - 14, 5, cell.frame.size.width / 2 - (iPad ? 64 : 20), cell.frame.size.height - 10)] autorelease];
    valueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    valueLabel.font = [UIFont systemFontOfSize:16];
    valueLabel.tag = UV_CUSTOM_FIELD_CELL_VALUE_LABEL_TAG;
    valueLabel.textColor = [UIColor blackColor];
    valueLabel.backgroundColor = [UIColor clearColor];
    valueLabel.adjustsFontSizeToFitWidth = YES;
    valueLabel.textAlignment = NSTextAlignmentRight;
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
            // TODO put the identifier = @"Text" cell here, and then the IA message, if on iPad
            // TODO on iPhone put just the message
            // TODO figure out the expand/collape madness (different for each)
            identifier = @"InstantAnswer";
            selectable = YES;
            break;
        case UV_NEW_TICKET_SECTION_PROFILE:
            identifier = @"Email";
            break;
    }

    return [self createCellForIdentifier:identifier
                               tableView:theTableView
                               indexPath:indexPath
                                   style:style
                              selectable:selectable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 3;
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

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO return 144 (or something) if this is the text cell on the ipad
    return 44;
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
        [self selectInstantAnswerAtIndex:indexPath.row];
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
    else if (activeField == textView)
        path = [NSIndexPath indexPathForRow:0 inSection:UV_NEW_TICKET_SECTION_INSTANT_ANSWERS];
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
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 62)];
    // TODO recalculate this on orientation change
    // TODO make tapping the text label take you back
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 300, 60)];
    textLabel.numberOfLines = 3;
    textLabel.font = [UIFont systemFontOfSize:15];
    textLabel.text = text;
    [textLabel sizeToFit];
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:textLabel];
    self.tableView.tableHeaderView = headerView;

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, screenWidth, 15)];
    label.text = NSLocalizedStringFromTable(@"Want to suggest an idea instead?", @"UserVoice", nil);
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UVStyleSheet linkTextColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:13];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
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
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [footer addSubview:button];
    self.tableView.tableFooterView = footer;
    [footer release];
    
    UIBarButtonItem *sendButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Send", @"UserVoice", nil)
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(sendButtonTapped)] autorelease];
    self.navigationItem.rightBarButtonItem = sendButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [textView becomeFirstResponder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.emailField = nil;
    self.activeField = nil;
    self.selectedCustomFieldValues = nil;
    [super dealloc];
}

@end
