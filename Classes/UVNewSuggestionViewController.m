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
#import "UVClientConfig.h"
#import "UVSubdomain.h"
#import "UVAccessToken.h"
#import "UVCategorySelectViewController.h"
#import "UVNewTicketViewController.h"
#import "UVTextView.h"
#import "NSError+UVExtras.h"
#import "UVWelcomeViewController.h"
#import "UVSuggestionListViewController.h"
#import "UVUser.h"
#import "UVKeyboardUtils.h"

#define UV_NEW_SUGGESTION_SECTION_PROFILE 0
#define UV_NEW_SUGGESTION_SECTION_CATEGORY 1

#define STATE_BEGIN 1000
#define STATE_IA 1001
#define STATE_SHOW_IA 1002
#define STATE_FIELDS 1003
#define STATE_FIELDS_IA 1004
#define STATE_WAITING 1005

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
@synthesize category;
@synthesize shouldShowCategories;
@synthesize scrollView;
@synthesize nextButton;
@synthesize sendButton;
@synthesize instantAnswersView;
@synthesize instantAnswersMessage;
@synthesize instantAnswersTableView;
@synthesize fieldsTableView;
@synthesize shade;
@synthesize activityIndicatorView;

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
    [[UVSession currentSession] trackInteraction:@"pi"];
    [UVSuggestion createWithForum:self.forum
                         category:self.category
                            title:self.title
                             text:self.text
                            votes:1
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
    if (self.email && [self.email length] > 1) {
        [self requireUserAuthenticated:email name:name action:@selector(createSuggestion)];
    } else {
        [self alertError:NSLocalizedStringFromTable(@"Please enter your email address before submitting your suggestion.", @"UserVoice", nil)];
    }
}

- (void)didCreateSuggestion:(UVSuggestion *)theSuggestion {
    [self hideActivityIndicator];
    /* [self alertSuccess:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Your idea \"%@\" was successfully created.", @"UserVoice", nil), self.title]]; */
    [[UVSession currentSession] flash:NSLocalizedStringFromTable(@"Your idea has been posted on our forum.", @"UserVoice", nil) title:NSLocalizedStringFromTable(@"Success!", @"UserVoice", nil) suggestion:theSuggestion];

    // increment the created suggestions and supported suggestions counts
    [[UVSession currentSession].user didCreateSuggestion:theSuggestion];

    [UVSession currentSession].clientConfig.forum.suggestionsNeedReload = YES;

    // update the remaining votes
    [UVSession currentSession].user.votesRemaining = theSuggestion.votesRemaining;

    // Back out to the welcome screen
    UVSuggestionListViewController *list = (UVSuggestionListViewController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject];
    if ([UVSession currentSession].isModal && list.firstController) {
        CATransition* transition = [CATransition animation];
        transition.duration = 0.3;
        transition.type = kCATransitionFade;
        [list.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        UVWelcomeViewController *welcomeView = [[[UVWelcomeViewController alloc] init] autorelease];
        welcomeView.firstController = YES;
        NSArray *viewControllers = @[list.navigationController.viewControllers[0], welcomeView];
        [list.navigationController setViewControllers:viewControllers animated:NO];
    } else {
        [list.navigationController popViewControllerAnimated:NO];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dismissTextView {
    [textView resignFirstResponder];
    [emailField resignFirstResponder];
    [nameField resignFirstResponder];
    [titleField resignFirstResponder];
}

#pragma mark ===== UITextFieldDelegate Methods =====

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.titleField) {
        if ([instantAnswers count] == 0)
            state = STATE_BEGIN;
        else
            state = STATE_IA;
        [self updateLayout];
        [scrollView setContentOffset:CGPointZero animated:YES];
        return;
    }
    CGPoint offset = [textField convertPoint:CGPointZero toView:scrollView];
    offset.x = 0;
    offset.y -= 20;
    offset.y = MIN(offset.y, MAX(0, scrollView.contentSize.height + [UVKeyboardUtils height] - scrollView.bounds.size.height));
    [scrollView setContentOffset:offset animated:YES];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [scrollView setContentOffset:CGPointZero animated:YES];
    return YES;
}

- (void)textViewDidBeginEditing:(UVTextView *)theTextEditor {
    if ([instantAnswers count] == 0)
        state = STATE_BEGIN;
    else
        state = STATE_IA;
    [self updateLayout];
    [scrollView setContentOffset:CGPointZero animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == titleField)
        [self nextButtonTapped];
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
    self.nameField.text = self.userName;
    self.nameField.delegate = self;
}

- (void)initCellForEmail:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    self.emailField = [self customizeTextFieldCell:cell label:NSLocalizedStringFromTable(@"Email", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"(required)", @"UserVoice", nil)];
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailField.text = self.userEmail;
    self.emailField.delegate = self;
}

- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [self customizeCellForInstantAnswer:cell index:indexPath.row];
}

- (void)titleChanged:(NSNotification *)notification {
    [self searchInstantAnswers:titleField.text];
    self.navigationItem.rightBarButtonItem.enabled = [titleField.text length] != 0 && state != STATE_WAITING;
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    BOOL selectable = NO;

    if (theTableView == fieldsTableView) {
        switch (indexPath.section) {
            case UV_NEW_SUGGESTION_SECTION_CATEGORY:
                identifier = @"Category";
                style = UITableViewCellStyleValue1;
                break;
            case UV_NEW_SUGGESTION_SECTION_PROFILE:
                identifier = indexPath.row == 0 ? @"Email" : @"Name";
                break;
        }
    } else {
        identifier = @"InstantAnswer";
        selectable = YES;
    }

    return [self createCellForIdentifier:identifier
                               tableView:theTableView
                               indexPath:indexPath
                                   style:style
                              selectable:selectable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    if (theTableView == fieldsTableView)
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    if (theTableView == fieldsTableView) {
        if (section == UV_NEW_SUGGESTION_SECTION_PROFILE)
            return 2;
        else if (section == UV_NEW_SUGGESTION_SECTION_CATEGORY)
            return self.shouldShowCategories ? 1 : 0;
        else
            return 1;
    } else {
        return [instantAnswers count];
    }
}

#pragma mark ===== UITableViewDelegate Methods =====

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];

    if (theTableView == fieldsTableView) {
        if (indexPath.section == UV_NEW_SUGGESTION_SECTION_CATEGORY && self.shouldShowCategories) {
            [self dismissTextView];
            UIViewController *next = [[UVCategorySelectViewController alloc] initWithForum:self.forum andSelectedCategory:self.category];
            [self.navigationController pushViewController:next animated:YES];
            [next release];
        }
    } else {
        [self selectInstantAnswerAtIndex:indexPath.row];
    }
}

#pragma mark ===== Basic View Methods =====

- (void)updateLayout {
    BOOL showTextView = state == STATE_BEGIN || state == STATE_IA || state == STATE_WAITING;
    BOOL showIAMessage = state == STATE_IA || state == STATE_SHOW_IA || state == STATE_FIELDS_IA;
    BOOL showIATable = state == STATE_SHOW_IA;
    BOOL showFieldsTable = state == STATE_FIELDS || state == STATE_FIELDS_IA;
    BOOL landscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);

    if (!showTextView) {
        [titleField resignFirstResponder];
        [textView resignFirstResponder];
    }

    CGFloat sH = [UIScreen mainScreen].bounds.size.height;
    CGFloat sW = [UIScreen mainScreen].bounds.size.width;
    CGFloat kbP = 280;
    CGFloat kbL = 214;

    CGRect textViewRect = landscape ?
        CGRectMake(0, textView.frame.origin.y, sH, sW - kbL - textView.frame.origin.y) :
        CGRectMake(0, textView.frame.origin.y, sW, sH - kbP - textView.frame.origin.y);

    if (showIAMessage)
        textViewRect.size.height -= 40;

    CGPoint instantAnswersOrigin = CGPointMake(0, textViewRect.origin.y + textViewRect.size.height);
    CGPoint fieldsTableViewOrigin = CGPointMake(0, showFieldsTable ? instantAnswersOrigin.y + (showIAMessage ? 40 : 0) : sH);

    instantAnswersView.hidden = !showIAMessage;
    if (showIATable)
        instantAnswersTableView.hidden = NO;
    if (showFieldsTable)
        fieldsTableView.hidden = NO;

    if (state == STATE_WAITING)
        [self showActivityIndicator];
    else
        [self hideActivityIndicator];

    if (showTextView || showIATable)
        self.navigationItem.rightBarButtonItem = nextButton;
    else
        self.navigationItem.rightBarButtonItem = sendButton;
    
    self.navigationItem.rightBarButtonItem.enabled = !(showTextView && [titleField.text length] == 0) && state != STATE_WAITING;

    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, textViewRect.origin.y + textViewRect.size.height + (showIAMessage ? 40 : 0) + (showIATable ? instantAnswersTableView.contentSize.height : 0) + (showFieldsTable ? fieldsTableView.contentSize.height : 0));

    [self updateSpinnerAndXIn:instantAnswersMessage withToggle:(state == STATE_SHOW_IA) animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        textView.frame = textViewRect;
        instantAnswersView.frame = CGRectMake(instantAnswersOrigin.x, instantAnswersOrigin.y, textViewRect.size.width, instantAnswersTableView.frame.origin.y + instantAnswersTableView.frame.size.height);
        fieldsTableView.frame = CGRectMake(fieldsTableViewOrigin.x, fieldsTableViewOrigin.y, textViewRect.size.width, fieldsTableView.bounds.size.height);
    } completion:^(BOOL finished) {
        if (showTextView)
            [textView scrollRangeToVisible:[textView selectedRange]];
        else
            [textView scrollRangeToVisible:NSMakeRange(0, 0)];
        if (!showFieldsTable)
            fieldsTableView.hidden = YES;
    }];
}

- (void)loadView {
    [super loadView];
    self.navigationItem.title = NSLocalizedStringFromTable(@"Post Idea", @"UserVoice", nil);

    self.scrollView = [[[UIScrollView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.view = scrollView;

    UIView *titleView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, 34)] autorelease];
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(7, 7, 0, 0)] autorelease];
    label.text = NSLocalizedStringFromTable(@"Title:", @"UserVoice", nil);
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

    self.instantAnswersView = [[[UIView alloc] initWithFrame:CGRectMake(0, 200, 320, 1000)] autorelease];
    self.instantAnswersView.backgroundColor = [UIColor colorWithRed:0.95f green:0.98f blue:1.00f alpha:1.0f];
    self.instantAnswersView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.instantAnswersView.layer.shadowOffset = CGSizeMake(0, 0);
    self.instantAnswersView.layer.shadowRadius = 2.0;
    self.instantAnswersView.layer.shadowOpacity = 0.3;
    self.instantAnswersMessage = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
    self.instantAnswersMessage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [instantAnswersMessage addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(instantAnswersMessageTapped)] autorelease]];
    UILabel *instantAnswersLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 4, 300, 30)] autorelease];
    instantAnswersLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    instantAnswersLabel.tag = TICKET_VIEW_IA_LABEL_TAG;
    instantAnswersLabel.numberOfLines = 2;
    instantAnswersLabel.textColor = [UIColor colorWithRed:0.20f green:0.31f blue:0.52f alpha:1.0f];
    instantAnswersLabel.font = [UIFont systemFontOfSize:15];
    instantAnswersLabel.backgroundColor = [UIColor clearColor];
    instantAnswersLabel.textAlignment = UITextAlignmentCenter;
    [instantAnswersMessage addSubview:instantAnswersLabel];
    [self addSpinnerAndXTo:instantAnswersMessage atCenter:CGPointMake(320 - 22, 20)];
    [instantAnswersView addSubview:instantAnswersMessage];
    [self addTopBorder:instantAnswersView];
    self.instantAnswersTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, 1000) style:UITableViewStyleGrouped] autorelease];
    self.instantAnswersTableView.backgroundView = nil;
    self.instantAnswersTableView.backgroundColor = [UIColor clearColor];
    self.instantAnswersTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    self.instantAnswersTableView.dataSource = self;
    self.instantAnswersTableView.delegate = self;
    self.instantAnswersTableView.scrollEnabled = NO;
    [instantAnswersView addSubview:instantAnswersTableView];
    [self.view addSubview:instantAnswersView];

    self.fieldsTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, titleView.bounds.size.height + textView.bounds.size.height, scrollView.bounds.size.width, 1000) style:UITableViewStyleGrouped] autorelease];
    self.fieldsTableView.backgroundView = nil;
    self.fieldsTableView.dataSource = self;
    self.fieldsTableView.delegate = self;
    self.fieldsTableView.scrollEnabled = NO;
    self.fieldsTableView.backgroundColor = [UIColor colorWithRed:0.94f green:0.95f blue:0.95f alpha:1.0f];
    self.fieldsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addTopBorder:fieldsTableView];
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
    self.fieldsTableView.tableFooterView = footer;
    [scrollView addSubview:fieldsTableView];

    [fieldsTableView reloadData];
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, titleView.bounds.size.height + textView.bounds.size.height + fieldsTableView.contentSize.height);

    self.nextButton = [self barButtonItem:@"Continue" withAction:@selector(nextButtonTapped)];
    self.sendButton = [self barButtonItem:@"Submit" withAction:@selector(createButtonTapped)];
    self.sendButton.style = UIBarButtonItemStyleDone;

    state = STATE_BEGIN;
    [self updateLayout];

    if (self.title && [self.title length] > 0) {
        self.instantAnswersQuery = self.title;
        [self loadInstantAnswers];
    }
    [titleField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
   [super viewWillAppear:animated];
   scrollView.contentInset = UIEdgeInsetsZero;
   scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
   scrollView.contentOffset = CGPointZero;
}

- (void)initNavigationItem {
    [super initNavigationItem];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(dismiss)] autorelease];
}

- (void)showActivityIndicator {
    if (!shade) {
        self.shade = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
        self.shade.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.shade.backgroundColor = [UIColor blackColor];
        self.shade.alpha = 0.5;
        [self.view addSubview:shade];
    }
    if (!activityIndicatorView) {
        self.activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        self.activityIndicatorView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4);
        self.activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        [self.view addSubview:activityIndicatorView];
    }
    shade.hidden = NO;
    activityIndicatorView.hidden = NO;
    [activityIndicatorView startAnimating];
}

- (void)hideActivityIndicator {
    [activityIndicatorView stopAnimating];
    activityIndicatorView.hidden = YES;
    shade.hidden = YES;
}

- (void)nextButtonTapped {
    if (state == STATE_BEGIN) {
        [self fireInstantAnswersTimer];
        if (loadingInstantAnswers)
            state = STATE_WAITING;
        else
            state = STATE_FIELDS;
    } else if (state == STATE_IA) {
        state = STATE_SHOW_IA;
    } else if (state == STATE_SHOW_IA) {
        state = STATE_FIELDS_IA;
    }
    [self updateLayout];
}

- (void)willLoadInstantAnswers {
    [self updateSpinnerAndXIn:instantAnswersMessage withToggle:(state == STATE_SHOW_IA) animated:YES];
}

- (void)didLoadInstantAnswers {
    BOOL found = [instantAnswers count] > 0;
    if (state == STATE_WAITING || state == STATE_SHOW_IA)
        state = found ? STATE_SHOW_IA : STATE_FIELDS;
    else if (found)
        state = (state == STATE_FIELDS) ? STATE_FIELDS_IA : STATE_IA;
    else
        state = (state == STATE_FIELDS_IA) ? STATE_FIELDS : STATE_BEGIN;
    [instantAnswersTableView reloadData];
    [self updateLayout];
}

- (void)instantAnswersMessageTapped {
    switch (state) {
    case STATE_IA:
        state = STATE_SHOW_IA;
        break;
    case STATE_SHOW_IA:
        state = STATE_FIELDS_IA;
        break;
    case STATE_FIELDS_IA:
        [emailField resignFirstResponder];
        state = STATE_SHOW_IA;
        break;
    }
    [self updateLayout];
}

- (void)keyboardDidShow:(NSNotification*)notification {
    [super keyboardDidShow:notification];
    [self updateLayout];
}

- (void)keyboardDidHide:(NSNotification*)notification {
    [super keyboardDidHide:notification];
    [self updateLayout];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self updateLayout];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
        [self dismissModalViewControllerAnimated:YES];
}

- (void)dismiss {
    if (titleField.text.length > 0) {
        UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"You have not posted your idea. Are you sure you want to lose your unsaved data?", @"UserVoice", nil)
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                      destructiveButtonTitle:NSLocalizedStringFromTable(@"OK", @"UserVoice", nil)
                                                           otherButtonTitles:nil] autorelease];
        [actionSheet showInView:self.view];
    } else {
        [self dismissModalViewControllerAnimated:YES];
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
    self.nextButton = nil;
    self.sendButton = nil;
    self.instantAnswersView = nil;
    self.instantAnswersMessage = nil;
    self.instantAnswersTableView = nil;
    self.fieldsTableView = nil;
    self.shade = nil;
    self.activityIndicatorView = nil;
    [super dealloc];
}

@end
