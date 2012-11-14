//
//  UVSuggestionDetailsViewController.h
//  UserVoice
//
//  Created by UserVoice on 10/29/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"
#import "UVSuggestion.h"

@interface UVSuggestionDetailsViewController : UVBaseViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    UVSuggestion *suggestion;
    UIScrollView *scrollView;
    UIView *statusBar;
}

@property (nonatomic, retain) UVSuggestion *suggestion;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIView *statusBar;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion;

@end
