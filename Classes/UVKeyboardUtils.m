//
//  UVKeyboardUtils.m
//  UserVoice
//
//  Created by Austin Taylor on 11/7/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVKeyboardUtils.h"

static UVKeyboardUtils *sharedInstance;

@implementation UVKeyboardUtils

+ (UVKeyboardUtils *)sharedInstance {
    return sharedInstance;
}

+ (void)load {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    sharedInstance = [[self alloc] init];
    [pool release];
}

+ (BOOL)visible {
    return [[self sharedInstance] visible];
}

- (id)init {
    if (self = [super init]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(willShow) name:UIKeyboardWillShowNotification object:nil];
        [center addObserver:self selector:@selector(willHide) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (BOOL)visible {
    return visible;
}

- (void)willShow {
    visible = YES;
}

- (void)willHide {
    visible = NO;
}

@end
