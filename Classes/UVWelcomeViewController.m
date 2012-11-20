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
#import "UVHelpTopic.h"
#import "UVHelpTopicViewController.h"
#import "UVConfig.h"

#define UV_WELCOME_VIEW_ROW_FEEDBACK 0
#define UV_WELCOME_VIEW_ROW_SUPPORT 1

@implementation UVWelcomeViewController

@synthesize scrollView;
@synthesize flashButton;
@synthesize flashMessageLabel;
@synthesize flashTitleLabel;
@synthesize flashView;
@synthesize buttons;

- (id)init {
    if (self = [super init]) {
        self.title = NSLocalizedStringFromTable(@"Welcome", @"UserVoice", nil);
    }
    return self;
}

- (NSString *)backButtonTitle {
    return NSLocalizedStringFromTable(@"Welcome", @"UserVoice", nil);
}

- (BOOL)showArticles {
    return [UVSession currentSession].config.topicId || [[UVSession currentSession].topics count] == 0;
}

#pragma mark ===== table cells =====

- (void)customizeCellForTopic:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    UVHelpTopic *topic = [[UVSession currentSession].topics objectAtIndex:indexPath.row];
    cell.textLabel.text = topic.name;
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

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    if ([self showArticles])
        identifier = @"Article";
    else
        identifier = @"Topic";

    return [self createCellForIdentifier:identifier tableView:theTableView indexPath:indexPath style:UITableViewCellStyleDefault selectable:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([[UVSession currentSession].topics count] > 0 || [[UVSession currentSession].articles count] > 0)
        return 1;
    else
        return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self showArticles])
        return [[UVSession currentSession].articles count];
    else
        return [[UVSession currentSession].topics count];
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    [[UVSession currentSession] clearFlash];
    if ([self showArticles]) {
        UVArticle *article = (UVArticle *)[[UVSession currentSession].articles objectAtIndex:indexPath.row];
        UVArticleViewController *next = [[[UVArticleViewController alloc] initWithArticle:article] autorelease];
        [self.navigationController pushViewController:next animated:YES];
    } else {
        UVHelpTopic *topic = (UVHelpTopic *)[[UVSession currentSession].topics objectAtIndex:indexPath.row];
        UVHelpTopicViewController *next = [[[UVHelpTopicViewController alloc] initWithTopic:topic] autorelease];
        [self.navigationController pushViewController:next animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([UVSession currentSession].config.topicId)
        return [((UVHelpTopic *)[[UVSession currentSession].topics objectAtIndex:0]) name];
    else
        return NSLocalizedStringFromTable(@"Knowledge Base", @"UserVoice", nil);
}

- (void)postIdeaTapped {
    [[UVSession currentSession] clearFlash];
    UVSuggestionListViewController *next = [[[UVSuggestionListViewController alloc] initWithForum:[UVSession currentSession].clientConfig.forum] autorelease];
    [self.navigationController pushViewController:next animated:YES];
}

- (void)contactUsTapped {
    [[UVSession currentSession] clearFlash];
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

- (void)flashButtonTapped {
    UIViewController *next = [[[UVSuggestionDetailsViewController alloc] initWithSuggestion:[UVSession currentSession].flashSuggestion] autorelease];
    UINavigationController *navigationController = [[[UINavigationController alloc] init] autorelease];
    navigationController.navigationBar.tintColor = [UVStyleSheet navigationBarTintColor];
    navigationController.viewControllers = @[next];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];
}

#pragma mark ===== Basic View Methods =====

- (void)updateLayout {
    if ([UVSession currentSession].flashMessage) {
        flashView.hidden = NO;
        flashTitleLabel.text = [UVSession currentSession].flashTitle;
        flashMessageLabel.text = [UVSession currentSession].flashMessage;
        if ([UVSession currentSession].flashSuggestion) {
            flashButton.hidden = NO;
            flashView.frame = CGRectMake(0, 0, scrollView.bounds.size.width, 140);
        } else {
            flashButton.hidden = YES;
            flashView.frame = CGRectMake(0, 0, scrollView.bounds.size.width, 80);
        }
        buttons.frame = CGRectMake(10, flashView.frame.origin.y + flashView.frame.size.height + 20, scrollView.bounds.size.width - 20, 100);
    } else {
        flashView.hidden = YES;
        buttons.frame = CGRectMake(10, 20, scrollView.bounds.size.width - 20, 100);
    }
    tableView.frame = CGRectMake(tableView.frame.origin.x, buttons.frame.origin.y + buttons.frame.size.height, tableView.frame.size.width, tableView.contentSize.height);
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, tableView.frame.origin.y + tableView.contentSize.height);
}

- (void)loadView {
    [super loadView];
    self.navigationItem.title = NSLocalizedStringFromTable(@"Feedback & Support", @"UserVoice", nil);
    self.scrollView = [[[UIScrollView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.view = scrollView;
    scrollView.backgroundColor = [UIColor colorWithRed:0.94f green:0.95f blue:0.95f alpha:1.0f];

    self.flashView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, 100)] autorelease];
    flashView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
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
    self.flashButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    flashButton.frame = CGRectMake(10, 80, flashView.bounds.size.width - 20, 40);
    [flashButton setTitle:NSLocalizedStringFromTable(@"View idea", @"UserVoice", nil) forState:UIControlStateNormal];
    [flashButton addTarget:self action:@selector(flashButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    flashButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [flashView addSubview:flashButton];
    UIView *border = [[[UIView alloc] initWithFrame:CGRectMake(0, flashView.bounds.size.height - 2, flashView.bounds.size.width, 1)] autorelease];
    border.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    border.backgroundColor = [UIColor colorWithRed:0.82f green:0.84f blue:0.86f alpha:1.0f];
    [flashView addSubview:border];
    border = [[[UIView alloc] initWithFrame:CGRectMake(0, flashView.bounds.size.height - 1, flashView.bounds.size.width, 1)] autorelease];
    border.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    border.backgroundColor = [UIColor whiteColor];
    [flashView addSubview:border];
    [scrollView addSubview:flashView];

    self.buttons = [[[UIView alloc] initWithFrame:CGRectMake(10, 20, scrollView.bounds.size.width - 20, 100)] autorelease];
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

    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, buttons.frame.origin.y + buttons.frame.size.height, scrollView.frame.size.width, 1000) style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:tableView];

    UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 50)] autorelease];
    footer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
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
    logo.center = CGPointMake(footer.bounds.size.width / 2, footer.bounds.size.height - logo.bounds.size.height / 2 - 15);
    logo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    [logo addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoTapped)] autorelease]];
    [footer addSubview:logo];
    
    tableView.tableFooterView = footer;
    [tableView reloadData];
    [self updateLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self updateLayout];
}

- (void)dealloc {
    self.scrollView = nil;
    self.flashButton = nil;
    self.flashMessageLabel = nil;
    self.flashTitleLabel = nil;
    self.flashView = nil;
    self.buttons = nil;
    [super dealloc];
}

@end
