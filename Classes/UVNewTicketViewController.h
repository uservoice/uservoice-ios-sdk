//
//  UVNewTicketViewController.h
//  UserVoice
//
//  Created by UserVoice on 2/19/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseTicketViewController.h"

@class UVCustomField;

@interface UVNewTicketViewController : UVBaseTicketViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    UITextField *emailField;
    UIView *activeField;
    NSMutableDictionary *selectedCustomFieldValues;
    BOOL showInstantAnswers;
    int instantAnswersCount;
}

+ (UIViewController *)viewController;
+ (UIViewController *)viewControllerWithText:(NSString *)text;

@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UIView *activeField;
@property (nonatomic, retain) NSMutableDictionary *selectedCustomFieldValues;
@property (assign) BOOL showInstantAnswers;

- (void)dismissKeyboard;

@end
