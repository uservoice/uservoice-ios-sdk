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
#import "UVSuccessViewController.h"
#import "UVTextView.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVConfig.h"
#import "UVTicket.h"

@implementation UVContactViewController {
    BOOL _proceed;
}

- (void)loadView {
    _instantAnswerManager = [UVInstantAnswerManager new];
    _instantAnswerManager.delegate = self;
    _instantAnswerManager.articleHelpfulPrompt = NSLocalizedStringFromTable(@"Do you still want to contact us?", @"UserVoice", nil);
    _instantAnswerManager.articleReturnMessage = NSLocalizedStringFromTable(@"Yes, go to my message", @"UserVoice", nil);

    self.navigationItem.title = NSLocalizedStringFromTable(@"Send us a message", @"UserVoice", nil);

    _textView = [[UVTextView alloc] initWithFrame:[self contentFrame]];
    _textView.placeholder = NSLocalizedStringFromTable(@"Give feedback or ask for help...", @"UserVoice", nil);
    _textView.delegate = self;

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(dismiss)] autorelease];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Next", @"UserVoice", nil)
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self
                                                                              action:@selector(next)] autorelease];
    self.view = _textView;
}

- (void)viewWillAppear:(BOOL)animated {
    [_textView becomeFirstResponder];
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

- (void)next {
    _proceed = YES;
    [_instantAnswerManager search];
    if (!_instantAnswerManager.loading) {
        [self didUpdateInstantAnswers];
    }
}

- (void)skipInstantAnswers {
    UVDetailsFormViewController *next = [[UVDetailsFormViewController new] autorelease];
    next.delegate = self;
    next.sendTitle = NSLocalizedStringFromTable(@"Send", @"UserVoice", nil);
    next.fields = [UVSession currentSession].clientConfig.customFields;
    next.selectedFieldValues = [NSMutableDictionary dictionaryWithDictionary:[UVSession currentSession].config.customFields];
    [self.navigationController pushViewController:next animated:YES];
}

- (void)sendWithEmail:(NSString *)email name:(NSString *)name fields:(NSDictionary *)fields {
    [self showActivityIndicator];
    self.userEmail = email;
    self.userName = name;
    [UVTicket createWithMessage:_textView.text andEmailIfNotLoggedIn:email andName:name andCustomFields:fields andDelegate:self];
}

- (void)didCreateTicket:(UVTicket *)ticket {
    [self hideActivityIndicator];
    UVSuccessViewController *next = [[UVSuccessViewController new] autorelease];
    next.titleText = NSLocalizedStringFromTable(@"Message sent!", @"UserVoice", nil);
    next.text = NSLocalizedStringFromTable(@"We'll be in touch.", @"UserVoice", nil);
    [self.navigationController pushViewController:next animated:YES];
    // [UIView transitionFromView:self.navigationController.view
    //                     toView:next.view
    //                   duration:0.5
    //                    options:UIViewAnimationOptionTransitionFlipFromRight
    //                 completion:nil];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    self.instantAnswerManager = nil;
    [super dealloc];
}

@end
