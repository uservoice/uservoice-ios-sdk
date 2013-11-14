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
#import "UVContactViewController.h"
#import "UVStyleSheet.h"
#import "UVSession.h"
#import "UVConfig.h"
#import "UVBabayaga.h"

#define LABEL 100

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
    return [UVSession currentSession].config.showContactUs ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? [articles count] : 1;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        UVArticle *article = (UVArticle *)[articles objectAtIndex:indexPath.row];
        UVArticleViewController *next = [[[UVArticleViewController alloc] initWithArticle:article helpfulPrompt:nil returnMessage:nil] autorelease];
        [self.navigationController pushViewController:next animated:YES];
    } else {
        [self presentModalViewController:[[UVContactViewController new] autorelease]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self createCellForIdentifier:@"Article" tableView:theTableView indexPath:indexPath style:UITableViewCellStyleDefault selectable:YES];
    } else {
        return [self createCellForIdentifier:@"Contact" tableView:theTableView indexPath:indexPath style:UITableViewCellStyleDefault selectable:YES];
    }
}

- (void)initCellForContact:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = NSLocalizedStringFromTable(@"Send us a message", @"UserVoice", nil);
    if (IOS7) {
        cell.textLabel.textColor = cell.textLabel.tintColor;
    }
}

- (void)initCellForArticle:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UILabel *label = [[UILabel new] autorelease];
    label.numberOfLines = 0;
    label.tag = LABEL;
    [self configureView:cell.contentView
               subviews:NSDictionaryOfVariableBindings(label)
            constraints:@[@"|-16-[label]-|", @"V:|-10-[label]-10-|"]];
}

- (void)customizeCellForArticle:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVArticle *article = [articles objectAtIndex:indexPath.row];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:LABEL];
    label.text = article.question;
}

- (void)didRetrieveArticles:(NSArray *)theArticles {
    [self hideActivityIndicator];
    self.articles = theArticles;
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self heightForDynamicRowWithReuseIdentifier:@"Article" indexPath:indexPath];
    } else {
        return 44;
    }
}

- (void)loadView {
    [self setupGroupedTableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    if (self.topic) {
        self.navigationItem.title = topic.name;
        [self showActivityIndicator];
        [UVBabayaga track:VIEW_TOPIC id:topic.topicId];
        [UVArticle getArticlesWithTopicId:topic.topicId delegate:self];
    } else {
        self.navigationItem.title = NSLocalizedStringFromTable(@"All Articles", @"UserVoice", nil);
        self.articles = [UVSession currentSession].articles;
        [tableView reloadData];
    }
}

- (void)dealloc {
    self.topic = nil;
    self.articles = nil;
    [super dealloc];
}

@end
