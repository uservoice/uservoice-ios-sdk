//
//  UVSuggestionListViewController.h
//  UserVoice
//
//  Created by Mirko Froehlich on 10/22/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseSuggestionListViewController.h"
#import "UVTextEditor.h"

@class UVForum;

@interface UVSuggestionListViewController : UVBaseSuggestionListViewController <UITableViewDataSource, UITableViewDelegate, UVTextEditorDelegate> {
	BOOL allSuggestionsRetrieved;
	UVForum *forum;
}

@property (nonatomic, retain) UVForum *forum;

- (id)initWithForum:(UVForum *)theForum;
- (id)initWithForum:(UVForum *)theForum andSuggestions:(NSArray *)theSuggestions;

// Override in subclasses if they should not support search.
- (BOOL)supportsSearch;

@end
