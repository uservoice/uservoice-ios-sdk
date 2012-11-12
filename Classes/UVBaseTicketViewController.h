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
#define TICKET_VIEW_IA_LABEL_TAG 1002

#define UV_CUSTOM_FIELD_CELL_LABEL_TAG 100
#define UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG 101

@interface UVBaseTicketViewController : UVBaseViewController<UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate> {
    NSString *text;
    NSString *email;
    NSString *name;
    NSString *initialText;
    UVTextView *textView;
    NSTimer *timer;
    NSArray *instantAnswers;
    UITextField *emailField;
    UITextField *nameField;
    NSMutableDictionary *selectedCustomFieldValues;
    BOOL loadingInstantAnswers;
    BOOL readyToPopView;
}

@property (nonatomic,retain) NSString *text;
@property (nonatomic,retain) NSString *email;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *initialText;
@property (nonatomic,retain) UVTextView *textView;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) NSArray *instantAnswers;
@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UITextField *nameField;
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
- (UIBarButtonItem *)barButtonItem:(NSString *)label withAction:(SEL)selector;
- (void)addButton:(NSString *)label withCaption:(NSString *)caption andRect:(CGRect)rect andMask:(int)autoresizingMask andAction:(SEL)selector toView:(UIView *)parentView;
- (UIView *)fieldsTableFooterView;
- (void)loadInstantAnswers;

- (void)dismissKeyboard;
- (void)willLoadInstantAnswers;
- (void)didLoadInstantAnswers;
- (void)reloadCustomFieldsTable;

@end
