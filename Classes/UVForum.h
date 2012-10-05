//
//  UVForum.h
//  UserVoice
//
//  Created by UserVoice on 11/23/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@interface UVForum : UVBaseModel {
    NSInteger forumId;
    BOOL isPrivate;
    NSString *name;
    NSString *example;
    NSString *prompt;
    NSInteger votesAllowed;
    NSInteger votesRemaining;
    NSInteger suggestionsCount;
    NSMutableArray *categories;
    NSMutableArray *suggestions;
    BOOL suggestionsNeedReload;
}

@property (assign) NSInteger forumId;
@property (assign) BOOL isPrivate;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *example;
@property (nonatomic, retain) NSString *prompt;
@property (nonatomic, assign) NSInteger votesAllowed;
@property (nonatomic, assign) NSInteger votesRemaining;
@property (nonatomic, assign) NSInteger suggestionsCount;
@property (assign) BOOL suggestionsNeedReload;
@property (nonatomic, retain) NSMutableArray *categories;
@property (nonatomic, retain) NSMutableArray *suggestions;

@end
