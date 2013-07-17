//
//  UVHighlightingLabel.m
//  UserVoice
//
//  Created by Austin Taylor on 11/29/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVHighlightingLabel.h"

@implementation UVHighlightingLabel

@synthesize pattern;

- (CGFloat)effectiveWidth {
    return self.frame.size.width - 6;
}

- (void)drawRect:(CGRect)theRect {
    if (self.text && pattern) {
        CGFloat radius = 4.0;
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context,[UIColor colorWithRed:1.00f green:0.95f blue:0.64f alpha:1.0f].CGColor); 
        [pattern enumerateMatchesInString:self.text options:0 range:NSMakeRange(0, [self.text length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
            NSRange matchRange = [match range];
            CGRect start = [self rectForLetterAtIndex:matchRange.location];
            CGRect end = [self rectForLetterAtIndex:matchRange.location + matchRange.length - 1];
            CGRect rect = CGRectMake(start.origin.x, start.origin.y, end.origin.x - start.origin.x + end.size.width + 5, start.size.height);
            
            if (CGRectContainsRect(self.bounds, rect)) {
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
                CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * M_PI / 2, 0, 0);
                CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, M_PI / 2, 0);
                CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, M_PI / 2, M_PI, 0);
                CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, M_PI, 3 * M_PI / 2, 0);
                CGContextClosePath(context);
                CGContextFillPath(context);
            }
        }];
    }
    [super drawRect:theRect];
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 3, 0, 3};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}


- (void)setPattern:(NSRegularExpression *)thePattern {
    [pattern release];
    pattern = [thePattern retain];
    [self setNeedsDisplay];
}

- (void)dealloc {
    self.pattern = nil;
    [super dealloc];
}

@end
