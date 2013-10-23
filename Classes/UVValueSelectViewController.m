//
//  UVValueSelectViewController.m
//  UserVoice
//
//  Created by UserVoice on 6/9/11.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import "UVValueSelectViewController.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVCustomField.h"
#import "UVSubdomain.h"
#import "UVBaseTicketViewController.h"

@implementation UVValueSelectViewController

- (id)initWithCustomField:(UVCustomField *)field valueDictionary:dictionary {
    if (self = [super init]) {
        self.customField = field;
        self.valueDictionary = dictionary;
    }
    return self;
}

#pragma mark ===== table cells =====

- (void)customizeCellForValue:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    NSString *value = _customField.values[indexPath.row];
    NSString *selectedValue = _valueDictionary[_customField.name];
    cell.textLabel.text = value;
    cell.accessoryType = [value isEqualToString:selectedValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self createCellForIdentifier:@"Value" tableView:theTableView indexPath:indexPath style:UITableViewCellStyleDefault selectable:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _customField.values.count;
}

#pragma mark ===== UITableViewDelegate Methods =====

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [theTableView cellForRowAtIndexPath:indexPath];
    _valueDictionary[_customField.name] = cell.textLabel.text;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [super loadView];
    self.navigationItem.title = self.customField.name;
    UITableView *theTableView = [[[UITableView alloc] initWithFrame:[self contentFrame] style:UITableViewStylePlain] autorelease];
    theTableView.dataSource = self;
    theTableView.delegate = self;
    self.view = theTableView;
}

- (void)dealloc {
    self.customField = nil;
    self.valueDictionary = nil;
    [super dealloc];
}

@end
