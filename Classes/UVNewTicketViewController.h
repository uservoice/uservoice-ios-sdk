//
//  UVNewTicketViewController.h
//  UserVoice
//
//  Created by UserVoice on 2/19/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"
#import "UVTextView.h"

@class UVCustomField;

@interface UVNewTicketViewController : UVBaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate> {
    UVTextView *textEditor;
    UITextField *emailField;
    UIView *activeField;
    NSString *text;
    NSMutableDictionary *selectedCustomFieldValues;
    NSTimer *timer;
    NSArray *instantAnswers;
    BOOL loadingInstantAnswers;
}

@property (nonatomic, retain) UVTextView *textEditor;
@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UIView *activeField;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSMutableDictionary *selectedCustomFieldValues;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSArray *instantAnswers;
@property (nonatomic, assign) BOOL loadingInstantAnswers;

- (id)initWithText:(NSString *)text;
- (void)dismissKeyboard;

@end
