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
#import "UVStyleSheet.h"
#import "UVUser.h"
#import "UVCellViewWithIndex.h"
#import "UVSuggestionButton.h"
#import "UVConfig.h"
#import "UVUtils.h"

#define SUGGESTIONS_PAGE_SIZE 10
#define UV_SEARCH_TEXTBAR 1
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_PREFIX 100
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_QUERY 101
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_SUFFIX 102
#define UV_BASE_GROUPED_CELL_BG 103
#define UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND 104
#define UV_SEARCH_TOOLBAR 1000
#define UV_SEARCH_TOOLBAR_LABEL 1001

@implementation UVSuggestionListViewController

@synthesize forum = _forum;
@synthesize suggestions;
@synthesize searchResults;
@synthesize searchController;
@synthesize searchPattern;

- (id)init {
    if ((self = [super init])) {
        self.forum = [UVSession currentSession].forum;
    }
    return self;
}

- (void)retrieveMoreSuggestions {
    NSInteger page = ([self.suggestions count] / SUGGESTIONS_PAGE_SIZE) + 1;
    [self showActivityIndicator];
    [UVSuggestion getWithForum:self.forum page:page delegate:self];
}

- (void)populateSuggestions {
    self.suggestions = [NSMutableArray arrayWithCapacity:10];
    _forum.suggestions = [NSMutableArray arrayWithCapacity:10];
    _forum.suggestionsNeedReload = NO;
    [self retrieveMoreSuggestions];
}

- (void)didRetrieveSuggestions:(NSArray *)theSuggestions {
    [self hideActivityIndicator];
    if ([theSuggestions count] > 0) {
        [self.suggestions addObjectsFromArray:theSuggestions];
    }

    [_forum.suggestions addObjectsFromArray:theSuggestions];
    [self.tableView reloadData];
}

- (void)didSearchSuggestions:(NSArray *)theSuggestions {
    self.searchResults = theSuggestions;
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:[theSuggestions count]];
    for (UVSuggestion *suggestion in theSuggestions) {
        [ids addObject:[NSNumber numberWithInt:suggestion.suggestionId]];
    }
    [[UVSession currentSession] trackInteraction:[theSuggestions count] > 0 ? @"rip" : @"riz" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[theSuggestions count]], @"count", ids, @"ids", nil]];
    [searchController.searchResultsTableView reloadData];
}

- (void)addSuggestion:(UVCellViewWithIndex *)cellView {
    UIViewController *next = [UVNewSuggestionViewController viewControllerWithTitle:self.searchController.searchBar.text];
    [self.navigationController pushViewController:next animated:YES];
}

- (void)updatePattern {
    self.searchPattern = [UVUtils patternForQuery:searchController.searchBar.text];
}

#pragma mark ===== UITableViewDataSource Methods =====

- (void)initCellForAdd:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UINavigationBar *toolbar = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height)] autorelease];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    toolbar.tintColor = [UIColor colorWithRed:0.77f green:0.78f blue:0.80f alpha:1.0f];
    toolbar.tag = UV_SEARCH_TOOLBAR;
    [toolbar addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(composeButtonTapped)] autorelease]];
    toolbar.layer.masksToBounds = YES;

    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, cell.bounds.size.width - 60, cell.bounds.size.height)] autorelease];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.textColor = [UIColor colorWithRed:0.20f green:0.31f blue:0.52f alpha:1.0f];
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.tag = UV_SEARCH_TOOLBAR_LABEL;
    [toolbar addSubview:label];

    UIBarButtonItem *compose = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonTapped)] autorelease];
    compose.style = UIBarButtonItemStyleBordered;
    if ([compose respondsToSelector:@selector(setTintColor:)])
        compose.tintColor = [UIColor colorWithRed:0.24f green:0.51f blue:0.95f alpha:1.0f];
    UINavigationItem *navItem = [[[UINavigationItem alloc] initWithTitle:nil] autorelease];
    navItem.rightBarButtonItem = compose;
    toolbar.items = @[navItem];

    [cell addSubview:toolbar];
}

- (void)customizeCellForAdd:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UILabel *label = (UILabel *)[[cell viewWithTag:UV_SEARCH_TOOLBAR] viewWithTag:UV_SEARCH_TOOLBAR_LABEL];
    NSLocale *locale = [NSLocale currentLocale];
    label.text = [NSString stringWithFormat:@"%@ %@%@%@...", NSLocalizedStringFromTable(@"Post", @"UserVoice", nil), [locale objectForKey:NSLocaleQuotationBeginDelimiterKey], self.searchController.searchBar.text, [locale objectForKey:NSLocaleQuotationEndDelimiterKey]];
}

- (void)initCellForResult:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVSuggestionButton *button = [[[UVSuggestionButton alloc] initWithIndex:indexPath.row] autorelease];
    button.tag = UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND;
    [cell.contentView addSubview:button];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)customizeCellForResult:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVSuggestion *suggestion = [searchResults objectAtIndex:indexPath.row - ([UVSession currentSession].config.showPostIdea ? 1 : 0)];
    UVSuggestionButton *button = (UVSuggestionButton *)[cell.contentView viewWithTag:UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND];
    [button setZebraColorFromIndex:indexPath.row];
    [button showSuggestion:suggestion withIndex:indexPath.row pattern:searchPattern];
}

- (void)initCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVSuggestionButton *button = [[[UVSuggestionButton alloc] initWithIndex:indexPath.row] autorelease];
    button.tag = UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND;
    [cell.contentView addSubview:button];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)customizeCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVSuggestion *suggestion = [suggestions objectAtIndex:indexPath.row];
    UVSuggestionButton *button = (UVSuggestionButton *)[cell.contentView viewWithTag:UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND];
    [button setZebraColorFromIndex:indexPath.row];
    [button showSuggestion:suggestion withIndex:indexPath.row];
}

- (void)initCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
    UILabel *label = [[[UILabel alloc] initWithFrame:cell.frame] autorelease];
    label.text = NSLocalizedStringFromTable(@"Load more", @"UserVoice", nil);
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = UITextAlignmentCenter;
    [cell addSubview:label];
}

- (void)customizeCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    if (!IOS7) {
        cell.backgroundView.backgroundColor = [UVStyleSheet zebraBgColor:(indexPath.row % 2 == 0)];
    }
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    BOOL selectable = YES;
    UITableViewCellStyle style = UITableViewCellStyleDefault;

    if (theTableView == tableView)
        identifier = (indexPath.row < [suggestions count]) ? @"Suggestion" : @"Load";
    else
        identifier = (indexPath.row == 0 && [UVSession currentSession].config.showPostIdea) ? @"Add" : @"Result";

    return [self createCellForIdentifier:identifier
                               tableView:theTableView
                               indexPath:indexPath
                                   style:style
                              selectable:selectable];
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    if (theTableView == tableView) {
        int loadedCount = [self.suggestions count];
        int suggestionsCount = _forum.suggestionsCount;
        return loadedCount + (loadedCount >= suggestionsCount || suggestionsCount < SUGGESTIONS_PAGE_SIZE ? 0 : 1);
    } else {
        return [searchResults count] + ([UVSession currentSession].config.showPostIdea ? 1 : 0);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (theTableView == tableView)
        return (indexPath.row < [suggestions count]) ? 71 : 44;
    else
        return (indexPath.row == 0 && [UVSession currentSession].config.showPostIdea) ? 44 : 71;
}

- (void)showSuggestion:(UVSuggestion *)suggestion {
    UVSuggestionDetailsViewController *next = [[[UVSuggestionDetailsViewController alloc] initWithSuggestion:suggestion] autorelease];
    [self.navigationController pushViewController:next animated:YES];
}

- (void)composeButtonTapped {
    [self presentModalViewController:[UVNewSuggestionViewController viewControllerWithTitle:self.searchController.searchBar.text]];
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (theTableView == tableView) {
        if (indexPath.row < [suggestions count])
            [self showSuggestion:[suggestions objectAtIndex:indexPath.row]];
        else
            [self retrieveMoreSuggestions];
    } else {
        if (indexPath.row == 0 && [UVSession currentSession].config.showPostIdea)
            [self composeButtonTapped];
        else
            [self showSuggestion:[searchResults objectAtIndex:indexPath.row - ([UVSession currentSession].config.showPostIdea ? 1 : 0)]];
    }
}

#pragma mark ===== UISearchBarDelegate Methods =====

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchController setActive:YES animated:YES];
    searchController.searchResultsTableView.separatorColor = [UVStyleSheet bottomSeparatorColor];
    searchController.searchResultsTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self updatePattern];
    [UVSuggestion searchWithForum:self.forum query:searchBar.text delegate:self];
    [[UVSession currentSession] trackInteraction:@"si"];
}

#pragma mark ===== Basic View Methods =====

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];

    self.navigationItem.title = NSLocalizedStringFromTable(@"Feedback Forum", @"UserVoice", nil);

    self.view = [[[UIView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.view.autoresizesSubviews = YES;
    CGFloat screenWidth = [UVClientConfig getScreenWidth];

    UITableView *theTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    theTableView.dataSource = self;
    theTableView.delegate = self;
    theTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    theTableView.sectionFooterHeight = 0.0;
    theTableView.sectionHeaderHeight = 0.0;
    theTableView.backgroundColor = [UVStyleSheet backgroundColor];
    theTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

    // Add empty footer, to suppress blank cells (with separators) after actual content
    UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)] autorelease];
    theTableView.tableFooterView = footer;
    theTableView.separatorColor = [UVStyleSheet bottomSeparatorColor];

    NSInteger headerHeight = 44;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, headerHeight)];
    headerView.backgroundColor = [UIColor clearColor];

    UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, headerHeight)] autorelease];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.placeholder = [NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"Search", @"UserVoice", nil), _forum.name];
    searchBar.delegate = self;

    if (!IOS7) {
        UIView *border = [[[UIView alloc] initWithFrame:CGRectMake(0, searchBar.bounds.size.height - 1, searchBar.bounds.size.width, 1)] autorelease];
        border.backgroundColor = [UIColor colorWithRed:0.64f green:0.66f blue:0.68f alpha:1.0f];
        border.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        [searchBar addSubview:border];
    }

    [headerView addSubview:searchBar];

    self.searchController = [[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self] autorelease];
    searchController.delegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
    theTableView.tableHeaderView = headerView;
    [headerView release];

    self.tableView = theTableView;
    [theTableView release];
    [self.view addSubview:tableView];


    if ([UVSession currentSession].config.showPostIdea) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                                target:self
                                                                                                action:@selector(composeButtonTapped)] autorelease];
        if ([self.navigationItem.rightBarButtonItem respondsToSelector:@selector(setTintColor:)])
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.24f green:0.51f blue:0.95f alpha:1.0f];
    }

    if ([UVSession currentSession].isModal && firstController) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Close", @"UserVoice", nil)
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(dismissUserVoice)] autorelease];
    }
}

- (void)reloadTableData {
    self.suggestions = _forum.suggestions;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_forum) {
        if (_forum.suggestionsNeedReload) {
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
    self.suggestions = nil;
    self.searchResults = nil;
    self.searchController = nil;
    self.searchPattern = nil;
    [super dealloc];
}

@end
