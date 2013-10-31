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
#import "UVCustomField.h"
#import "UVBabayaga.h"

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
    [self loadDraft];
    self.navigationItem.rightBarButtonItem.enabled = (_textView.text.length > 0);
    self.view = _textView;
}

- (void)viewWillAppear:(BOOL)animated {
    [_textView becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (void)textViewDidChange:(UVTextView *)theTextEditor {
    self.navigationItem.rightBarButtonItem.enabled = (_textView.text.length > 0);
    _instantAnswerManager.searchText = theTextEditor.text;
}

- (void)didUpdateInstantAnswers {
    if (_proceed) {
        _proceed = NO;
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
    NSMutableArray *fields = [NSMutableArray array];
    for (UVCustomField *field in [UVSession currentSession].clientConfig.customFields) {
        NSMutableArray *values = [NSMutableArray array];
        for (NSString *value in field.values) {
            [values addObject:@{@"id" : value, @"label" : value}];
        }
        if (field.isRequired)
            [fields addObject:@{ @"name" : field.name, @"values" : values, @"required" : @(1) }];
        else
            [fields addObject:@{ @"name" : field.name, @"values" : values }];
    }
    next.fields = fields;
    next.selectedFieldValues = [NSMutableDictionary dictionary];
    for (NSString *key in [UVSession currentSession].config.customFields.allKeys) {
        NSString *value = [UVSession currentSession].config.customFields[key];
        next.selectedFieldValues[key] = @{ @"id" : value, @"label" : value };
    }
    [self.navigationController pushViewController:next animated:YES];
}

- (BOOL)validateCustomFields:(NSDictionary *)fields {
    for (UVCustomField *field in [UVSession currentSession].clientConfig.customFields) {
        if ([field isRequired]) {
            NSString *value = fields[field.name];
            if (!value || value.length == 0)
                return NO;
        }
    }
    return YES;
}


- (void)sendWithEmail:(NSString *)email name:(NSString *)name fields:(NSDictionary *)fields {
    [self showActivityIndicator];
    NSMutableDictionary *customFields = [NSMutableDictionary dictionary];
    for (NSString *key in fields.allKeys) {
        customFields[key] = fields[key][@"label"];
    }
    self.userEmail = email;
    self.userName = name;
    if (![UVSession currentSession].user && email.length == 0) {
        [self alertError:NSLocalizedStringFromTable(@"Please enter your email address before submitting your ticket.", @"UserVoice", nil)];
    } else if (![self validateCustomFields:customFields]) {
        [self alertError:NSLocalizedStringFromTable(@"Please fill out all required fields.", @"UserVoice", nil)];
    } else {
        [UVTicket createWithMessage:_textView.text andEmailIfNotLoggedIn:email andName:name andCustomFields:customFields andDelegate:self];
    }
}

- (void)didCreateTicket:(UVTicket *)ticket {
    [self hideActivityIndicator];
    [self clearDraft];
    [UVBabayaga track:SUBMIT_TICKET];
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

- (void)showSaveActionSheet {
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                destructiveButtonTitle:NSLocalizedStringFromTable(@"Don't save", @"UserVoice", nil)
                                                     otherButtonTitles:NSLocalizedStringFromTable(@"Save draft", @"UserVoice", nil), nil] autorelease];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [actionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
    } else {
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self clearDraft];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 1:
            [self saveDraft];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            break;
    }
}

- (void)clearDraft {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"uv-message-text"];
    [prefs synchronize];
}

- (void)loadDraft {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.loadedDraft = _instantAnswerManager.searchText = _textView.text = [prefs stringForKey:@"uv-message-text"];
}

- (void)saveDraft {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:_textView.text forKey:@"uv-message-text"];
    [prefs synchronize];
}

- (BOOL)shouldLeaveViewController {
    if (_textView.text.length == 0 || [_textView.text isEqualToString:_loadedDraft]) {
        return YES;
    } else {
        [self showSaveActionSheet];
        return NO;
    }
}

- (void)dismiss {
    if ([self shouldLeaveViewController])
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    self.instantAnswerManager = nil;
    self.loadedDraft = nil;
    [super dealloc];
}

@end
