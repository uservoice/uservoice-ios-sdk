//
//  UVBaseTicketViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVBaseTicketViewController.h"
#import "UVSession.h"
#import "UVArticle.h"
#import "UVSuggestion.h"
#import "UVArticleViewController.h"
#import "UVSuggestionDetailsViewController.h"
#import "UVNewSuggestionViewController.h"
#import "UVCustomFieldValueSelectViewController.h"
#import "UVStylesheet.h"
#import "UVCustomField.h"
#import "UVUser.h"
#import "UVClientConfig.h"
#import "UVConfig.h"
#import "UVTicket.h"
#import "UVForum.h"
#import "UVKeyboardUtils.h"

@implementation UVBaseTicketViewController

@synthesize timer;
@synthesize textView;
@synthesize instantAnswers;
@synthesize emailField;
@synthesize nameField;
@synthesize selectedCustomFieldValues;
@synthesize initialText;

- (id)initWithText:(NSString *)theText {
    if (self = [self init]) {
        if (theText)
            self.text = theText;
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        self.selectedCustomFieldValues = [NSMutableDictionary dictionaryWithDictionary:[UVSession currentSession].config.customFields];
    }
    return self;
}

- (void)willLoadInstantAnswers {
}

- (void)didLoadInstantAnswers {
}

- (void)dismissKeyboard {
}

- (void)sendButtonTapped {
    [self dismissKeyboard];
    self.email = emailField.text;
    self.name = nameField.text;
    self.text = textView.text;
    if ([UVSession currentSession].user || (email && [email length] > 1)) {
        [self showActivityIndicator];
        [UVTicket createWithMessage:self.text andEmailIfNotLoggedIn:self.email andName:self.name andCustomFields:selectedCustomFieldValues andDelegate:self];
        [[UVSession currentSession] trackInteraction:@"pt"];
    } else {
        [self alertError:NSLocalizedStringFromTable(@"Please enter your email address before submitting your ticket.", @"UserVoice", nil)];
    }
}

- (void)didCreateTicket:(UVTicket *)theTicket {
    self.text = nil;
    [self hideActivityIndicator];
    [self alertSuccess:NSLocalizedStringFromTable(@"Your ticket was successfully submitted.", @"UserVoice", nil)];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)suggestionButtonTapped {
    UIViewController *next = [[UVNewSuggestionViewController alloc] initWithForum:[UVSession currentSession].clientConfig.forum title:self.textView.text];
    [self pushViewControllerFromWelcome:next];
}

- (void)reloadCustomFieldsTable {
    [tableView reloadData];
}

- (void)selectCustomFieldAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)theTableView {
    [emailField resignFirstResponder];
    UVCustomField *field = [[UVSession currentSession].clientConfig.customFields objectAtIndex:indexPath.row];
    if ([field isPredefined]) {
        UIViewController *next = [[[UVCustomFieldValueSelectViewController alloc] initWithCustomField:field valueDictionary:selectedCustomFieldValues] autorelease];
        self.navigationItem.backBarButtonItem.title = NSLocalizedStringFromTable(@"Back", @"UserVoice", nil);
        [self dismissKeyboard];
        [self.navigationController pushViewController:next animated:YES];
    } else {
        UITableViewCell *cell = [theTableView cellForRowAtIndexPath:indexPath];
        UITextField *textField = (UITextField *)[cell viewWithTag:UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG];
        [textField becomeFirstResponder];
    }
}

- (void)nonPredefinedValueChanged:(NSNotification *)notification {
    UITextField *textField = (UITextField *)[notification object];
    UITableViewCell *cell = (UITableViewCell *)[textField superview];
    UITableView *table = (UITableView *)[cell superview];
    NSIndexPath *path = [table indexPathForCell:cell];
    UVCustomField *field = (UVCustomField *)[[UVSession currentSession].clientConfig.customFields objectAtIndex:path.row];
    [selectedCustomFieldValues setObject:textField.text forKey:field.name];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textViewDidChange:(UVTextView *)theTextEditor {
    if ([[self.text lowercaseString] isEqualToString:[self.textView.text lowercaseString]])
        return;
    self.text = self.textView.text;
    [self.timer invalidate];
    self.timer = nil;
    if (self.textView.text.length == 0) {
        self.instantAnswers = [NSArray array];
        [self didLoadInstantAnswers];
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadInstantAnswers:) userInfo:nil repeats:NO];
    }
}

- (void)setName:(NSString *)theName {
    [theName retain];
    [name release];
    name = theName;

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:name forKey:@"uv-message-name"];
    [prefs synchronize];
}

- (NSString *)name {
    if (name)
        return name;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    name = [[prefs stringForKey:@"uv-message-name"] retain];
    return name;
}

- (void)setEmail:(NSString *)theEmail {
    [theEmail retain];
    [email release];
    email = theEmail;

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:email forKey:@"uv-message-email"];
    [prefs synchronize];
}

- (NSString *)email {
    if (email)
        return email;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    email = [[prefs stringForKey:@"uv-message-email"] retain];
    return email;
}

- (void)setText:(NSString *)theText {
    [theText retain];
    [text release];
    text = theText;

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:text forKey:@"uv-message-text"];
    [prefs synchronize];
}

- (NSString *)text {
    if (text)
        return text;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    text = [[prefs stringForKey:@"uv-message-text"] retain];
    return text;
}

- (void)loadInstantAnswers:(NSTimer *)timer {
    loadingInstantAnswers = YES;
    self.instantAnswers = [NSArray array];
    [self willLoadInstantAnswers];
    // It's a combined search, remember?
    [[UVSession currentSession] trackInteraction:@"sf"];
    [[UVSession currentSession] trackInteraction:@"si"];
    [UVArticle getInstantAnswers:self.text delegate:self];
}

- (void)loadInstantAnswers {
    [self loadInstantAnswers:nil];
}

- (void)didRetrieveInstantAnswers:(NSArray *)theInstantAnswers {
    self.instantAnswers = [theInstantAnswers subarrayWithRange:NSMakeRange(0, MIN(3, [theInstantAnswers count]))];
    loadingInstantAnswers = NO;
    [self didLoadInstantAnswers];
    
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

- (UIView *)fieldsTableFooterView {
    UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
    [self addTopBorder:footer alpha:0.5f];
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)] autorelease];
    label.text = NSLocalizedStringFromTable(@"Would you rather post an idea on our forum so others can vote and comment on it?", @"UserVoice", nil);
    label.textColor = [UIColor colorWithRed:0.20f green:0.31f blue:0.52f alpha:1.0f];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:11];
    label.textAlignment = UITextAlignmentLeft;
    label.numberOfLines = 2;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suggestionButtonTapped)] autorelease]];
    [footer addSubview:label];
    return footer;
}

- (void)addButton:(NSString *)label withCaption:(NSString *)caption andRect:(CGRect)rect andMask:(int)autoresizingMask andAction:(SEL)selector toView:(UIView *)parentView {
    CGRect containerRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height + 20);
    UIView *container = [[[UIView alloc] initWithFrame:containerRect] autorelease];
    container.autoresizingMask = autoresizingMask;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [button setTitle:NSLocalizedStringFromTable(label, @"UserVoice", nil) forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:button];
    UILabel *captionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 36, rect.size.width, 15)] autorelease];
    captionLabel.textAlignment = UITextAlignmentCenter;
    captionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    captionLabel.text = NSLocalizedStringFromTable(caption, @"UserVoice", nil);
    captionLabel.font = [UIFont systemFontOfSize:10];
    captionLabel.textColor = [UIColor grayColor];
    [container addSubview:captionLabel];
    [parentView addSubview:container];
}

- (UIBarButtonItem *)barButtonItem:(NSString *)label withAction:(SEL)selector {
    return [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(label, @"UserVoice", nil)
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:selector] autorelease];
}

- (void)initCellForCustomField:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(16 + (IPAD ? 25 : 0), 0, cell.frame.size.width / 2 - 20, cell.frame.size.height)] autorelease];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    label.font = [UIFont boldSystemFontOfSize:16];
    label.tag = UV_CUSTOM_FIELD_CELL_LABEL_TAG;
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.adjustsFontSizeToFitWidth = YES;
    [cell addSubview:label];

    UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width / 2 + 10, 10, cell.frame.size.width / 2 - (IPAD ? 64 : 20), cell.frame.size.height - 10)] autorelease];
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    textField.borderStyle = UITextBorderStyleNone;
    textField.tag = UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG;
    textField.delegate = self;
    [cell addSubview:textField];
}

- (void)customizeCellForCustomField:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVCustomField *field = [[UVSession currentSession].clientConfig.customFields objectAtIndex:indexPath.row];
    UILabel *label = (UILabel *)[cell viewWithTag:UV_CUSTOM_FIELD_CELL_LABEL_TAG];
    UITextField *textField = (UITextField *)[cell viewWithTag:UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG];
    UILabel *valueLabel = cell.detailTextLabel;
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
    cell.backgroundColor = [UIColor whiteColor];
    self.emailField = [self customizeTextFieldCell:cell label:NSLocalizedStringFromTable(@"Email", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"(required)", @"UserVoice", nil)];
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailField.text = self.email;
}

- (void)initCellForName:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    self.nameField = [self customizeTextFieldCell:cell label:NSLocalizedStringFromTable(@"Name", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"“Anonymous”", @"UserVoice", nil)];
    self.nameField.text = self.name;
}

- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell index:(int)index {
    cell.backgroundColor = [UIColor whiteColor];
    id model = [instantAnswers objectAtIndex:index];
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

- (void)selectInstantAnswerAtIndex:(int)index {
    id model = [self.instantAnswers objectAtIndex:index];
    if ([model isMemberOfClass:[UVArticle class]]) {
        UVArticle *article = (UVArticle *)model;
        [[UVSession currentSession] trackInteraction:@"cf" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:article.articleId], @"id", self.textView.text, @"t", nil]];
        UVArticleViewController *next = [[[UVArticleViewController alloc] initWithArticle:article] autorelease];
        [self.navigationController pushViewController:next animated:YES];
    } else {
        UVSuggestion *suggestion = (UVSuggestion *)model;
        [[UVSession currentSession] trackInteraction:@"ci" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:suggestion.suggestionId], @"id", self.textView.text, @"t", nil]];
        UVSuggestionDetailsViewController *next = [[[UVSuggestionDetailsViewController alloc] initWithSuggestion:suggestion] autorelease];
        [self.navigationController pushViewController:next animated:YES];
    }
}

- (void)addSpinnerAndArrowTo:(UIView *)view atCenter:(CGPoint)center {
    UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    spinner.center = center;
    spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    spinner.tag = TICKET_VIEW_SPINNER_TAG;
    [spinner startAnimating];
    [view addSubview:spinner];
}

- (void)updateSpinnerAndArrowIn:(UIView *)view withToggle:(BOOL)toggled animated:(BOOL)animated {
    UILabel *label = (UILabel *)[view viewWithTag:TICKET_VIEW_IA_LABEL_TAG];
    UIView *spinner = [view viewWithTag:TICKET_VIEW_SPINNER_TAG];
    if ([instantAnswers count] > 0)
      label.text = [self instantAnswersFoundMessage:toggled];
    void (^update)() = ^{
        if (loadingInstantAnswers) {
            spinner.layer.opacity = 1.0;
        } else {
            spinner.layer.opacity = 0.0;
        }
    };
    if (animated) {
        [UIView animateWithDuration:0.3 animations:update];
    } else {
        update();
    }
}

- (BOOL)signedIn {
    return [UVSession currentSession].user != nil;
}

- (NSString *)instantAnswersFoundMessage:(BOOL)toggled {
    BOOL foundArticles = NO;
    BOOL foundIdeas = NO;
    for (id answer in instantAnswers) {
        if ([answer isKindOfClass:[UVArticle class]])
            foundArticles = YES;
        else if ([answer isKindOfClass:[UVSuggestion class]])
            foundIdeas = YES;
    }
    if (foundArticles && foundIdeas)
        return toggled ? NSLocalizedStringFromTable(@"Matching articles and ideas", @"UserVoice", nil) : NSLocalizedStringFromTable(@"View matching articles and ideas", @"UserVoice", nil);
    else if (foundArticles)
        return toggled ? NSLocalizedStringFromTable(@"Matching articles", @"UserVoice", nil) : NSLocalizedStringFromTable(@"View matching articles", @"UserVoice", nil);
    else if (foundIdeas)
        return toggled ? NSLocalizedStringFromTable(@"Matching ideas", @"UserVoice", nil) : NSLocalizedStringFromTable(@"View matching ideas", @"UserVoice", nil);
    else
        return @"";
}

- (void)initNavigationItem {
    [super initNavigationItem];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(dismiss)] autorelease];
}

- (void)dismiss {
    if ([self shouldLeaveViewController]) {
        if ([UVSession currentSession].isModal && firstController)
            [self dismissUserVoice];
        else
            [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)showSaveActionSheet {
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                destructiveButtonTitle:NSLocalizedStringFromTable(@"Don't save", @"UserVoice", nil)
                                                     otherButtonTitles:NSLocalizedStringFromTable(@"Save draft", @"UserVoice", nil), nil] autorelease];

    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
        self.text = nil;
    if (buttonIndex == 0 || buttonIndex == 1) {
        readyToPopView = YES;
        [self dismiss];
    }
}

- (BOOL)shouldLeaveViewController {
    BOOL textChanged = self.text && [self.text length] > 0 && ![self.initialText isEqualToString:self.text];
    if (readyToPopView || !textChanged)
        return YES;
    [self showSaveActionSheet];
    return NO;
}

- (void)dismissUserVoice {
    if ([self shouldLeaveViewController])
        [super dismissUserVoice];
}

- (void)loadView {
    [super loadView];
    self.initialText = self.text;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer invalidate];
    self.timer = nil;
    self.instantAnswers = nil;
    self.textView = nil;
    self.emailField = nil;
    self.nameField = nil;
    self.selectedCustomFieldValues = nil;
    self.initialText = nil;
    [text release];
    text = nil;
    [email release];
    email = nil;
    [name release];
    name = nil;
    [super dealloc];
}

@end
