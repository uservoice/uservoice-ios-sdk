//
//  UVForum.h
//  UserVoice
//
//  Created by UserVoice on 11/23/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"
#import "UVTopic.h"

@interface UVForum : UVBaseModel {
	NSInteger forumId;
	BOOL isPrivate;
	NSString *name;
	NSMutableArray *topics;
	UVTopic *currentTopic;
}

@property (assign) NSInteger forumId;
@property (assign) BOOL isPrivate;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *topics;
@property (nonatomic, retain) UVTopic *currentTopic;

- (NSArray *)availableCategories;
- (NSString *)prompt;
- (NSString *)example;

@end
