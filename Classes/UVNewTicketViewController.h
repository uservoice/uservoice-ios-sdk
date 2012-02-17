//
//  UVNewTicketViewController.h
//  UserVoice
//
//  Created by UserVoice on 2/19/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"
#import "UVTextEditor.h"

@class UVCustomField;

@interface UVNewTicketViewController : UVBaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UVTextEditorDelegate> {
	UVTextEditor *textEditor;
	UITextField *emailField;
	UIBarButtonItem *prevBarButton;
    UIView *activeField;
	//NSArray *customFields;
}

@property (nonatomic, retain) UVTextEditor *textEditor;
@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UIBarButtonItem *prevBarButton;
@property (nonatomic, retain) UIView *activeField;
//@property (nonatomic, retain) NSArray *customFields;

@end
