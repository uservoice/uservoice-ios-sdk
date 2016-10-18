//
//  UVWelcomeViewController.m
//  UserVoice
//
//  Created by UserVoice on 12/15/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVWelcomeViewController.h"
#import "UVStyleSheet.h"
#import "UVSession.h"
#import "UVForum.h"
#import "UVClientConfig.h"
#import "UVSubdomain.h"
#import "UVContactViewController.h"
#import "UVSuggestionListViewController.h"
#import "UVSuggestion.h"
#import "UVArticle.h"
#import "UVSuggestionDetailsViewController.h"
#import "UVArticleViewController.h"
#import "UVHelpTopic.h"
#import "UVHelpTopicViewController.h"
#import "UVConfig.h"
#import "UVPostIdeaViewController.h"
#import "UVBabayaga.h"
#import "UVUtils.h"
#import "UVPaginationInfo.h"
#import "UVWelcomeSearchResultsController.h"

#define LOADING 30

@interface UVWelcomeViewController ()
@property (nonatomic, retain) UISearchController *searchController;
@property (nonatomic, retain) UVWelcomeSearchResultsController *searchResultsController;
@end

@implementation UVWelcomeViewController {
    NSInteger _filter;
    BOOL _allHelpRowsLoaded;
    BOOL _loadingHelpContent;
}

- (BOOL)showArticles {
    return [UVSession currentSession].config.topicId || [[UVSession currentSession].topics count] == 0;
}

#pragma mark ===== table cells =====

- (void)initCellForContact:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Send us a message", @"UserVoice", [UserVoice bundle], nil);
    if (IOS7) {
        cell.textLabel.textColor = cell.textLabel.tintColor;
    }
}

- (void)initCellForPostIdea:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Post an idea", @"UserVoice", [UserVoice bundle], nil);
    if (IOS7) {
        cell.textLabel.textColor = cell.textLabel.tintColor;
    }
}

- (void)initCellForForum:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Feedback Forum", @"UserVoice", [UserVoice bundle], nil);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    label.text = _loadingHelpContent ? NSLocalizedStringFromTableInBundle(@"Loading...", @"UserVoice", [UserVoice bundle], nil) : NSLocalizedStringFromTableInBundle(@"Load more", @"UserVoice", [UserVoice bundle], nil);
}

- (void)customizeCellForForum:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    NSString *detail;
    if ([UVSession currentSession].forum.suggestionsCount == 1) {
        detail = NSLocalizedStringFromTableInBundle(@"1 idea", @"UserVoice", [UserVoice bundle], nil);
    } else {
        detail = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"%@ ideas", @"UserVoice", [UserVoice bundle], nil), [UVUtils formatInteger:[UVSession currentSession].forum.suggestionsCount]];
    }
    cell.detailTextLabel.text = detail;
}

- (void)customizeCellForTopic:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.row == [[UVSession currentSession].topics count]) {
        cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"All Articles", @"UserVoice", [UserVoice bundle], nil);
        cell.detailTextLabel.text = nil;
    } else {
        UVHelpTopic *topic = [[UVSession currentSession].topics objectAtIndex:indexPath.row];
        cell.textLabel.text = topic.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)topic.articleCount];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)customizeCellForArticle:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    UVArticle *article = [[UVSession currentSession].articles objectAtIndex:indexPath.row];
    cell.textLabel.text = article.question;
    cell.imageView.image = [UVUtils imageNamed:@"uv_article.png"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
}

- (void)initCellForFlash:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"View idea", @"UserVoice", [UserVoice bundle], nil);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    NSInteger style = UITableViewCellStyleValue1;

    if (indexPath.section == 0 && indexPath.row == 0 && [UVSession currentSession].config.showContactUs)
        identifier = @"Contact";
    else if (indexPath.section == 0 && [UVSession currentSession].config.showForum)
        identifier = @"Forum";
    else if (indexPath.section == 0 && [UVSession currentSession].config.showPostIdea)
        identifier = @"PostIdea";
    else if ([self showArticles] && indexPath.row < [[UVSession currentSession].articles count])
        identifier = @"Article";
    else if (indexPath.row < [[UVSession currentSession].topics count] + 1)
        identifier = @"Topic";
    else
        identifier = @"Load";

    return [self createCellForIdentifier:identifier tableView:theTableView indexPath:indexPath style:style selectable:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    int sections = 0;

    if ([UVSession currentSession].config.showKnowledgeBase && ([[UVSession currentSession].topics count] > 0 || [[UVSession currentSession].articles count] > 0))
        sections++;
    
    if ([UVSession currentSession].config.showForum || [UVSession currentSession].config.showContactUs || [UVSession currentSession].config.showPostIdea)
        sections++;

    return sections;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && ([UVSession currentSession].config.showForum || [UVSession currentSession].config.showContactUs || [UVSession currentSession].config.showPostIdea))
        return (([UVSession currentSession].config.showForum || [UVSession currentSession].config.showPostIdea) && [UVSession currentSession].config.showContactUs) ? 2 : 1;
    else if ([self showArticles])
        return [[UVSession currentSession].articles count] + ([UVSession currentSession].articlePagination.hasMoreData ? 1 : 0);
    else
        return [[UVSession currentSession].topics count] + 1 + ([UVSession currentSession].topicPagination.hasMoreData ? 1 : 0);
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0 && [UVSession currentSession].config.showContactUs) {
        [self presentModalViewController:[UVContactViewController new]];
    } else if (indexPath.section == 0 && [UVSession currentSession].config.showForum) {
        UVSuggestionListViewController *next = [UVSuggestionListViewController new];
        [self.navigationController pushViewController:next animated:YES];
    } else if (indexPath.section == 0 && [UVSession currentSession].config.showPostIdea) {
        [self presentModalViewController:[UVPostIdeaViewController new]];
    } else if ([self showArticles] && indexPath.row < [[UVSession currentSession].articles count]) {
        UVArticle *article = (UVArticle *)[[UVSession currentSession].articles objectAtIndex:indexPath.row];
        UVArticleViewController *next = [UVArticleViewController new];
        next.article = article;
        [self.navigationController pushViewController:next animated:YES];
    } else if (indexPath.row < [[UVSession currentSession].topics count] + 1) {
        UVHelpTopic *topic = nil;
        if (indexPath.row < [[UVSession currentSession].topics count])
            topic = (UVHelpTopic *)[[UVSession currentSession].topics objectAtIndex:indexPath.row];
        UVHelpTopicViewController *next = [[UVHelpTopicViewController alloc] initWithTopic:topic];
        [self.navigationController pushViewController:next animated:YES];
    } else {
        if (!_loadingHelpContent) {
            _loadingHelpContent = YES;
            [theTableView reloadData];
            if ([self showArticles]) {
                NSInteger page = [UVSession currentSession].articlePagination.page + 1;
                if ([UVSession currentSession].config.topicId) {
                    [UVArticle getArticlesWithTopicId:[UVSession currentSession].config.topicId page:page delegate:self];
                } else {
                    [UVArticle getArticlesWithPage:page delegate:self];
                }
            } else {
                NSInteger page = [UVSession currentSession].topicPagination.page + 1;
                [UVHelpTopic getTopicsWithPage:page delegate:self];
            }
        }
    }
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)theTableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0 && ([UVSession currentSession].config.showForum || [UVSession currentSession].config.showContactUs || [UVSession currentSession].config.showPostIdea))
        return nil;
    else if ([UVSession currentSession].config.topicId)
        return [((UVHelpTopic *)[[UVSession currentSession].topics objectAtIndex:0]) name];
    else
        return NSLocalizedStringFromTableInBundle(@"Knowledge Base", @"UserVoice", [UserVoice bundle], nil);
}

- (CGFloat)tableView:(UITableView *)theTableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (void)logoTapped {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.uservoice.com/ios"]];
}

#pragma mark ===== UISearchBarDelegate Methods =====

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    _filter = _searchController.searchBar.selectedScopeButtonIndex;
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    _filter = searchBar.selectedScopeButtonIndex;
    // Make sure that we update the displayed search results if the scope changes
    [self didUpdateInstantAnswers];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _searchController.searchBar.selectedScopeButtonIndex = 0;
    _searchController.searchBar.text = @"";
    _instantAnswerManager.instantAnswers = [NSArray array];
    [_tableView reloadData];
}

#pragma mark ==== UISearchResultsUpdating Methods ====

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // Perform search whenever the search text is changed
    _instantAnswerManager.searchText = searchController.searchBar.text;
    [_instantAnswerManager search];
}

#pragma mark ===== Search handling =====

- (void)didUpdateInstantAnswers {
    if (_searchController.searchResultsController) {
        UVWelcomeSearchResultsController *searchResultsTVC = (UVWelcomeSearchResultsController *)_searchController.searchResultsController;
        searchResultsTVC.searchResults = self.searchResults;
        searchResultsTVC.tableView.backgroundView = [searchResultsTVC displayNoResults];
        [searchResultsTVC.tableView reloadData];
    }
}

- (NSArray *)searchResults {
    switch (_filter) {
        case IA_FILTER_ALL:
            return _instantAnswerManager.instantAnswers;
        case IA_FILTER_ARTICLES:
            return _instantAnswerManager.articles;
        case IA_FILTER_IDEAS:
            return _instantAnswerManager.ideas;
        default:
            return nil;
    }
}

#pragma mark ===== UVModelDelegate =====

- (void)didRetrieveHelpTopics:(NSArray *)topics pagination:(UVPaginationInfo *)pagination {
    NSArray *filteredTopics = [topics filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"articleCount > 0"]];
    [UVSession currentSession].topics = [[UVSession currentSession].topics arrayByAddingObjectsFromArray:filteredTopics];
    [UVSession currentSession].topicPagination = pagination;
    _loadingHelpContent = NO;
    [_tableView reloadData];
}

- (void)didRetrieveArticles:(NSArray *)articles pagination:(UVPaginationInfo *)pagination {
    [UVSession currentSession].articles = [[UVSession currentSession].articles arrayByAddingObjectsFromArray:articles];
    [UVSession currentSession].articlePagination = pagination;
    _loadingHelpContent = NO;
    [_tableView reloadData];
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [super loadView];
    [UVBabayaga track:VIEW_KB];
    _instantAnswerManager = [UVInstantAnswerManager new];
    _instantAnswerManager.delegate = self;
    self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"Feedback & Support", @"UserVoice", [UserVoice bundle], nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Close", @"UserVoice", [UserVoice bundle], nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismiss)];

    [self setupGroupedTableView];

    if ([UVSession currentSession].config.showKnowledgeBase) {
        self.definesPresentationContext = true;
        self.searchResultsController = [[UVWelcomeSearchResultsController alloc] init];
        _searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
        _searchController.searchResultsUpdater = self;
        [_searchController.searchBar sizeToFit];
        _searchController.searchBar.delegate = self;
        _searchController.searchBar.placeholder = NSLocalizedStringFromTableInBundle(@"Search", @"UserVoice", [UserVoice bundle], nil);
        if ([UVSession currentSession].config.showForum ) {
            _searchController.searchBar.scopeButtonTitles = @[NSLocalizedStringFromTableInBundle(@"All", @"UserVoice", [UserVoice bundle], nil), NSLocalizedStringFromTableInBundle(@"Articles", @"UserVoice", [UserVoice bundle], nil), NSLocalizedStringFromTableInBundle(@"Ideas", @"UserVoice", [UserVoice bundle], nil)];
        }
        
        if (FORMSHEET) {
            _searchController.hidesNavigationBarDuringPresentation = NO;
        }
        
        _tableView.tableHeaderView = _searchController.searchBar;
    }

    if (![UVSession currentSession].clientConfig.whiteLabel) {
        _tableView.tableFooterView = self.poweredByView;
    }

    [_tableView reloadData];
}

- (void)dismiss {
    self.searchResultsController = nil;
    _instantAnswerManager.delegate = nil;
    [super dismiss];
}

- (void)viewWillAppear:(BOOL)animated {
    [_tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)dealloc {
    if (_instantAnswerManager) {
        _instantAnswerManager.delegate = nil;
    }
    
    if (_searchController) {
        _searchController.searchResultsUpdater = nil;
    }
    if (self.searchResultsController) {
        self.searchResultsController = nil;
    }
}

@end
