//
//  UVSuggestionButton.m
//  UserVoice
//
//  Created by Scott Rutherford on 03/07/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVSuggestionButton.h"
#import "UVCellViewWithIndex.h"
#import "UVSuggestionChickletView.h"
#import "UVStyleSheet.h"

#define UV_BASE_SUGGESTION_LIST_TAG_CELL_TITLE 9000
#define UV_BASE_SUGGESTION_LIST_TAG_CELL_CATEGORY 9001
#define UV_BASE_SUGGESTION_LIST_TAG_CELL_CHICKLET 9002

@implementation UVSuggestionButton

- (id)initWithIndex:(NSInteger)index andFrame:(CGRect)theFrame {
	if (self = [super initWithIndex:index andFrame:theFrame]) {
		// Title	
		UILabel *label = [[UILabel alloc] init];
		label.tag = UV_BASE_SUGGESTION_LIST_TAG_CELL_TITLE;
		label.lineBreakMode = UILineBreakModeTailTruncation;
		label.numberOfLines = 0;
		label.font = [UIFont boldSystemFontOfSize:14];
		label.textColor = [UVStyleSheet primaryTextColor];
		label.backgroundColor = [UIColor clearColor];
		[self addSubview:label];
		[label release];
		
		// Forum + Category
		label = [[UILabel alloc] initWithFrame:CGRectMake(75, 50, 225, 14)];
		label.tag = UV_BASE_SUGGESTION_LIST_TAG_CELL_CATEGORY;
		label.lineBreakMode = UILineBreakModeTailTruncation;
		label.numberOfLines = 1;
		label.font = [UIFont boldSystemFontOfSize:11];
		label.textColor = [UVStyleSheet secondaryTextColor];
		label.backgroundColor = [UIColor clearColor];
		[self addSubview:label];
		[label release];
		
		// Chicklet
		UVSuggestionChickletView *chicklet = [[UVSuggestionChickletView alloc] initWithOrigin:CGPointMake(10, 5)];
		chicklet.tag = UV_BASE_SUGGESTION_LIST_TAG_CELL_CHICKLET;
		[self addSubview:chicklet];
		[chicklet release];
	}
	return self;
}

- (void)showSuggestion:(UVSuggestion *)suggestion withIndex:(NSInteger)theIndex {
	if (_suggestion!=suggestion)
		_suggestion = suggestion;
	
	// update the index
	_index = theIndex;
	
	UILabel *label = (UILabel *)[self viewWithTag:UV_BASE_SUGGESTION_LIST_TAG_CELL_TITLE];
	CGSize maxSize = CGSizeMake(225, 34);
	CGSize size = [suggestion.title sizeWithFont:label.font 
							   constrainedToSize:maxSize 
								   lineBreakMode:UILineBreakModeTailTruncation];
	label.frame = CGRectMake(75, 10, size.width, size.height);
	label.text = suggestion.title;
	//label.textColor = [self isHighlighted] ? [UIColor whiteColor] : [UIColor blackColor];
	
	label = (UILabel *)[self viewWithTag:UV_BASE_SUGGESTION_LIST_TAG_CELL_CATEGORY];
	label.text = suggestion.categoryString;
	//label.textColor = [self isHighlighted] ? [UIColor whiteColor] : [UIColor blackColor];
	
	UVSuggestionChickletView *chicklet = 
		(UVSuggestionChickletView *)[self viewWithTag:UV_BASE_SUGGESTION_LIST_TAG_CELL_CHICKLET];
	UVSuggestionChickletStyle style;
	if (suggestion.status) {
		style = _index % 2 == 0 ? UVSuggestionChickletStyleDark : UVSuggestionChickletStyleLight;
	} else {
		style = UVSuggestionChickletStyleEmpty;
	}
	[chicklet updateWithSuggestion:suggestion style:style];
}
	
@end
