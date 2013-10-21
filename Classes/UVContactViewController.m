//
//  UVContactViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/18/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVContactViewController.h"
#import "UVInstantAnswersViewController.h"
#import "UVDetailsFormViewController.h"
#import "UVTextView.h"
#import "UVSession.h"
#import "UVClientConfig.h"

@implementation UVContactViewController {
    BOOL _proceed;
}

- (void)loadView {
    _instantAnswerManager = [UVInstantAnswerManager new];
    _instantAnswerManager.delegate = self;
    _instantAnswerManager.articleHelpfulPrompt = NSLocalizedStringFromTable(@"Do you still want to contact us?", @"UserVoice", nil);
    _instantAnswerManager.articleReturnMessage = NSLocalizedStringFromTable(@"Yes, go to my message", @"UserVoice", nil);

    self.navigationItem.title = NSLocalizedStringFromTable(@"Send us a message", @"UserVoice", nil);

    UVTextView *view = [[[UVTextView alloc] initWithFrame:[self contentFrame]] autorelease];
    view.placeholder = NSLocalizedStringFromTable(@"Give feedback or ask for help...", @"UserVoice", nil);
    view.delegate = self;

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(dismiss)] autorelease];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Next", @"UserVoice", nil)
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self
                                                                              action:@selector(next)] autorelease];
    self.view = view;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.view becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (void)textViewDidChange:(UVTextView *)theTextEditor {
    _instantAnswerManager.searchText = theTextEditor.text;
}

- (void)didUpdateInstantAnswers {
    if (_proceed) {
        [_instantAnswerManager pushInstantAnswersViewForParent:self articlesFirst:YES];
    }
}

- (void)skipInstantAnswers {
    UVDetailsFormViewController *next = [[UVDetailsFormViewController new] autorelease];
    next.delegate = self;
    next.sendTitle = NSLocalizedStringFromTable(@"Send", @"UserVoice", nil);
    next.fields = [UVSession currentSession].clientConfig.customFields;
    [self.navigationController pushViewController:next animated:YES];
}

- (void)next {
    _proceed = YES;
    [_instantAnswerManager search];
    if (!_instantAnswerManager.loading) {
        [self didUpdateInstantAnswers];
    }
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    self.instantAnswerManager = nil;
    [super dealloc];
}

@end
