//
//  UVSuggestionListViewController.m
//  UserVoice
//
//  Created by UserVoice on 10/22/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVSuggestionListViewController.h"
#import "UVClientConfig.h"
#import "UVSession.h"
#import "UVSuggestion.h"
#import "UVSuggestionDetailsViewController.h"
#import "UVNewSuggestionViewController.h"
#import "UVProfileViewController.h"
#import "UVInfoViewController.h"
#import "UVStyleSheet.h"
#import "UVUser.h"
#import "UVCellViewWithIndex.h"
#import "UVSuggestionButton.h"

#define SUGGESTIONS_PAGE_SIZE 10
#define UV_SEARCH_TEXTBAR 1
#define UV_SEARCH_SHADE 2
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_PREFIX 100
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_QUERY 101
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_SUFFIX 102
#define UV_BASE_GROUPED_CELL_BG 103
#define UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND 104

@implementation UVSuggestionListViewController

@synthesize forum = _forum;
@synthesize textEditor = _textEditor;
@synthesize suggestions;

- (id)initWithForum:(UVForum *)theForum {
    if ((self = [super init])) {
        if (theForum.suggestions) {
            self = [self initWithForum:theForum andSuggestions:theForum.suggestions];
        } else {
            self.forum = theForum;
        }
        _searching = NO;
    }
    return self;
}

- (id)initWithForum:(UVForum *)theForum andSuggestions:(NSArray *)theSuggestions {
    if ((self = [super init])) {
        self.suggestions = [NSMutableArray arrayWithArray:theSuggestions];
        self.forum = theForum;
        _searching = NO;
    }
    return self;
}

- (NSString *)backButtonTitle {
    return NSLocalizedStringFromTable(@"Ideas", @"UserVoice", nil);
}

- (void)retrieveMoreSuggestions {
    NSInteger page = ([self.suggestions count] / SUGGESTIONS_PAGE_SIZE) + 1;
    [self showActivityIndicator];
    [UVSuggestion getWithForum:self.forum page:page delegate:self];
}

// Populates the suggestions. The default implementation retrieves the 10 most recent
// suggestions, but this can be overridden in subclasses (e.g. for profile idea view).
- (void)populateSuggestions {
    self.suggestions = [NSMutableArray arrayWithCapacity:10];
    [UVSession currentSession].clientConfig.forum.suggestions = [NSMutableArray arrayWithCapacity:10];
    [UVSession currentSession].clientConfig.forum.suggestionsNeedReload = NO;
    [self retrieveMoreSuggestions];
}

- (void)didRetrieveSuggestions:(NSArray *)theSuggestions {
    [self hideActivityIndicator];
    if ([theSuggestions count] > 0) {
        [self.suggestions addObjectsFromArray:theSuggestions];
    }

    [[UVSession currentSession].clientConfig.forum.suggestions addObjectsFromArray:theSuggestions];
    [self.tableView reloadData];
}

- (void)didSearchSuggestions:(NSArray *)theSuggestions {
    [self.suggestions removeAllObjects];
    [self hideActivityIndicator];
    if ([theSuggestions count] > 0) {
        [self.suggestions addObjectsFromArray:theSuggestions];
    }
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:[theSuggestions count]];
    for (UVSuggestion *suggestion in theSuggestions) {
        [ids addObject:[NSNumber numberWithInt:suggestion.suggestionId]];
    }
    [[UVSession currentSession] trackInteraction:[theSuggestions count] > 0 ? @"rip" : @"riz" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[theSuggestions count]], @"count", ids, @"ids", nil]];

    [self.tableView reloadData];
}

- (BOOL)supportsSearch {
    return YES;
}

- (void)addSuggestion:(UVCellViewWithIndex *)cellView {
    UVNewSuggestionViewController *next = [[UVNewSuggestionViewController alloc] initWithForum:self.forum
                                                                                         title:_textEditor.text];
    [self.navigationController pushViewController:next animated:YES];
    [next release];
    [self dismissTextEditor];
}

#pragma mark ===== UITableViewDataSource Methods =====

// Overridden from superclass. In this case the Extra cell is responsible for
// creating a new suggestion.
- (void)initCellForAdd:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    // getting the cell size
    UVCellViewWithIndex *cellView = [[UVCellViewWithIndex alloc] initWithIndex:indexPath.row];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    UIFont *font = [UIFont boldSystemFontOfSize:18];
    UILabel *label = [[UILabel alloc] init];
    label.tag = UV_SEARCH_RESULTS_TAG_CELL_ADD_PREFIX;
    label.text = [NSString stringWithFormat:@"%@ \"", NSLocalizedStringFromTable(@"Add", @"UserVoice", nil)];
    label.font = font;
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UVStyleSheet primaryTextColor];
    label.backgroundColor = [UIColor clearColor];
    [cellView addSubview:label];
    [label release];

    label = [[UILabel alloc] init];
    label.tag = UV_SEARCH_RESULTS_TAG_CELL_ADD_QUERY;
    label.text = _textEditor.text;
    label.font = font;
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UVStyleSheet linkTextColor];
    label.backgroundColor = [UIColor clearColor];
    [cellView addSubview:label];
    [label release];

    label = [[UILabel alloc] init];
    label.tag = UV_SEARCH_RESULTS_TAG_CELL_ADD_SUFFIX;
    label.text = @"\"";
    label.font = font;
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UVStyleSheet primaryTextColor];
    label.backgroundColor = [UIColor clearColor];
    [cellView addSubview:label];
    [label release];

    [cell.contentView addSubview:cellView];
    [cellView release];
}

- (void)customizeCellForAdd:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundView.backgroundColor = [UVStyleSheet zebraBgColor:(indexPath.row % 2 == 0)];

    UIFont *font = [UIFont boldSystemFontOfSize:18];
    NSString *text = [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedStringFromTable(@"Add", @"UserVoice", nil), _textEditor.text];
    CGSize size = [text sizeWithFont:font forWidth:260 lineBreakMode:UILineBreakModeTailTruncation];
    CGFloat startX = 30.0 + ((260.0 - size.width) / 2.0);

    // Prefix: Add "
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:UV_SEARCH_RESULTS_TAG_CELL_ADD_PREFIX];
    size = [label.text sizeWithFont:font forWidth:260 lineBreakMode:UILineBreakModeTailTruncation];
    label.frame = CGRectMake(startX, 26, size.width, 20);

    // Query
    NSInteger prevEndX = label.frame.origin.x + label.frame.size.width;
    CGFloat maxWidth = 260 - (size.width + 10);
    label = (UILabel *)[cell.contentView viewWithTag:UV_SEARCH_RESULTS_TAG_CELL_ADD_QUERY];
    label.text = _textEditor.text;
    label.textColor = [UVStyleSheet linkTextColor];
    size = [label.text sizeWithFont:font forWidth:maxWidth lineBreakMode:UILineBreakModeTailTruncation];
    label.frame = CGRectMake(prevEndX, 26, size.width, 20);

    // Suffix: "
    prevEndX = label.frame.origin.x + label.frame.size.width;
    label = (UILabel *)[cell.contentView viewWithTag:UV_SEARCH_RESULTS_TAG_CELL_ADD_SUFFIX];
    label.frame = CGRectMake(prevEndX-1, 26, 10, 20);
}

- (void)initCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVSuggestionButton *button = [[UVSuggestionButton alloc] initWithIndex:indexPath.row];

    button.tag = UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND;
    [cell.contentView addSubview:button];
    [button release];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)customizeCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVSuggestion *suggestion = [[self suggestions] objectAtIndex:(_searching ? indexPath.row-1 : indexPath.row)];
    UVSuggestionButton *button = (UVSuggestionButton *)[cell.contentView viewWithTag:UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND];
    [button setZebraColorFromIndex:indexPath.row];
    [button showSuggestion:suggestion withIndex:indexPath.row];
}

- (void)initCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    CGFloat screenWidth = [UVClientConfig getScreenWidth];
    UVCellViewWithIndex *cellView = [[UVCellViewWithIndex alloc] initWithIndex:indexPath.row];
    [cellView setZebraColorFromIndex:indexPath.row];

    // Can't use built-in textLabel, as this forces a white background
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, screenWidth, 20)];
    textLabel.text = NSLocalizedStringFromTable(@"Load more ideas...", @"UserVoice", nil);
    textLabel.textColor = [UVStyleSheet primaryTextColor];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.font = [UIFont boldSystemFontOfSize:18];
    textLabel.textAlignment = UITextAlignmentCenter;
    [cell addSubview:textLabel];
    [textLabel release];

    [cell.contentView addSubview:cellView];
    [cellView release];
}

- (void)customizeCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundView.backgroundColor = [UVStyleSheet zebraBgColor:(indexPath.row % 2 == 0)];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    BOOL selectable = YES;
    UITableViewCellStyle style = UITableViewCellStyleDefault;

    if (indexPath.row == 0 && _searching)
        identifier = @"Add";
    else if (indexPath.row < (_searching ? [self.suggestions count] + 1 : [self.suggestions count]))
        identifier = @"Suggestion";
    else
        identifier = @"Load";
    return [self createCellForIdentifier:identifier
                               tableView:theTableView
                               indexPath:indexPath
                                   style:style
                              selectable:selectable];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    NSInteger loadedCount = [self.suggestions count];
    NSInteger suggestionsCount = [UVSession currentSession].clientConfig.forum.suggestionsCount;

    if (_searching) {
        // One cell per suggestion + one for "add"
        rows = loadedCount + 1;
    } else {
        // One cell per suggestion + "Load More"
        rows = [self.suggestions count] + (loadedCount>=suggestionsCount || suggestionsCount<SUGGESTIONS_PAGE_SIZE ? 0 : 1);
    }
    return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Both for suggestions and Load More
    return 71;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0 && _searching) {
        UVNewSuggestionViewController *next = [[UVNewSuggestionViewController alloc] initWithForum:self.forum
                                                                                             title:_textEditor.text];
        [self.navigationController pushViewController:next animated:YES];
        [next release];
    } else if (indexPath.row < (_searching ? [self.suggestions count] + 1 : [self.suggestions count])) {
        UVSuggestion *suggestion = [suggestions objectAtIndex:(_searching ? indexPath.row-1 : indexPath.row)];
        UVSuggestionDetailsViewController *next = [[UVSuggestionDetailsViewController alloc] init];
        next.suggestion = suggestion;

        [self.navigationController pushViewController:next animated:YES];
        [next release];
    } else {
        // This is the last row in the table, so it's the "Load more ideas" cell
        [self retrieveMoreSuggestions];
    }
}

- (void)pushSuggestionShowView:(NSInteger)index {
    UVSuggestion *suggestion = [suggestions objectAtIndex:index];
    UVSuggestionDetailsViewController *next = [[UVSuggestionDetailsViewController alloc] init];
    next.suggestion = suggestion;

    [self.navigationController pushViewController:next animated:YES];
    [next release];
}

- (void)setLeftBarButtonCancel {
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(dismissTextEditor)];
    [self.navigationItem setLeftBarButtonItem:cancelItem animated:NO];
    [cancelItem release];
}

- (void)setLeftBarButtonClear {
    UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(resetList)];
    [self.navigationItem setLeftBarButtonItem:clearItem animated:NO];
    [clearItem release];
}

- (void)resetList {
    _searching = NO;
    [self showExitButton];
    _textEditor.text = @"";

    [self.suggestions removeAllObjects];
    [self.suggestions addObjectsFromArray:[UVSession currentSession].clientConfig.forum.suggestions];
    [self.tableView reloadData];
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
}

- (void)dismissTextEditor {
    [self.textEditor resignFirstResponder];
    [self resetList];
}

#pragma mark ===== UVTextEditorDelegate Methods =====

- (BOOL)textFieldShouldBeginEditing:(UITextField *)theTextEditor {
    tableView.allowsSelection = NO;
    tableView.scrollEnabled = NO;

    UIView *headerView = (UIView *)self.tableView.tableHeaderView;
    UIView *shade = [headerView viewWithTag:UV_SEARCH_SHADE];

    [self setLeftBarButtonCancel];
    [self hideExitButton];
    shade.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    [UIView animateWithDuration:0.5 animations:^{
        shade.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    }];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextEditor {
    [self showActivityIndicator];
    [self.textEditor resignFirstResponder];
    _searching = YES;

    if (self.textEditor.text) {
        [UVSuggestion searchWithForum:self.forum query:self.textEditor.text delegate:self];
        [[UVSession currentSession] trackInteraction:@"si"];
    }

    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)theTextEditor {
    if (_textEditor.text) {
        [self setLeftBarButtonClear];
    }

    UIView *headerView = (UIView *)self.tableView.tableHeaderView;
    UIView *shade = [headerView viewWithTag:UV_SEARCH_SHADE];

    [UIView animateWithDuration:0.5 animations:^{
        shade.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    }];

    tableView.allowsSelection = YES;
    tableView.scrollEnabled = YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)theTextEditor {
    return YES;
}

#pragma mark ===== Basic View Methods =====

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];

    self.navigationItem.title = self.forum.prompt;

    CGRect frame = [self contentFrame];
    CGFloat screenWidth = [UVClientConfig getScreenWidth];

    UITableView *theTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    theTableView.dataSource = self;
    theTableView.delegate = self;
    theTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    theTableView.sectionFooterHeight = 0.0;
    theTableView.sectionHeaderHeight = 0.0;
    theTableView.backgroundColor = [UVStyleSheet backgroundColor];

    // Add empty footer, to suppress blank cells (with separators) after actual content
    UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)] autorelease];
    theTableView.tableFooterView = footer;

    [self addShadowSeparatorToTableView:theTableView];

    NSInteger headerHeight = [self supportsSearch] ? 40 : 0;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, headerHeight)];
    headerView.backgroundColor = [UIColor clearColor];

    if ([self supportsSearch]) {
        // Add text editor to table header
        
        UIView *shade = [[[UIView alloc] initWithFrame:CGRectMake(0, 40, screenWidth, [UVClientConfig getScreenHeight])] autorelease];
        shade.tag = UV_SEARCH_SHADE;
        shade.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [headerView addSubview:shade];

        UIView *textBar = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)] autorelease];
        textBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        textBar.backgroundColor = [UIColor whiteColor];

        _textEditor = [[UITextField alloc] initWithFrame:CGRectMake(10, 8, screenWidth-20, 24)];
        _textEditor.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _textEditor.delegate = self;
        _textEditor.autocorrectionType = UITextAutocorrectionTypeYes;

        [_textEditor setReturnKeyType:UIReturnKeyGo];
        _textEditor.enablesReturnKeyAutomatically = NO;
        _textEditor.placeholder = [self.forum example];

        [textBar addSubview:_textEditor];
        [headerView addSubview:textBar];
    }
    theTableView.tableHeaderView = headerView;
    [headerView release];

    self.tableView = theTableView;
    [theTableView release];
    self.view = tableView;
}

- (void)reloadTableData {
    self.suggestions = [UVSession currentSession].clientConfig.forum.suggestions;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.forum) {
        if ([UVSession currentSession].clientConfig.forum.suggestionsNeedReload) {
            self.suggestions = nil;
        }

        if (!self.suggestions) {
            [self populateSuggestions];
        }
    }
    [self.tableView reloadData];
}

- (void)dealloc {
    self.forum = nil;
    self.textEditor = nil;
    self.suggestions = nil;
    [super dealloc];
}


@end
