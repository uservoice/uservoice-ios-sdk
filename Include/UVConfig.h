//
//  UVConfig.h
//  UserVoice
//
//  Created by UserVoice on 10/19/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UVConfig : NSObject {
    NSString *site;
    NSString *key;
    NSString *secret;
    NSString *ssoToken;
    NSString *displayName;
    NSString *email;
    NSString *guid;
    NSInteger topicId;
    BOOL showForum;
    BOOL showPostIdea;
    BOOL showContactUs;
    BOOL showKnowledgeBase;
}

+ (UVConfig *)configWithSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret;
+ (UVConfig *)configWithSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret andSSOToken:(NSString *)token;
+ (UVConfig *)configWithSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret andEmail:(NSString *)email andDisplayName:(NSString *)displayName andGUID:(NSString *)guid;

@property (nonatomic, retain) NSString *site;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *secret;
@property (nonatomic, retain) NSString *ssoToken;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *guid;
@property (nonatomic, retain) NSDictionary *customFields;
@property (assign) NSInteger topicId;
@property (nonatomic, assign) BOOL showForum;
@property (nonatomic, assign) BOOL showPostIdea;
@property (nonatomic, assign) BOOL showContactUs;
@property (nonatomic, assign) BOOL showKnowledgeBase;

- (id)initWithSite:(NSString *)theSite andKey:(NSString *)theKey andSecret:(NSString *)theSecret;
- (id)initWithSite:(NSString *)theSite andKey:(NSString *)theKey andSecret:(NSString *)theSecret andSSOToken:(NSString *)theToken;
- (id)initWithSite:(NSString *)theSite andKey:(NSString *)theKey andSecret:(NSString *)theSecret andEmail:(NSString *)theEmail andDisplayName:(NSString *)theDisplayName andGUID:(NSString *)theGuid;
- (BOOL)wasSignedInBySDK;

@end
