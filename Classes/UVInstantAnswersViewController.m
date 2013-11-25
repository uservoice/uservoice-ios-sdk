//
//  UVInstantAnswersViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/18/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVInstantAnswersViewController.h"
#import "UVArticle.h"
#import "UVSuggestion.h"
#import "UVDeflection.h"

#define TITLE 20
#define SUBSCRIBER_COUNT 21
#define STATUS 22
#define STATUS_COLOR 23
#define SECTION 24

@implementation UVInstantAnswersViewController

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [self setupGroupedTableView];
    self.navigationItem.title = NSLocalizedStringFromTable(@"Are any of these helpful?", @"UserVoice", nil);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Skip", @"UserVoice", nil)
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(next)];

    NSArray *visibleIdeas = [_instantAnswerManager.ideas subarrayWithRange:NSMakeRange(0, MIN(3, _instantAnswerManager.ideas.count))];
    NSArray *visibleArticles = [_instantAnswerManager.articles subarrayWithRange:NSMakeRange(0, MIN(3, _instantAnswerManager.articles.count))];
    [UVDeflection trackSearchDeflection:[visibleIdeas arrayByAddingObjectsFromArray:visibleArticles]];
}

#pragma mark ===== UITableViewDataSource Methods =====

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return (_instantAnswerManager.ideas.count > 0 && _instantAnswerManager.articles.count > 0) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return MIN([self resultsForSection:section].count, 3);
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self sectionIsArticles:indexPath.section] ? @"Article" : @"Suggestion";
    return [self createCellForIdentifier:identifier tableView:theTableView indexPath:indexPath style:UITableViewCellStyleSubtitle selectable:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self sectionIsArticles:section] ? NSLocalizedStringFromTable(@"Related articles", @"UserVoice", nil) : NSLocalizedStringFromTable(@"Related feedback", @"UserVoice", nil);
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = [[self resultsForSection:indexPath.section] objectAtIndex:indexPath.row];
    [_instantAnswerManager pushViewFor:model parent:self];
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)initCellForArticle:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.separatorInset = UIEdgeInsetsMake(0, 58, 0, 0);
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_article.png"]];
    UILabel *title = [UILabel new];
    title.font = [UIFont systemFontOfSize:18];
    title.numberOfLines = 0;
    title.tag = TITLE;
    UILabel *section = [UILabel new];
    section.font = [UIFont systemFontOfSize:12];
    section.textColor = [UIColor grayColor];
    section.tag = SECTION;
    NSArray *constraints = @[
        @"|-15-[icon(==28)]-15-[title]-|",
        @"|-58-[section]",
        @"V:|-15-[icon(==28)]",
        @"V:|-12-[title]-6-[section]"
    ];
    [self configureView:cell.contentView
               subviews:NSDictionaryOfVariableBindings(icon, title, section)
            constraints:constraints
         finalCondition:indexPath == nil
        finalConstraint:@"V:[section]-14-|"];
}

- (void)customizeCellForArticle:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVArticle *article = (UVArticle *)[[self resultsForSection:indexPath.section] objectAtIndex:indexPath.row];
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:TITLE];
    UILabel *section = (UILabel *)[cell.contentView viewWithTag:SECTION];
    title.text = article.question;
    section.text = article.topicName;
}

- (void)initCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.separatorInset = UIEdgeInsetsMake(0, 58, 0, 0);
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_idea.png"]];
    UIImageView *heart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_heart.png"]];
    UILabel *subs = [UILabel new];
    subs.font = [UIFont systemFontOfSize:14];
    subs.textColor = [UIColor grayColor];
    subs.tag = SUBSCRIBER_COUNT;
    UILabel *title = [UILabel new];
    title.numberOfLines = 0;
    title.tag = TITLE;
    title.font = [UIFont systemFontOfSize:17];
    UILabel *status = [UILabel new];
    status.font = [UIFont systemFontOfSize:11];
    status.tag = STATUS;
    UIView *statusColor = [UIView new];
    statusColor.tag = STATUS_COLOR;
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 9, 9);
    [statusColor.layer addSublayer:layer];
    NSArray *constraints = @[
        @"|-15-[icon(==28)]-15-[title]-|",
        @"|-58-[heart(==9)]-3-[subs]-10-[statusColor(==9)]-5-[status]",
        @"V:|-15-[icon(==28)]",
        @"V:|-12-[title]-6-[heart(==9)]",
        @"V:[title]-6-[statusColor(==9)]",
        @"V:[title]-4-[status]",
        @"V:[title]-2-[subs]"
    ];
    [self configureView:cell.contentView
               subviews:NSDictionaryOfVariableBindings(icon, subs, title, heart, statusColor, status)
            constraints:constraints
         finalCondition:indexPath == nil
        finalConstraint:@"V:[heart]-14-|"];
}

- (void)customizeCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVSuggestion *suggestion = (UVSuggestion *)[[self resultsForSection:indexPath.section] objectAtIndex:indexPath.row];
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:TITLE];
    UILabel *subs = (UILabel *)[cell.contentView viewWithTag:SUBSCRIBER_COUNT];
    UILabel *status = (UILabel *)[cell.contentView viewWithTag:STATUS];
    UIView *statusColor = [cell.contentView viewWithTag:STATUS_COLOR];
    title.text = suggestion.title;
    subs.text = [NSString stringWithFormat:@"%d", (int)suggestion.subscriberCount];
    [statusColor.layer.sublayers.lastObject setBackgroundColor:suggestion.statusColor.CGColor];
    status.textColor = suggestion.statusColor;
    status.text = [suggestion.status uppercaseString];
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self sectionIsArticles:indexPath.section]) {
        return [self heightForDynamicRowWithReuseIdentifier:@"Article" indexPath:indexPath];
    } else {
        return [self heightForDynamicRowWithReuseIdentifier:@"Suggestion" indexPath:indexPath];
    }
}

#pragma mark ===== Misc =====

- (void)next {
    [_instantAnswerManager skipInstantAnswers];
}

- (NSArray *)resultsForSection:(NSInteger)section {
    return [self sectionIsArticles:section] ? _instantAnswerManager.articles : _instantAnswerManager.ideas;
}

- (BOOL)sectionIsArticles:(NSInteger)section {
    return (_articlesFirst && _instantAnswerManager.articles.count > 0) ? section == 0 : section == 1;
}

@end
