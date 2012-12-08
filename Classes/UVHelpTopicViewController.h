//
//  UVHelpTopicViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 11/16/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseViewController.h"

@class UVHelpTopic;

@interface UVHelpTopicViewController : UVBaseViewController<UITableViewDataSource,UITableViewDelegate> {
    UVHelpTopic *topic;
    NSArray *articles;
}

@property (nonatomic,retain) UVHelpTopic *topic;
@property (nonatomic,retain) NSArray *articles;

- (id)initWithTopic:(UVHelpTopic *)theTopic;

@end
