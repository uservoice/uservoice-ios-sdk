//
//  UVSuggestionListViewController.h
//  UserVoice
//
//  Created by UserVoice on 10/22/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"

@class UVForum;

@interface UVSuggestionListViewController : UVBaseViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    UVForum *_forum;
    UITextField *_textEditor;
    NSMutableArray *suggestions;
    NSArray *searchResults;
    UISearchDisplayController *searchController;
}

@property (nonatomic, retain) UVForum *forum;
@property (nonatomic, retain) UITextField *textEditor;
@property (nonatomic, retain) NSMutableArray *suggestions;
@property (nonatomic, retain) NSArray *searchResults;
@property (nonatomic, retain) UISearchDisplayController *searchController;

- (id)initWithForum:(UVForum *)theForum;
- (id)initWithForum:(UVForum *)theForum andSuggestions:(NSArray *)theSuggestions;
- (void)reloadTableData;

@end
