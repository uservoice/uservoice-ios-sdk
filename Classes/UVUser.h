//
//  UVUser.h
//  UserVoice
//
//  Created by UserVoice on 10/26/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@class UVSuggestion;

@interface UVUser : UVBaseModel {
	NSInteger userId;
	NSString *name;
	NSString *displayName;
	NSString *email;
	BOOL emailConfirmed;
	BOOL suggestionsNeedReload;
	NSInteger ideaScore;
	NSInteger activityScore;
	NSInteger karmaScore;
	NSInteger supportedSuggestionsCount;
	NSInteger createdSuggestionsCount;
	NSString *url;
	NSString *avatarUrl;
	NSMutableArray *supportedSuggestions;
	NSMutableArray *createdSuggestions;
	NSDate *createdAt;
}

@property (assign) NSInteger userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSString *email;
@property (assign) BOOL emailConfirmed;
@property (assign) BOOL suggestionsNeedReload;
@property (assign) NSInteger ideaScore;
@property (assign) NSInteger activityScore;
@property (assign) NSInteger karmaScore;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *avatarUrl;
@property (nonatomic, retain) NSMutableArray *supportedSuggestions;
@property (nonatomic, retain) NSMutableArray *createdSuggestions;
@property (nonatomic, retain) NSDate *createdAt;

- (NSInteger)createdSuggestionsCount;
- (NSInteger)supportedSuggestionsCount;


// fetch
+ (id)getWithUserId:(NSInteger)userId delegate:(id)delegate;

// discover
+ (id)discoverWithEmail:(NSString *)email delegate:(id)delegate;
+ (id)discoverWithGUID:(NSString *)guid delegate:(id)delegate;

// create
+ (id)findOrCreateWithEmail:(NSString *)anEmail andName:(NSString *)aName andDelegate:(id)delegate;
+ (id)findOrCreateWithGUID:(NSString *)aGUID andEmail:(NSString *)anEmail andName:(NSString *)aName andDelegate:(id)delegate;
+ (id)findOrCreateWithSsoToken:(NSString *)aToken delegate:(id)delegate;
+ (id)retrieveCurrentUser:(id)delegate;

// use https (updates and creations only)
+ (void)useHTTPS:(BOOL)secure;

// update
- (id)updateName:(NSString *)newName email:(NSString *)newEmail delegate:(id)delegate;
- (void)didSupportSuggestion:(UVSuggestion *)suggestion;
- (void)didWithdrawSupportForSuggestion:(UVSuggestion *)suggestion;
- (void)didCreateSuggestion:(UVSuggestion *)suggestion;
- (void)didLoadSuggestions:(NSArray *)suggestions;

// others
- (id)forgotPasswordForEmail:(NSString *)anEmail andDelegate:(id)delegate;

- (BOOL)hasEmail;
- (BOOL)hasConfirmedEmail;
- (BOOL)hasUnconfirmedEmail;

// Returns the user's name, or "Anonymous" if they don't have one.
- (NSString *)nameOrAnonymous;

@end
