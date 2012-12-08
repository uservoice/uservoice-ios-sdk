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
#import "UVHighlightingLabel.h"

#define UV_BASE_SUGGESTION_LIST_TAG_CELL_TITLE 9000
#define UV_BASE_SUGGESTION_LIST_TAG_CELL_CATEGORY 9001
#define UV_BASE_SUGGESTION_LIST_TAG_CELL_CHICKLET 9002

@implementation UVSuggestionButton

- (id)initWithIndex:(NSInteger)index {
    if (self = [super initWithIndex:index]) {
        // Title
        UVHighlightingLabel *label = [[UVHighlightingLabel alloc] init];
        label.tag = UV_BASE_SUGGESTION_LIST_TAG_CELL_TITLE;
        label.lineBreakMode = UILineBreakModeTailTruncation;
        label.numberOfLines = 0;
        label.font = [UIFont boldSystemFontOfSize:14];
        label.textColor = [UVStyleSheet primaryTextColor];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        [label release];

        // Forum + Category
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(75, 50, 225, 14)];
        label2.tag = UV_BASE_SUGGESTION_LIST_TAG_CELL_CATEGORY;
        label2.lineBreakMode = UILineBreakModeTailTruncation;
        label2.numberOfLines = 1;
        label2.font = [UIFont boldSystemFontOfSize:11];
        label2.textColor = [UVStyleSheet secondaryTextColor];
        label2.backgroundColor = [UIColor clearColor];
        [self addSubview:label2];
        [label2 release];

        // Chicklet
        UVSuggestionChickletView *chicklet = [[UVSuggestionChickletView alloc] initWithOrigin:CGPointMake(10, 5)];
        chicklet.tag = UV_BASE_SUGGESTION_LIST_TAG_CELL_CHICKLET;
        [self addSubview:chicklet];
        [chicklet release];
    }
    return self;
}

- (void)showSuggestion:(UVSuggestion *)suggestion withIndex:(NSInteger)theIndex {
    [self showSuggestion:suggestion withIndex:theIndex pattern:nil];
}

- (void)showSuggestion:(UVSuggestion *)suggestion withIndex:(NSInteger)theIndex pattern:(NSRegularExpression *)pattern {
    if (_suggestion!=suggestion)
        _suggestion = suggestion;

    // update the index
    _index = theIndex;

    UVHighlightingLabel *label = (UVHighlightingLabel *)[self viewWithTag:UV_BASE_SUGGESTION_LIST_TAG_CELL_TITLE];
    CGSize maxSize = CGSizeMake(225, 34);
    CGSize size = [suggestion.title sizeWithFont:label.font
                               constrainedToSize:maxSize
                                   lineBreakMode:UILineBreakModeTailTruncation];
    label.frame = CGRectMake(75 - 3, 10, size.width + 6, size.height);
    label.pattern = pattern;
    label.text = suggestion.title;
    //label.textColor = [self isHighlighted] ? [UIColor whiteColor] : [UIColor blackColor];

    UILabel *label2 = (UILabel *)[self viewWithTag:UV_BASE_SUGGESTION_LIST_TAG_CELL_CATEGORY];
    label2.text = suggestion.categoryString;
    //label2.textColor = [self isHighlighted] ? [UIColor whiteColor] : [UIColor blackColor];

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
