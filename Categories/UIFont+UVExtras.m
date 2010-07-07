//
//  UIFont+UVExtras.m
//  UserVoice
//
//  Created by Scott Rutherford on 30/06/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UIFont+UVExtras.h"


@implementation UIFont (UVExtras)

-(CGFloat)ttLineHeight {
	return (self.ascender - self.descender) + 1;
}

@end
