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
#import "UVAccessToken.h"
#import "UVCategorySelectViewController.h"
#import "UVNewTicketViewController.h"
#import "UVSignInViewController.h"
#import "UVTextView.h"
#import "NSError+UVExtras.h"

#define UV_NEW_SUGGESTION_SECTION_PROFILE 0
#define UV_NEW_SUGGESTION_SECTION_CATEGORY 1

@implementation UVNewSuggestionViewController

@synthesize forum;
@synthesize title;
@synthesize text;
@synthesize name;
@synthesize email;
@synthesize textView;
@synthesize titleField;
@synthesize nameField;
@synthesize emailField;
@synthesize numVotes;
@synthesize category;
@synthesize shouldShowCategories;
@synthesize scrollView;

- (id)initWithForum:(UVForum *)theForum title:(NSString *)theTitle {
    if (self = [super init]) {
        self.forum = theForum;
        self.title = theTitle;
        self.shouldShowCategories = self.forum.categories && [self.forum.categories count] > 0;
    }
    return self;
}

- (void)didReceiveError:(NSError *)error {
    if ([error isNotFoundError]) {
        [self hideActivityIndicator];
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
    [textView resignFirstResponder];
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
        [[UVSession currentSession] trackInteraction:@"pi"];
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
    [[UVSession currentSession].accessToken persist];

    [self createSuggestion];
}

- (void)didCreateSuggestion:(UVSuggestion *)theSuggestion {
    [self hideActivityIndicator];
    [self alertSuccess:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Your idea \"%@\" was successfully created.", @"UserVoice", nil), self.title]];

    // increment the created suggestions and supported suggestions counts
    [[UVSession currentSession].user didCreateSuggestion:theSuggestion];

    [UVSession currentSession].clientConfig.forum.suggestionsNeedReload = YES;

    // update the remaining votes
    [UVSession currentSession].user.votesRemaining = theSuggestion.votesRemaining;

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
        [self showActivityIndicator];
        [UVUser discoverWithEmail:emailField.text delegate:self];
    }
}

- (void)dismissTextView {
    [textView resignFirstResponder];
    [emailField resignFirstResponder];
    [nameField resignFirstResponder];
    [titleField resignFirstResponder];
}

- (void)voteSegmentChanged:(id)sender {
    UISegmentedControl *segments = (UISegmentedControl *)sender;
    self.numVotes = segments.selectedSegmentIndex + 1;
    [self dismissTextView];
}

- (void)contactButtonTapped {
    UIViewController *next = [UVNewTicketViewController viewControllerWithText:titleField.text];
    [self pushViewControllerFromWelcome:next];
}

#pragma mark ===== UITextFieldDelegate Methods =====

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.titleField)
        return;
    CGPoint offset = [textField convertPoint:CGPointZero toView:scrollView];
    offset.x = 0;
    offset.y -= 20;
    offset.y = MIN(offset.y, MAX(0, scrollView.contentSize.height + kbHeight - scrollView.bounds.size.height));
    [scrollView setContentOffset:offset animated:YES];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField==emailField) {
        [nameField resignFirstResponder];
        [textView resignFirstResponder];
        [self checkEmail];
    }
    [scrollView setContentOffset:CGPointZero animated:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
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

- (void)customizeCellForCategory:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = NSLocalizedStringFromTable(@"Category", @"UserVoice", nil);
    cell.detailTextLabel.text = self.category.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)initCellForName:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    self.nameField = [self customizeTextFieldCell:cell label:NSLocalizedStringFromTable(@"Name", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"“Anonymous”", @"UserVoice", nil)];
}

- (void)initCellForEmail:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    self.emailField = [self customizeTextFieldCell:cell label:NSLocalizedStringFromTable(@"Email", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"(required)", @"UserVoice", nil)];
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

- (void)titleChanged:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem.enabled = [titleField.text length] > 0;
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    BOOL selectable = NO;

    switch (indexPath.section) {
        case UV_NEW_SUGGESTION_SECTION_CATEGORY:
            identifier = @"Category";
            style = UITableViewCellStyleValue1;
            break;
        case UV_NEW_SUGGESTION_SECTION_PROFILE:
            identifier = indexPath.row == 0 ? @"Email" : @"Name";
            break;
    }

    return [self createCellForIdentifier:identifier
                               tableView:theTableView
                               indexPath:indexPath
                                   style:style
                              selectable:selectable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 2;
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
    self.navigationItem.title = NSLocalizedStringFromTable(@"Post Idea", @"UserVoice", nil);

    self.scrollView = [[[UIScrollView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.view = scrollView;

    UIView *titleView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, 34)] autorelease];
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(7, 7, 0, 0)] autorelease];
    label.text = NSLocalizedStringFromTable(@"Title", @"UserVoice", nil);
    label.font = [UIFont systemFontOfSize:15];
    [label sizeToFit];
    label.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
    [titleView addSubview:label];
    self.titleField = [[[UITextField alloc] initWithFrame:CGRectMake(14 + label.bounds.size.width, 7, titleView.bounds.size.width - 14 - label.bounds.size.width, 22)] autorelease];
    titleField.text = self.title;
    titleField.font = [UIFont systemFontOfSize:15];
    titleField.placeholder = NSLocalizedStringFromTable(@"(required)", @"UserVoice", nil);
    titleField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleField.returnKeyType = UIReturnKeyDone;
    titleField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(titleChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:titleField];
    [titleView addSubview:titleField];
    UIView *border = [[[UIView alloc] initWithFrame:CGRectMake(0, 33, scrollView.bounds.size.width, 1)] autorelease];
    border.backgroundColor = [UIColor colorWithRed:0.82f green:0.84f blue:0.86f alpha:1.0f];
    border.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [titleView addSubview:border];
    [scrollView addSubview:titleView];

    self.textView = [[[UVTextView alloc] initWithFrame:CGRectMake(0, titleView.bounds.size.height, scrollView.bounds.size.width, 84)] autorelease];
    textView.placeholder = NSLocalizedStringFromTable(@"Description (optional)", @"UserVoice", nil);
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textView.delegate = self;
    [scrollView addSubview:textView];

    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, titleView.bounds.size.height + textView.bounds.size.height, scrollView.bounds.size.width, 1000) style:UITableViewStyleGrouped] autorelease];
    self.tableView.backgroundView = nil;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.94f green:0.95f blue:0.95f alpha:1.0f];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addTopBorder:tableView];
    UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
    label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 50)] autorelease];
    label.text = NSLocalizedStringFromTable(@"When you post an idea on our forum, others will be able to vote and comment on it as well. When we respond to the idea, you'll get notified.", @"UserVoice", nil);
    label.font = [UIFont systemFontOfSize:11];
    label.textAlignment = UITextAlignmentLeft;
    label.numberOfLines = 0;
    label.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [label sizeToFit];
    [footer addSubview:label];
    self.tableView.tableFooterView = footer;
    [scrollView addSubview:tableView];

    [tableView reloadData];
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, titleView.bounds.size.height + textView.bounds.size.height + tableView.contentSize.height);

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Submit", @"UserVoice", nil)
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self
                                                                              action:@selector(createButtonTapped)] autorelease];
    self.navigationItem.rightBarButtonItem.enabled = [titleField.text length] > 0;
}

- (void)viewWillAppear:(BOOL)animated {
   [super viewWillAppear:animated];
   scrollView.contentInset = UIEdgeInsetsZero;
   scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
   scrollView.contentOffset = CGPointZero;
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
    self.textView = nil;
    self.titleField = nil;
    self.nameField = nil;
    self.emailField = nil;
    self.category = nil;
    self.scrollView = nil;
    [super dealloc];
}

@end
