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
#import "UVCallback.h"

@class UVCategory;
@class UVUser;

@interface UVSuggestion : UVBaseModel {
    NSInteger suggestionId;
    NSInteger forumId;
    NSInteger commentsCount;
    NSInteger subscriberCount;
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
    NSString *responseUserTitle;
    NSString *responseUserAvatarUrl;
    NSInteger responseUserId;
    NSDate *responseCreatedAt;

    UVCategory *category;
    BOOL subscribed;
}

@property (assign) NSInteger suggestionId;
@property (assign) NSInteger forumId;
@property (assign) NSInteger commentsCount;
@property (assign) NSInteger subscriberCount;
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
@property (nonatomic, retain) NSString *responseUserTitle;
@property (nonatomic, retain) NSDate *responseCreatedAt;
@property (assign) NSInteger responseUserId;
@property (nonatomic, retain) UVCategory *category;
@property (nonatomic, readonly) UIColor *statusColor;
@property (nonatomic, readonly) NSString *categoryString;
@property (assign) BOOL subscribed;

// Retrieves a page (10 items) of suggestions.
+ (id)getWithForum:(UVForum *)forum page:(NSInteger)page delegate:(id)delegate;

// Retrieves the suggestions for the specified query.
+ (id)searchWithForum:(UVForum *)forum query:(NSString *)query delegate:(id)delegate;

// Creates a new suggestion with the specified title and text.
+ (id)createWithForum:(UVForum *)forum
             category:(NSInteger)categoryId
                title:(NSString *)title
                 text:(NSString *)text
                votes:(NSInteger)votes
             callback:(UVCallback *)callback;

- (id)subscribe:(id)delegate;
- (id)unsubscribe:(id)delegate;

- (UIColor *)statusColor;
- (NSString *)responseUserWithTitle;

@end
