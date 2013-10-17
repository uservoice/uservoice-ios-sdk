//
//  UVWelcomeViewController.h
//  UserVoice
//
//  Created by UserVoice on 12/15/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"
#import "UVInstantAnswerManager.h"

#define IA_FILTER_ALL 0
#define IA_FILTER_ARTICLES 1
#define IA_FILTER_IDEAS 2

@interface UVWelcomeViewController : UVBaseViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, UVInstantAnswersDelegate> 

@property (nonatomic, retain) UISearchDisplayController *searchController;
@property (nonatomic, retain) UVInstantAnswerManager *instantAnswerManager;

@end
