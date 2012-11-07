//
//  UVTextView.m
//  UserVoice
//
//  Created by UserVoice on 10/12/12.
//  Copyright 2012 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UVTextView : UITextView {
    UILabel *placeholder;
}

@property(nonatomic,retain) NSString* placeholder;

@end
