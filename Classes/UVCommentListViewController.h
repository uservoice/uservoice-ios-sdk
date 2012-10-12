//
//  UVCommentListViewController.h
//  UserVoice
//
//  Created by UserVoice on 11/10/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"
#import "UVTextView.h"

@class UVSuggestion;
@class UVComment;

@interface UVCommentListViewController : UVBaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate> {
    BOOL allCommentsRetrieved;
    UVSuggestion *suggestion;
    NSMutableArray *comments;
    UVComment *commentToFlag;
    UVTextView *textEditor;
    UIBarButtonItem *prevLeftBarButton;
    UIBarButtonItem *prevRightBarButton;
    UIView *textBar;
    UIView *headerView;
}

@property (nonatomic, retain) UVSuggestion *suggestion;
@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, retain) UVComment *commentToFlag;
@property (nonatomic, retain) UVTextView *textEditor;
@property (nonatomic, retain) UIBarButtonItem *prevLeftBarButton;
@property (nonatomic, retain) UIBarButtonItem *prevRightBarButton;
@property (nonatomic, retain) UIView *textBar;
@property (nonatomic, retain) UIView *headerView;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion;

@end
