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

@implementation UVCommentViewController

@synthesize suggestion;
@synthesize textView;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion {
    if ((self = [super init])) {
        self.suggestion = theSuggestion;
    }
    return self;
}

- (void)dismiss {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)commentButtonTapped {
    if (textView.text.length == 0) {
        [self dismiss];
    } else {
        [self showActivityIndicator];
        [UVComment createWithSuggestion:suggestion text:textView.text delegate:self];
    }
}

- (void)didCreateComment:(UVComment *)comment {
    [self hideActivityIndicator];
    self.suggestion.commentsCount += 1;
    UINavigationController *navController = (UINavigationController *)self.presentingViewController;
    UVSuggestionDetailsViewController *previous = (UVSuggestionDetailsViewController *)[navController.viewControllers lastObject];
    [previous reloadComments];
    [self dismiss];
}

- (void)loadView {
    [super loadView];
    self.navigationItem.title = suggestion.title;
    self.view = [[[UIView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.view.backgroundColor = [UIColor whiteColor];

    self.textView = [[[UVTextView alloc] initWithFrame:self.view.bounds] autorelease];
    self.textView.placeholder = NSLocalizedStringFromTable(@"Write a comment...", @"UserVoice", nil);
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:textView];

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(dismiss)] autorelease];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Comment", @"UserVoice", nil)
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self
                                                                              action:@selector(commentButtonTapped)] autorelease];
    [self.textView becomeFirstResponder];
}

- (UIScrollView *)scrollView {
    return self.textView;
}

- (void)dealloc {
    self.suggestion = nil;
    self.textView = nil;
    [super dealloc];
}

@end
