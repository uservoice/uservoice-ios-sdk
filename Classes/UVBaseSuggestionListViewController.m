//
//  UVBaseSuggestionListViewController.m
//  UserVoice
//
//  Created by UserVoice on 11/12/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVBaseSuggestionListViewController.h"
#import "UVSuggestionDetailsViewController.h"
#import "UVSuggestion.h"
#import "UVCategory.h"
#import "UVClientConfig.h"
#import "UVStyleSheet.h"
#import "UVBaseGroupedCell.h"
#import "UVSuggestionChickletView.h"
#import "UVSuggestionButton.h"
#import <QuartzCore/QuartzCore.h>
#import "UVSuggestionButton.h"

#define UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND 104

@implementation UVBaseSuggestionListViewController

@synthesize suggestions;

- (void)pushSuggestionShowView:(NSInteger)index {
	UVSuggestion *suggestion = [suggestions objectAtIndex:index];
	UVSuggestionDetailsViewController *next = [[UVSuggestionDetailsViewController alloc] init];
	next.suggestion = suggestion;
	
	[self.navigationController pushViewController:next animated:YES];
	[next release];
}

#pragma mark ===== common table cells =====

- (void)initCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	// getting the cell size
    //CGRect contentRect = cell.contentView.bounds;
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	CGRect contentRect = CGRectMake(0, 0, screenWidth, 71);
	UVSuggestionButton *button = [[UVSuggestionButton alloc] initWithIndex:indexPath.row andFrame:contentRect];	
	NSLog(@"Init suggestion with index: %d", indexPath.row);
	
	//[button addTarget:self action:@selector(pushSuggestionShowView:) forControlEvents:UIControlEventTouchUpInside];	
	button.tag = UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND;
	
	//UVSuggestion *suggestion = [[self suggestions] objectAtIndex:indexPath.row];
	//[button showSuggestion:suggestion withIndex:indexPath.row];
	
	[cell.contentView addSubview:button];
	[button release];
		
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)customizeCellForSuggestion:(UVBaseGroupedCell *)cell indexPath:(NSIndexPath *)indexPath {
	NSLog(@"Customize suggestion with index: %d", indexPath.row);
	
	UVSuggestion *suggestion = [[self suggestions] objectAtIndex:indexPath.row];
	UVSuggestionButton *button = (UVSuggestionButton *)[cell.contentView viewWithTag:UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND];
	[button setZebraColorFromIndex:indexPath.row];
	[button showSuggestion:suggestion withIndex:indexPath.row];
}

- (void)initCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	//NSLog(@"Load more index: %d", indexPath.row);
	
	//CGRect contentRect = cell.contentView.bounds;
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	CGRect contentRect = CGRectMake(0, 0, screenWidth, 71);
	UVCellViewWithIndex *cellView = [[UVCellViewWithIndex alloc] initWithIndex:indexPath.row andFrame:contentRect];
	[cellView setZebraColorFromIndex:indexPath.row];
		
	//[button addTarget:self action:@selector(retrieveMoreSuggestions) forControlEvents:UIControlEventTouchUpInside];	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	// Can't use built-in textLabel, as this forces a white background
	UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, screenWidth, 18)];
	textLabel.text = @"Load more ideas...";
	textLabel.textColor = [UIColor blackColor];
	textLabel.backgroundColor = [UIColor clearColor];
	textLabel.font = [UIFont boldSystemFontOfSize:18];
	textLabel.textAlignment = UITextAlignmentCenter;
	[cell addSubview:textLabel];
	[textLabel release];
		
	[cell.contentView addSubview:cellView];
	[cellView release];
}

- (void)customizeCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UIColor *bgColor = indexPath.row % 2 == 0 ? [UVStyleSheet darkZebraBgColor] : [UVStyleSheet lightZebraBgColor];
	cell.backgroundView.backgroundColor = bgColor;
}

#pragma mark ===== basic view methods =====

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end
