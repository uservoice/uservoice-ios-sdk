//
//  UVCommentViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 11/15/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"

@class UVSuggestion;
@class UVTextView;

@interface UVCommentViewController : UVBaseViewController {
    UVSuggestion *suggestion;
    UVTextView *textView;
}

@property (nonatomic,retain) UVSuggestion *suggestion;
@property (nonatomic,retain) UVTextView *textView;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion;

@end
