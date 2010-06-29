//
//  UVProfileEditViewController.h
//  UserVoice
//
//  Created by Scott Rutherford on 13/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"

@class UVUser;

@interface UVProfileEditViewController : UVBaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
	NSString *name;
	NSString *email;
	UITextField *nameField;
	UITextField *emailField;
	UVUser *user;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UVUser *user;

@end
