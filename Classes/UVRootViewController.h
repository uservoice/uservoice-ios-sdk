//
//  UVRootViewController.h
//  UserVoice
//
//  Created by UserVoice on 12/15/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"


// This is an intermediate controller that is responsible for logging in and retrieving
// the iPhone app config, and then yields control to the actual view controller.
@interface UVRootViewController : UVBaseViewController {
    NSString *viewToLoad;
}

@property (nonatomic, retain) NSString *viewToLoad;

- (id)initWithViewToLoad:(NSString *)theViewToLoad;

@end
