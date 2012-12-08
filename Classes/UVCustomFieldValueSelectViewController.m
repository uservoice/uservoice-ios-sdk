//
//  UVCustomFieldValueSelectViewController.m
//  UserVoice
//
//  Created by UserVoice on 6/9/11.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import "UVCustomFieldValueSelectViewController.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVCustomField.h"
#import "UVSubdomain.h"
#import "UVBaseTicketViewController.h"

@implementation UVCustomFieldValueSelectViewController

@synthesize customField;
@synthesize valueDictionary;

- (id)initWithCustomField:(UVCustomField *)field valueDictionary:dictionary {
    if (self = [super init]) {
        self.customField = field;
        self.valueDictionary = dictionary;
    }
    return self;
}

#pragma mark ===== table cells =====

- (void)customizeCellForValue:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    NSString *value = (NSString *)[self.customField.values objectAtIndex:indexPath.row];
    cell.textLabel.text = value;
    NSString *selectedValue = [valueDictionary objectForKey:customField.name];
    cell.accessoryType = [value isEqualToString:selectedValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self createCellForIdentifier:@"Value"
                               tableView:theTableView
                               indexPath:indexPath
                                   style:UITableViewCellStyleDefault
                              selectable:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.customField.values count];
}

#pragma mark ===== UITableViewDelegate Methods =====

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [theTableView cellForRowAtIndexPath:indexPath];
    [valueDictionary setObject:cell.textLabel.text forKey:customField.name];
    // TODO: Uncheck the previously selected row
    NSArray *viewControllers = [self.navigationController viewControllers];
    UVBaseTicketViewController *prev = (UVBaseTicketViewController *)[viewControllers objectAtIndex:[viewControllers count] - 2];
    [prev reloadCustomFieldsTable];
    [prev dismissKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ===== Basic View Methods =====

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        NSArray *viewControllers = [self.navigationController viewControllers];
        UVBaseTicketViewController *prev = (UVBaseTicketViewController *)[viewControllers lastObject];
        [prev reloadCustomFieldsTable];
        [prev dismissKeyboard];
    }
    [super viewWillDisappear:animated];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];

    self.navigationItem.title = self.customField.name;

    CGRect frame = [self contentFrame];
    UITableView *theTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    theTableView.dataSource = self;
    theTableView.delegate = self;

    self.view = theTableView;
    [theTableView release];
}

- (void)dealloc {
    self.customField = nil;
    self.valueDictionary = nil;
    [super dealloc];
}

@end
