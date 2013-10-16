//
//  UVWelcomeViewController.h
//  UserVoice
//
//  Created by UserVoice on 12/15/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseInstantAnswersViewController.h"

@interface UVWelcomeViewController : UVBaseInstantAnswersViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate> {
    UISearchDisplayController *searchController;
}

@property (nonatomic, retain) UISearchDisplayController *searchController;

@end
