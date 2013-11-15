//
//  UVInstantAnswersViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/18/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVInstantAnswersViewController.h"
#import "UVArticle.h"
#import "UVSuggestion.h"
#import "UVDeflection.h"

@implementation UVInstantAnswersViewController

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [self setupGroupedTableView];
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
    return [self createCellForIdentifier:@"InstantAnswer" tableView:theTableView indexPath:indexPath style:UITableViewCellStyleSubtitle selectable:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self sectionIsArticles:section] ? NSLocalizedStringFromTable(@"Related articles", @"UserVoice", nil) : NSLocalizedStringFromTable(@"Related feedback", @"UserVoice", nil);
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = [[self resultsForSection:indexPath.section] objectAtIndex:indexPath.row];
    [_instantAnswerManager pushViewFor:model parent:self];
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    id model = [[self resultsForSection:indexPath.section] objectAtIndex:indexPath.row];
    if ([model isMemberOfClass:[UVArticle class]]) {
        UVArticle *article = (UVArticle *)model;
        cell.textLabel.text = article.question;
        cell.detailTextLabel.text = article.topicName;
        cell.imageView.image = [UIImage imageNamed:@"uv_article.png"];
    } else {
        UVSuggestion *suggestion = (UVSuggestion *)model;
        cell.textLabel.text = suggestion.title;
        cell.detailTextLabel.text = suggestion.forumName;
        cell.imageView.image = [UIImage imageNamed:@"uv_idea.png"];
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
