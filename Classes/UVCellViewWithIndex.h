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
	UIImage* _normalImage;
	UIImage* _highlightedImage;
}

@property (assign) NSInteger index;
@property (nonatomic, retain) UIImage *normalImage;
@property (nonatomic, retain) UIImage *highlightedImage;

- (NSInteger)index;
- (id)initWithIndex:(NSInteger)index andFrame:(CGRect)theFrame;
- (void)setZebraColorFromIndex:(NSInteger)index;

@end
