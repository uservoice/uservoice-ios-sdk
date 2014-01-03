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
#import "UVTextWithFieldsView.h"

@implementation UVContactViewController {
    BOOL _proceed;
    BOOL _sending;
    UVDetailsFormViewController *_detailsController;
    UVTextWithFieldsView *_fieldsView;
}

- (void)loadView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    view.frame = [self contentFrame];

    [self registerForKeyboardNotifications];
    _instantAnswerManager = [UVInstantAnswerManager new];
    _instantAnswerManager.delegate = self;
    _instantAnswerManager.articleHelpfulPrompt = NSLocalizedStringFromTable(@"Do you still want to contact us?", @"UserVoice", nil);
    _instantAnswerManager.articleReturnMessage = NSLocalizedStringFromTable(@"Yes, go to my message", @"UserVoice", nil);
    _instantAnswerManager.deflectingType = @"Ticket";

    self.navigationItem.title = NSLocalizedStringFromTable(@"Send us a message", @"UserVoice", nil);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    // using a fields view with no fields extra still gives us better scroll handling
    _fieldsView = [UVTextWithFieldsView new];
    _fieldsView.textView.placeholder = NSLocalizedStringFromTable(@"Give feedback or ask for help...", @"UserVoice", nil);
    _fieldsView.textViewDelegate = self;
    [self configureView:view
               subviews:NSDictionaryOfVariableBindings(_fieldsView)
            constraints:@[@"|[_fieldsView]|", @"V:|[_fieldsView]|"]];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(requestDismissal)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Next", @"UserVoice", nil)
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(next)];
    [self loadDraft];
    self.navigationItem.rightBarButtonItem.enabled = (_fieldsView.textView.text.length > 0);
    self.view = view;
}

- (void)viewWillAppear:(BOOL)animated {
    [_fieldsView.textView becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (void)textViewDidChange:(UVTextView *)theTextEditor {
    self.navigationItem.rightBarButtonItem.enabled = (_fieldsView.textView.text.length > 0);
    _instantAnswerManager.searchText = theTextEditor.text;
}

- (void)didUpdateInstantAnswers {
    if (_proceed) {
        _proceed = NO;
        [self hideActivityIndicator];
        [_instantAnswerManager pushInstantAnswersViewForParent:self articlesFirst:YES];
    }
}

- (void)next {
    _proceed = YES;
    [self showActivityIndicator];
    [_instantAnswerManager search];
    if (!_instantAnswerManager.loading) {
        [self didUpdateInstantAnswers];
    }
}

- (UIScrollView *)scrollView {
    return _fieldsView;
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
    _detailsController.sendTitle = NSLocalizedStringFromTable(@"Send", @"UserVoice", nil);
    NSMutableArray *fields = [NSMutableArray array];
    for (UVCustomField *field in [UVSession currentSession].clientConfig.customFields) {
        NSMutableArray *values = [NSMutableArray array];
        if (!field.isRequired && field.isPredefined)
            [values addObject:@{@"id" : @"", @"label" : NSLocalizedStringFromTable(@"(none)", @"UserVoice", nil)}];
        for (NSString *value in field.values) {
            [values addObject:@{@"id" : value, @"label" : value}];
        }
        if (field.isRequired)
            [fields addObject:@{ @"name" : field.name, @"values" : values, @"required" : @(1) }];
        else
            [fields addObject:@{ @"name" : field.name, @"values" : values }];
    }
    _detailsController.fields = fields;
    _detailsController.selectedFieldValues = [NSMutableDictionary dictionary];
    for (NSString *key in [UVSession currentSession].config.customFields.allKeys) {
        NSString *value = [UVSession currentSession].config.customFields[key];
        _detailsController.selectedFieldValues[key] = @{ @"id" : value, @"label" : value };
    }
    [self.navigationController pushViewController:_detailsController animated:YES];
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
    if (_sending) return;
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
        [_detailsController showActivityIndicator];
        _sending = YES;
        [UVTicket createWithMessage:_fieldsView.textView.text andEmailIfNotLoggedIn:email andName:name andCustomFields:customFields andDelegate:self];
    }
}

- (void)didCreateTicket:(UVTicket *)ticket {
    [self clearDraft];
    [UVBabayaga track:SUBMIT_TICKET];
    UVSuccessViewController *next = [UVSuccessViewController new];
    next.titleText = NSLocalizedStringFromTable(@"Message sent!", @"UserVoice", nil);
    next.text = NSLocalizedStringFromTable(@"We'll be in touch.", @"UserVoice", nil);
    [self.navigationController setViewControllers:@[next] animated:YES];
}

- (void)didReceiveError:(NSError *)error {
    _sending = NO;
    [_detailsController hideActivityIndicator];
    [super didReceiveError:error];
}

- (void)showSaveActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                               destructiveButtonTitle:NSLocalizedStringFromTable(@"Don't save", @"UserVoice", nil)
                                                    otherButtonTitles:NSLocalizedStringFromTable(@"Save draft", @"UserVoice", nil), nil];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [actionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
    } else {
        [actionSheet showInView:self.view];
    }
    [_fieldsView.textView resignFirstResponder];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self clearDraft];
            [self dismiss];
            break;
        case 1:
            [self saveDraft];
            [self dismiss];
            break;
        default:
            [_fieldsView.textView becomeFirstResponder];
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
    self.loadedDraft = _instantAnswerManager.searchText = _fieldsView.textView.text = [prefs stringForKey:@"uv-message-text"];
}

- (void)saveDraft {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:_fieldsView.textView.text forKey:@"uv-message-text"];
    [prefs synchronize];
}

- (void)requestDismissal {
    if (_fieldsView.textView.text.length == 0 || [_fieldsView.textView.text isEqualToString:_loadedDraft]) {
        [self dismiss];
    } else {
        [self showSaveActionSheet];
    }
}

@end
