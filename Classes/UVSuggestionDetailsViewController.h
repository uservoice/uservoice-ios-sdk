//
//  UVSuggestionDetailsViewController.h
//  UserVoice
//
//  Created by Mirko Froehlich on 10/29/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"
#import "UVSuggestion.h"

@interface UVSuggestionDetailsViewController : UVBaseViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	UVSuggestion *suggestion;
	UITableView *tableView;
}

@property (nonatomic, retain) UVSuggestion *suggestion;
@property (nonatomic, retain) UITableView *tableView;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion;

@end
