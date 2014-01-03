//
//  UVTruncatingLabel.m
//  UserVoice
//
//  Created by Austin Taylor on 12/4/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVTruncatingLabel.h"
#import "UVDefines.h"

@implementation UVTruncatingLabel {
    BOOL _expanded;
    CGFloat _lastWidth;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandAndNotify)]];
        _moreLabel = [UILabel new];
        _moreLabel.text = NSLocalizedStringFromTable(@"more", @"UserVoice", nil);
        _moreLabel.font = [UIFont systemFontOfSize:12];
        _moreLabel.backgroundColor = [UIColor clearColor];
        if (IOS7) {
            _moreLabel.textColor = self.tintColor;
        }
        // TODO hardcode blue for ios6 ??
        _moreLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_moreLabel];
        NSDictionary *views = @{@"more":_moreLabel};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[more]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[more]|" options:0 metrics:nil views:views]];
    }
    return self;
}

- (void)setFullText:(NSString *)theText {
    _fullText = theText;
    [self update];
}

- (void)update {
    if (!_fullText || self.effectiveWidth == 0) return;
    self.text = _fullText;
    _lastWidth = self.effectiveWidth;
    if (_expanded) {
        _moreLabel.hidden = YES;
    } else {
        NSArray *lines = [self breakString];
        if ([lines count] > 3) {
            CGSize moreSize = [_moreLabel intrinsicContentSize];
            self.text = [NSString stringWithFormat:@"%@%@%@", [lines objectAtIndex:0], [lines objectAtIndex:1], [lines objectAtIndex:2]];
            int i = [self.text length] - 1;
            CGRect r = [self rectForLetterAtIndex:i];
            while (self.effectiveWidth - r.origin.x - r.size.width < (20 + moreSize.width) && i > 0) {
                i--;
                r = [self rectForLetterAtIndex:i];
            }
            self.text = [NSString stringWithFormat:@"%@...", [self.text substringWithRange:NSMakeRange(0, i+1)]];
            _moreLabel.hidden = NO;
        } else {
            _moreLabel.hidden = YES;
        }
    }
}

- (CGSize)intrinsicContentSize {
    [self update];
    return [super intrinsicContentSize];
}

- (CGFloat)effectiveWidth {
    return MAX(self.frame.size.width, self.preferredMaxLayoutWidth) - 4;
}

- (void)layoutSubviews {
    if (_lastWidth != self.effectiveWidth) {
        [self update];
    }
    [super layoutSubviews];
}

- (void)expandAndNotify {
    [self expand];
    [_delegate performSelector:@selector(labelExpanded:) withObject:self];
}

- (void)expand {
    _expanded = YES;
    [self update];
}

@end
