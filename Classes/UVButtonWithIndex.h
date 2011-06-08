//
//  UVButtonWithIndex.h
//  UserVoice
//
//  Created by UserVoice on 2/23/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UVButtonWithIndex : UIView {
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
