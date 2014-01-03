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

@interface UVUser : UVBaseModel

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;

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

@end


@protocol UVUserDelegate <NSObject>

@optional

- (void)didCreateUser:(UVUser *)user;
- (void)didDiscoverUser:(UVUser *)user;
- (void)didIdentifyUser:(UVUser *)user;
- (void)didRetrieveCurrentUser:(UVUser *)user;
- (void)didSendForgotPassword:(id)obj;

@end
