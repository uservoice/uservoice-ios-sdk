//
//  UVNewSuggestionViewController.h
//  UserVoice
//
//  Created by UserVoice on 11/17/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseInstantAnswersViewController.h"
#import "UVTextView.h"

@class UVForum;
@class UVCategory;

@interface UVNewSuggestionViewController : UVBaseInstantAnswersViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate> {
    UVForum *forum;
    NSString *title;
    NSString *text;
    NSString *name;
    NSString *email;
    UIScrollView *scrollView;
    UVTextView *textView;
    UITextField *titleField;
    UITextField *nameField;
    UITextField *emailField;
    UIBarButtonItem *nextButton;
    UIBarButtonItem *sendButton;
    UIView *instantAnswersView;
    UIView *instantAnswersMessage;
    UITableView *instantAnswersTableView;
    UITableView *fieldsTableView;
    UVCategory *category;
    BOOL shouldShowCategories;
    int state;
    UIView *shade;
    UIActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic, retain) UVForum *forum;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UVTextView *textView;
@property (nonatomic, retain) UITextField *titleField;
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UIBarButtonItem *nextButton;
@property (nonatomic, retain) UIBarButtonItem *sendButton;
@property (nonatomic, retain) UIView *instantAnswersView;
@property (nonatomic, retain) UIView *instantAnswersMessage;
@property (nonatomic, retain) UITableView *instantAnswersTableView;
@property (nonatomic, retain) UITableView *fieldsTableView;
@property (nonatomic, retain) UIView *shade;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UVCategory *category;
@property (assign) BOOL shouldShowCategories;

- (id)initWithForum:(UVForum *)theForum title:(NSString *)theTitle;

@end
