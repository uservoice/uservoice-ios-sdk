//
//  UVTextView.m
//  UserVoice
//
//  Created by UserVoice on 10/12/12.
//  Copyright 2012 UserVoice Inc. All rights reserved.
//

#import "UVTextView.h"
#import "UVDefines.h"

@implementation UVTextView {
    BOOL _constraintsAdded;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
        
        self.font = [UIFont systemFontOfSize:15];
        _placeholderLabel = [UILabel new];
        _placeholderLabel.font = self.font;
        _placeholderLabel.textColor = IOS7 ? [UIColor colorWithRed:0.78f green:0.78f blue:0.80f alpha:1.0f] : [UIColor colorWithWhite:0.702f alpha:1.0f];
        _placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_placeholderLabel];
    }
    return self;
}

- (void)layoutSubviews {
    if (!_constraintsAdded) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[placeholder]" options:0 metrics:nil views:@{@"placeholder":_placeholderLabel}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:(@"|-12-[placeholder]") options:0 metrics:nil views:@{@"placeholder":_placeholderLabel}]];
        _constraintsAdded = YES;
    }
    [super layoutSubviews];
}

- (void)setPlaceholder:(NSString *)newPlaceholder {
    _placeholderLabel.text = newPlaceholder;
    [self updateShouldDrawPlaceholder];
}

- (NSString *)placeholder {
    return _placeholderLabel.text;
}

- (void)updateShouldDrawPlaceholder {
    _placeholderLabel.hidden = self.text.length != 0;
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
}

@end
