//
//  UVActivityIndicator.m
//  UserVoice
//
//  Created by UserVoice on 2/27/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVActivityIndicator.h"
#import "UVClientConfig.h"

@implementation UVActivityIndicator

@synthesize activityIndicatorView;

- (id)init {
    if (self = [super init]) {
        CGRect frame = [UIApplication sharedApplication].keyWindow.bounds;
        self.frame = frame;
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0.4;
        [self addSubview:backgroundView];
        [backgroundView release];

        UIView *activityFrame = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        activityFrame.center = backgroundView.center;
        activityFrame.backgroundColor = [UIColor blackColor];
        activityFrame.alpha = 0.9;
        activityFrame.layer.cornerRadius = 10;

        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activity.center = CGPointMake(60, 60);
        self.activityIndicatorView = activity;
        [activityFrame addSubview:activity];
        [activity release];

        [self addSubview:activityFrame];
        [activityFrame release];
    }

    return self;
}

+ (UVActivityIndicator *)activityIndicator {
    return [[[UVActivityIndicator alloc] init] autorelease];
}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    [self.activityIndicatorView startAnimating];
}

- (void)hide {
    [self.activityIndicatorView stopAnimating];
    [self removeFromSuperview];
}

- (void)dealloc {
    self.activityIndicatorView = nil;
    [super dealloc];
}

@end
