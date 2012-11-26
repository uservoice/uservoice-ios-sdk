//
//  UVGradientButton.m
//  UserVoice
//
//  Created by Austin Taylor on 11/26/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVGradientButton.h"

@implementation UVGradientButton

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 12.0;
        self.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
        self.layer.borderWidth = 1.0;

        highlight = [CALayer layer];
        highlight.backgroundColor = UIColorFromRGB(0xf7f7f7).CGColor;
        [self.layer addSublayer:highlight];

        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [self setTitleColor:UIColorFromRGB(0x373838) forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    highlight.frame = CGRectMake(12, 1, self.bounds.size.width - 24, 1);
    CAGradientLayer *gradient = (CAGradientLayer *)self.layer;
    if (self.highlighted) {
        highlight.hidden = YES;
        gradient.colors = @[(id)[UIColor colorWithRed:0.03f green:0.56f blue:0.93f alpha:1.0f].CGColor, (id)[UIColor colorWithRed:0.07f green:0.38f blue:0.87f alpha:1.0f].CGColor];
    } else {
        highlight.hidden = NO;
        gradient.colors = @[(id)UIColorFromRGB(0xeaeaea).CGColor, (id)UIColorFromRGB(0xd6d6d6).CGColor];
    }
    [CATransaction commit];
}

@end
