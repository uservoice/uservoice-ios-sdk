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

+ (UIViewController *)viewController {
    return [self viewControllerWithText:@""];
}

+ (UIViewController *)viewControllerWithText:(NSString *)text {
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

    self.instantAnswersView = [[[UIView alloc] initWithFrame:CGRectMake(0, 200, 320, 50)] autorelease];
    self.instantAnswersMessage = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
    self.instantAnswersMessage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [instantAnswersMessage addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(instantAnswersMessageTapped)] autorelease]];
    UILabel *instantAnswersLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 6, 250, 30)] autorelease];
    instantAnswersLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    instantAnswersLabel.tag = TICKET_VIEW_IA_LABEL_TAG;
    instantAnswersLabel.numberOfLines = 2;
    instantAnswersLabel.textColor = [UIColor grayColor];
    instantAnswersLabel.font = [UIFont systemFontOfSize:11];
    instantAnswersLabel.backgroundColor = [UIColor clearColor];
    instantAnswersLabel.textAlignment = UITextAlignmentLeft;
    [instantAnswersMessage addSubview:instantAnswersLabel];
    [self addSpinnerAndArrowTo:instantAnswersMessage atCenter:CGPointMake(320 - 22, 20)];
    [instantAnswersView addSubview:instantAnswersMessage];
    UIView *border = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)] autorelease];
    border.backgroundColor = [UIColor colorWithRed:0.76f green:0.76f blue:0.76f alpha:1.0f];
    border.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [instantAnswersView addSubview:border];
    self.instantAnswersTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, 100) style:UITableViewStyleGrouped] autorelease];
    self.instantAnswersTableView.backgroundView = nil;
    self.instantAnswersTableView.backgroundColor = [UIColor clearColor];
    self.instantAnswersTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.instantAnswersTableView.dataSource = self;
    self.instantAnswersTableView.delegate = self;
    self.instantAnswersTableView.scrollEnabled = NO;

    // IA footer
    UIView *iaFooter = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, instantAnswersTableView.bounds.size.width, 90)] autorelease];
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, instantAnswersTableView.bounds.size.width, 15)] autorelease];
    label.text = NSLocalizedStringFromTable(@"Do any of these answer your question?", @"UserVoice", nil);
    label.font = [UIFont boldSystemFontOfSize:13];
    [iaFooter addSubview:label];

    UIView *container = [[[UIView alloc] initWithFrame:CGRectMake(10, 35, 145, 55)] autorelease];
    container.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 0, container.bounds.size.width, 35);
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [button setTitle:NSLocalizedStringFromTable(@"Thanks!", @"UserVoice", nil) forState:UIControlStateNormal];
    [container addSubview:button];
    label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 36, container.bounds.size.width, 15)] autorelease];
    label.textAlignment = UITextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.text = NSLocalizedStringFromTable(@"I found what I was looking for!", @"UserVoice", nil);
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = [UIColor grayColor];
    [container addSubview:label];
    [iaFooter addSubview:container];

    container = [[[UIView alloc] initWithFrame:CGRectMake(165, 35, 145, 55)] autorelease];
    container.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 0, container.bounds.size.width, 35);
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [button setTitle:NSLocalizedStringFromTable(@"Not helpful", @"UserVoice", nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(notInterestedTapped) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:button];
    label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 36, container.bounds.size.width, 15)] autorelease];
    label.textAlignment = UITextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.text = NSLocalizedStringFromTable(@"I still need to contact you", @"UserVoice", nil);
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = [UIColor grayColor];
    [container addSubview:label];
    [iaFooter addSubview:container];

    self.instantAnswersTableView.tableFooterView = iaFooter;
    [instantAnswersView addSubview:instantAnswersTableView];
    [self.view addSubview:instantAnswersView];
    
    self.fieldsTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 200, 320, 100) style:UITableViewStyleGrouped] autorelease];
    self.fieldsTableView.backgroundView = nil;
    self.fieldsTableView.dataSource = self;
    self.fieldsTableView.delegate = self;
    self.fieldsTableView.scrollEnabled = NO;
    self.fieldsTableView.backgroundColor = [UIColor whiteColor];
    fieldsTableView.hidden = YES;
    border = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)] autorelease];
    border.backgroundColor = [UIColor colorWithRed:0.76f green:0.76f blue:0.76f alpha:1.0f];
    border.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [fieldsTableView addSubview:border];

    UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, fieldsTableView.bounds.size.width, 50)] autorelease];
    label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 10, fieldsTableView.bounds.size.width, 15)] autorelease];
    label.text = NSLocalizedStringFromTable(@"Want to suggest an idea instead?", @"UserVoice", nil);
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UVStyleSheet linkTextColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:13];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [footer addSubview:label];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 25, 320, 15);
    [button setTitle:[[UVSession currentSession].clientConfig.forum prompt] forState:UIControlStateNormal];
    [button setTitleColor:[UVStyleSheet linkTextColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.showsTouchWhenHighlighted = YES;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [button addTarget:self action:@selector(suggestionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    button.center = CGPointMake(footer.center.x, button.center.y);
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [footer addSubview:button];
    self.fieldsTableView.tableFooterView = footer;
    [self.view addSubview:fieldsTableView];
    
    self.nextButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Next", @"UserVoice", nil)
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(nextButtonTapped)] autorelease];

    self.sendButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Send", @"UserVoice", nil)
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(sendButtonTapped)] autorelease];

    state = STATE_BEGIN;
    [textView becomeFirstResponder];
    [self updateLayout];
}

- (void)notInterestedTapped {
    state = STATE_FIELDS_IA;
    [self updateLayout];
}

- (void)nextButtonTapped {
    if (state == STATE_BEGIN) {
        if (timer) {
            [timer fire];
            [timer invalidate];
            self.timer = nil;
        }
        if (loadingInstantAnswers)
            state = STATE_WAITING;
        else
            state = STATE_FIELDS;
    } else if (state == STATE_IA) {
        state = STATE_SHOW_IA;
    }
    [self updateLayout];
}

- (void)dismissKeyboard {
    [emailField becomeFirstResponder];
    [emailField resignFirstResponder];
}

- (void)textViewDidChange:(UVTextView *)theTextEditor {
    [super textViewDidChange:theTextEditor];
    self.navigationItem.rightBarButtonItem = [theTextEditor.text length] == 0 ? nil : nextButton;
}

- (void)reloadCustomFieldsTable {
    [fieldsTableView reloadData];
}

- (void)willLoadInstantAnswers {
    [self updateSpinnerAndArrowIn:instantAnswersMessage withToggle:(state == STATE_SHOW_IA) animated:YES];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CGPoint offset = [textField convertPoint:CGPointZero toView:scrollView];
    offset.x = 0;
    offset.y -= 20;
    [scrollView setContentOffset:offset animated:YES];
    return YES;
}

- (void)textViewDidBeginEditing:(UVTextView *)theTextEditor {
    if ([instantAnswers count] == 0)
        state = STATE_BEGIN;
    else
        state = STATE_IA;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    if (theTableView == fieldsTableView)
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    if (theTableView == fieldsTableView) {
        if (section == SECTION_PROFILE)
            return [self signedIn] ? 0 : 1;
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
            identifier = @"Email";
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

    BOOL keyboardHidden = ![UVKeyboardUtils visible];
    CGFloat sH = [UIScreen mainScreen].bounds.size.height;
    CGFloat sW = [UIScreen mainScreen].bounds.size.width;
    CGFloat kbP = keyboardHidden ? 64 : 280;
    CGFloat kbL = keyboardHidden ? 64 : 214;

    CGRect textViewRect = landscape ?
        CGRectMake(0, 0, sH, showTextView ? (sW - kbL) : 50) :
        CGRectMake(0, 0, sW, showTextView ? (sH - kbP) : 60);

    if (showTextView && showIAMessage)
        textViewRect.size.height -= 40;

    CGPoint instantAnswersOrigin = CGPointMake(0, textViewRect.size.height);
    CGPoint fieldsTableOrigin = CGPointMake(0, showFieldsTable ? instantAnswersOrigin.y + (showIAMessage ? 40 : 0) : sH);

    instantAnswersView.hidden = !showIAMessage;
    if (showIATable)
        instantAnswersTableView.hidden = NO;
    if (showFieldsTable)
        fieldsTableView.hidden = NO;

    if (state == STATE_WAITING)
        [self showActivityIndicator];
    else
        [self hideActivityIndicator];

    if (showTextView)
        self.navigationItem.rightBarButtonItem = [textView.text length] == 0 ? nil : nextButton;
    else if (showIATable)
        self.navigationItem.rightBarButtonItem = nil;
    else
        self.navigationItem.rightBarButtonItem = sendButton;
    
    fieldsTableView.frame = CGRectMake(fieldsTableView.frame.origin.x, fieldsTableView.frame.origin.y, fieldsTableView.frame.size.width, fieldsTableView.contentSize.height);
    instantAnswersTableView.frame = CGRectMake(instantAnswersTableView.frame.origin.x, instantAnswersTableView.frame.origin.y, instantAnswersTableView.frame.size.width, instantAnswersTableView.contentSize.height);
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, textViewRect.size.height + (showIAMessage ? 40 : 0) + (showIATable ? instantAnswersTableView.frame.size.height : 0) + (showFieldsTable ? fieldsTableView.frame.size.height : 0));

    [self updateSpinnerAndArrowIn:instantAnswersMessage withToggle:(state == STATE_SHOW_IA) animated:YES];
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
        if (!showIATable)
            instantAnswersTableView.hidden = YES;
    }];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self updateLayout];
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
