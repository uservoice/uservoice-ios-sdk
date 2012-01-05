//
//  UVCellViewWithIndex.h
//  UserVoice
//
//  Created by UserVoice on 6/8/11.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UVCellViewWithIndex : UIView {
	NSInteger _index;
}

@property (assign) NSInteger index;

- (NSInteger)index;
- (id)initWithIndex:(NSInteger)index andFrame:(CGRect)theFrame;
- (void)setZebraColorFromIndex:(NSInteger)index;

@end
