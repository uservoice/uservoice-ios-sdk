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
}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

+ (UVActivityIndicator *)activityIndicator;
- (void)show;
- (void)hide;

@end
