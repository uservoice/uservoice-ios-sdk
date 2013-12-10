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

@implementation UVCommentViewController {
    BOOL _signedIn;
    UIScrollView *_scrollView;
    UITextField *_emailField;
    UITextField *_nameField;
    NSLayoutConstraint *_textViewConstraint;
}

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
        // TODO if needed sign the user in
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
    UIView *view = [UIView new];
    view.frame = [self contentFrame];
    view.backgroundColor = [UIColor whiteColor];

    _textView = [UVTextView new];
    _textView.placeholder = NSLocalizedStringFromTable(@"Write a comment...", @"UserVoice", nil);
    _signedIn = NO;
    if (_signedIn) {
        [self configureView:view
                   subviews:NSDictionaryOfVariableBindings(_textView)
                constraints:@[@"|-12-[_textView]-|", @"V:|[_textView]|"]];
    } else {
        UIView *email = [UIView new];
        _emailField = [self configureView:email label:NSLocalizedStringFromTable(@"Email", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"(required)", @"UserVoice", nil)];

        UIView *sep0 = [UIView new];
        sep0.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.f];

        UIView *name = [UIView new];
        _nameField = [self configureView:name label:NSLocalizedStringFromTable(@"Name", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"“Anonymous”", @"UserVoice", nil)];

        UIView *sep1 = [UIView new];
        sep1.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.f];

        UIView *container = [UIView new];
        UIScrollView *scrollView = [UIScrollView new];

        NSArray *constraints = @[
            @"|[email]|", @"|-16-[sep0]|", @"|[name]|", @"|-16-[sep1]|", @"|-12-[_textView]-|",
            @"V:|[email(==44)][sep0(==1)][name(==44)][sep1(==1)]-4-[_textView(>=10)]-4-|"
        ];
        [self configureView:container
                   subviews:NSDictionaryOfVariableBindings(email, sep0, name, sep1, _textView)
                constraints:constraints];
        [self configureView:scrollView
                   subviews:NSDictionaryOfVariableBindings(container)
                constraints:@[@"|[container]", @"V:|[container]"]];
        [self configureView:view
                   subviews:NSDictionaryOfVariableBindings(scrollView)
                constraints:@[@"|[scrollView]|", @"V:|[scrollView]|"]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
        _textViewConstraint = [NSLayoutConstraint constraintWithItem:_textView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:500];
        [view addConstraint:_textViewConstraint];
        _scrollView = scrollView;
        _textView.delegate = self;
        _textView.scrollEnabled = NO;
    }

    self.view = view;
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

- (void)textViewDidChange:(UITextView *)textView {
    if (!IOS7) {
        [self textViewDidChangeSelection:textView];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    CGSize contentSize = [_textView sizeThatFits:CGSizeMake(_textView.frame.size.width, MAXFLOAT)];
    _textViewConstraint.constant = MAX(contentSize.height, _scrollView.bounds.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom - _textView.frame.origin.y);
    _scrollView.contentSize = CGSizeMake(0, _textView.frame.origin.y + _textView.contentSize.height);
    CGRect rect = [_textView caretRectForPosition:_textView.selectedTextRange.end];
    if (rect.origin.x == INFINITY || rect.size.height < 2) {
        // caretRectForPosition: gives wonky results sometimes. let's just scroll to the bottom.
        // also, when this happens, sizeThatFits: will be off by about a line. (WHY)
        _scrollView.contentSize = CGSizeMake(0, _scrollView.contentSize.height + _textView.font.lineHeight);
        rect = CGRectMake(0, _textView.contentSize.height + _textView.font.lineHeight - 1, 1, 1);
    }
    CGFloat top = rect.origin.y + _textView.frame.origin.y;
    CGFloat bottom = top + rect.size.height;
    if (top < _scrollView.contentOffset.y + _scrollView.contentInset.top) {
        [_scrollView setContentOffset:CGPointMake(0, top - _scrollView.contentInset.top) animated:NO];
    } else if (bottom > _scrollView.contentOffset.y + _scrollView.bounds.size.height - _scrollView.contentInset.bottom) {
        [_scrollView setContentOffset:CGPointMake(0, bottom - _scrollView.bounds.size.height + _scrollView.contentInset.bottom) animated:NO];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if (!_signedIn) {
        [self performSelector:@selector(textViewDidChangeSelection:) withObject:_textView afterDelay:0];
    }
}

- (UIScrollView *)scrollView {
    return _signedIn ? _textView : _scrollView;
}

@end
