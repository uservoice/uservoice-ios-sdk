//
//  UVStyleSheet.m
//  UserVoice
//
//  Created by UserVoice on 10/28/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVStyleSheet.h"
#import "UVSuggestion.h"

@implementation UVStyleSheet

static UVStyleSheet *styleSheet;

+ (UVStyleSheet *)styleSheet {
    if (styleSheet == nil) {
        styleSheet = [[UVStyleSheet alloc] init];
    }
    return styleSheet;
}

+ (void)setStyleSheet:(UVStyleSheet *)aStyleSheet {
    [styleSheet release];
    styleSheet = [aStyleSheet retain];
}

+ (UIColor *)primaryTextColor {
    return [[self styleSheet] primaryTextColor];
}

+ (UIColor *)secondaryTextColor {
    return [[self styleSheet] secondaryTextColor];
}

+ (UIColor *)signedInUserTextColor {
    return [[self styleSheet] signedInUserTextColor];
}

+ (UIColor *)labelTextColor {
    return [[self styleSheet] labelTextColor];
}

+ (UIColor *)backgroundColor {
	return [[self styleSheet] backgroundColor];
}

+ (UIColor *)zebraBgColor:(BOOL)dark {
	return dark ? [self darkZebraBgColor] : [self lightZebraBgColor];
}

+ (UIColor *)darkZebraBgColor {
	return [[self styleSheet] darkZebraBgColor];
}

+ (UIColor *)lightZebraBgColor {
	return [[self styleSheet] lightZebraBgColor];
}

+ (UIColor *)bottomSeparatorColor {
    CGFloat hue, saturation, brightness, alpha;
    UIColor *reference = [[self styleSheet] darkZebraBgColor];
    if ([reference respondsToSelector:@selector(getHue:saturation:brightness:alpha:)])
    {
        [reference getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        return [UIColor colorWithHue:hue saturation:saturation - 0.1 brightness:brightness - 0.2 alpha:alpha];
    }
    else
    {
        return [UIColor colorWithRed:0.729 green:0.741 blue:0.745 alpha:1.0];
    }
}

+ (UIColor *)topSeparatorColor {
    CGFloat hue, saturation, brightness, alpha;
    UIColor *reference = [[self styleSheet] lightZebraBgColor];
    if ([reference respondsToSelector:@selector(getHue:saturation:brightness:alpha:)])
    {
        [reference getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        return [UIColor colorWithHue:hue saturation:saturation - 0.1 brightness:brightness + 0.15 alpha:alpha];
    }
    else
    {
        return [UIColor colorWithRed:0.953 green:0.953 blue:0.953 alpha:1.0];
    }
}

+ (UIColor *)tableViewHeaderColor {
	return [[self styleSheet] tableViewHeaderColor];
}

+ (UIColor *)linkTextColor {
	return [[self styleSheet] linkTextColor];
}

+ (UIColor *)alertTextColor {
	return [[self styleSheet] alertTextColor];
}

- (UIColor *)primaryTextColor {
	return [UIColor colorWithRed:0.102 green:0.102 blue:0.102 alpha:1.0];
}

- (UIColor *)secondaryTextColor {
	return [UIColor lightGrayColor];
}

- (UIColor *)signedInUserTextColor {
	return [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
}

- (UIColor *)labelTextColor {
	return [UIColor grayColor];
}

- (UIColor *)backgroundColor {
	return [UIColor colorWithRed:0.902 green:0.902 blue:0.902 alpha:1.0];
}

- (UIColor *)darkZebraBgColor {
	return [UIColor colorWithRed:0.851 green:0.851 blue:0.851 alpha:1.0];
}

- (UIColor *)lightZebraBgColor {
	return [UIColor colorWithRed:0.902 green:0.902 blue:0.902 alpha:1.0];
}

- (UIColor *)tableViewHeaderColor {
	return [UIColor colorWithRed:0.298 green:0.337 blue:0.424 alpha:1.0];
}

- (UIColor *)linkTextColor {
	return [UIColor colorWithRed:0.451 green:0.529 blue:0.643 alpha:1.0];
}

- (UIColor *)alertTextColor {
	return [UIColor colorWithRed:0.631 green:0.0 blue:0.2 alpha:1.0];
}

@end
