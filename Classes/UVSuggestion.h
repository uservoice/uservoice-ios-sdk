//
//  UVSuggestion.h
//  UserVoice
//
//  Created by UserVoice on 10/27/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseModel.h"
#import "UVForum.h"

@class UVCategory;
@class UVUser;

@interface UVSuggestion : UVBaseModel {
	NSInteger suggestionId;
	NSInteger forumId;
	NSInteger commentsCount;
	NSInteger voteCount;
	NSInteger votesFor;
	NSInteger votesRemaining;
	NSString *title;
	NSString *abstract;
	NSString *text;
	NSString *status;
	NSString *statusHexColor;
	NSString *forumName;
	
	NSDate *createdAt;
	NSDate *updatedAt;
	NSDate *closedAt;

	NSString *creatorName;
	NSInteger creatorId;
	NSString *responseText;
	NSString *responseUserName;
	NSString *responseUserAvatarUrl;
	NSInteger responseUserId;
	
	UVCategory *category;
}

@property (assign) NSInteger suggestionId;
@property (assign) NSInteger forumId;
@property (assign) NSInteger commentsCount;
@property (assign) NSInteger voteCount;
@property (assign) NSInteger votesFor;
@property (assign) NSInteger votesRemaining;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *abstract;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *statusHexColor;
@property (nonatomic, retain) NSString *forumName;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSDate *closedAt;
@property (nonatomic, retain) NSString *creatorName;
@property (assign) NSInteger creatorId;
@property (nonatomic, retain) NSString *responseText;
@property (nonatomic, retain) NSString *responseUserName;
@property (nonatomic, retain) NSString *responseUserAvatarUrl;
@property (assign) NSInteger responseUserId;
@property (nonatomic, retain) UVCategory *category;
@property (nonatomic, readonly) UIColor *statusColor;
@property (nonatomic, readonly) NSString *categoryString;

// Retrieves a page (10 items) of suggestions.
+ (id)getWithForum:(UVForum *)forum page:(NSInteger)page delegate:(id)delegate;

// Retrieves all suggestions for a user in a forum
+ (id)getWithForumAndUser:(UVForum *)forum user:(UVUser *)user delegate:(id)delegate;

// Retrieves all suggestions for a user
+ (id)getWithUser:(UVUser *)user delegate:(id)delegate;

// Retrieves the suggestions for the specified query.
+ (id)searchWithForum:(UVForum *)forum query:(NSString *)query delegate:(id)delegate;

// Creates a new suggestion with the specified title and text.
+ (id)createWithForum:(UVForum *)forum
			 category:(UVCategory *)category
				title:(NSString *)title
				 text:(NSString *)text
				votes:(NSInteger)votes
			 delegate:(id)delegate;

// Records the specified number of votes for a suggestion.
- (id)vote:(NSInteger)number delegate:(id)delegate;

// Flags a suggestion with the specified code.
- (id)flag:(NSString *)code delegate:(id)delegate;

// Returns the color to use for rendering this suggestion's status.
- (UIColor *)statusColor;

@end
