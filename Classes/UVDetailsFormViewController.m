//
//  UVDetailsFormViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/21/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVDetailsFormViewController.h"

@implementation UVDetailsFormViewController

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    self.tableView = [[[UITableView alloc] initWithFrame:[self contentFrame] style:UITableViewStyleGrouped] autorelease];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.view = tableView;

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(_sendTitle, @"UserVoice", nil)
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self
                                                                              action:@selector(send)] autorelease];
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
    BOOL selectable;
    if (indexPath.section == 0) {
        identifier = (indexPath.row == 0) ? @"Email" : @"Name";
        selectable = NO;
    } else {
        UVCustomField *field = _fields[indexPath.row];
        if (field.isPredefined) {
            identifier = @"PredefinedField";
            selectable = YES;
        } else {
            identifier = @"FreeformField";
            selectable = NO;
        }
    }
    return [self createCellForIdentifier:identifier tableView:theTableView indexPath:indexPath style:UITableViewCellStyleDefault selectable:selectable];
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark ===== Cells =====

// - (void)initCellForField:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
//     cell.backgroundColor = [UIColor whiteColor];
//     UILabel *label = [self addCellLabel:cell];
//     label.tag = UV_CUSTOM_FIELD_CELL_LABEL_TAG;
//     UILabel *valueLabel = [self addCellValueLabel:cell];
//     valueLabel.tag = UV_CUSTOM_FIELD_CELL_VALUE_LABEL_TAG;
//     UITextField *textField = [self addCellValueTextField:cell];
//     textField.tag = UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG;
//     textField.delegate = self;
// }

// - (void)customizeCellForField:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
//     UVCustomField *field = [[UVSession currentSession].clientConfig.customFields objectAtIndex:indexPath.row];
//     UILabel *label = (UILabel *)[cell viewWithTag:UV_CUSTOM_FIELD_CELL_LABEL_TAG];
//     UITextField *textField = (UITextField *)[cell viewWithTag:UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG];
//     UILabel *valueLabel = (UILabel *)[cell viewWithTag:UV_CUSTOM_FIELD_CELL_VALUE_LABEL_TAG];
//     label.text = [field isRequired] ? [NSString stringWithFormat:@"%@*", field.name] : field.name;
//     cell.accessoryType = [field isPredefined] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
//     textField.enabled = [field isPredefined] ? NO : YES;
//     cell.selectionStyle = [field isPredefined] ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
//     valueLabel.hidden = ![field isPredefined];
//     textField.hidden = [field isPredefined];
//     if ([selectedFieldValues objectForKey:field.name]) {
//         valueLabel.text = [selectedFieldValues objectForKey:field.name];
//         valueLabel.textColor = [UIColor blackColor];
//     } else {
//         valueLabel.text = NSLocalizedStringFromTable(@"select", @"UserVoice", nil);
//         valueLabel.textColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.80f alpha:1.0f];
//     }
//     [[NSNotificationCenter defaultCenter] addObserver:self
//                                              selector:@selector(nonPredefinedValueChanged:)
//                                                  name:UITextFieldTextDidChangeNotification
//                                                object:textField];
// }

- (void)initCellForEmail:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    self.emailField = [self configureCell:cell label:NSLocalizedStringFromTable(@"Email", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"(required)", @"UserVoice", nil)];
    _emailField.keyboardType = UIKeyboardTypeEmailAddress;
    _emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _emailField.text = self.userEmail;
}

- (void)initCellForName:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    self.nameField = [self configureCell:cell label:NSLocalizedStringFromTable(@"Name", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"“Anonymous”", @"UserVoice", nil)];
    _nameField.text = self.userName;
}

#pragma mark ===== Misc =====

- (UITextField *)configureCell:(UITableViewCell *)cell label:(NSString *)labelText placeholder:(NSString *)placeholderText {
    UITextField *field = [[UITextField new] autorelease];
    field.placeholder = placeholderText;
    [field setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    UILabel *label = [[UILabel new] autorelease];
    label.text = labelText;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    [label setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self configureView:cell.contentView
               subviews:NSDictionaryOfVariableBindings(field, label)
            constraints:@[@"|-16-[label]-[field]-|", @"V:|-12-[label]", @"V:|-12-[field]"]];
    return field;
}

- (void)send {
    [_delegate send];
}

- (void)dealloc {
    self.emailField = nil;
    self.nameField = nil;
    self.fields = nil;
    self.sendTitle = nil;
    [super dealloc];
}

@end
