//
//  UVSession.h
//  UserVoice
//
//  Created by UserVoice on 10/22/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UVConfig;
@class UVClientConfig;
@class UVUser;
@class UVToken;
@class YOAuthConsumer;
@class UVInfo;

// Keeps track of data such as the user's login state, app configuration, etc.
// during the course of a single UserVoice session.
@interface UVSession : NSObject {
    BOOL isModal;
    UVConfig *config;
    UVClientConfig *clientConfig;
    UVUser *user;
    UVInfo *info;
    YOAuthConsumer *yOAuthConsumer;
    UVToken *currentToken;
    NSMutableDictionary *userCache;
    NSDate *startTime;
    NSMutableDictionary *interactions;
    NSMutableArray *interactionSequence;
    NSMutableArray *interactionDetails;
    NSUInteger interactionId;
}

@property (assign) BOOL isModal;
@property (nonatomic, retain) UVConfig *config;
@property (nonatomic, retain) UVClientConfig *clientConfig;
@property (nonatomic, retain) UVUser *user;
@property (nonatomic, retain) UVInfo *info;
@property (nonatomic, retain) UVToken *currentToken;
@property (nonatomic, retain) NSMutableDictionary *userCache;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSMutableDictionary *interactions;
@property (nonatomic, retain) NSMutableArray *interactionSequence;
@property (nonatomic, retain) NSMutableArray *interactionDetails;
@property (assign) NSUInteger interactionId;

+ (UVSession *)currentSession;
- (YOAuthConsumer *)yOAuthConsumer;

- (BOOL)loggedIn;
- (void)trackInteraction:(NSString *)interaction;
- (void)trackInteraction:(NSString *)interaction details:(NSDictionary *)details;
- (void)flushInteractions;

@end
