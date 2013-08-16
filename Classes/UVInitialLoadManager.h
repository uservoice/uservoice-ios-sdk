//
//  UVInitialLoadManager.h
//  UserVoice
//
//  Created by Austin Taylor on 12/10/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVUser.h"

@interface UVInitialLoadManager : NSObject<UIAlertViewDelegate, UVUserDelegate> {
    id delegate;
    SEL action;
    BOOL userDone;
    BOOL topicsDone;
    BOOL articlesDone;
    BOOL configDone;
    BOOL forumDone;
    BOOL dismissed;
}

+ (UVInitialLoadManager *)loadWithDelegate:(id)delegate action:(SEL)action;

@property (assign) BOOL dismissed;

@end
