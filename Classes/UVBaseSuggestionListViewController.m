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
#import "UVStyleSheet.h"
#import "UVBaseGroupedCell.h"
#import "UVSuggestionChickletView.h"
#import "UVSuggestionButton.h"
#import <QuartzCore/QuartzCore.h>
#import "UVSuggestionButton.h"

#define UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND 100

@implementation UVBaseSuggestionListViewController

@synthesize suggestions;

- (UITableViewCell *)createCellForIdentifier:(NSString *)identifier
								   tableView:(UITableView *)theTableView
								   indexPath:(NSIndexPath *)indexPath
									   style:(UITableViewCellStyle)style
								  selectable:(BOOL)selectable {
    UVBaseGroupedCell *cell = (UVBaseGroupedCell *)[theTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UVBaseGroupedCell alloc] initWithStyle:style reuseIdentifier:identifier] autorelease];
		cell.selectionStyle = selectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		
		SEL initCellSelector = NSSelectorFromString([NSString stringWithFormat:@"initCellFor%@:indexPath:", identifier]);
		if ([self respondsToSelector:initCellSelector]) {
			[self performSelector:initCellSelector withObject:cell withObject:indexPath];
		}
	}
	
	SEL customizeCellSelector = NSSelectorFromString([NSString stringWithFormat:@"customizeCellFor%@:indexPath:", identifier]);
	if ([self respondsToSelector:customizeCellSelector]) {
		[self performSelector:customizeCellSelector withObject:cell withObject:indexPath];
	}
	return cell;
}

- (void)pushSuggestionShowView:(UVButtonWithIndex *)button {
	NSLog(@"Suggestion selected: %d", button.index);
	UVSuggestion *suggestion = [suggestions objectAtIndex:button.index];
	UVSuggestionDetailsViewController *next = [[UVSuggestionDetailsViewController alloc] init];
	next.suggestion = suggestion;
	
	[self.navigationController pushViewController:next animated:YES];
	[next release];
}

#pragma mark ===== common table cells =====

- (void)initCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	// getting the cell size
    CGRect contentRect = cell.contentView.bounds;
	UVSuggestionButton *button = [[UVSuggestionButton alloc] initWithIndex:indexPath.row andFrame:contentRect];	
	[button addTarget:self action:@selector(pushSuggestionShowView:) forControlEvents:UIControlEventTouchUpInside];	
	button.tag = UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND;
	
	[cell.contentView addSubview:button];
	[button release];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)customizeCellForSuggestion:(UVBaseGroupedCell *)cell indexPath:(NSIndexPath *)indexPath {
	UVSuggestion *suggestion = [[self suggestions] objectAtIndex:indexPath.row];
	UVSuggestionButton *button = (UVSuggestionButton *)[cell.contentView viewWithTag:UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND];
	[button showSuggestion:suggestion];
}

- (void)initCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	cell.backgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
	[self addHighlightToCell:cell];
	
	// Can't use built-in textLabel, as this forces a white background
	UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, 320, 18)];
	textLabel.text = @"Load more ideas...";
	textLabel.textColor = [UIColor blackColor];
	textLabel.backgroundColor = [UIColor clearColor];
	textLabel.font = [UIFont boldSystemFontOfSize:18];
	textLabel.textAlignment = UITextAlignmentCenter;
	[cell.contentView addSubview:textLabel];
	[textLabel release];
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
