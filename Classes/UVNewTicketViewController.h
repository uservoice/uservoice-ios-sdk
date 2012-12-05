//
//  UVNewTicketViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 10/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseTicketViewController.h"

@interface UVNewTicketViewController : UVBaseTicketViewController {
    int state;
    UIScrollView *scrollView;
    UIView *messageTextView;
    UIView *instantAnswersView;
    UIView *instantAnswersMessage;
    UITableView *instantAnswersTableView;
    UITableView *fieldsTableView;
    UIBarButtonItem *nextButton;
    UIBarButtonItem *sendButton;
}

+ (UVBaseViewController *)viewController;
+ (UVBaseViewController *)viewControllerWithText:(NSString *)text;

@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,retain) UIView *messageTextView;
@property (nonatomic,retain) UIView *instantAnswersView;
@property (nonatomic,retain) UIView *instantAnswersMessage;
@property (nonatomic,retain) UITableView *instantAnswersTableView;
@property (nonatomic,retain) UITableView *fieldsTableView;
@property (nonatomic,retain) UIBarButtonItem *nextButton;
@property (nonatomic,retain) UIBarButtonItem *sendButton;

- (void)updateLayout;

@end
