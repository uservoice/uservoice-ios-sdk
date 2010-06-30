//
//  UVCommentListViewController.h
//  UserVoice
//
//  Created by UserVoice on 11/10/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"
#import "UVTextEditor.h"

@class UVSuggestion;
@class UVComment;

@interface UVCommentListViewController : UVBaseViewController <UITableViewDataSource, UITableViewDelegate, UVTextEditorDelegate, UIActionSheetDelegate> {
	BOOL allCommentsRetrieved;
	BOOL editing;
	
	UVSuggestion *suggestion;
	NSMutableArray *comments;
	UVComment *commentToFlag;
	NSString *text;
	UVTextEditor *textEditor;
	UIBarButtonItem *prevLeftBarButton;
	UIBarButtonItem *prevRightBarButton;
}

@property (nonatomic, retain) UVSuggestion *suggestion;
@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, retain) UVComment *commentToFlag;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) UVTextEditor *textEditor;
@property (nonatomic, retain) UIBarButtonItem *prevLeftBarButton;
@property (nonatomic, retain) UIBarButtonItem *prevRightBarButton;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion;

@end
