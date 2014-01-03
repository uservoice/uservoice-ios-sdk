//
//  UVPostIdeaViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/23/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVPostIdeaViewController.h"
#import "UVDetailsFormViewController.h"
#import "UVSuccessViewController.h"
#import "UVTextView.h"
#import "UVSession.h"
#import "UVForum.h"
#import "UVCategory.h"
#import "UVUtils.h"
#import "UVSuggestion.h"
#import "UVBabayaga.h"
#import "UVTextWithFieldsView.h"

@implementation UVPostIdeaViewController {
    BOOL _proceed;
    BOOL _sending;
    UVDetailsFormViewController *_detailsController;
    UVTextWithFieldsView *_fieldsView;
}

- (void)loadView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    view.frame = [self contentFrame];
    _instantAnswerManager = [UVInstantAnswerManager new];
    _instantAnswerManager.delegate = self;
    _instantAnswerManager.articleHelpfulPrompt = NSLocalizedStringFromTable(@"Do you still want to post your own idea?", @"UserVoice", nil);
    _instantAnswerManager.articleReturnMessage = NSLocalizedStringFromTable(@"Yes, I want to post my idea", @"UserVoice", nil);
    _instantAnswerManager.deflectingType = @"Suggestion";

    self.navigationItem.title = NSLocalizedStringFromTable(@"Post an idea", @"UserVoice", nil);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    _fieldsView = [UVTextWithFieldsView new];
    _titleField = [_fieldsView addFieldWithLabel:NSLocalizedStringFromTable(@"Title", @"UserVoice", nil)];
    if (_initialText) {
        _titleField.text = _initialText;
    }
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:_titleField queue:nil usingBlock:^(NSNotification *note) {
        _instantAnswerManager.searchText = _titleField.text;
        self.navigationItem.rightBarButtonItem.enabled = (_titleField.text.length > 0);
    }];

    _fieldsView.textView.placeholder = NSLocalizedStringFromTable(@"Description (optional)", @"UserVoice", nil);

    UIView *sep = [UIView new];
    sep.backgroundColor = [UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.f];

    UIView *bg = [UIView new];
    bg.backgroundColor = [UIColor colorWithRed:0.937f green:0.937f blue:0.957f alpha:1.f];

    UILabel *desc = [UILabel new];
    desc.backgroundColor = [UIColor clearColor];
    desc.text = NSLocalizedStringFromTable(@"When you post an idea on our forum, others will be able to subscribe to it and make comments. When we respond to the idea, you'll get notified.", @"UserVoice", nil);
    desc.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f];
    desc.numberOfLines = 0;
    desc.font = [UIFont systemFontOfSize:12];
    self.desc = desc;

    NSArray *constraints = @[
        @"|[_fieldsView]|",
        @"|[sep]|",
        @"|-[desc]-|",
        @"|[bg]|",
        @"V:[_fieldsView][sep(==1)]-[desc]",
        @"V:[sep][bg]|"
    ];

    [self configureView:view
               subviews:NSDictionaryOfVariableBindings(_fieldsView, sep, desc, bg)
            constraints:constraints];
    [view bringSubviewToFront:desc];

    self.keyboardConstraint = [NSLayoutConstraint constraintWithItem:desc
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:view
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:-_kbHeight-10];
    [view addConstraint:_keyboardConstraint];
    self.topConstraint = [NSLayoutConstraint constraintWithItem:_fieldsView
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:view
                                                      attribute:NSLayoutAttributeTop
                                                     multiplier:1.0
                                                       constant:64];
    [view addConstraint:_topConstraint];
    self.descConstraint = [NSLayoutConstraint constraintWithItem:desc
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1
                                                       constant:0];
    self.view = view;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismiss)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Next", @"UserVoice", nil)
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(next)];
    self.navigationItem.rightBarButtonItem.enabled = (_titleField.text.length > 0);
    [self registerForKeyboardNotifications];
    _didCreateCallback = [[UVCallback alloc] initWithTarget:self selector:@selector(didCreateSuggestion:)];
    _didAuthenticateCallback = [[UVCallback alloc] initWithTarget:self selector:@selector(createSuggestion)];
    [self updateLayout];
}

- (void)updateLayout {
    _topConstraint.constant = (IOS7 ? (IPAD ? 44 : (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 64 : 52)) : 0);
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) || IPAD) {
        _desc.hidden = NO;
        [self.view removeConstraint:_descConstraint];
    } else {
        _desc.hidden = YES;
        [self.view addConstraint:_descConstraint];
    }
    if (!IOS7) {
        _desc.preferredMaxLayoutWidth = 0;
        [self.view layoutIfNeeded];
        _desc.preferredMaxLayoutWidth = _desc.frame.size.width;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self updateLayout];
    [_fieldsView performSelector:@selector(updateLayout) withObject:nil afterDelay:0];
}

- (void)keyboardDidShow:(NSNotification *)note {
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) || IPAD) {
        _keyboardConstraint.constant = -_kbHeight-10;
    } else {
        _keyboardConstraint.constant = -_kbHeight+10;
    }
    [self.view layoutIfNeeded];
    [_fieldsView updateLayout];
}

- (void)keyboardDidHide:(NSNotification *)note {
    _keyboardConstraint.constant = -10;
    [self.view layoutIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_titleField becomeFirstResponder];
}

- (void)didUpdateInstantAnswers {
    if (_proceed) {
        _proceed = NO;
        [self hideActivityIndicator];
        [_instantAnswerManager pushInstantAnswersViewForParent:self articlesFirst:NO];
    }
}

- (void)next {
    if (_proceed) return;
    [self showActivityIndicator];
    _proceed = YES;
    [_instantAnswerManager search];
    if (!_instantAnswerManager.loading) {
        [self didUpdateInstantAnswers];
    }
}

- (void)showActivityIndicator {
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
}

- (void)hideActivityIndicator {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Next", @"UserVoice", nil) style:UIBarButtonItemStyleDone target:self action:@selector(next)];
}

- (void)skipInstantAnswers {
    _detailsController = [UVDetailsFormViewController new];
    _detailsController.delegate = self;
    _detailsController.helpText = NSLocalizedStringFromTable(@"When you post an idea on our forum, others will be able to subscribe to it and make comments. When we respond to the idea, you'll get notified.", @"UserVoice", nil);
    _detailsController.sendTitle = NSLocalizedStringFromTable(@"Post", @"UserVoice", nil);
    UVForum *forum = [UVSession currentSession].forum;
    if (forum.categories && forum.categories.count > 0) {
        NSMutableArray *values = [NSMutableArray array];
        [values addObject:@{ @"id" : @"", @"label" : NSLocalizedStringFromTable(@"(none)", @"UserVoice", nil) }];
        for (UVCategory *category in forum.categories) {
            [values addObject:@{ @"id" : [NSString stringWithFormat:@"%d", (int)category.categoryId], @"label" : category.name }];
        }
        _detailsController.fields = @[ @{
            @"name" : NSLocalizedStringFromTable(@"Category", @"UserVoice", nil),
            @"values" : values
        } ];
        _detailsController.selectedFieldValues = [NSMutableDictionary dictionary];
    }
    [self.navigationController pushViewController:_detailsController animated:YES];
}

- (void)sendWithEmail:(NSString *)email name:(NSString *)name fields:(NSDictionary *)fields {
    if (_sending) return;
    self.userEmail = email;
    self.userName = name;
    if (email.length == 0) {
        [self alertError:NSLocalizedStringFromTable(@"Please enter your email address before submitting your ticket.", @"UserVoice", nil)];
    } else {
        [_detailsController showActivityIndicator];
        _selectedCategoryId = [fields[@"Category"][@"id"] integerValue];
        [self requireUserAuthenticated:email name:name callback:_didAuthenticateCallback];
    }
}

- (void)didReceiveError:(NSError *)error {
    _sending = NO;
    if ([UVUtils isNotFoundError:error]) {
        [_detailsController hideActivityIndicator];
    } else if ([UVUtils isUVRecordInvalid:error forField:@"title" withMessage:@"is not allowed."]) {
        [_detailsController hideActivityIndicator];
        [self alertError:NSLocalizedStringFromTable(@"A suggestion with this title already exists. Please change the title.", @"UserVoice", nil)];
    } else {
        [super didReceiveError:error];
    }
}

- (void)createSuggestion {
    _sending = YES;
    [UVSuggestion createWithForum:[UVSession currentSession].forum
                         category:_selectedCategoryId
                            title:_titleField.text
                             text:_fieldsView.textView.text
                         callback:_didCreateCallback];
}

- (void)didCreateSuggestion:(UVSuggestion *)theSuggestion {
    [UVBabayaga track:SUBMIT_IDEA];
    UVSuccessViewController *next = [UVSuccessViewController new];
    next.titleText = NSLocalizedStringFromTable(@"Thank you!", @"UserVoice", nil);
    next.text = NSLocalizedStringFromTable(@"Your feedback has been posted to our feedback forum.", @"UserVoice", nil);
    [self.navigationController setViewControllers:@[next] animated:YES];
    _sending = NO;
}

@end
