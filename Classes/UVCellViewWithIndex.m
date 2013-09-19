//
//  UVCellViewWithIndex.m
//  UserVoice
//
//  Created by UserVoice on 6/8/11.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import "UVCellViewWithIndex.h"
#import "UVStyleSheet.h"
#import "UVClientConfig.h"
#import <QuartzCore/QuartzCore.h>
#import "UVDefines.h"

@implementation UVCellViewWithIndex

@synthesize index = _index;

- (id)initWithIndex:(NSInteger)index {
    CGFloat screenWidth = [UVClientConfig getScreenWidth];
    if ((self = [super initWithFrame:CGRectMake(0, 0, screenWidth + 20, 71)])) {
        self.opaque = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self setZebraColorFromIndex:index];

        UIView *highlight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
        highlight.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        highlight.backgroundColor = [UVStyleSheet topSeparatorColor];
        highlight.opaque = YES;
        [self addSubview:highlight];
        [highlight release];
    }
    return self;
}

- (void)setZebraColorFromIndex:(NSInteger)index {
    BOOL darkZebra = index % 2 == 0;
    if (!IOS7) {
        self.backgroundColor = [UVStyleSheet zebraBgColor:darkZebra];
    }
}

@end
