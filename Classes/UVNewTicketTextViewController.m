//
//  UVNewTicketTextViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVNewTicketTextViewController.h"

@implementation UVNewTicketTextViewController

- (void)loadView {
    [super loadView];
    self.view = [[UIView alloc] initWithFrame:[self contentFrame]];
    
    self.textView = [[UVTextView alloc] initWithFrame:CGRectZero];
    [self calculateTextViewFrame];
    self.textView.text = self.text;
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.placeholder = NSLocalizedStringFromTable(@"How can we help you today", @"UserVoice", nil);
    self.textView.delegate = self;
    [self.textView becomeFirstResponder];
    [self.view addSubview:self.textView];
    
    // Next button
}

- (void)calculateTextViewFrame {
    // TODO: add IA popup to calculation
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.textView.frame = CGRectMake(0, 0, 480, 106);
    } else {
        self.textView.frame = CGRectMake(0, 0, 320, 200);
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self calculateTextViewFrame];
}

@end
