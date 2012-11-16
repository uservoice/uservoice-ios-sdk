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
}

@property (nonatomic, retain) UIScrollView *scrollView;

@end
