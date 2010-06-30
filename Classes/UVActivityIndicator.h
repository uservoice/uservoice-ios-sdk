//
//  UVActivityIndicator.h
//  UserVoice
//
//  Created by UserVoice on 2/27/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UVActivityIndicator : UIView {
	UIActivityIndicatorView *activityIndicatorView;
	NSInteger heightOffset;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (assign) NSInteger heightOffset;

+ (UVActivityIndicator *)activityIndicator;
+ (UVActivityIndicator *)activityIndicatorWithText:(NSString *)text;
- (void)show;
- (void)hide;
- (id)initWithText:(NSString *)text;

@end
