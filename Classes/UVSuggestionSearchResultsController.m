//
//  UVSuggestionSearchResultsController.m
//  UserVoice
//
//  Created by Donny Davis on 9/13/16.
//  Copyright © 2016 UserVoice Inc. All rights reserved.
//

#import "UVSuggestionSearchResultsController.h"
#import "UVUtils.h"
#import "UVClientConfig.h"
#import "UVSession.h"
#import "UVSuggestion.h"
#import "UVSuggestionDetailsViewController.h"

@interface UVSuggestionSearchResultsController ()

@end

@implementation UVSuggestionSearchResultsController

- (void)dismiss {
    [super dismiss];
}

#pragma mark ===== table cells =====

- (void)initCellForResult:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [self initCellForSuggestion:cell indexPath:indexPath];
}

- (void)customizeCellForResult:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [self customizeCellForSuggestion:[self.searchResults objectAtIndex:indexPath.row] cell:cell];
}

#pragma mark - Table view data source

- (UITableViewCell *)setupCellForRow:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"Result";
    NSInteger style = UITableViewCellStyleDefault;
    
    return [self createCellForIdentifier:identifier tableView:tableView indexPath:indexPath style:style selectable:YES];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showSuggestion:[self.searchResults objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForDynamicRowWithReuseIdentifier:@"Result" indexPath:indexPath];
}

- (void)showSuggestion:(UVSuggestion *)suggestion {
    UVSuggestionDetailsViewController *next = [[UVSuggestionDetailsViewController alloc] initWithSuggestion:suggestion];
    [self.presentingViewController.navigationController pushViewController:next animated:YES];
}

@end
