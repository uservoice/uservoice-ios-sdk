//
//  UVTruncatingLabel.m
//  UserVoice
//
//  Created by Austin Taylor on 12/4/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVTruncatingLabel.h"

@implementation UVTruncatingLabel

@synthesize fullText;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expand)] autorelease]];
    }
    return self;
}

- (void)setFullText:(NSString *)theText {
    [fullText release];
    fullText = [theText retain];
    [self setNeedsDisplay];
}

- (void)sizeToFit {
    self.text = fullText;
    [super sizeToFit];
    if (!expanded && self.frame.size.height > self.font.lineHeight * 3)
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.font.lineHeight * 3);
}

- (void)expand {
    expanded = YES;
    [self sizeToFit];
    [self setNeedsDisplay];
    [delegate performSelector:@selector(labelExpanded:) withObject:self];
}

- (void)drawRect:(CGRect)rect {
    self.text = fullText;
    if (!expanded) {
        NSArray *lines = [self breakString];
        if ([lines count] > 3) {
            UIFont *moreFont = [UIFont boldSystemFontOfSize:self.font.pointSize];
            NSString *more = NSLocalizedStringFromTable(@"More", @"UserVoice", nil);
            CGSize moreSize = [more sizeWithFont:moreFont];
            self.text = [NSString stringWithFormat:@"%@%@%@", lines[0], lines[1], lines[2]];
            int i = [self.text length] - 1;
            CGRect r = [self rectForLetterAtIndex:i];
            while (self.frame.size.width - r.origin.x - r.size.width < 30 + moreSize.width) {
                i--;
                r = [self rectForLetterAtIndex:i];
            }
            self.text = [NSString stringWithFormat:@"%@...", [self.text substringWithRange:NSMakeRange(0, i+1)]];
            CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), self.textColor.CGColor);
            [more drawAtPoint:CGPointMake(r.origin.x + r.size.width + 12, self.font.lineHeight * 2) withFont:moreFont];
            UIBezierPath *path = [UIBezierPath bezierPath];
            CGPoint start = CGPointMake(r.origin.x + r.size.width + 15 + moreSize.width, self.font.lineHeight * 2.4);
            [path moveToPoint:start];
            [path addLineToPoint:CGPointMake(start.x + 10, start.y)];
            [path addLineToPoint:CGPointMake(start.x + 5, start.y + 7)];
            [path closePath];
            [path fill];
        }
    }
    [super drawRect:rect];
}

- (void)dealloc {
    self.fullText = nil;
    [super dealloc];
}

@end
