//
//  UVTaskBar.m
//  UserVoice
//
//  Created by Scott Rutherford on 30/06/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVTaskBar.h"

@implementation UVTaskBar

- (void)drawRect:(CGRect)rect {
	NSLog(@"Attempting to style UVTaskBar");
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    CGContextSetShadow(currentContext, CGSizeMake(1, -1), 2);
    [super drawRect: rect];
    CGContextRestoreGState(currentContext);
}

@end
