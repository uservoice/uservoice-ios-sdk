//
//  UVNewTicketViewIpadController.m
//  UserVoice
//
//  Created by UserVoice on 2/19/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVNewTicketIpadViewController.h"
#import "UVStyleSheet.h"
#import "UVCustomField.h"
#import "UVSession.h"
#import "UVUser.h"
#import "UVClientConfig.h"
#import "UVCustomFieldValueSelectViewController.h"
#import "UVClientConfig.h"
#import "UVTicket.h"
#import "UVForum.h"
#import "UVSubdomain.h"
#import "UVTextView.h"
#import "UVArticle.h"
#import "UVSuggestion.h"
#import "UVArticleViewController.h"
#import "UVSuggestionDetailsViewController.h"
#import "UVConfig.h"

#define UV_NEW_TICKET_SECTION_INSTANT_ANSWERS 0
#define UV_NEW_TICKET_SECTION_PROFILE 1
#define UV_NEW_TICKET_SECTION_CUSTOM_FIELDS 2

@implementation UVNewTicketIpadViewController

- (void)dismissKeyboard {
    [textView becomeFirstResponder];
    [textView resignFirstResponder];
}

- (void)willLoadInstantAnswers {
    [tableView beginUpdates];
    int count = instantAnswersCount;
    instantAnswersCount = 0;
    if (showInstantAnswers) {
        [tableView deleteRowsAtIndexPaths:[self indexPathsForInstantAnswers:count] withRowAnimation:UITableViewRowAnimationFade];
    }
    if (showInstantAnswersMessage) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:UV_NEW_TICKET_SECTION_INSTANT_ANSWERS]];
        [self updateSpinnerAndXIn:cell withToggle:showInstantAnswers animated:YES];
    }
    [tableView endUpdates];
}

- (void)didLoadInstantAnswers {
    [tableView beginUpdates];
    if (showInstantAnswers) {
        [tableView deleteRowsAtIndexPaths:[self indexPathsForInstantAnswers:instantAnswersCount] withRowAnimation:UITableViewRowAnimationFade];
    }
    instantAnswersCount = [instantAnswers count];
    showInstantAnswers = YES;
    if (showInstantAnswers) {
        [tableView insertRowsAtIndexPaths:[self indexPathsForInstantAnswers:instantAnswersCount] withRowAnimation:UITableViewRowAnimationFade];
    }
    if (instantAnswersCount == 0) {
        if (showInstantAnswersMessage) {
            showInstantAnswersMessage = NO;
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:UV_NEW_TICKET_SECTION_INSTANT_ANSWERS]] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else {
        if (showInstantAnswersMessage) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:UV_NEW_TICKET_SECTION_INSTANT_ANSWERS]];
            [self updateSpinnerAndXIn:cell withToggle:showInstantAnswers animated:YES];
        } else {
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:UV_NEW_TICKET_SECTION_INSTANT_ANSWERS]] withRowAnimation:UITableViewRowAnimationFade];
        }
        showInstantAnswersMessage = YES;
    }
    [tableView endUpdates];
}

- (void)textViewDidChange:(UVTextView *)theTextEditor {
    [super textViewDidChange:theTextEditor];
    
    if ([theTextEditor.text length] != 0) {
        [self enableSubmitButton];
    } else {
        [self disableSubmitButton];
    }
}

#pragma mark ===== table cells =====

- (void)initCellForText:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    self.textView = [[[UVTextView alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, 144)] autorelease];
    textView.delegate = self;
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textView.autocorrectionType = UITextAutocorrectionTypeYes;
    textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    textView.backgroundColor = [UIColor clearColor];
    textView.placeholder = NSLocalizedStringFromTable(@"Message", @"UserVoice", nil);
    textView.text = self.text;
    [cell.contentView addSubview:textView];
    [textView becomeFirstResponder];
}

- (void)initCellForInstantAnswersMessage:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithRed:0.95f green:0.98f blue:1.00f alpha:1.0f];

    CGFloat margin = 35;
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(margin, 1, cell.bounds.size.width - margin*2, 40)] autorelease];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.tag = TICKET_VIEW_IA_LABEL_TAG;
    label.font = [UIFont systemFontOfSize:15];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 2;
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0.20f green:0.31f blue:0.52f alpha:1.0f];
    [cell addSubview:label];

    [self addSpinnerAndXTo:cell atCenter:CGPointMake(cell.bounds.size.width - margin - 20, 22)];
}

- (void)customizeCellForInstantAnswersMessage:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [self updateSpinnerAndXIn:cell withToggle:showInstantAnswers animated:NO];
}

- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [self customizeCellForInstantAnswer:cell index:indexPath.row - 2];
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
            if (indexPath.row == 0) {
                identifier = @"Text";
            } else if (indexPath.row == 1) {
                identifier = @"InstantAnswersMessage";
                selectable = YES;
            } else {
                identifier = @"InstantAnswer";
                selectable = YES;
            }
            break;
        case UV_NEW_TICKET_SECTION_PROFILE:
            if (indexPath.row == 0)
                identifier = @"Email";
            else
                identifier = @"Name";
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
        return 2;
    } else if (section == UV_NEW_TICKET_SECTION_INSTANT_ANSWERS) {
        return 1 + (showInstantAnswersMessage ? 1 : 0) + (showInstantAnswers ? instantAnswersCount : 0);
    } else if (section == UV_NEW_TICKET_SECTION_CUSTOM_FIELDS) {
        return [[UVSession currentSession].clientConfig.customFields count];
    } else {
        return 1;
    }
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == UV_NEW_TICKET_SECTION_INSTANT_ANSWERS && indexPath.row == 0) {
        return 144;
    } else if (indexPath.section == UV_NEW_TICKET_SECTION_CUSTOM_FIELDS || indexPath.section == UV_NEW_TICKET_SECTION_PROFILE) {
        return 62;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == UV_NEW_TICKET_SECTION_CUSTOM_FIELDS) {
        [self selectCustomFieldAtIndexPath:indexPath tableView:theTableView];
    } else if (indexPath.section == UV_NEW_TICKET_SECTION_INSTANT_ANSWERS) {
        if (indexPath.row == 1) {
            [self toggleInstantAnswers:indexPath];
        } else {
            [self selectInstantAnswerAtIndex:indexPath.row - 2];
        }
    }
}

- (void)toggleInstantAnswers:(NSIndexPath *)indexPath {
    showInstantAnswers = !showInstantAnswers;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self updateSpinnerAndXIn:cell withToggle:showInstantAnswers animated:YES];
    NSMutableArray *instantAnswerIndexPaths = [self indexPathsForInstantAnswers:instantAnswersCount];
    if (showInstantAnswers) {
        [tableView insertRowsAtIndexPaths:instantAnswerIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [tableView deleteRowsAtIndexPaths:instantAnswerIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSMutableArray *)indexPathsForInstantAnswers:(int)count {
    NSMutableArray *instantAnswerIndexPaths = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        NSIndexPath *indexPath = [[NSIndexPath indexPathWithIndex:UV_NEW_TICKET_SECTION_INSTANT_ANSWERS] indexPathByAddingIndex:i + 2];
        [instantAnswerIndexPaths addObject:indexPath];
    }
    return instantAnswerIndexPaths;
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [super loadView];
    self.navigationItem.title = NSLocalizedStringFromTable(@"Contact Us", @"UserVoice", nil);
    [self setupGroupedTableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.sectionFooterHeight = 0.0;
    self.navigationItem.rightBarButtonItem = [self barButtonItem:NSLocalizedStringFromTable(@"Send", @"UserVoice", nil) withAction:@selector(sendButtonTapped)];
    self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
    
    if ([self.text length] != 0) {
        [self enableSubmitButton];
    } else {
        [self disableSubmitButton];
    }

    if (self.text && [self.text length] > 0) {
        self.instantAnswersQuery = self.text;
        [self loadInstantAnswers];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [textView becomeFirstResponder];
}

@end
