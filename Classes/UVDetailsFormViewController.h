//
//  UVDetailsFormViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 10/21/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVBaseViewController.h"
#import "UVInstantAnswerManager.h"
#import "UVForum.h"

@interface UVDetailsFormViewController : UVBaseViewController<UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, retain) NSString *sendTitle;
@property (nonatomic, retain) NSArray *fields;
@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, assign) id<NSObject, UVInstantAnswersDelegate> delegate;
@property (nonatomic, retain) NSMutableDictionary *selectedFieldValues;
@property (nonatomic, retain) NSString *helpText;
@property (nonatomic, retain) UIPickerView *forumPicker;
@property (nonatomic, retain) NSMutableArray *pickerData;
@property (nonatomic, retain) UVForum *forum;

-(BOOL)showForumPicker;

@end
