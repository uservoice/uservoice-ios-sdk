//
//  UVBaseTicketViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 10/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseInstantAnswersViewController.h"
#import "UVTextView.h"

#define UV_CUSTOM_FIELD_CELL_LABEL_TAG 100
#define UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG 101

@interface UVBaseTicketViewController : UVBaseInstantAnswersViewController<UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate> {
    UVTextView *textView;
    NSString *text;
    NSString *initialText;
    UITextField *emailField;
    UITextField *nameField;
    NSMutableDictionary *selectedCustomFieldValues;
    BOOL readyToPopView;
    BOOL dismissed;
}

@property (nonatomic,retain) UVTextView *textView;
@property (nonatomic,retain) NSString *text;
@property (nonatomic,retain) NSString *initialText;
@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) NSMutableDictionary *selectedCustomFieldValues;

- (id)initWithText:(NSString *)theText;
- (void)selectCustomFieldAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)theTableView;
- (void)sendButtonTapped;
- (void)suggestionButtonTapped;
- (void)addButton:(NSString *)label withCaption:(NSString *)caption andRect:(CGRect)rect andMask:(int)autoresizingMask andAction:(SEL)selector toView:(UIView *)parentView;
- (UIView *)fieldsTableFooterView;
- (void)dismissKeyboard;
- (void)reloadCustomFieldsTable;

@end
