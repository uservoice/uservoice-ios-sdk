//
//  UVNewTicketTextViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVNewTicketTextViewController.h"
#import "UVNewTicketViewController.h"

@implementation UVNewTicketTextViewController

@synthesize instantAnswersMessage;
@synthesize shadowView;
@synthesize ticketViewController;

- (void)loadView {
    [super loadView];
    self.view = [[[UIView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.view.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.0f];

    self.instantAnswersMessage = [[[UIView alloc] initWithFrame:CGRectMake(0, 200, 320, 50)] autorelease];
    [instantAnswersMessage addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(instantAnswersMessageTapped)] autorelease]];
    UILabel *instantAnswersLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 6, 250, 30)] autorelease];
    instantAnswersLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    instantAnswersLabel.numberOfLines = 2;
    instantAnswersLabel.text = [self instantAnswersFoundMessage];
    instantAnswersLabel.font = [UIFont systemFontOfSize:11];
    instantAnswersLabel.backgroundColor = [UIColor clearColor];
    instantAnswersLabel.textAlignment = UITextAlignmentLeft;
    [instantAnswersMessage addSubview:instantAnswersLabel];
    [self addSpinnerAndArrowTo:instantAnswersMessage atCenter:CGPointMake(320 - 22, 20)];
    instantAnswersMessage.hidden = YES;
    [self.view addSubview:instantAnswersMessage];
    
    self.shadowView = [[[UIView alloc] initWithFrame:CGRectMake(-10, -100, 340, [UIScreen mainScreen].bounds.size.height - 180)] autorelease];
    self.shadowView.backgroundColor = [UIColor whiteColor];
    self.shadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.shadowView.layer.shadowOpacity = 0.4;
    self.shadowView.layer.shadowOffset = CGSizeMake(0, 1);
    self.shadowView.layer.shadowRadius = 5.0f;
    self.shadowView.layer.masksToBounds = NO;
    [self.view addSubview:shadowView];
    
    self.textView = [[[UVTextView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height - 280)] autorelease];
    self.textView.text = self.text;
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.placeholder = NSLocalizedStringFromTable(@"How can we help you today?", @"UserVoice", nil);
    self.textView.delegate = self;
    [self.view addSubview:self.textView];

    UIBarButtonItem *nextButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Next", @"UserVoice", nil)
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(nextButtonTapped)] autorelease];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 250, 320, self.view.bounds.size.height-250) style:UITableViewStyleGrouped] autorelease];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    /* self.tableView.scrollEnabled = NO; */
    [self.view addSubview:self.tableView];
    
    [self calculateFrames];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [textView becomeFirstResponder];
    keyboardHidden = NO;
    [self updateSpinnerAndArrowIn:instantAnswersMessage withToggle:keyboardHidden animated:NO];
}

- (void)nextButtonTapped {
    self.ticketViewController = [[[UVNewTicketViewController alloc] initWithText:textView.text] autorelease];
    self.ticketViewController.instantAnswers = instantAnswers;
    self.ticketViewController.loadingInstantAnswers = loadingInstantAnswers;
    if (!userHasSeenInstantAnswers)
        self.ticketViewController.showInstantAnswers = YES;
    userHasSeenInstantAnswers = YES;
    [self.ticketViewController didLoadInstantAnswers];
    [self.navigationController pushViewController:ticketViewController animated:YES];
}

- (void)updateInstantAnswersMessage {
    showInstantAnswersMessage = loadingInstantAnswers || [instantAnswers count] != 0;
    [self calculateFrames];
    if (showInstantAnswersMessage) {
        instantAnswersMessage.hidden = NO;
        [self updateSpinnerAndArrowIn:instantAnswersMessage withToggle:keyboardHidden animated:YES];
    }
}

- (void)willLoadInstantAnswers {
    [self updateInstantAnswersMessage];
    userHasSeenInstantAnswers = NO;
    [tableView reloadData];
    if (ticketViewController) {
        ticketViewController.instantAnswers = instantAnswers;
        ticketViewController.loadingInstantAnswers = loadingInstantAnswers;
        [ticketViewController willLoadInstantAnswers];
    }
}

- (void)didLoadInstantAnswers {
    [self updateInstantAnswersMessage];
    [tableView reloadData];
    if (ticketViewController) {
        ticketViewController.instantAnswers = instantAnswers;
        ticketViewController.loadingInstantAnswers = loadingInstantAnswers;
        [ticketViewController didLoadInstantAnswers];
    }
}

- (void)instantAnswersMessageTapped {
    if ([textView isFirstResponder])
        [textView resignFirstResponder];
    else
        [textView becomeFirstResponder];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    keyboardHidden = NO;
    [self updateInstantAnswersMessage];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    userHasSeenInstantAnswers = YES;
    keyboardHidden = YES;
    [self updateInstantAnswersMessage];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return [instantAnswers count];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self createCellForIdentifier:@"InstantAnswer"
                               tableView:theTableView
                               indexPath:indexPath
                                   style:UITableViewCellStyleDefault
                              selectable:YES];
}

- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [self customizeCellForInstantAnswer:cell index:indexPath.row];
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self selectInstantAnswerAtIndex:indexPath.row];
}

- (void)calculateFrames {
    CGSize textViewSize;
    CGSize instantAnswersMessageSize = CGSizeMake(320, 40);
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        textViewSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, 106);
    } else {
        textViewSize = CGSizeMake(320, [UIScreen mainScreen].bounds.size.height - 280);
    }
    instantAnswersMessageSize.width = textViewSize.width;
    if (showInstantAnswersMessage) {
        textViewSize.height -= instantAnswersMessageSize.height;
    }
    CGFloat tableY = textViewSize.height + instantAnswersMessageSize.height;

    [UIView animateWithDuration:0.3 animations:^{
        textView.frame = CGRectMake(0, 0, textViewSize.width, textViewSize.height);
        shadowView.frame = CGRectMake(-10, -100, textViewSize.width + 20, textViewSize.height + 100);
        instantAnswersMessage.frame = CGRectMake(0, textViewSize.height, instantAnswersMessageSize.width, instantAnswersMessageSize.height);
        tableView.frame = CGRectMake(0, tableY, instantAnswersMessageSize.width, self.view.frame.size.height - tableY);
    } completion:^(BOOL finished) {
        [textView scrollRangeToVisible:[textView selectedRange]];
    }];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    // If the keyboard is visible during rotation it calls keyboardWillHide/Show which does this anyway. Doing
    // it again here makes the shadow look wonky during animation.
    if (![textView isFirstResponder])
        [self calculateFrames];
}

- (void)dealloc {
    self.instantAnswersMessage = nil;
    self.shadowView = nil;
    self.ticketViewController = nil;
    [super dealloc];
}

@end
