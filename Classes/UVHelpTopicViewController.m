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
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"UVArticle"];
    UVArticle *article = [articles objectAtIndex:indexPath.row];
    cell.textLabel.text = article.question;
    return cell;
}

- (void)didRetrieveArticles:(NSArray *)theArticles {
//    [self hideActivityIndicator];
    self.articles = theArticles;
    [self.tableView reloadData];
}

- (void)contactUsTapped {
//    [self presentModalViewController:[UVNewTicketViewController viewController]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = topic.name;
    if (![UVSession currentSession].config.showContactUs) {
        // hide contact button
    }
//    [self showActivityIndicator];
    [UVArticle getArticlesWithTopicId:topic.topicId delegate:self];
}

- (void)dealloc {
    self.topic = nil;
    self.articles = nil;
    [super dealloc];
}

@end
