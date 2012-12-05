//
//  UVNewSuggestionViewController.h
//  UserVoice
//
//  Created by UserVoice on 11/17/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseSuggestionViewController.h"

@interface UVNewSuggestionViewController : UVBaseSuggestionViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate> {
    UIScrollView *scrollView;
    UIBarButtonItem *nextButton;
    UIBarButtonItem *sendButton;
    UIView *instantAnswersView;
    UIView *instantAnswersMessage;
    UITableView *instantAnswersTableView;
    UITableView *fieldsTableView;
    int state;
}

+ (UVBaseViewController *)viewController;
+ (UVBaseViewController *)viewControllerWithTitle:(NSString *)text;

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIBarButtonItem *nextButton;
@property (nonatomic, retain) UIBarButtonItem *sendButton;
@property (nonatomic, retain) UIView *instantAnswersView;
@property (nonatomic, retain) UIView *instantAnswersMessage;
@property (nonatomic, retain) UITableView *instantAnswersTableView;
@property (nonatomic, retain) UITableView *fieldsTableView;

@end
