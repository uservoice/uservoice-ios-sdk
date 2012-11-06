//
//  UVBaseTicketViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 10/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseViewController.h"
#import "UVTextView.h"

#define TICKET_VIEW_ARROW_TAG 1000
#define TICKET_VIEW_SPINNER_TAG 1001

#define UV_CUSTOM_FIELD_CELL_LABEL_TAG 100
#define UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG 101
#define UV_CUSTOM_FIELD_CELL_VALUE_LABEL_TAG 102

@interface UVBaseTicketViewController : UVBaseViewController<UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSString *text;
    UVTextView *textView;
    NSTimer *timer;
    NSArray *instantAnswers;
    UITextField *emailField;
    UIView *activeField;
    NSMutableDictionary *selectedCustomFieldValues;
    BOOL loadingInstantAnswers;
}

@property (nonatomic,retain) NSString *text;
@property (nonatomic,retain) UVTextView *textView;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) NSArray *instantAnswers;
@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UIView *activeField;
@property (nonatomic, retain) NSMutableDictionary *selectedCustomFieldValues;

- (id)initWithText:(NSString *)theText;
- (void)selectInstantAnswerAtIndex:(int)index;
- (void)selectCustomFieldAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)theTableView;
- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell index:(int)index;
- (void)addSpinnerAndArrowTo:(UIView *)view atCenter:(CGPoint)center;
- (void)updateSpinnerAndArrowIn:(UIView *)view withToggle:(BOOL)toggled animated:(BOOL)animated;
- (NSString *)instantAnswersFoundMessage;
- (BOOL)signedIn;
- (void)sendButtonTapped;
- (void)suggestionButtonTapped;

- (void)dismissKeyboard;
- (void)willLoadInstantAnswers;
- (void)didLoadInstantAnswers;
- (void)reloadCustomFieldsTable;

@end
