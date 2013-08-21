//
//  UVNewTicketViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVNewTicketIpadViewController.h"
#import "UVNewTicketViewController.h"
#import "UVStylesheet.h"
#import "UVSession.h"
#import "UVCustomField.h"
#import "UVUser.h"
#import "UVClientConfig.h"
#import "UVTicket.h"
#import "UVForum.h"
#import "UVKeyboardUtils.h"

@implementation UVNewTicketViewController

@synthesize scrollView;
@synthesize messageTextView;
@synthesize instantAnswersView;
@synthesize instantAnswersMessage;
@synthesize instantAnswersTableView;
@synthesize fieldsTableView;
@synthesize nextButton;
@synthesize sendButton;

#define STATE_BEGIN 1000
#define STATE_IA 1001
#define STATE_SHOW_IA 1002
#define STATE_FIELDS 1003
#define STATE_FIELDS_IA 1004
#define STATE_WAITING 1005

#define SECTION_PROFILE 0
#define SECTION_FIELDS 1

+ (UVBaseViewController *)viewController {
    return [self viewControllerWithText:nil];
}

+ (UVBaseViewController *)viewControllerWithText:(NSString *)text {
    if (IPAD) {
        return [[[UVNewTicketIpadViewController alloc] initWithText:text] autorelease];
    } else {
        return [[[UVNewTicketViewController alloc] initWithText:text] autorelease];
    }
}

- (void)loadView {
    [super loadView];
    self.navigationItem.title = NSLocalizedStringFromTable(@"Contact Us", @"UserVoice", nil);

    self.scrollView = [[[UIScrollView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.view = scrollView;

    self.messageTextView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height - 280)] autorelease];
    self.textView = [[[UVTextView alloc] initWithFrame:messageTextView.bounds] autorelease];
    self.textView.text = self.text;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.textView.placeholder = NSLocalizedStringFromTable(@"How can we help you today?", @"UserVoice", nil);
    self.textView.delegate = self;
    [messageTextView addSubview:self.textView];
    [self.view addSubview:messageTextView];

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
    
    self.fieldsTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 200, 320, 1000) style:UITableViewStyleGrouped] autorelease];
    self.fieldsTableView.rowHeight = 62;
    self.fieldsTableView.backgroundView = nil;
    self.fieldsTableView.dataSource = self;
    self.fieldsTableView.delegate = self;
    self.fieldsTableView.scrollEnabled = NO;
    self.fieldsTableView.backgroundColor = [UIColor colorWithRed:0.94f green:0.95f blue:0.95f alpha:1.0f];
    fieldsTableView.hidden = YES;
    [self addTopBorder:fieldsTableView];
    [self.view addSubview:fieldsTableView];

    self.nextButton = [self barButtonItem:NSLocalizedStringFromTable(@"Continue", @"UserVoice", nil) withAction:@selector(nextButtonTapped)];
    self.sendButton = [self barButtonItem:NSLocalizedStringFromTable(@"Send", @"UserVoice", nil) withAction:@selector(sendButtonTapped)];
    self.sendButton.style = UIBarButtonItemStyleDone;

    state = STATE_BEGIN;
    [textView becomeFirstResponder];
    [self updateLayout];

    if (self.text && [self.text length] > 0) {
        self.instantAnswersQuery = self.text;
        [self loadInstantAnswers];
    }
}

- (void)nextButtonTapped {
    if (state == STATE_BEGIN) {
        [self fireInstantAnswersTimer];
        if (loadingInstantAnswers)
            state = STATE_WAITING;
        else
            state = STATE_FIELDS;
    } else if (state == STATE_IA) {
        state = [UVKeyboardUtils visible] ? STATE_SHOW_IA : STATE_FIELDS_IA;
    } else if (state == STATE_SHOW_IA) {
        state = STATE_FIELDS_IA;
    }
    [self updateLayout];
}

- (void)dismissKeyboard {
    [emailField becomeFirstResponder];
    [emailField resignFirstResponder];
}

- (void)textViewDidChange:(UVTextView *)theTextEditor {
    [super textViewDidChange:theTextEditor];
    
    if ([theTextEditor.text length] != 0 && state != STATE_WAITING) {
        [self enableSubmitButton];
    } else {
        [self disableSubmitButton];
    }
}

- (void)reloadCustomFieldsTable {
    [fieldsTableView reloadData];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGPoint offset = [textField convertPoint:CGPointMake(0, -scrollView.contentInset.top) toView:scrollView];
    offset.x = 0;
    offset.y -= 20;
    offset.y = MIN(offset.y, MAX(0, scrollView.contentSize.height + [UVKeyboardUtils height] - scrollView.bounds.size.height));
    [scrollView setContentOffset:offset animated:YES];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [scrollView setContentOffset:CGPointMake(0, -scrollView.contentInset.top) animated:YES];
    return YES;
}

- (void)textViewDidBeginEditing:(UVTextView *)theTextEditor {
    if ([instantAnswers count] == 0)
        state = STATE_BEGIN;
    else
        state = STATE_IA;
    [self updateLayout];
    [scrollView setContentOffset:CGPointMake(0, -scrollView.contentInset.top) animated:YES];
}

- (void)instantAnswersMessageTapped {
    switch (state) {
    case STATE_IA:
        state = [UVKeyboardUtils visible] ? STATE_SHOW_IA : STATE_FIELDS_IA;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    if (theTableView == fieldsTableView)
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    if (theTableView == fieldsTableView) {
        if (section == SECTION_PROFILE)
            return 2;
        else
            return [[UVSession currentSession].clientConfig.customFields count];
    } else {
        return [instantAnswers count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    BOOL selectable = NO;

    if (theTableView == fieldsTableView) {
        if (indexPath.section == SECTION_PROFILE) {
            if (indexPath.row == 0)
                identifier = @"Email";
            else
                identifier = @"Name";
        } else if (indexPath.section == SECTION_FIELDS) {
            identifier = @"CustomField";
            style = UITableViewCellStyleValue1;
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

- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [self customizeCellForInstantAnswer:cell index:indexPath.row];
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (theTableView == fieldsTableView) {
        if (indexPath.section == SECTION_FIELDS)
            [self selectCustomFieldAtIndexPath:indexPath tableView:theTableView];
    } else {
        [self selectInstantAnswerAtIndex:indexPath.row];
    }
}

- (void)updateLayout {
    BOOL showTextView = state == STATE_BEGIN || state == STATE_IA || state == STATE_WAITING;
    BOOL showIAMessage = state == STATE_IA || state == STATE_SHOW_IA || state == STATE_FIELDS_IA;
    BOOL showIATable = state == STATE_SHOW_IA;
    BOOL showFieldsTable = state == STATE_FIELDS || state == STATE_FIELDS_IA;
    BOOL landscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);

    if (showTextView)
        [textView becomeFirstResponder];
    else
        [textView resignFirstResponder];

    CGFloat sH = [UIScreen mainScreen].bounds.size.height;
    CGFloat sW = [UIScreen mainScreen].bounds.size.width;
    CGFloat kbP = 280;
    CGFloat kbL = 214;

    CGRect textViewRect = landscape ?
        CGRectMake(0, 0, sH, sW - kbL) :
        CGRectMake(0, 0, sW, sH - kbP);

    if (showIAMessage)
        textViewRect.size.height -= 40;

    CGPoint instantAnswersOrigin = CGPointMake(0, textViewRect.size.height);
    CGPoint fieldsTableOrigin = CGPointMake(0, showFieldsTable ? instantAnswersOrigin.y + (showIAMessage ? 40 : 0) : sH);

    if (state == STATE_BEGIN && ![UVKeyboardUtils visible])
        instantAnswersOrigin.y = sH;

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
    
    if (!(showTextView && [self.text length] == 0) && state != STATE_WAITING) {
        [self enableSubmitButton];
    } else {
        [self disableSubmitButton];
    }

    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, textViewRect.size.height + (showIAMessage ? 40 : 0) + (showIATable ? instantAnswersTableView.contentSize.height : 0) + (showFieldsTable ? fieldsTableView.contentSize.height : 0));

    [self updateSpinnerAndXIn:instantAnswersMessage withToggle:(state == STATE_SHOW_IA || (state == STATE_IA && ![UVKeyboardUtils visible])) animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        messageTextView.frame = textViewRect;
        instantAnswersView.frame = CGRectMake(instantAnswersOrigin.x, instantAnswersOrigin.y, textViewRect.size.width, instantAnswersTableView.frame.origin.y + instantAnswersTableView.frame.size.height);
        fieldsTableView.frame = CGRectMake(fieldsTableOrigin.x, fieldsTableOrigin.y, textViewRect.size.width, fieldsTableView.bounds.size.height);
    } completion:^(BOOL finished) {
        if (showTextView)
            [textView scrollRangeToVisible:[textView selectedRange]];
        else
            [textView scrollRangeToVisible:NSMakeRange(0, 0)];
        if (!showFieldsTable)
            fieldsTableView.hidden = YES;
    }];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self updateLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!IOS7) {
        scrollView.contentInset = UIEdgeInsetsZero;
        scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
        scrollView.contentOffset = CGPointZero;
    }
}

- (void)dealloc {
    self.scrollView = nil;
    self.messageTextView = nil;
    self.instantAnswersView = nil;
    self.instantAnswersMessage = nil;
    self.instantAnswersTableView = nil;
    self.fieldsTableView = nil;
    self.nextButton = nil;
    self.sendButton = nil;
    [super dealloc];
}

@end
