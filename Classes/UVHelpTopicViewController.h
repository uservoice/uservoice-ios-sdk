//
//  UVHelpTopicViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 11/16/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseViewController.h"

@class UVHelpTopic;

@interface UVHelpTopicViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate> {
    UVHelpTopic *topic;
    NSArray *articles;
    IBOutlet UIButton *contactButton;
}

@property (nonatomic,retain) UVHelpTopic *topic;
@property (nonatomic,retain) NSArray *articles;

- (IBAction)contactUsTapped;

@end
