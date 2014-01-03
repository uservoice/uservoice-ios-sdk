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
#import "UVStyleSheet.h"
#import "UVUser.h"
#import "UVConfig.h"
#import "UVUtils.h"
#import "UVBabayaga.h"
#import "UVPostIdeaViewController.h"

#define SUGGESTIONS_PAGE_SIZE 10
#define UV_SEARCH_TEXTBAR 1
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_PREFIX 100
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_QUERY 101
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_SUFFIX 102
#define UV_BASE_GROUPED_CELL_BG 103
#define UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND 104
#define UV_SEARCH_TOOLBAR 1000
#define UV_SEARCH_TOOLBAR_LABEL 1001

#define TITLE 20
#define SUBSCRIBER_COUNT 21
#define STATUS 22
#define STATUS_COLOR 23
#define LOADING 30

@implementation UVSuggestionListViewController {
    UITableViewCell *_templateCell;
    UILabel *_loadingLabel;
    BOOL _loading;
}

- (id)init {
    if ((self = [super init])) {
        _forum = [UVSession currentSession].forum;
    }
    return self;
}

- (void)retrieveMoreSuggestions {
    NSInteger page = (_suggestions.count / SUGGESTIONS_PAGE_SIZE) + 1;
    [self showActivityIndicator];
    [UVSuggestion getWithForum:_forum page:page delegate:self];
}

- (void)populateSuggestions {
    _suggestions = [NSMutableArray arrayWithCapacity:10];
    _forum.suggestions = [NSMutableArray arrayWithCapacity:10];
    [self retrieveMoreSuggestions];
}

- (void)didRetrieveSuggestions:(NSArray *)theSuggestions {
    if (theSuggestions.count > 0) {
        [_suggestions addObjectsFromArray:theSuggestions];
    }

    [_forum.suggestions addObjectsFromArray:theSuggestions];
    [self hideActivityIndicator];
    [_tableView reloadData];
}

- (void)didSearchSuggestions:(NSArray *)theSuggestions {
    _searchResults = theSuggestions;
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:[theSuggestions count]];
    for (UVSuggestion *suggestion in theSuggestions) {
        [ids addObject:[NSNumber numberWithInt:suggestion.suggestionId]];
    }
    [UVBabayaga track:SEARCH_IDEAS searchText:_searchController.searchBar.text ids:ids];
    [_searchController.searchResultsTableView reloadData];
}

#pragma mark ===== UITableViewDataSource Methods =====

- (void)initCellForAdd:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = NSLocalizedStringFromTable(@"Post an idea", @"UserVoice", nil);
    if (IOS7) {
        cell.textLabel.textColor = cell.textLabel.tintColor;
    }
}

- (void)initCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UIImageView *heart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_heart.png"]];
    UILabel *subs = [UILabel new];
    subs.font = [UIFont systemFontOfSize:14];
    subs.textColor = [UIColor grayColor];
    subs.tag = SUBSCRIBER_COUNT;
    UILabel *title = [UILabel new];
    title.numberOfLines = 0;
    title.tag = TITLE;
    title.font = [UIFont systemFontOfSize:17];
    UILabel *status = [UILabel new];
    status.font = [UIFont systemFontOfSize:11];
    status.tag = STATUS;
    UIView *statusColor = [UIView new];
    statusColor.tag = STATUS_COLOR;
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 9, 9);
    [statusColor.layer addSublayer:layer];
    NSArray *constraints = @[
        @"|-[title]-|",
        @"|-[heart(==9)]-3-[subs]-10-[statusColor(==9)]-5-[status]",
        @"V:|-12-[title]-6-[heart(==9)]",
        @"V:[title]-6-[statusColor(==9)]",
        @"V:[title]-4-[status]",
        @"V:[title]-2-[subs]"
    ];
    [self configureView:cell.contentView
               subviews:NSDictionaryOfVariableBindings(subs, title, heart, statusColor, status)
            constraints:constraints
         finalCondition:indexPath == nil
        finalConstraint:@"V:[heart]-14-|"];
}

- (void)customizeCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [self customizeCellForSuggestion:[_suggestions objectAtIndex:indexPath.row] cell:cell];
}

- (void)initCellForResult:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [self initCellForSuggestion:cell indexPath:indexPath];
}

- (void)customizeCellForResult:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [self customizeCellForSuggestion:[_searchResults objectAtIndex:indexPath.row] cell:cell];
}

- (void)initCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundView = [[UIView alloc] initWithFrame:cell.frame];
    UILabel *label = [[UILabel alloc] initWithFrame:cell.frame];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = LOADING;
    [cell addSubview:label];
}

- (void)customizeCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UILabel *label = (UILabel *)[cell viewWithTag:LOADING];
    label.text = _loading ? NSLocalizedStringFromTable(@"Loading...", @"UserVoice", nil) : NSLocalizedStringFromTable(@"Load more", @"UserVoice", nil);
}

- (void)customizeCellForSuggestion:(UVSuggestion *)suggestion cell:(UITableViewCell *)cell {
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:TITLE];
    UILabel *subs = (UILabel *)[cell.contentView viewWithTag:SUBSCRIBER_COUNT];
    UILabel *status = (UILabel *)[cell.contentView viewWithTag:STATUS];
    UIView *statusColor = [cell.contentView viewWithTag:STATUS_COLOR];
    title.text = suggestion.title;
    subs.text = [NSString stringWithFormat:@"%d", (int)suggestion.subscriberCount];
    [statusColor.layer.sublayers.lastObject setBackgroundColor:suggestion.statusColor.CGColor];
    status.textColor = suggestion.statusColor;
    status.text = [suggestion.status uppercaseString];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    if (theTableView == _tableView) {
        identifier = (indexPath.section == 0 && [UVSession currentSession].config.showPostIdea) ? @"Add" : (indexPath.row < _suggestions.count) ? @"Suggestion" : @"Load";
    } else {
        identifier = @"Result";
    }
    return [self createCellForIdentifier:identifier
                               tableView:theTableView
                               indexPath:indexPath
                                   style:UITableViewCellStyleDefault
                              selectable:YES];
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && [UVSession currentSession].config.showPostIdea && theTableView == _tableView) {
        return 1;
    } else if (theTableView == _tableView) {
        int loadedCount = _suggestions.count;
        int suggestionsCount = _forum.suggestionsCount;
        return loadedCount + (loadedCount >= suggestionsCount || suggestionsCount < SUGGESTIONS_PAGE_SIZE ? 0 : 1);
    } else {
        return _searchResults.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [UVSession currentSession].config.showPostIdea && tableView == _tableView ? 2 : 1;
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && [UVSession currentSession].config.showPostIdea && theTableView == _tableView) {
        return 44;
    } else if (theTableView == _tableView && indexPath.row < _suggestions.count) {
        return [self heightForDynamicRowWithReuseIdentifier:@"Suggestion" indexPath:indexPath];
    } else if (theTableView != _tableView) {
        return [self heightForDynamicRowWithReuseIdentifier:@"Result" indexPath:indexPath];
    } else {
        return 44;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ((section == 0 && [UVSession currentSession].config.showPostIdea) || tableView != _tableView) {
        return nil;
    } else {
        return _forum.prompt;
    }
}

- (void)showSuggestion:(UVSuggestion *)suggestion {
    UVSuggestionDetailsViewController *next = [[UVSuggestionDetailsViewController alloc] initWithSuggestion:suggestion];
    [self.navigationController pushViewController:next animated:YES];
}

- (void)composeButtonTapped {
    UVPostIdeaViewController *next = [UVPostIdeaViewController new];
    next.initialText = _searchController.searchBar.text;
    [self presentModalViewController:next];
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (theTableView == _tableView) {
        if (indexPath.section == 0 && [UVSession currentSession].config.showPostIdea) {
            [self composeButtonTapped];
        } else if (indexPath.row < _suggestions.count) {
            [self showSuggestion:[_suggestions objectAtIndex:indexPath.row]];
        } else {
            [self retrieveMoreSuggestions];
        }
    } else {
        [self showSuggestion:[_searchResults objectAtIndex:indexPath.row]];
    }
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return tableView == _tableView ? 30 : 0;
}

#pragma mark ===== UISearchBarDelegate Methods =====

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [_searchController setActive:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [UVSuggestion searchWithForum:_forum query:searchBar.text delegate:self];
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [super loadView];
    [UVBabayaga track:VIEW_FORUM id:_forum.forumId];
    [self setupGroupedTableView];

    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    searchBar.placeholder = NSLocalizedStringFromTable(@"Search forum", @"UserVoice", nil);
    searchBar.delegate = self;

    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    _searchController.delegate = self;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsDelegate = self;
    _tableView.tableHeaderView = searchBar;

    if (![UVSession currentSession].clientConfig.whiteLabel) {
        _tableView.tableFooterView = self.poweredByView;
    }

    if ([UVSession currentSession].config.showPostIdea) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                               target:self
                                                                                               action:@selector(composeButtonTapped)];
        if ([self.navigationItem.rightBarButtonItem respondsToSelector:@selector(setTintColor:)])
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.24f green:0.51f blue:0.95f alpha:1.0f];
    }

    if ([UVSession currentSession].isModal && _firstController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Close", @"UserVoice", nil)
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(dismiss)];
    }
}

- (void)showActivityIndicator {
    _loading = YES;
    [_tableView reloadData];
}

- (void)hideActivityIndicator {
    _loading = NO;
}

- (void)initNavigationItem {
    self.navigationItem.title = _forum.name;
    self.exitButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(dismiss)];
    if ([UVSession currentSession].isModal && _firstController) {
        self.navigationItem.leftBarButtonItem = _exitButton;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_forum) {
        if (!_suggestions) {
            [self populateSuggestions];
        }
    }
    [_tableView reloadData];
}

- (void)dealloc {
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

@end
