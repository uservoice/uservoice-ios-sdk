//
//  UVNewSuggestionViewController.h
//  UserVoice
//
//  Created by Mirko Froehlich on 11/17/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"
#import "Three20.h"

@class UVForum;
@class UVCategory;

@interface UVNewSuggestionViewController : UVBaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, TTTextEditorDelegate> {
	UVForum *forum;
	NSString *title;
	NSString *text;
	NSString *name;
	NSString *email;
	TTTextEditor *textEditor;
	UITextField *titleField;
	UITextField *nameField;
	UITextField *emailField;
	UIBarButtonItem *prevBarButton;
	UITableView *tableView;
	NSInteger numVotes;
	UVCategory *category;
	BOOL shouldResizeForKeyboard;
}

@property (nonatomic, retain) UVForum *forum;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) TTTextEditor *textEditor;
@property (nonatomic, retain) UITextField *titleField;
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UIBarButtonItem *prevBarButton;
@property (nonatomic, retain) UITableView *tableView;
@property (assign) NSInteger numVotes;
@property (nonatomic, retain) UVCategory *category;

- (id)initWithForum:(UVForum *)theForum title:(NSString *)theTitle;

@end
