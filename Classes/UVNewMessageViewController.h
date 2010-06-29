//
//  UVNewMessageViewController.h
//  UserVoice
//
//  Created by Mirko Froehlich on 2/19/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"
#import "Three20/Three20.h"

@class UVSubject;

@interface UVNewMessageViewController : UVBaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, TTTextEditorDelegate> {
	NSString *text;
	NSString *name;
	NSString *email;
	TTTextEditor *textEditor;
	UITextField *nameField;
	UITextField *emailField;
	UIBarButtonItem *prevBarButton;
	UVSubject *subject;
	BOOL shouldResizeForKeyboard;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) TTTextEditor *textEditor;
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UIBarButtonItem *prevBarButton;
@property (nonatomic, retain) UVSubject *subject;

@end
