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
#import "UVSuggestionSearchResultsController.h"

#define SUGGESTIONS_PAGE_SIZE 10
#define UV_SEARCH_TEXTBAR 1
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_PREFIX 100
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_QUERY 101
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_SUFFIX 102
#define UV_BASE_GROUPED_CELL_BG 103
#define UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND 104
#define UV_SEARCH_TOOLBAR 1000
#define UV_SEARCH_TOOLBAR_LABEL 1001

#define LOADING 30

@interface UVSuggestionListViewController()
@property (nonatomic, retain) UISearchController *searchController;
@property (nonatomic, retain) UVSuggestionSearchResultsController *searchResultsController;
@end

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
    NSInteger page = (_forum.suggestions.count / SUGGESTIONS_PAGE_SIZE) + 1;
    [self showActivityIndicator];
    [UVSuggestion getWithForum:_forum page:page delegate:self];
}

- (void)populateSuggestions {
    _forum.suggestions = [NSMutableArray arrayWithCapacity:10];
    [self retrieveMoreSuggestions];
}

- (void)didRetrieveSuggestions:(NSArray *)theSuggestions {
    if (theSuggestions.count > 0) {
        [_forum.suggestions addObjectsFromArray:theSuggestions];
    }
    [self hideActivityIndicator];
    [_tableView reloadData];
}

- (void)didSearchSuggestions:(NSArray *)theSuggestions {
    _searchResults = theSuggestions;
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:[theSuggestions count]];
    for (UVSuggestion *suggestion in theSuggestions) {
        [ids addObject:[NSNumber numberWithInteger:suggestion.suggestionId]];
    }
    [UVBabayaga track:SEARCH_IDEAS searchText:_searchController.searchBar.text ids:ids];
    
    if (_searchController.active && ![_searchController.searchBar.text isEqualToString:@""]) {
        [self updateSearchResultsForSearchController:_searchController];
    } else {
        [_tableView reloadData];
    }
}

#pragma mark ===== UITableViewDataSource Methods =====

- (void)initCellForAdd:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Post an idea", @"UserVoice", [UserVoice bundle], nil);
    if (IOS7) {
        cell.textLabel.textColor = cell.textLabel.tintColor;
    }
}

- (void)customizeCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [self customizeCellForSuggestion:[_forum.suggestions objectAtIndex:indexPath.row] cell:cell];
}

- (void)initCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
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
    label.text = _loading ? NSLocalizedStringFromTableInBundle(@"Loading...", @"UserVoice", [UserVoice bundle], nil) : NSLocalizedStringFromTableInBundle(@"Load more", @"UserVoice", [UserVoice bundle], nil);
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = (indexPath.section == 0 && [UVSession currentSession].config.showPostIdea) ? @"Add" : (indexPath.row < _forum.suggestions.count) ? @"Suggestion" : @"Load";

    return [self createCellForIdentifier:identifier
                               tableView:theTableView
                               indexPath:indexPath
                                   style:UITableViewCellStyleDefault
                              selectable:YES];
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && [UVSession currentSession].config.showPostIdea && theTableView == _tableView) {
        return 1;
    } else {
        return _forum.suggestions.count + (_forum.suggestions.count < _forum.suggestionsCount || _loading ? 1 : 0);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [UVSession currentSession].config.showPostIdea && tableView == _tableView ? 2 : 1;
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && [UVSession currentSession].config.showPostIdea && theTableView == _tableView) {
        return 44;
    } else if (theTableView == _tableView && indexPath.row < _forum.suggestions.count) {
        return [self heightForDynamicRowWithReuseIdentifier:@"Suggestion" indexPath:indexPath];
    } else {
        return 44;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0 && [UVSession currentSession].config.showPostIdea) {
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
    next.delegate = self;
    [self presentModalViewController:next];
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && [UVSession currentSession].config.showPostIdea) {
        [self composeButtonTapped];
    } else if (indexPath.row < _forum.suggestions.count) {
        [self showSuggestion:[_forum.suggestions objectAtIndex:indexPath.row]];
    } else {
        if (!_loading) {
            [self retrieveMoreSuggestions];
        }
    }

    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

#pragma mark ===== UISearchBarDelegate Methods =====

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _searchController.searchBar.text = @"";
    _searchResults = [NSArray array];
    [_tableView reloadData];
}

#pragma mark ==== UISearchResultsUpdating Methods ====

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [UVSuggestion searchWithForum:_forum query:searchController.searchBar.text delegate:self];
    
    if (_searchController.searchResultsController) {
        UVSuggestionSearchResultsController *searchResultsTVC = (UVSuggestionSearchResultsController *)_searchController.searchResultsController;
        searchResultsTVC.searchResults = self.searchResults;
        searchResultsTVC.tableView.backgroundView = [searchResultsTVC displayNoResults];
        [searchResultsTVC.tableView reloadData];
    }
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [super loadView];
    [UVBabayaga track:VIEW_FORUM id:_forum.forumId];
    [self setupGroupedTableView];

    self.definesPresentationContext = true;
    self.searchResultsController = [[UVSuggestionSearchResultsController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.delegate = self;
    _searchController.searchBar.placeholder = NSLocalizedStringFromTableInBundle(@"Search forum", @"UserVoice", [UserVoice bundle], nil);
    if (FORMSHEET) {
        _searchController.hidesNavigationBarDuringPresentation = false;
    }
    
    _tableView.tableHeaderView = _searchController.searchBar;

    if (![UVSession currentSession].clientConfig.whiteLabel) {
        _tableView.tableFooterView = self.poweredByView;
    }

    if ([UVSession currentSession].config.showPostIdea) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                               target:self
                                                                                               action:@selector(composeButtonTapped)];
    }

    if ([UVSession currentSession].isModal && _firstController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Close", @"UserVoice", [UserVoice bundle], nil)
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(dismiss)];
    }
    
    if (_forum && !_forum.suggestions.count) {
        [self populateSuggestions];
        [_tableView reloadData];
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
    self.exitButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", @"UserVoice", [UserVoice bundle], nil)
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(dismiss)];
    if ([UVSession currentSession].isModal && _firstController) {
        self.navigationItem.leftBarButtonItem = _exitButton;
    }
}

- (void)ideaWasCreated:(UVSuggestion *)suggestion {
    _forum.suggestions = nil;
    [self populateSuggestions];
    [_tableView reloadData];
}

- (void)dealloc {
    _searchResults = nil;
    if (_searchController) {
        _searchController.searchResultsUpdater = nil;
    }
    if (self.searchResultsController) {
        self.searchResultsController = nil;
    }
}

@end
