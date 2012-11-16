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
    UVArticleViewController *next = [[[UVArticleViewController alloc] initWithArticle:article] autorelease];
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

- (void)loadView {
    [self setupGroupedTableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.navigationItem.title = topic.name;
    // TODO footer contact us button
    [self showActivityIndicator];
    [UVArticle getArticlesWithTopic:topic delegate:self];
}

- (void)dealloc {
    self.topic = nil;
    self.articles = nil;
    [super dealloc];
}

@end
