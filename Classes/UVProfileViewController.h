//
//  UVProfileViewController.h
//  UserVoice
//
//  Created by UserVoice on 11/12/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"

@class UVUser;

@interface UVProfileViewController : UVBaseViewController <UITableViewDataSource, UITableViewDelegate> {
	// We need these before we have retrieved the full user object
	NSInteger userId;
	NSString *userName;
	NSString *avatarUrl;
	
	UVUser *user;
	NSString *message;
}

@property (assign) NSInteger userId;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) UVUser *user;
@property (nonatomic, retain) NSString *avatarUrl;
@property (nonatomic, retain) NSString *message;

- (id)initWithUserId:(NSInteger)theUserId name:(NSString *)theUserName;
- (id)initWithUserId:(NSInteger)theUserId name:(NSString *)theUserName avatarUrl:(NSString *)theAatarUrl;
// Note: Have to call this initWithUVUser instead of initWithUser to avoid conflict
//       with [NSUserDefaults initWithUser:] 
- (id)initWithUVUser:(UVUser *)theUser;

@end
