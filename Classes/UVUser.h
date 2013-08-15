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

@protocol UVUserDelegate;

@interface UVUser : UVBaseModel {
    NSInteger userId;
    NSString *name;
    NSString *displayName;
    NSString *email;
    BOOL suggestionsNeedReload;
    NSInteger ideaScore;
    NSInteger activityScore;
    NSInteger karmaScore;
    NSInteger supportedSuggestionsCount;
    NSInteger createdSuggestionsCount;
    NSInteger votesRemaining;
    NSString *url;
    NSString *avatarUrl;
    NSMutableArray *supportedSuggestions;
    NSMutableArray *createdSuggestions;
    NSDate *createdAt;
    NSDictionary *visibleForumsDict;
}

@property (assign) NSInteger userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSString *email;
@property (assign) BOOL suggestionsNeedReload;
@property (assign) NSInteger ideaScore;
@property (assign) NSInteger activityScore;
@property (assign) NSInteger karmaScore;
@property (assign) NSInteger votesRemaining;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *avatarUrl;
@property (nonatomic, retain) NSMutableArray *supportedSuggestions;
@property (nonatomic, retain) NSMutableArray *createdSuggestions;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDictionary *visibleForumsDict;

- (NSInteger)createdSuggestionsCount;
- (NSInteger)supportedSuggestionsCount;

+ (id)forgotPassword:(NSString *)email delegate:(id<UVUserDelegate>)delegate;

// discover
+ (id)discoverWithEmail:(NSString *)email delegate:(id<UVUserDelegate>)delegate;

// create
+ (id)findOrCreateWithEmail:(NSString *)anEmail andName:(NSString *)aName andDelegate:(id<UVUserDelegate>)delegate;
+ (id)findOrCreateWithGUID:(NSString *)aGUID andEmail:(NSString *)anEmail andName:(NSString *)aName andDelegate:(id<UVUserDelegate>)delegate;
+ (id)findOrCreateWithSsoToken:(NSString *)aToken delegate:(id<UVUserDelegate>)delegate;
+ (id)retrieveCurrentUser:(id<UVUserDelegate>)delegate;

// update
- (id)identify:(NSString *)externalId withScope:(NSString *)externalScope delegate:(id<UVUserDelegate>)delegate;
- (void)didSupportSuggestion:(UVSuggestion *)suggestion;
- (void)didWithdrawSupportForSuggestion:(UVSuggestion *)suggestion;
- (void)didCreateSuggestion:(UVSuggestion *)suggestion;
- (void)didLoadSuggestions:(NSArray *)suggestions;

// others
- (BOOL)hasEmail;

// this is used to get around an order dependency when loading the config
- (void)updateVotesRemaining;

// Returns the user's name, or "Anonymous" if they don't have one.
- (NSString *)nameOrAnonymous;

@end


@protocol UVUserDelegate <NSObject>

@optional

- (void)didCreateUser:(UVUser *)user;
- (void)didDiscoverUser:(UVUser *)user;
- (void)didIdentifyUser:(UVUser *)user;
- (void)didRetrieveCurrentUser:(UVUser *)user;
- (void)didSendForgotPassword:(id)obj;

@end