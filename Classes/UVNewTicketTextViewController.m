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

#define SPINNER_TAG 101
#define ARROW_TAG 102

@synthesize instantAnswersMessage;

- (void)loadView {
    [super loadView];
    self.view = [[[UIView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.view.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.0f];

    self.textView = [[[UVTextView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)] autorelease];
    self.textView.text = self.text;
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.placeholder = NSLocalizedStringFromTable(@"How can we help you today", @"UserVoice", nil);
    self.textView.delegate = self;
    self.textView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.textView.layer.shadowOpacity = 0.4;
    self.textView.layer.shadowOffset = CGSizeMake(0, 1);
    self.textView.layer.shadowRadius = 5.0f;
    self.textView.layer.masksToBounds = NO;
    [self.textView becomeFirstResponder];

    [self.view addSubview:self.textView];
    
    
    UIBarButtonItem *nextButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Next", @"UserVoice", nil)
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(nextButtonTapped)] autorelease];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    self.instantAnswersMessage = [[[UIView alloc] initWithFrame:CGRectMake(0, 200, 320, 50)] autorelease];
    [instantAnswersMessage addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(instantAnswersMessageTapped)] autorelease]];
    UILabel *instantAnswersLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 6, 250, 30)] autorelease];
    instantAnswersLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    instantAnswersLabel.numberOfLines = 2;
    instantAnswersLabel.text = NSLocalizedStringFromTable(@"We've found some related articles and ideas that may help you faster than sending a message", @"UserVoice", nil);
    instantAnswersLabel.font = [UIFont systemFontOfSize:11];
    instantAnswersLabel.backgroundColor = [UIColor clearColor];
    instantAnswersLabel.textAlignment = UITextAlignmentLeft;
    [instantAnswersMessage addSubview:instantAnswersLabel];
    UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    spinner.center = CGPointMake(320 - 22, 20);
    spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    spinner.tag = SPINNER_TAG;
    [spinner startAnimating];
    [instantAnswersMessage addSubview:spinner];
    UIImageView *arrow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_arrow.png"]] autorelease];
    arrow.center = spinner.center;
    arrow.autoresizingMask = spinner.autoresizingMask;
    arrow.tag = ARROW_TAG;
    [instantAnswersMessage addSubview:arrow];
    instantAnswersMessage.hidden = YES;
    [self.view addSubview:instantAnswersMessage];
    
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 250, 320, self.view.bounds.size.height-250) style:UITableViewStyleGrouped] autorelease];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;
    [self.view addSubview:self.tableView];
    
    [self calculateFrames];
}

- (void)nextButtonTapped {
    UVNewTicketViewController *next = [[[UVNewTicketViewController alloc] initWithText:textView.text] autorelease];
    next.instantAnswers = instantAnswers;
    // TODO isn't there a problem where they tap next before IAs are loaded?
    // TODO if (!userHasSeenInstantAnswers) tell the next controller to show 'em
    [self.navigationController pushViewController:next animated:YES];
}

- (void)updateInstantAnswersMessage {
    showInstantAnswersMessage = loadingInstantAnswers || [instantAnswers count] != 0;
    [self calculateFrames];
    if (showInstantAnswersMessage) {
        instantAnswersMessage.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            if (loadingInstantAnswers) {
                [instantAnswersMessage viewWithTag:SPINNER_TAG].layer.opacity = 1.0;
                [instantAnswersMessage viewWithTag:ARROW_TAG].layer.opacity = 0.0;
            } else {
                [instantAnswersMessage viewWithTag:SPINNER_TAG].layer.opacity = 0.0;
                UIView *arrow = [instantAnswersMessage viewWithTag:ARROW_TAG];
                arrow.layer.opacity = 1.0;
                if (keyboardHidden) {
                    arrow.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
                } else {
                    arrow.layer.transform = CATransform3DIdentity;
                }
            }
        }];
    }
}

- (void)willLoadInstantAnswers {
    [self updateInstantAnswersMessage];
    [tableView reloadData];
}

- (void)didLoadInstantAnswers {
    [self updateInstantAnswersMessage];
    [tableView reloadData];
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

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self selectInstantAnswerAtIndex:indexPath.row];
}

- (void)calculateFrames {
    CGSize textViewSize;
    CGSize instantAnswersMessageSize = CGSizeMake(320, 40);
    // TODO all these calculations need to be adjusted for iPhone 5
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        textViewSize = CGSizeMake(480, 106);
    } else {
        textViewSize = CGSizeMake(320, 200);
    }
    instantAnswersMessageSize.width = textViewSize.width;
    if (showInstantAnswersMessage) {
        textViewSize.height -= instantAnswersMessageSize.height;
    }
    CGFloat tableY = textViewSize.height + instantAnswersMessageSize.height;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(-10, 0, textViewSize.width + 20, textViewSize.height)].CGPath;

    CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    shadowAnimation.duration = 0.3;
    shadowAnimation.fromValue = (id)textView.layer.shadowPath;
    shadowAnimation.toValue = (id)shadowPath;
    shadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [UIView animateWithDuration:0.3 animations:^{
        textView.frame = CGRectMake(0, 0, textViewSize.width, textViewSize.height);
        instantAnswersMessage.frame = CGRectMake(0, textViewSize.height, instantAnswersMessageSize.width, instantAnswersMessageSize.height);
        tableView.frame = CGRectMake(0, tableY, instantAnswersMessageSize.width, self.view.frame.size.height - tableY);
    }];

    [textView.layer addAnimation:shadowAnimation forKey:@"shadowPath"];
    textView.layer.shadowPath = shadowPath;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    // If the keyboard is visible during rotation it calls keyboardWillHide/Show which does this anyway. Doing
    // it again here makes the shadow look wonky during animation.
    if (![textView isFirstResponder])
        [self calculateFrames];
}

- (void)dealloc {
    self.instantAnswersMessage = nil;
    [super dealloc];
}

@end
