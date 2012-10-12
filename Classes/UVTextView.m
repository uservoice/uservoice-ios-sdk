//
//  UVTextView.m
//  UserVoice
//
//  Created by UserVoice on 10/12/12.
//  Copyright 2012 UserVoice Inc. All rights reserved.
//

#import "UVTextView.h"

@implementation UVTextView

@synthesize placeholder;
@synthesize placeholderColor;
@synthesize shouldDrawPlaceholder;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
        
        self.placeholderColor = [UIColor colorWithWhite:0.702f alpha:1.0f];
        self.shouldDrawPlaceholder = NO;
        self.font = [UIFont systemFontOfSize:15];
    }
    return self;
}

- (void)setText:(NSString *)string {
    [super setText:string];
    [self updateShouldDrawPlaceholder];
}


- (void)setPlaceholder:(NSString *)newPlaceholder {
    if ([newPlaceholder isEqual:placeholder]) {
        return;
    }
    
    [placeholder release];
    placeholder = [newPlaceholder retain];
    
    [self updateShouldDrawPlaceholder];
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (shouldDrawPlaceholder) {
        [placeholderColor set];
        [placeholder drawInRect:CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f, self.frame.size.height - 16.0f) withFont:self.font];
    }
}

- (void)updateShouldDrawPlaceholder {
    BOOL prev = shouldDrawPlaceholder;
    shouldDrawPlaceholder = self.placeholder && self.placeholderColor && self.text.length == 0;
    
    if (prev != shouldDrawPlaceholder) {
        [self setNeedsDisplay];
    }
}


- (void)textChanged:(NSNotification *)notificaiton {
    [self updateShouldDrawPlaceholder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
    
    self.placeholder = nil;
    self.placeholderColor = nil;
    [super dealloc];
}

@end