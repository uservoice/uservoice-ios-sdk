//
//  UVBaseSuggestionViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 11/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseViewController.h"
#import "UVBaseInstantAnswersViewController.h"
#import "UVTextView.h"

@class UVForum;
@class UVCategory;

@interface UVBaseSuggestionViewController : UVBaseInstantAnswersViewController <UIActionSheetDelegate> {
    UVForum *forum;
    NSString *title;
    NSString *text;
    NSString *name;
    NSString *email;
    UITextField *titleField;
    UITextField *nameField;
    UITextField *emailField;
    UVTextView *textView;
    UVCategory *category;
    BOOL shouldShowCategories;
}

@property (nonatomic, retain) UVForum *forum;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) UVTextView *textView;
@property (nonatomic, retain) UITextField *titleField;
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UVCategory *category;
@property (assign) BOOL shouldShowCategories;

- (id)initWithTitle:(NSString *)theTitle;
- (void)pushCategorySelectView;
- (UITextField *)customizeTextFieldCell:(UITableViewCell *)cell label:(NSString *)label placeholder:(NSString *)placeholder;

@end
