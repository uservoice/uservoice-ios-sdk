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

- (void)updateLayout {
    CGFloat sH = [UIScreen mainScreen].bounds.size.height;
    CGFloat sW = [UIScreen mainScreen].bounds.size.width;
    CGFloat kbP = 280;
    CGFloat kbL = 214;

    CGRect textViewRect = UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ?
        CGRectMake(0, 0, sH, sW - kbL) :
        CGRectMake(0, 0, sW, sH - kbP);

    [UIView animateWithDuration:0.3 animations:^{
        self.textView.frame = textViewRect;
    }];
}

- (void)loadView {
    [super loadView];
    self.navigationItem.title = suggestion.title;
    self.view = [[[UIView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.view.backgroundColor = [UIColor whiteColor];

    self.textView = [[[UVTextView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height - 280)] autorelease];
    self.textView.placeholder = NSLocalizedStringFromTable(@"Write a comment...", @"UserVoice", nil);
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self updateLayout];
}

- (void)dealloc {
    self.suggestion = nil;
    self.textView = nil;
    [super dealloc];
}

@end
