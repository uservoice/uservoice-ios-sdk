//
//  UVNewSuggestionIpadViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 11/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVNewSuggestionIpadViewController.h"
#import "UVClientConfig.h"

#define UV_NEW_SUGGESTION_SECTION_INSTANT_ANSWERS 0
#define UV_NEW_SUGGESTION_SECTION_PROFILE 1
#define UV_NEW_SUGGESTION_SECTION_CATEGORY 2

@implementation UVNewSuggestionIpadViewController

- (void)willLoadInstantAnswers {
    [tableView beginUpdates];
    int count = instantAnswersCount;
    instantAnswersCount = 0;
    if (showInstantAnswers) {
        [tableView deleteRowsAtIndexPaths:[self indexPathsForInstantAnswers:count] withRowAnimation:UITableViewRowAnimationFade];
    }
    if (showInstantAnswersMessage) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:UV_NEW_SUGGESTION_SECTION_INSTANT_ANSWERS]];
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
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:UV_NEW_SUGGESTION_SECTION_INSTANT_ANSWERS]] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else {
        if (showInstantAnswersMessage) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:UV_NEW_SUGGESTION_SECTION_INSTANT_ANSWERS]];
            [self updateSpinnerAndXIn:cell withToggle:showInstantAnswers animated:YES];
        } else {
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:UV_NEW_SUGGESTION_SECTION_INSTANT_ANSWERS]] withRowAnimation:UITableViewRowAnimationFade];
        }
        showInstantAnswersMessage = YES;
    }
    [tableView endUpdates];
}

- (NSMutableArray *)indexPathsForInstantAnswers:(int)count {
    NSMutableArray *instantAnswerIndexPaths = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        NSIndexPath *indexPath = [[NSIndexPath indexPathWithIndex:UV_NEW_SUGGESTION_SECTION_INSTANT_ANSWERS] indexPathByAddingIndex:i + 3];
        [instantAnswerIndexPaths addObject:indexPath];
    }
    return instantAnswerIndexPaths;
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

- (void)titleChanged:(NSNotification *)notification {
    [self searchInstantAnswers:titleField.text];

    if ([titleField.text length] != 0) {
        [self enableSubmitButton];
    } else {
        [self disableSubmitButton];
    }
}

#pragma mark ===== table cells =====

- (void)initCellForTitle:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    self.titleField = [self customizeTextFieldCell:cell label:NSLocalizedStringFromTable(@"Title", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"(required)", @"UserVoice", nil)];
    self.titleField.text = self.title;
    self.titleField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(titleChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:titleField];
    [titleField becomeFirstResponder];
}

- (void)initCellForText:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    self.textView = [[[UVTextView alloc] initWithFrame:CGRectMake(IOS7 ? 12 : 0, 0, cell.bounds.size.width - 14, 144)] autorelease];
    textView.delegate = self;
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textView.autocorrectionType = UITextAutocorrectionTypeYes;
    textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    textView.backgroundColor = [UIColor clearColor];
    textView.placeholder = NSLocalizedStringFromTable(@"Description (optional)", @"UserVoice", nil);
    textView.text = self.text;
    [cell.contentView addSubview:textView];
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
    [self customizeCellForInstantAnswer:cell index:indexPath.row - 3];
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    BOOL selectable = NO;

    switch (indexPath.section) {
        case UV_NEW_SUGGESTION_SECTION_INSTANT_ANSWERS:
            if (indexPath.row == 0) {
                identifier = @"Title";
            } else if (indexPath.row == 1) {
                identifier = @"Text";
            } else if (indexPath.row == 2) {
                identifier = @"InstantAnswersMessage";
                selectable = YES;
            } else {
                identifier = @"InstantAnswer";
                selectable = YES;
            }
            break;
        case UV_NEW_SUGGESTION_SECTION_PROFILE:
            if (indexPath.row == 0)
                identifier = @"Email";
            else
                identifier = @"Name";
            break;
        case UV_NEW_SUGGESTION_SECTION_CATEGORY:
            identifier = @"Category";
            style = UITableViewCellStyleValue1;
            selectable = YES;
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
    if (section == UV_NEW_SUGGESTION_SECTION_PROFILE) {
        return 2;
    } else if (section == UV_NEW_SUGGESTION_SECTION_INSTANT_ANSWERS) {
        return 2 + (showInstantAnswersMessage ? 1 : 0) + (showInstantAnswers ? instantAnswersCount : 0);
    } else if (section == UV_NEW_SUGGESTION_SECTION_CATEGORY) {
        return (shouldShowCategories ? 1 : 0);
    } else {
        return 1;
    }
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == UV_NEW_SUGGESTION_SECTION_INSTANT_ANSWERS && indexPath.row == 1) {
        return 144;
    } else if (indexPath.section == UV_NEW_SUGGESTION_SECTION_INSTANT_ANSWERS && indexPath.row != 0) {
        return 44;
    } else {
        return 62;
    }
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == UV_NEW_SUGGESTION_SECTION_CATEGORY) {
        [self pushCategorySelectView];
    } else if (indexPath.section == UV_NEW_SUGGESTION_SECTION_INSTANT_ANSWERS) {
        if (indexPath.row == 2) {
            [self toggleInstantAnswers:indexPath];
        } else if (indexPath.row > 2) {
            [self selectInstantAnswerAtIndex:indexPath.row - 3];
        }
    }
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [super loadView];
    self.navigationItem.title = NSLocalizedStringFromTable(@"Post Idea", @"UserVoice", nil);
    [self setupGroupedTableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.sectionFooterHeight = 0.0;
    self.navigationItem.rightBarButtonItem = [self barButtonItem:NSLocalizedStringFromTable(@"Submit", @"UserVoice", nil) withAction:@selector(createButtonTapped)];
    self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;

    if (self.title && [self.title length] > 0) {
        [self enableSubmitButton];
        self.instantAnswersQuery = self.title;
        [self loadInstantAnswers];
    } else {
        [self disableSubmitButton];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (needsReload)
        [tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [titleField becomeFirstResponder];
}

@end
