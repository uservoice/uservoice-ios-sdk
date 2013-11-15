//
//  UVCommentViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 11/15/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVCommentViewController.h"
#import "UVSuggestion.h"
#import "UVTextView.h"
#import "UVComment.h"
#import "UVSuggestionDetailsViewController.h"
#import "UVKeyboardUtils.h"
#import "UVBabayaga.h"

@implementation UVCommentViewController

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion {
    if ((self = [super init])) {
        _suggestion = theSuggestion;
    }
    return self;
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)commentButtonTapped {
    if (_textView.text.length == 0) {
        [self dismiss];
    } else {
        [self disableSubmitButton];
        [self showActivityIndicator];
        [UVComment createWithSuggestion:_suggestion text:_textView.text delegate:self];
    }
}

- (void)didCreateComment:(UVComment *)comment {
    [self hideActivityIndicator];
    [UVBabayaga track:COMMENT_IDEA id:_suggestion.suggestionId];
    _suggestion.commentsCount += 1;
    UINavigationController *navController = (UINavigationController *)self.presentingViewController;
    UVSuggestionDetailsViewController *previous = (UVSuggestionDetailsViewController *)[navController.viewControllers lastObject];
    [previous reloadComments];
    [self dismiss];
}

- (void)loadView {
    [super loadView];
    self.navigationItem.title = _suggestion.title;
    self.view = [[UIView alloc] initWithFrame:[self contentFrame]];
    self.view.backgroundColor = [UIColor whiteColor];

    _textView = [[UVTextView alloc] initWithFrame:self.view.bounds];
    _textView.placeholder = NSLocalizedStringFromTable(@"Write a comment...", @"UserVoice", nil);
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_textView];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismiss)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Comment", @"UserVoice", nil)
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(commentButtonTapped)];
    [_textView becomeFirstResponder];
}

- (UIScrollView *)scrollView {
    return _textView;
}

@end
