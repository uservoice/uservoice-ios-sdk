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

@implementation UVCellViewWithIndex

@synthesize index = _index;

- (id)initWithIndex:(NSInteger)index andFrame:(CGRect)theFrame {
    CGFloat screenWidth = [UVClientConfig getScreenWidth];
	if ((self = [super initWithFrame:CGRectMake(0, 0, screenWidth, 71)])) {
        self.opaque = YES;
		[self setZebraColorFromIndex:index];
		
		UIView *highlight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
		highlight.backgroundColor = [UVStyleSheet topSeparatorColor];
		highlight.opaque = YES;
		[self addSubview:highlight];
		[highlight release];
	}
	return self;
}

- (void)setZebraColorFromIndex:(NSInteger)index {
	BOOL darkZebra = index % 2 == 0;
	self.backgroundColor = [UVStyleSheet zebraBgColor:darkZebra];
}

@end
