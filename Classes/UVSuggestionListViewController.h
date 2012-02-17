//
//  UVSuggestionListViewController.h
//  UserVoice
//
//  Created by UserVoice on 10/22/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVTextEditor.h"
#import "UVBaseViewController.h"

@class UVForum;

@interface UVSuggestionListViewController : UVBaseViewController <UITableViewDataSource, UITableViewDelegate, UVTextEditorDelegate> {
	BOOL _searching;
	UVForum *_forum;
	UVTextEditor *_textEditor;
    NSMutableArray *suggestions;
}

@property (nonatomic, retain) UVForum *forum;
@property (nonatomic, retain) UVTextEditor *textEditor;
@property (nonatomic, retain) NSMutableArray *suggestions;

- (id)initWithForum:(UVForum *)theForum;
- (id)initWithForum:(UVForum *)theForum andSuggestions:(NSArray *)theSuggestions;
- (void)reloadTableData;
- (BOOL)supportsSearch;
- (void)dismissTextEditor;

@end
