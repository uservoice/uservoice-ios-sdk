//
//  UVTextView.m
//  UserVoice
//
//  Created by UserVoice on 10/12/12.
//  Copyright 2012 UserVoice Inc. All rights reserved.
//

#import "UVTextView.h"

@implementation UVTextView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
        
        self.font = [UIFont systemFontOfSize:15];
        placeholder = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, self.frame.size.width - 16, self.frame.size.height - 16)];
        placeholder.font = self.font;
        placeholder.textColor = [UIColor colorWithWhite:0.702f alpha:1.0f];
        [self addSubview:placeholder];
    }
    return self;
}

- (void)setPlaceholder:(NSString *)newPlaceholder {
    placeholder.text = newPlaceholder;
    [placeholder sizeToFit];
    [self updateShouldDrawPlaceholder];
}

- (NSString *)placeholder {
    return placeholder.text;
}

- (void)updateShouldDrawPlaceholder {
    placeholder.hidden = self.text.length != 0;
}

- (void)setText:(NSString *)string {
    [super setText:string];
    [self updateShouldDrawPlaceholder];
}

- (void)textChanged:(NSNotification *)notificaiton {
    [self updateShouldDrawPlaceholder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
    [placeholder release];
    [super dealloc];
}

@end
