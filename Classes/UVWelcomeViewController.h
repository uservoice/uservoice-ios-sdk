//
//  UVWelcomeViewController.h
//  UserVoice
//
//  Created by UserVoice on 12/15/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"

@interface UVWelcomeViewController : UVBaseViewController <UITableViewDelegate, UITableViewDataSource> {
    UIScrollView *scrollView;
    UITableView *flashTable;
    UILabel *flashMessageLabel;
    UILabel *flashTitleLabel;
    UIView *flashView;
    UIView *buttons;
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UITableView *flashTable;
@property (nonatomic, retain) UILabel *flashMessageLabel;
@property (nonatomic, retain) UILabel *flashTitleLabel;
@property (nonatomic, retain) UIView *flashView;
@property (nonatomic, retain) UIView *buttons;

- (void)updateLayout;

@end
