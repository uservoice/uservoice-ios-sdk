//
//  UVComment.h
//  UserVoice
//
//  Created by UserVoice on 11/11/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@class UVSuggestion;

@interface UVComment : UVBaseModel {
	NSInteger commentId;
	NSString *text;
	NSString *userName;
	NSInteger userId;
	NSString *avatarUrl;
	NSInteger karmaScore;
	NSDate *createdAt;
}

@property (assign) NSInteger commentId;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *userName;
@property (assign) NSInteger userId;
@property (nonatomic, retain) NSString *avatarUrl;
@property (assign) NSInteger karmaScore;
@property (nonatomic, retain) NSDate *createdAt;

+ (id)getWithSuggestion:(UVSuggestion *)suggestion page:(NSInteger)page delegate:(id)delegate;
+ (id)createWithSuggestion:(UVSuggestion *)suggestion text:(NSString *)text delegate:(id)delegate;
- (id)flag:(NSString *)code suggestion:(UVSuggestion *)suggestion delegate:(id)delegate;

@end
