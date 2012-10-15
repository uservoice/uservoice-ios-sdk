//
//  UVWelcomeViewController.m
//  UserVoice
//
//  Created by UserVoice on 12/15/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVWelcomeViewController.h"
#import "UVStyleSheet.h"
#import "UVFooterView.h"
#import "UVSession.h"
#import "UVForum.h"
#import "UVClientConfig.h"
#import "UVSubdomain.h"
#import "UVNewTicketViewController.h"
#import "UVSuggestionListViewController.h"
#import "UVSignInViewController.h"
#import "UVSuggestion.h"
#import "UVArticle.h"
#import "UVSuggestionDetailsViewController.h"
#import "UVArticleViewController.h"
#import <QuartzCore/QuartzCore.h>

#define UV_WELCOME_VIEW_ROW_FEEDBACK 0
#define UV_WELCOME_VIEW_ROW_SUPPORT 1

@implementation UVWelcomeViewController

@synthesize forum = _forum;

- (id)init {
    if (self = [super init]) {
        self.title = NSLocalizedStringFromTable(@"Welcome", @"UserVoice", nil);
    }
    return self;
}

- (NSString *)backButtonTitle {
    return NSLocalizedStringFromTable(@"Welcome", @"UserVoice", nil);
}

#pragma mark ===== table cells =====

- (void)initCellForForum:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = NSLocalizedStringFromTable(@"Give feedback", @"UserVoice", nil);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.minimumFontSize = 8.0;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)initCellForSupport:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = NSLocalizedStringFromTable(@"Contact support", @"UserVoice", nil);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.minimumFontSize = 8.0;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)customizeCellForArticle:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVArticle *article = [[UVSession currentSession].clientConfig.topArticles objectAtIndex:indexPath.row];
    cell.textLabel.text = article.question;
    cell.imageView.image = [UIImage imageNamed:@"uv_article.png"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
}

- (void)customizeCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVSuggestion *suggestion = [[UVSession currentSession].clientConfig.topSuggestions objectAtIndex:indexPath.row];
    cell.textLabel.text = suggestion.title;
    cell.imageView.image = [UIImage imageNamed:@"uv_idea.png"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    BOOL selectable = YES;

    UITableViewCellStyle style = UITableViewCellStyleDefault;
    if (indexPath.section == 0) {
        if (indexPath.row == 0 && [UVSession currentSession].clientConfig.feedbackEnabled) {
            identifier = @"Forum";
        } else {
            identifier = @"Support";
        }
    } else if (indexPath.section == 1 && [UVSession currentSession].clientConfig.ticketsEnabled) {
        identifier = @"Article";
        style = UITableViewCellStyleSubtitle;
    } else {
        identifier = @"Suggestion";
        style = UITableViewCellStyleSubtitle;
    }

    return [self createCellForIdentifier:identifier
                               tableView:theTableView
                               indexPath:indexPath
                                   style:style
                              selectable:selectable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 1;
    if ([UVSession currentSession].clientConfig.ticketsEnabled)
        sections += 1;
    if ([UVSession currentSession].clientConfig.feedbackEnabled)
        sections += 1;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        NSInteger rows = 0;
        if ([UVSession currentSession].clientConfig.ticketsEnabled)
            rows += 1;
        if ([UVSession currentSession].clientConfig.feedbackEnabled)
            rows += 1;
        return rows;
    } else if (section == 1 && [UVSession currentSession].clientConfig.ticketsEnabled) {
        return [[UVSession currentSession].clientConfig.topArticles count];
    } else {
        return [[UVSession currentSession].clientConfig.topSuggestions count];
    }
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        if (indexPath.row == 0 && [UVSession currentSession].clientConfig.feedbackEnabled) {
            UVSuggestionListViewController *next = [[[UVSuggestionListViewController alloc] initWithForum:self.forum] autorelease];
            [self.navigationController pushViewController:next animated:YES];
        } else {
            UVNewTicketViewController *next = [[[UVNewTicketViewController alloc] init] autorelease];
            [self.navigationController pushViewController:next animated:YES];
        }
    } else if (indexPath.section == 1 && [UVSession currentSession].clientConfig.ticketsEnabled) {
        UVArticle *article = [[UVSession currentSession].clientConfig.topArticles objectAtIndex:indexPath.row];
        [[UVSession currentSession] trackInteraction:@"cf" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:article.articleId], @"id", nil]];
        UVArticleViewController *next = [[[UVArticleViewController alloc] initWithArticle:article] autorelease];
        [self.navigationController pushViewController:next animated:YES];
    } else {
        UVSuggestion *suggestion = [[UVSession currentSession].clientConfig.topSuggestions objectAtIndex:indexPath.row];
        [[UVSession currentSession] trackInteraction:@"ci" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:suggestion.suggestionId], @"id", nil]];
        UVSuggestionDetailsViewController *next = [[[UVSuggestionDetailsViewController alloc] initWithSuggestion:suggestion] autorelease];
        [self.navigationController pushViewController:next animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if ([UVSession currentSession].clientConfig.ticketsEnabled && [UVSession currentSession].clientConfig.feedbackEnabled) {
            return NSLocalizedStringFromTable(@"Feedback & Support", @"UserVoice", nil);
        } else if ([UVSession currentSession].clientConfig.ticketsEnabled) {
            return NSLocalizedStringFromTable(@"Support", @"UserVoice", nil);
        } else {
            return NSLocalizedStringFromTable(@"Feedback", @"UserVoice", nil);
        }
        return NSLocalizedStringFromTable(@"Feedback & Support", @"UserVoice", nil);
    } else if (section == 1 && [UVSession currentSession].clientConfig.ticketsEnabled) {
        return NSLocalizedStringFromTable(@"FAQs", @"UserVoice", nil);
    } else {
        return [[UVSession currentSession].clientConfig.subdomain ideasHeading];
    }
}

- (CGFloat)tableView:(UITableView *)theTableView heightForHeaderInSection:(NSInteger)section {
    return (section == 0) ? 36 + 11 : 36;
}

- (UIView *)tableView:(UITableView *)theTableView viewForHeaderInSection:(NSInteger)section {
    UIView *containerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];
    containerView.backgroundColor = [UIColor clearColor];
    CGFloat marginLeft = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 45 : 10;
    CGRect labelFrame = CGRectMake(marginLeft, 2, 320, 30);
    if (section == 0)
        labelFrame.origin.y += 11;
    UILabel *label = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:17];
    label.shadowColor = [UVStyleSheet tableViewHeaderShadowColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.textColor = [UVStyleSheet tableViewHeaderColor];
    label.text = [self tableView:theTableView titleForHeaderInSection:section];
    [containerView addSubview:label];
    return containerView;
}

#pragma mark ===== Basic View Methods =====

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [self setupGroupedTableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.sectionFooterHeight = 0.0;
    self.tableView.tableFooterView = [UVFooterView footerViewForController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.forum = [UVSession currentSession].clientConfig.forum;
    if ([self needsReload]) {
        [(UVFooterView *)tableView.tableFooterView reloadFooter];
    }

    [tableView reloadData];

    UVFooterView *footer = (UVFooterView *) self.tableView.tableFooterView;
    [footer reloadFooter];
}

- (void)dealloc {
    self.forum = nil;
    self.tableView = nil;
    [super dealloc];
}

@end
