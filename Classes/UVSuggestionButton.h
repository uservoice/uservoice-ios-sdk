//
//  UVSuggestionButton.h
//  UserVoice
//
//  Created by Scott Rutherford on 03/07/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVButtonWithIndex.h"
#import "UVSuggestion.h"

@interface UVSuggestionButton : UVButtonWithIndex {
	UVSuggestion *_suggestion;
}

- (id)initWithIndex:(NSInteger)index andFrame:(CGRect)theFrame;

- (void)showSuggestion:(UVSuggestion *)suggestion withIndex:(NSInteger)theIndex;

@end
