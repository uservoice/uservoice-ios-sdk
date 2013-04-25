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
#import "UVNewTicketViewController.h"
#import "UVSuggestionListViewController.h"
#import "UVSuggestion.h"
#import "UVArticle.h"
#import "UVSuggestionDetailsViewController.h"
#import "UVArticleViewController.h"
#import "UVHelpTopic.h"
#import "UVHelpTopicViewController.h"
#import "UVConfig.h"
#import "UVNewSuggestionViewController.h"
#import "UVGradientButton.h"

#define UV_WELCOME_VIEW_ROW_FEEDBACK 0
#define UV_WELCOME_VIEW_ROW_SUPPORT 1

#define SEARCH_BAR_BORDER1 1001
#define SEARCH_BAR_BORDER2 1002

@implementation UVWelcomeViewController

@synthesize scrollView;
@synthesize flashTable;
@synthesize flashMessageLabel;
@synthesize flashTitleLabel;
@synthesize flashView;
@synthesize buttons;
@synthesize searchController;

- (id)init {
    if (self = [super init]) {
        self.title = NSLocalizedStringFromTable(@"Welcome", @"UserVoice", nil);
    }
    return self;
}

- (BOOL)showArticles {
    return [UVSession currentSession].config.topicId || [[UVSession currentSession].topics count] == 0;
}

- (void)clearFlash {
    [[UVSession currentSession] clearFlash];
    [self performSelector:@selector(updateLayout) withObject:nil afterDelay:1];
}

#pragma mark ===== table cells =====

- (void)customizeCellForForum:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = NSLocalizedStringFromTable(@"Feedback Forum", @"UserVoice", nil);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)customizeCellForTopic:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.row == [[UVSession currentSession].topics count]) {
        cell.textLabel.text = NSLocalizedStringFromTable(@"All Articles", @"UserVoice", nil);
    } else {
        UVHelpTopic *topic = [[UVSession currentSession].topics objectAtIndex:indexPath.row];
        cell.textLabel.text = topic.name;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)customizeCellForArticle:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    UVArticle *article = [[UVSession currentSession].articles objectAtIndex:indexPath.row];
    cell.textLabel.text = article.question;
    cell.imageView.image = [UIImage imageNamed:@"uv_article.png"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
}

- (void)initCellForFlash:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = NSLocalizedStringFromTable(@"View idea", @"UserVoice", nil);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)initCellForInstantAnswer:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [super initCellForInstantAnswer:cell indexPath:indexPath];
    UIView *label = [cell viewWithTag:HIGHLIGHTING_LABEL_TAG];
    label.frame = CGRectMake(40, 12, cell.bounds.size.width - 80, 20);
}

- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [self customizeCellForInstantAnswer:cell index:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    if (theTableView == flashTable) {
        identifier = @"Flash";
    } else if (theTableView == searchController.searchResultsTableView) {
        identifier = @"InstantAnswer";
    } else {
        if (indexPath.section == 0 && [UVSession currentSession].config.showForum)
            identifier = @"Forum";
        else if ([self showArticles])
            identifier = @"Article";
        else
            identifier = @"Topic";
    }

    return [self createCellForIdentifier:identifier tableView:theTableView indexPath:indexPath style:UITableViewCellStyleDefault selectable:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    if (theTableView == flashTable) {
        return [UVSession currentSession].flashSuggestion ? 1 : 0;
    } else if (theTableView == searchController.searchResultsTableView) {
        return 1;
    } else {
        int sections = 0;

        if ([UVSession currentSession].config.showKnowledgeBase && ([[UVSession currentSession].topics count] > 0 || [[UVSession currentSession].articles count] > 0))
            sections++;
        
        if ([UVSession currentSession].config.showForum)
            sections++;

        return sections;
    }
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    if (theTableView == flashTable) {
        return 1;
    } else if (theTableView == searchController.searchResultsTableView) {
        return [instantAnswers count];
    } else {
        if (section == 0 && [UVSession currentSession].config.showForum)
            return 1;
        else if ([self showArticles])
            return [[UVSession currentSession].articles count];
        else
            return [[UVSession currentSession].topics count] + 1;
    }
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (theTableView == flashTable) {
        UIViewController *next = [[[UVSuggestionDetailsViewController alloc] initWithSuggestion:[UVSession currentSession].flashSuggestion] autorelease];
        [self.navigationController pushViewController:next animated:YES];
    } else if (theTableView == searchController.searchResultsTableView) {
        [self selectInstantAnswerAtIndex:indexPath.row];
    } else {
        [self clearFlash];
        if (indexPath.section == 0 && [UVSession currentSession].config.showForum) {
            UVSuggestionListViewController *next = [[[UVSuggestionListViewController alloc] init] autorelease];
            [self.navigationController pushViewController:next animated:YES];
        } else if ([self showArticles]) {
            UVArticle *article = (UVArticle *)[[UVSession currentSession].articles objectAtIndex:indexPath.row];
            UVArticleViewController *next = [[[UVArticleViewController alloc] initWithArticle:article helpfulPrompt:nil returnMessage:nil] autorelease];
            [self.navigationController pushViewController:next animated:YES];
        } else {
            UVHelpTopic *topic = nil;
            if (indexPath.row < [[UVSession currentSession].topics count])
                topic = (UVHelpTopic *)[[UVSession currentSession].topics objectAtIndex:indexPath.row];
            UVHelpTopicViewController *next = [[[UVHelpTopicViewController alloc] initWithTopic:topic] autorelease];
            [self.navigationController pushViewController:next animated:YES];
        }
    }
}

- (NSString *)tableView:(UITableView *)theTableView titleForHeaderInSection:(NSInteger)section {
    if (theTableView == flashTable)
        return nil;
    else if (section == 0 && [UVSession currentSession].config.showForum)
        return nil;
    else if ([UVSession currentSession].config.topicId)
        return [((UVHelpTopic *)[[UVSession currentSession].topics objectAtIndex:0]) name];
    else
        return NSLocalizedStringFromTable(@"Knowledge Base", @"UserVoice", nil);
}

- (void)postIdeaTapped {
    [self clearFlash];
    [self presentModalViewController:[UVNewSuggestionViewController viewController]];
}

- (void)contactUsTapped {
    [self clearFlash];
    [self presentModalViewController:[UVNewTicketViewController viewController]];
}

- (void)logoTapped {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.uservoice.com/ios"]];
}

#pragma mark ===== UISearchBarDelegate Methods =====

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchController setActive:YES animated:YES];
    [self updateLayoutAnimated:YES];
    searchController.searchResultsTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    searchController.searchResultsTableView.backgroundView = nil;
    searchController.searchResultsTableView.backgroundColor = [UIColor colorWithRed:0.94f green:0.95f blue:0.95f alpha:1.0f];
    searchController.searchResultsTableView.separatorColor = [UIColor colorWithRed:0.80f green:0.80f blue:0.80f alpha:1.0f];
    [searchBar setShowsCancelButton:YES animated:YES];
    filter = IA_FILTER_ALL;
    searchBar.showsScopeBar = YES;
    searchBar.selectedScopeButtonIndex = 0;
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    controller.searchBar.showsScopeBar = NO;
    [self updateLayoutAnimated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    self.filter = searchBar.selectedScopeButtonIndex;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.instantAnswersQuery = searchBar.text;
    [self loadInstantAnswers];
}

- (void)didLoadInstantAnswers {
    if (searchController.active)
        [searchController.searchResultsTableView reloadData];
}

- (int)maxInstantAnswerResults {
    return 10;
}

#pragma mark ===== Basic View Methods =====

- (void)addButton:(NSString *)title frame:(CGRect)frame action:(SEL)selector autoresizingMask:(int)mask {
    UVGradientButton *button = [[[UVGradientButton alloc] initWithFrame:frame] autorelease];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    button.autoresizingMask = mask;
    [buttons addSubview:button];
}

- (void)updateLayout {
    [self updateLayoutAnimated:NO];
}

- (void)updateLayoutAnimated:(BOOL)animated {
    CGFloat searchY = [UVSession currentSession].config.showKnowledgeBase ? (searchController.active && searchController.searchBar.showsScopeBar ? 80 : 44) : 0;
    BOOL hasButtons = [UVSession currentSession].config.showContactUs || [UVSession currentSession].config.showPostIdea;
    
    void (^update)() = ^{
        if ([UVSession currentSession].flashMessage) {
            flashView.hidden = NO;
            flashTitleLabel.text = [UVSession currentSession].flashTitle;
            flashMessageLabel.text = [UVSession currentSession].flashMessage;
            if ([UVSession currentSession].flashSuggestion) {
                flashView.frame = CGRectMake(0, searchY, scrollView.bounds.size.width, 140);
            } else {
                flashView.frame = CGRectMake(0, searchY, scrollView.bounds.size.width, 80);
            }
            [flashTable reloadData];
            flashTable.frame = CGRectMake(flashTable.frame.origin.x, flashTable.frame.origin.y, flashTable.contentSize.width, flashTable.contentSize.height);
            buttons.frame = CGRectMake(IPAD ? 30 : 10, flashView.frame.origin.y + flashView.frame.size.height + 20, scrollView.bounds.size.width - (IPAD ? 60 : 20), hasButtons ? 44 : 0);
        } else {
            flashView.hidden = YES;
            buttons.frame = CGRectMake(IPAD ? 30 : 10, searchY + 20, scrollView.bounds.size.width - (IPAD ? 60 : 20), hasButtons ? 44 : 0);
        }
        tableView.frame = CGRectMake(tableView.frame.origin.x, buttons.frame.origin.y + buttons.frame.size.height + (IPAD ? 0 : 10) - (hasButtons ? 0 : 20), tableView.frame.size.width, tableView.contentSize.height);
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, tableView.frame.origin.y + tableView.contentSize.height);
    };
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0 options:0 animations:update completion:nil];
    } else {
        update();
    }
}

- (void)loadView {
    [super loadView];
    self.navigationItem.title = NSLocalizedStringFromTable(@"Feedback & Support", @"UserVoice", nil);
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Close", @"UserVoice", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(dismissUserVoice)] autorelease];

    self.scrollView = [[[UIScrollView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.view = scrollView;
    scrollView.backgroundColor = [UIColor colorWithRed:0.94f green:0.95f blue:0.95f alpha:1.0f];
    scrollView.alwaysBounceVertical = YES;

    if ([UVSession currentSession].config.showKnowledgeBase) {
        UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)] autorelease];
        searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        searchBar.placeholder = NSLocalizedStringFromTable(@"Search", @"UserVoice", nil);
        searchBar.delegate = self;
        searchBar.showsScopeBar = NO;
        if ([UVSession currentSession].config.showForum) {
            searchBar.scopeButtonTitles = @[NSLocalizedStringFromTable(@"All", @"UserVoice", nil), NSLocalizedStringFromTable(@"Articles", @"UserVoice", nil), NSLocalizedStringFromTable(@"Ideas", @"UserVoice", nil)];
        }
        UIView *border = [[[UIView alloc] initWithFrame:CGRectMake(0, searchBar.bounds.size.height, searchBar.bounds.size.width, 1)] autorelease];
        border.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        border.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:border];
        [self.view addSubview:searchBar];

        self.searchController = [[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self] autorelease];
        searchController.delegate = self;
        searchController.searchResultsDelegate = self;
        searchController.searchResultsDataSource = self;
    }

    self.flashView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, 100)] autorelease];
    flashView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    flashView.backgroundColor = [UIColor colorWithRed:1.00f green:0.99f blue:0.90f alpha:1.0f];
    self.flashTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, 20, flashView.bounds.size.width - 40, 20)] autorelease];
    flashTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    flashTitleLabel.backgroundColor = [UIColor clearColor];
    flashTitleLabel.textColor = [UIColor colorWithRed:0.30f green:0.34f blue:0.42f alpha:1.0f];
    flashTitleLabel.font = [UIFont boldSystemFontOfSize:15];
    [flashView addSubview:flashTitleLabel];
    self.flashMessageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, 40, flashView.bounds.size.width - 40, 20)] autorelease];
    flashMessageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    flashMessageLabel.backgroundColor = [UIColor clearColor];
    flashMessageLabel.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
    flashMessageLabel.font = [UIFont systemFontOfSize:14];
    [flashView addSubview:flashMessageLabel];
    self.flashTable = [[[UITableView alloc] initWithFrame:CGRectMake(0, IPAD ? 50 : 70, flashView.bounds.size.width, 40) style:UITableViewStyleGrouped] autorelease];
    flashTable.delegate = self;
    flashTable.dataSource = self;
    flashTable.backgroundView = nil;
    flashTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    flashTable.backgroundColor = [UIColor clearColor];
    [flashView addSubview:flashTable];
    UIView *border = [[[UIView alloc] initWithFrame:CGRectMake(0, flashView.bounds.size.height - 2, flashView.bounds.size.width, 1)] autorelease];
    border.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    border.backgroundColor = [UIColor colorWithRed:0.82f green:0.84f blue:0.86f alpha:1.0f];
    [flashView addSubview:border];
    border = [[[UIView alloc] initWithFrame:CGRectMake(0, flashView.bounds.size.height - 1, flashView.bounds.size.width, 1)] autorelease];
    border.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    border.backgroundColor = [UIColor whiteColor];
    [flashView addSubview:border];
    [scrollView addSubview:flashView];

    self.buttons = [[[UIView alloc] initWithFrame:CGRectMake(IPAD ? 30 : 10, 44 + 20, scrollView.bounds.size.width - (IPAD ? 60 : 20), 44)] autorelease];
    buttons.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if ([UVSession currentSession].config.showContactUs && [UVSession currentSession].config.showPostIdea) {
        [self addButton:NSLocalizedStringFromTable(@"Post an idea", @"UserVoice", nil) frame:CGRectMake(0, 0, buttons.bounds.size.width / 2 - (IPAD ? 10 : 5), buttons.bounds.size.height) action:@selector(postIdeaTapped) autoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
        [self addButton:NSLocalizedStringFromTable(@"Contact us", @"UserVoice", nil) frame:CGRectMake(buttons.bounds.size.width / 2 + (IPAD ? 10 : 5), 0, buttons.bounds.size.width / 2 - (IPAD ? 10 : 5), buttons.bounds.size.height) action:@selector(contactUsTapped) autoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin];
    } else if ([UVSession currentSession].config.showPostIdea) {
        [self addButton:NSLocalizedStringFromTable(@"Post an idea", @"UserVoice", nil) frame:buttons.bounds action:@selector(postIdeaTapped) autoresizingMask:UIViewAutoresizingFlexibleWidth];
    } else if ([UVSession currentSession].config.showContactUs) {
        [self addButton:NSLocalizedStringFromTable(@"Contact us", @"UserVoice", nil) frame:buttons.bounds action:@selector(contactUsTapped) autoresizingMask:UIViewAutoresizingFlexibleWidth];
    }
    [scrollView addSubview:buttons];

    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, buttons.frame.origin.y + buttons.frame.size.height, scrollView.frame.size.width, 1000) style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:tableView];

    if (![UVSession currentSession].clientConfig.whiteLabel) {
        UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 50)] autorelease];
        footer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIView *logo = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        UILabel *poweredBy = [[[UILabel alloc] initWithFrame:CGRectMake(0, 6, 0, 0)] autorelease];
        // tweak for retina
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))
            poweredBy.frame = CGRectMake(0, 8, 0, 0);
        poweredBy.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        poweredBy.backgroundColor = [UIColor clearColor];
        poweredBy.textColor = [UIColor grayColor];
        poweredBy.font = [UIFont systemFontOfSize:11];
        poweredBy.text = NSLocalizedStringFromTable(@"powered by", @"UserVoice", nil);
        [poweredBy sizeToFit];
        [logo addSubview:poweredBy];
        UIImageView *image = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_logo.png"]] autorelease];
        image.frame = CGRectMake(poweredBy.bounds.size.width + 7, 0, image.bounds.size.width * 0.8, image.bounds.size.height * 0.8);
        [logo addSubview:image];
        logo.frame = CGRectMake(0, 0, image.frame.origin.x + image.frame.size.width, image.frame.size.height);
        logo.center = CGPointMake(footer.bounds.size.width / 2, footer.bounds.size.height - logo.bounds.size.height / 2 - 15);
        logo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        [logo addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoTapped)] autorelease]];
        [footer addSubview:logo];
        tableView.tableFooterView = footer;
    }

    [tableView reloadData];
    [self updateLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self updateLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateLayout];
}

- (void)dealloc {
    self.scrollView = nil;
    self.flashTable = nil;
    self.flashMessageLabel = nil;
    self.flashTitleLabel = nil;
    self.flashView = nil;
    self.buttons = nil;
    self.searchController = nil;
    [super dealloc];
}

@end
