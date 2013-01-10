//
//  UVHelpTopic.h
//  UserVoice
//
//  Created by Austin Taylor on 11/16/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseModel.h"

@interface UVHelpTopic : UVBaseModel {
    NSString *name;
    NSInteger topicId;
    NSInteger articleCount;
}

@property (nonatomic,retain) NSString *name;
@property (assign) NSInteger topicId;
@property (assign) NSInteger articleCount;

+ (id)getAllWithDelegate:(id)delegate;
+ (id)getTopicWithId:(NSInteger)topicId delegate:(id)delegate;

@end
