//
//  UVSuggestionFooterView.h
//  UserVoice
//
//  Created by Scott Rutherford on 04/07/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVFooterView.h"
#import "UVSuggestion.h"

@class UVBaseViewController;

@interface UVSuggestionFooterView : UVFooterView {
	UVSuggestion *_suggestion;
}

@property (nonatomic, retain) UVSuggestion *suggestion;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion andController:(UVBaseViewController *)theController;

@end
