//
//  UVProfileIdeaListViewController.m
//  UserVoice
//
//  Created by Mirko Froehlich on 12/17/09.
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
	if (self = [super init]) {
		self.suggestions = [NSMutableArray arrayWithArray:theSuggestions];
		self.title = theTitle;
	}
	return self;
}

- (id)initWithUVUser:(UVUser *)theUser andTitle:(NSString *)theTitle showingCreated:(BOOL)shouldShowCreated {
	if (self = [super init]) {
		self.user = theUser;
		self.title = theTitle;
		self.showCreated = shouldShowCreated;
		if (self.user.suggestionsNeedReload) {
			// add a fake array of suggestions to stop the UVSuggestionListView (parent) being a dick
			// clearly this is not correct, the inheritance structure here needs some love			
			self.suggestions = [NSMutableArray arrayWithCapacity:1];
		} else {
			if (self.showCreated) {
				self.suggestions = self.user.createdSuggestions;
			} else {
				self.suggestions = self.user.supportedSuggestions;
			}
		}
	}
	return self;	
}

- (void) didRetrieveUserSuggestions:(NSArray *) theSuggestions {
	[self hideActivityIndicator];
	[self.user.supportedSuggestions removeAllObjects];
	[self.user.createdSuggestions removeAllObjects];
	
	if (theSuggestions && ![[NSNull null] isEqual:theSuggestions]) {
		for (UVSuggestion *suggestion in theSuggestions) {
			[self.user.supportedSuggestions addObject:suggestion];
		}
	}	
	for (UVSuggestion *suggestion in self.user.supportedSuggestions) {
		if (suggestion.creatorId == self.user.userId) {
			[self.user.createdSuggestions addObject:suggestion];
		}
	}		
	if (self.showCreated) {
		self.suggestions = self.user.createdSuggestions;
	} else {
		self.suggestions = self.user.supportedSuggestions;
	}
	[self.tableView reloadData];
	
	// TODO make sure that this gets unset after voting or creating
	self.user.suggestionsNeedReload = NO;
}

- (void)reloadUserSuggestions {
	[self showActivityIndicator];
	[UVSuggestion getWithForumAndUser:[UVSession currentSession].clientConfig.forum 
								 user:self.user delegate:self];	
}

- (BOOL)supportsSearch {
	return NO;
}

- (BOOL)supportsFooter {
	return NO;
}

#pragma mark ===== Basic View Methods =====

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.user.suggestionsNeedReload)
		[self reloadUserSuggestions];
}

- (void)loadView {
	[super loadView];
	
	self.navigationItem.title = self.title;
	allSuggestionsRetrieved = YES;
	
	[self addGradientBackground];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.title = nil;
	self.user = nil;
	
    [super dealloc];
}


@end
