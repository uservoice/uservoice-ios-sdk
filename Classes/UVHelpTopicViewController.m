//
//  UVHelpTopicViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 11/16/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVHelpTopicViewController.h"
#import "UVHelpTopic.h"
#import "UVArticle.h"
#import "UVArticleViewController.h"
#import "UVNewTicketViewController.h"
#import "UVStyleSheet.h"
#import "UVGradientButton.h"
#import "UVSession.h"
#import "UVConfig.h"

@implementation UVHelpTopicViewController

@synthesize topic;
@synthesize articles;

- (id)initWithTopic:(UVHelpTopic *)theTopic {
    if (self = [super init]) {
        self.topic = theTopic;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [articles count];
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    UVArticle *article = (UVArticle *)[articles objectAtIndex:indexPath.row];
    UVArticleViewController *next = [[[UVArticleViewController alloc] initWithArticle:article helpfulPrompt:nil returnMessage:nil] autorelease];
    [self.navigationController pushViewController:next animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self createCellForIdentifier:@"Article" tableView:theTableView indexPath:indexPath style:UITableViewCellStyleDefault selectable:YES];
}

- (void)customizeCellForArticle:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    UVArticle *article = [articles objectAtIndex:indexPath.row];
    cell.textLabel.text = article.question;
    cell.imageView.image = [UIImage imageNamed:@"uv_article.png"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
}

- (void)didRetrieveArticles:(NSArray *)theArticles {
    [self hideActivityIndicator];
    self.articles = theArticles;
    [tableView reloadData];
}

- (void)contactUsTapped {
    UIViewController *next = [UVNewTicketViewController viewController];
    UINavigationController *navigationController = [[[UINavigationController alloc] init] autorelease];
    navigationController.navigationBar.tintColor = [UVStyleSheet navigationBarTintColor];
    navigationController.viewControllers = @[next];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];
}

- (void)loadView {
    [self setupGroupedTableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.navigationItem.title = topic.name;
    if ([UVSession currentSession].config.showContactUs) {
        UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 60)] autorelease];
        footer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UVGradientButton *contactUsButton = [[[UVGradientButton alloc] initWithFrame:CGRectMake(IPAD ? 30 : 10, 10, footer.bounds.size.width - (IPAD ? 60 : 20), footer.bounds.size.height - 20)] autorelease];
        [contactUsButton setTitle:NSLocalizedStringFromTable(@"Contact us", @"UserVoice", nil) forState:UIControlStateNormal];
        [contactUsButton addTarget:self action:@selector(contactUsTapped) forControlEvents:UIControlEventTouchUpInside];
        contactUsButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [footer addSubview:contactUsButton];
        tableView.tableFooterView = footer;
    }
    [self showActivityIndicator];
    [UVArticle getArticlesWithTopic:topic delegate:self];
}

- (void)dealloc {
    self.topic = nil;
    self.articles = nil;
    [super dealloc];
}

@end
