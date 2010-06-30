//
//  UVSearchResultsViewController.h
//  UserVoice
//
//  Created by Mirko Froehlich on 11/16/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseSuggestionListViewController.h"

@class UVForum;

@interface UVSearchResultsViewController : 
	UVBaseSuggestionListViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
		
	UVForum *forum;
	NSString *query;
	UITextField *textField;
	BOOL showAllSuggestions;
}

@property (nonatomic, retain) UVForum *forum;
@property (nonatomic, retain) NSString *query;
@property (nonatomic, retain) UITextField *textField;

- (id)initWithForum:(UVForum *)theForum;

@end
