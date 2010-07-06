//
//  UVButtonWithIndex.m
//  UserVoice
//
//  Created by UserVoice on 2/23/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVButtonWithIndex.h"
#import "UVStyleSheet.h"
#import <QuartzCore/QuartzCore.h>

@implementation UVButtonWithIndex

@synthesize index = _index, normalImage = _normalImage, highlightedImage = _highlightedImage;

- (id)initWithIndex:(NSInteger)index andFrame:(CGRect)theFrame {
	if (self = [[super class] buttonWithType:UIButtonTypeCustom]) {
		self.index = index;
		self.opaque = YES;
		CGFloat boundsX = theFrame.origin.x;	
		self.frame = CGRectMake(boundsX-10, 0, 320, 71); // position in the parent view and set the size of the button
		
		UIView *drawingView = [[UIView alloc] initWithFrame:theFrame];
		BOOL darkZebra = index % 2 == 0;
		drawingView.backgroundColor = [UVStyleSheet zebraBgColor:darkZebra];
		
		UIGraphicsBeginImageContext(theFrame.size);
		[drawingView.layer renderInContext:UIGraphicsGetCurrentContext()];
		self.normalImage = UIGraphicsGetImageFromCurrentImageContext();		
		
		CAGradientLayer *gradient = [CAGradientLayer layer];
		UIColor *lightBlue = [UIColor colorWithRed:0.25 green:0.50 blue:0.95 alpha:1.0];
		UIColor *darkBlue = [UIColor colorWithRed:0.18 green:0.39 blue:0.76 alpha:1.0];
		gradient.frame = theFrame;
		gradient.colors = [NSArray arrayWithObjects:
						   (id)[lightBlue CGColor],
						   (id)[darkBlue CGColor],
						   nil];
		gradient.startPoint = CGPointMake(0.0, 0.0);
		gradient.endPoint = CGPointMake(0.0, 1.0); // limit gradient to top fifth of the view
		[drawingView.layer insertSublayer:gradient atIndex:0];
		[drawingView.layer renderInContext:UIGraphicsGetCurrentContext()];
		self.highlightedImage = UIGraphicsGetImageFromCurrentImageContext();	

		[self setBackgroundImage:self.normalImage forState:UIControlStateNormal];
		[self setBackgroundImage:self.highlightedImage forState:UIControlStateHighlighted];		
		[drawingView release];
		
		// Highlight row at the top (dark shadow is already taken care of by table separator)
		UIView *highlight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
		highlight.backgroundColor = [UVStyleSheet topSeparatorColor];
		highlight.opaque = YES;
		[self addSubview:highlight];
		[highlight release];	
	}
	return [self retain];
}

- (void)updateLayoutsForHighlighted {
	for (UILabel *subview in self.subviews) {
		UIColor *color;
		if ([subview respondsToSelector:NSSelectorFromString(@"textColor")]) {			
			color = [self isHighlighted] ? [UIColor whiteColor] : [UIColor blackColor];
			subview.textColor = color;
		}
    }
}

- (void)setHighlighted:(BOOL)highlighted {
	if ([self isHighlighted] != highlighted) {
		[super setHighlighted:highlighted];	
		
		[self updateLayoutsForHighlighted];		
		[self setNeedsDisplay];
	}
}

@end
