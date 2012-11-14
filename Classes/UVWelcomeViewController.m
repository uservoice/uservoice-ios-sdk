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
@synthesize scrollView;

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
            UIViewController *next = [UVNewTicketViewController viewController];
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

- (void)postIdeaTapped {
    UVSuggestionListViewController *next = [[[UVSuggestionListViewController alloc] initWithForum:self.forum] autorelease];
    [self.navigationController pushViewController:next animated:YES];
}

- (void)contactUsTapped {
    UIViewController *next = [UVNewTicketViewController viewController];
    UINavigationController *navigationController = [[[UINavigationController alloc] init] autorelease];
    navigationController.navigationBar.tintColor = [UVStyleSheet navigationBarTintColor];
    navigationController.viewControllers = @[next];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];
}

- (void)logoTapped {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.uservoice.com/ios"]];
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [super loadView];
    self.navigationItem.title = NSLocalizedStringFromTable(@"Feedback & Support", @"UserVoice", nil);
    self.scrollView = [[[UIScrollView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.view = scrollView;
    scrollView.backgroundColor = [UIColor colorWithRed:0.94f green:0.95f blue:0.95f alpha:1.0f];

    UIView *buttons = [[[UIView alloc] initWithFrame:CGRectMake(10, 130, scrollView.bounds.size.width - 20, 100)] autorelease];
    buttons.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if ([UVSession currentSession].clientConfig.feedbackEnabled) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(0, 0, buttons.bounds.size.width, 40);
        [button setTitle:NSLocalizedStringFromTable(@"Post an idea on our forum", @"UserVoice", nil) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(postIdeaTapped) forControlEvents:UIControlEventTouchUpInside];
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [buttons addSubview:button];
    }
    if ([UVSession currentSession].clientConfig.ticketsEnabled) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(0, 50, buttons.bounds.size.width, 40);
        [button setTitle:NSLocalizedStringFromTable(@"Contact us", @"UserVoice", nil) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(contactUsTapped) forControlEvents:UIControlEventTouchUpInside];
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [buttons addSubview:button];
    }
    [scrollView addSubview:buttons];

    UIView *logo = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    UILabel *poweredBy = [[[UILabel alloc] initWithFrame:CGRectMake(0, 5, 0, 0)] autorelease];
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
    logo.center = CGPointMake(scrollView.bounds.size.width / 2, scrollView.bounds.size.height - logo.bounds.size.height / 2 - 15);
    logo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    [logo addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoTapped)] autorelease]];
    
    [scrollView addSubview:logo];
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
    self.scrollView = nil;
    [super dealloc];
}

@end
