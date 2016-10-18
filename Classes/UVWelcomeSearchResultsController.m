//
//  UVWelcomeSearchResultsController.m
//  UserVoice
//
//  Created by Donny Davis on 9/5/16.
//  Copyright © 2016 UserVoice Inc. All rights reserved.
//

#import "UVWelcomeSearchResultsController.h"
#import "UVArticle.h"

@interface UVWelcomeSearchResultsController ()
@end

@implementation UVWelcomeSearchResultsController

- (void)loadView {
    [super loadView];
    _instantAnswerManager = [UVInstantAnswerManager new];
}

- (void)dealloc {
    _instantAnswerManager = nil;
}

- (void)dismiss {
    _instantAnswerManager = nil;
    [super dismiss];
}

#pragma mark ===== table cells =====

- (void)initCellForArticleResult:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [_instantAnswerManager initCellForArticle:cell finalCondition:indexPath == nil];
}

- (void)customizeCellForArticleResult:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    id model = [self.searchResults objectAtIndex:indexPath.row];
    [_instantAnswerManager customizeCell:cell forArticle:(UVArticle *)model];
}

- (void)initCellForSuggestionResult:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [_instantAnswerManager initCellForSuggestion:cell finalCondition:indexPath == nil];
}

- (void)customizeCellForSuggestionResult:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    id model = [self.searchResults objectAtIndex:indexPath.row];
    [_instantAnswerManager customizeCell:cell forSuggestion:(UVSuggestion *)model];
}

#pragma mark - Table view data source

- (UITableViewCell *)setupCellForRow:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    NSInteger style = UITableViewCellStyleDefault;
    id model = [self.searchResults objectAtIndex:indexPath.row];
    if ([model isMemberOfClass:[UVArticle class]]) {
        identifier = @"ArticleResult";
    } else {
        identifier = @"SuggestionResult";
    }
    
    return [self createCellForIdentifier:identifier tableView:tableView indexPath:indexPath style:style selectable:YES];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_instantAnswerManager pushViewFor:[self.searchResults objectAtIndex:indexPath.row] parent:self.presentingViewController];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    id model = [self.searchResults objectAtIndex:indexPath.row];
    if ([model isMemberOfClass:[UVArticle class]]) {
        identifier = @"ArticleResult";
    } else {
        identifier = @"SuggestionResult";
    }
    return [self heightForDynamicRowWithReuseIdentifier:identifier indexPath:indexPath];
}

@end
