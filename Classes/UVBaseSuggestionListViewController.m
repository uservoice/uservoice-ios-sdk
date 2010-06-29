//
//  UVBaseSuggestionListViewController.m
//  UserVoice
//
//  Created by Mirko Froehlich on 11/12/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVBaseSuggestionListViewController.h"
#import "UVSuggestion.h"
#import "UVCategory.h"
#import "UVStyleSheet.h"
#import "UVSuggestionChickletView.h"

#define UV_BASE_SUGGESTION_LIST_TAG_CELL_TITLE 100
#define UV_BASE_SUGGESTION_LIST_TAG_CELL_CATEGORY 101
#define UV_BASE_SUGGESTION_LIST_TAG_CELL_CHICKLET 102

@implementation UVBaseSuggestionListViewController

@synthesize suggestions;

#pragma mark ===== common table cells =====

- (void)initCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	cell.backgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
	[self addHighlightToCell:cell];
	
	// Title
	UILabel *label = [[UILabel alloc] init];
	label.tag = UV_BASE_SUGGESTION_LIST_TAG_CELL_TITLE;
	label.lineBreakMode = UILineBreakModeTailTruncation;
	label.numberOfLines = 0;
	label.font = [UIFont boldSystemFontOfSize:14];
	label.textColor = [UIColor blackColor];
	label.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:label];
	[label release];

	// Forum + Category
	label = [[UILabel alloc] initWithFrame:CGRectMake(75, 50, 225, 14)];
	label.tag = UV_BASE_SUGGESTION_LIST_TAG_CELL_CATEGORY;
	label.lineBreakMode = UILineBreakModeTailTruncation;
	label.numberOfLines = 1;
	label.font = [UIFont boldSystemFontOfSize:11];
	label.textColor = [UIColor darkGrayColor];
	label.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:label];
	[label release];
	
	// Chicklet
	UVSuggestionChickletView *chicklet = [[UVSuggestionChickletView alloc] initWithOrigin:CGPointMake(10, 5)];
	chicklet.tag = UV_BASE_SUGGESTION_LIST_TAG_CELL_CHICKLET;
	[cell.contentView addSubview:chicklet];
	[chicklet release];
	
	// Highlight row at the top (dark shadow is already taken care of by table separator)
	UIView *highlight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
	highlight.backgroundColor = [UVStyleSheet topSeparatorColor];
	highlight.opaque = YES;
	[cell.contentView addSubview:highlight];
	[highlight release];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)customizeCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UVSuggestion *suggestion = [[self suggestions] objectAtIndex:indexPath.row];
	
	BOOL darkZebra = indexPath.row % 2 == 0;
	cell.backgroundView.backgroundColor = [UVStyleSheet zebraBgColor:darkZebra];

	UILabel *label = (UILabel *)[cell.contentView viewWithTag:UV_BASE_SUGGESTION_LIST_TAG_CELL_TITLE];
	CGSize maxSize = CGSizeMake(225, 34);
	CGSize size = [suggestion.title sizeWithFont:label.font constrainedToSize:maxSize lineBreakMode:UILineBreakModeTailTruncation];
	label.frame = CGRectMake(75, 10, size.width, size.height);
	label.text = suggestion.title;
	
	label = (UILabel *)[cell.contentView viewWithTag:UV_BASE_SUGGESTION_LIST_TAG_CELL_CATEGORY];
	label.text = suggestion.categoryString;

	UVSuggestionChickletView *chicklet = (UVSuggestionChickletView *)[cell.contentView viewWithTag:UV_BASE_SUGGESTION_LIST_TAG_CELL_CHICKLET];
	UVSuggestionChickletStyle style;
	if (suggestion.status)
	{
		style = darkZebra ? UVSuggestionChickletStyleDark : UVSuggestionChickletStyleLight;
	}
	else
	{
		style = UVSuggestionChickletStyleEmpty;
	}
	[chicklet updateWithSuggestion:suggestion style:style];
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
