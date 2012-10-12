//
//  UVTextView.m
//  UserVoice
//
//  Created by UserVoice on 10/12/12.
//  Copyright 2012 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UVTextView : UITextView {
    NSString *placeholder;
    UIColor *placeholderColor;
    BOOL shouldDrawPlaceholder;
}

@property(nonatomic,retain) NSString* placeholder;
@property(nonatomic,retain) UIColor* placeholderColor;
@property(nonatomic) BOOL shouldDrawPlaceholder;

@end
