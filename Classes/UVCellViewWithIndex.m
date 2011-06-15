//
//  UVCellViewWithIndex.m
//  UserVoice
//
//  Created by UserVoice on 6/8/11.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import "UVCellViewWithIndex.h"
#import "UVStyleSheet.h"
#import "UVClientConfig.h"
#import <QuartzCore/QuartzCore.h>

@implementation UVCellViewWithIndex

@synthesize index = _index, normalImage = _normalImage, highlightedImage = _highlightedImage;


- (void)setZebraColorFromIndex:(NSInteger)index
{
	BOOL darkZebra = index % 2 == 0;
	self.backgroundColor = [UVStyleSheet zebraBgColor:darkZebra];
}

- (id)initWithIndex:(NSInteger)index andFrame:(CGRect)theFrame 
{
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	self.opaque = YES;
	
	if (self = [super initWithFrame:CGRectMake(0, 0, screenWidth, 71)]) 
	{
		[self setZebraColorFromIndex:index];
		
		UIView *highlight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
		highlight.backgroundColor = [UVStyleSheet topSeparatorColor];
		highlight.opaque = YES;
		[self addSubview:highlight];
		[highlight release];
		
	}
	return [self retain];
}

- (void)updateLayoutsForHighlighted {
	
	/*
	for (UILabel *subview in self.subviews) {
		UIColor *color;
		if ([subview respondsToSelector:NSSelectorFromString(@"textColor")]) {			
			color = [self isHighlighted] ? [UIColor whiteColor] : [UIColor blackColor];
			subview.textColor = color;
		}
    }
	 */
	
}

- (void)setHighlighted:(BOOL)highlighted {
	
	/*
	if ([self isHighlighted] != highlighted) {
		[super setHighlighted:highlighted];	
		
		[self updateLayoutsForHighlighted];		
		[self setNeedsDisplay];
	}*/
	
}

@end
