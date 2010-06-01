//
//  UVInfoViewController.h
//  UserVoice
//
//  Created by Mirko Froehlich on 12/8/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"


@interface UVInfoViewController : UVBaseViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *tableView;
}

@property (nonatomic, retain) UITableView *tableView;

@end
