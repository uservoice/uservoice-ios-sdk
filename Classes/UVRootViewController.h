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
	NSString *ssoToken;
	NSString *email;
	NSString *guid;
	NSString *displayName;
}

@property (nonatomic, retain) NSString *ssoToken;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *guid;
@property (nonatomic, retain) NSString *displayName;

- (id)initWithSsoToken:(NSString *)aToken;
- (id)initWithEmail:(NSString *)anEmail andGUID:(NSString *)aGUID andName:(NSString *)aDisplayName;

@end
