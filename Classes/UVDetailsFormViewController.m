//
//  UVDetailsFormViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/21/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVDetailsFormViewController.h"
#import "UVValueSelectViewController.h"
#import "UVStyleSheet.h"
#import "UVSession.h"

#define LABEL 100
#define VALUE 101
#define TEXT 102
#define ROW_HEIGHT 44

@implementation UVDetailsFormViewController

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [self registerForKeyboardNotifications];
    [self setupGroupedTableView];
    self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"Additional Details", @"UserVoice", [UserVoice bundle], nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:_sendTitle
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(send)];
    if([self showForumPicker]){
        _pickerData = [[NSMutableArray alloc] init];
        for(UVForum *forum in [UVSession currentSession].forums){
            [_pickerData addObject:forum.name];
        }
        _forumPicker.dataSource = _pickerData;
        _forumPicker.delegate = self;
    } else {
        _forum = [UVSession currentSession].forum;
    }
    if (_helpText) {
        UIView *help = [UIView new];
        help.frame = CGRectMake(0, 0, 0, 80);
        UILabel *label = [UILabel new];
        label.text = _helpText;
        label.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:12];
        label.backgroundColor = [UIColor clearColor];
        [self configureView:help subviews:@{@"label":label} constraints:@[@"|-[label]-|", @"V:|[label]"]];
        _tableView.tableFooterView = help;
    }
}

-(BOOL)showForumPicker{
    return ([[UVSession currentSession].forums count] > 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

#pragma mark ===== UITableViewDataSource Methods =====

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 3 : _fields.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    BOOL selectable = NO;
    if (indexPath.section == 0) {
        if(indexPath.row == 0)
           identifier = @"Email";
        else if (indexPath.row == 1)
            identifier = @"Name";
        else if (indexPath.row == 2 && ([self showForumPicker]))
            identifier = @"ForumDropdown";
    } else {
        NSDictionary *field = _fields[indexPath.row];
        if ([field[@"values"] count] > 0) {
            identifier = @"PredefinedField";
            selectable = YES;
        } else {
            identifier = @"FreeformField";
        }
    }
    return [self createCellForIdentifier:identifier tableView:theTableView indexPath:indexPath style:UITableViewCellStyleDefault selectable:selectable];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return ROW_HEIGHT;
    } else {
        NSDictionary *field = _fields[indexPath.row];
        if ([field[@"values"] count] > 0) {
            return [self heightForDynamicRowWithReuseIdentifier:@"PredefinedField" indexPath:indexPath];
        } else {
            return 60;
        }
    }
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 1) {
        return;
    }
    NSDictionary *field = _fields[indexPath.row];
    if ([field[@"values"] count] > 0) {
        UVValueSelectViewController *next = [[UVValueSelectViewController alloc] initWithField:field valueDictionary:_selectedFieldValues];
        [self.navigationController pushViewController:next animated:YES];
        [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        UITableViewCell *cell = [theTableView cellForRowAtIndexPath:indexPath];
        [[cell viewWithTag:TEXT] becomeFirstResponder];
    }
}

#pragma mark ===== Cells =====

- (void)initCellForPredefinedField:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UILabel *label = [UILabel new];
    label.tag = LABEL;
    label.font = [UIFont systemFontOfSize:13];
    if (IOS7) {
        label.textColor = label.tintColor;
    }
    UILabel *value = [UILabel new];
    value.tag = VALUE;
    value.numberOfLines = 0;
    value.font = [UIFont systemFontOfSize:16];
    [self configureView:cell.contentView
               subviews:NSDictionaryOfVariableBindings(label, value)
            constraints:@[@"|-16-[label]-|", @"|-16-[value]-|", @"V:|-10-[label]-6-[value]"]
         finalCondition:(indexPath == nil)
        finalConstraint:@"V:[value]-8-|"];
}

- (void)customizeCellForPredefinedField:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    NSDictionary *field = _fields[indexPath.row];
    UILabel *label = (UILabel *)[cell viewWithTag:LABEL];
    UILabel *value = (UILabel *)[cell viewWithTag:VALUE];
    label.text = field[@"required"] ? [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"%@ (required)", @"UserVoice", [UserVoice bundle], nil), field[@"name"]] : field[@"name"];
    if (_selectedFieldValues[field[@"name"]]) {
        value.text = _selectedFieldValues[field[@"name"]][@"label"];
        value.textColor = [UIColor blackColor];
    } else {
        value.text = NSLocalizedStringFromTableInBundle(@"select", @"UserVoice", [UserVoice bundle], nil);
        value.textColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.80f alpha:1.0f];
    }
}

- (void)initCellForFreeformField:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UILabel *label = [UILabel new];
    label.tag = LABEL;
    label.font = [UIFont systemFontOfSize:13];
    if (IOS7) {
        label.textColor = label.tintColor;
    }
    UITextField *text = [UITextField new];
    text.tag = TEXT;
    text.borderStyle = UITextBorderStyleNone;
    text.returnKeyType = UIReturnKeyDone;
    text.placeholder = NSLocalizedStringFromTableInBundle(@"enter value", @"UserVoice", [UserVoice bundle], nil);
    [self configureView:cell.contentView
               subviews:NSDictionaryOfVariableBindings(label, text)
            constraints:@[@"|-16-[label]-|", @"|-16-[text]-|", @"V:|-10-[label]-6-[text]"]];
}

- (void)customizeCellForFreeformField:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    NSDictionary *field = _fields[indexPath.row];
    UILabel *label = (UILabel *)[cell viewWithTag:LABEL];
    UITextField *text = (UITextField *)[cell viewWithTag:TEXT];
    label.text = field[@"required"] ? [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"%@ (required)", @"UserVoice", [UserVoice bundle], nil), field[@"name"]] : field[@"name"];
    text.text = _selectedFieldValues[field[@"name"]][@"label"];
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:text queue:nil usingBlock:^(NSNotification *note) {
        self->_selectedFieldValues[field[@"name"]] = @{ @"id" : text.text, @"label" : text.text};
    }];
}

- (void)initCellForEmail:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    self.emailField = [self configureView:cell.contentView label:NSLocalizedStringFromTableInBundle(@"Email", @"UserVoice", [UserVoice bundle], nil) placeholder:NSLocalizedStringFromTableInBundle(@"(required)", @"UserVoice", [UserVoice bundle], nil)];
    _emailField.keyboardType = UIKeyboardTypeEmailAddress;
    _emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _emailField.text = self.userEmail;
}

- (void)initCellForName:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    self.nameField = [self configureView:cell.contentView label:NSLocalizedStringFromTableInBundle(@"Name", @"UserVoice", [UserVoice bundle], nil) placeholder:NSLocalizedStringFromTableInBundle(@"“Anonymous”", @"UserVoice", [UserVoice bundle], nil)];
    _nameField.text = self.userName;
}


- (void)initCellForForumDropdown:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UILabel *label = [UILabel new];
    label.text = [NSString stringWithFormat:@"%@:", NSLocalizedStringFromTableInBundle(@"Forum", @"UserVoice", [UserVoice bundle], nil)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    [label setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

    label.frame = CGRectMake(18, 0, 75, ROW_HEIGHT+10);
    _forumPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(80, 0, 200, ROW_HEIGHT+10)];
    _forumPicker.delegate = self;
    [cell addSubview:_forumPicker];
    [cell addSubview:label];


}

#pragma mark === picker methods ===
// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return (int)_pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [UILabel new];
        tView.font = [UIFont systemFontOfSize:13];
        tView.text = _pickerData[row];
    }
    return tView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _forum = (UVForum *)[[UVSession currentSession].forums objectAtIndex:row];
}

#pragma mark ===== Misc =====

- (void)send {
    [_delegate sendWithEmail:_emailField.text name:_nameField.text fields:_selectedFieldValues];
}

- (void)showActivityIndicator {
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.color = [UVStyleSheet instance].navigationBarActivityIndicatorColor;
    [activityView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", @"UserVoice", [UserVoice bundle], nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.hidesBackButton = YES;
}

- (void)hideActivityIndicator {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:_sendTitle style:UIBarButtonItemStyleDone target:self action:@selector(send)];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = NO;
}

- (void)dismiss {
    if ([_delegate respondsToSelector:@selector(cancel)]) {
        [_delegate cancel];
    }
    [super dismiss];
}

@end
