//
//  UVProfileIdeaListViewController.h
//  UserVoice
//
//  Created by UserVoice on 12/17/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVSuggestionListViewController.h"

@class UVUser;

@interface UVProfileIdeaListViewController : UVSuggestionListViewController {
	NSString *title;
	UVUser *user;
	BOOL showCreated;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) UVUser *user;
@property (assign) BOOL showCreated;

- (id)initWithSuggestions:(NSArray *)theSuggestions title:(NSString *)theTitle;
- (id)initWithUVUser:(UVUser *)theUser andTitle:(NSString *)theTitle showingCreated:(BOOL)shouldShowCreated;

@end
