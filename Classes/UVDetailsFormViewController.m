//
//  UVDetailsFormViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/21/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVDetailsFormViewController.h"
#import "UVValueSelectViewController.h"

#define LABEL 100
#define VALUE 101
#define TEXT 102

@implementation UVDetailsFormViewController

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [self setupGroupedTableView];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(_sendTitle, @"UserVoice", nil)
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self
                                                                              action:@selector(send)] autorelease];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [tableView reloadData];
}

#pragma mark ===== UITableViewDataSource Methods =====

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 2 : _fields.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    BOOL selectable = NO;
    if (indexPath.section == 0) {
        identifier = (indexPath.row == 0) ? @"Email" : @"Name";
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
    return (indexPath.section == 0) ? 44 : 60;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *field = _fields[indexPath.row];
    if ([field[@"values"] count] > 0) {
        UVValueSelectViewController *next = [[[UVValueSelectViewController alloc] initWithField:field valueDictionary:_selectedFieldValues] autorelease];
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
    UILabel *label = [[UILabel new] autorelease];
    label.tag = LABEL;
    label.font = [UIFont systemFontOfSize:13];
    label.backgroundColor = [UIColor clearColor];
    if (IOS7) {
        label.textColor = label.tintColor;
    }
    UILabel *value = [[UILabel new] autorelease];
    value.tag = VALUE;
    value.font = [UIFont systemFontOfSize:16];
    value.backgroundColor = [UIColor clearColor];
    [self configureView:cell.contentView
               subviews:NSDictionaryOfVariableBindings(label, value)
            constraints:@[@"|-16-[label]-|", @"|-16-[value]-|", @"V:|-10-[label]-6-[value]"]];
}

- (void)customizeCellForPredefinedField:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    NSDictionary *field = _fields[indexPath.row];
    UILabel *label = (UILabel *)[cell viewWithTag:LABEL];
    UILabel *value = (UILabel *)[cell viewWithTag:VALUE];
    label.text = field[@"required"] ? [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ (required)", @"UserVoice", nil), field[@"name"]] : field[@"name"];
    if (_selectedFieldValues[field[@"name"]]) {
        value.text = _selectedFieldValues[field[@"name"]][@"label"];
        value.textColor = [UIColor blackColor];
    } else {
        value.text = NSLocalizedStringFromTable(@"select", @"UserVoice", nil);
        value.textColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.80f alpha:1.0f];
    }
}

- (void)initCellForFreeformField:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UILabel *label = [[UILabel new] autorelease];
    label.tag = LABEL;
    label.font = [UIFont systemFontOfSize:13];
    label.backgroundColor = [UIColor clearColor];
    if (IOS7) {
        label.textColor = label.tintColor;
    }
    UITextField *text = [[UITextField new] autorelease];
    text.tag = TEXT;
    text.borderStyle = UITextBorderStyleNone;
    text.backgroundColor = [UIColor clearColor];
    text.returnKeyType = UIReturnKeyDone;
    text.placeholder = NSLocalizedStringFromTable(@"enter value", @"UserVoice", nil);
    [self configureView:cell.contentView
               subviews:NSDictionaryOfVariableBindings(label, text)
            constraints:@[@"|-16-[label]-|", @"|-16-[text]-|", @"V:|-10-[label]-6-[text]"]];
}

- (void)customizeCellForFreeformField:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    NSDictionary *field = _fields[indexPath.row];
    UILabel *label = (UILabel *)[cell viewWithTag:LABEL];
    UITextField *text = (UITextField *)[cell viewWithTag:TEXT];
    label.text = field[@"required"] ? [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ (required)", @"UserVoice", nil), field[@"name"]] : field[@"name"];
    text.text = _selectedFieldValues[field[@"name"]][@"label"];
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:text queue:nil usingBlock:^(NSNotification *note) {
        _selectedFieldValues[field[@"name"]] = @{ @"id" : text.text, @"label" : text.text};
    }];
}

- (void)initCellForEmail:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    self.emailField = [self configureView:cell.contentView label:NSLocalizedStringFromTable(@"Email", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"(required)", @"UserVoice", nil)];
    _emailField.keyboardType = UIKeyboardTypeEmailAddress;
    _emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _emailField.text = self.userEmail;
}

- (void)initCellForName:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    self.nameField = [self configureView:cell.contentView label:NSLocalizedStringFromTable(@"Name", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"“Anonymous”", @"UserVoice", nil)];
    _nameField.text = self.userName;
}

#pragma mark ===== Misc =====

- (void)send {
    [_delegate sendWithEmail:_emailField.text name:_nameField.text fields:_selectedFieldValues];
}

- (void)dealloc {
    self.emailField = nil;
    self.nameField = nil;
    self.fields = nil;
    self.sendTitle = nil;
    self.selectedFieldValues = nil;
    [super dealloc];
}

@end
