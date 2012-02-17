//
//  UVProfileIdeaListViewController.m
//  UserVoice
//
//  Created by UserVoice on 12/17/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVProfileIdeaListViewController.h"
#import "UVUser.h"
#import "UVSuggestion.h"
#import "UVSession.h"
#import "UVClientConfig.h"

@implementation UVProfileIdeaListViewController

@synthesize title;
@synthesize user;
@synthesize showCreated;

- (id)initWithSuggestions:(NSArray *)theSuggestions title:(NSString *)theTitle {
	if ((self = [super init])) {
		self.suggestions = [NSMutableArray arrayWithArray:theSuggestions];
		self.title = theTitle;
	}
	return self;
}

- (id)initWithUVUser:(UVUser *)theUser andTitle:(NSString *)theTitle showingCreated:(BOOL)shouldShowCreated {
	if ((self = [super init])) {
		self.user = theUser;
		self.title = theTitle;
		self.showCreated = shouldShowCreated;
        
		if (self.user.suggestionsNeedReload) {
			// add a fake array of suggestions to stop the UVSuggestionListView (parent) being a dick
			// clearly this is not correct, the inheritance structure here needs some love			
			self.suggestions = [NSMutableArray arrayWithCapacity:1];
		} else {
            self.suggestions = showCreated ? user.createdSuggestions : user.supportedSuggestions;
		}
	}
	return self;
}

- (void) didRetrieveUserSuggestions:(NSArray *) theSuggestions {
	[self hideActivityIndicator];
    [self.user didLoadSuggestions:theSuggestions];
	self.suggestions = showCreated ? self.user.createdSuggestions : self.user.supportedSuggestions;
	[self.tableView reloadData];
}

- (void)reloadUserSuggestions {
	[self showActivityIndicator];
//	[UVSuggestion getWithUser:self.user delegate:self];	
    [UVSuggestion getWithForumAndUser:[UVSession currentSession].clientConfig.forum 
								 user:self.user
                             delegate:self];	
}

- (BOOL)supportsSearch {
	return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.suggestions count];
}

#pragma mark ===== Basic View Methods =====

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.user.suggestionsNeedReload) {
        NSLog(@"Reloading User Suggestions");
		[self reloadUserSuggestions];
    }
}

- (void)loadView {
	[super loadView];
	self.navigationItem.title = self.title;		
}

- (void)dealloc {
	self.title = nil;
	self.user = nil;
    [super dealloc];
}

@end
