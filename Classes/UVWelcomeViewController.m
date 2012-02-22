//
//  UVWelcomeViewController.m
//  UserVoice
//
//  Created by UserVoice on 12/15/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVWelcomeViewController.h"
#import "UVStyleSheet.h"
#import "UVFooterView.h"
#import "UVSession.h"
#import "UVForum.h"
#import "UVClientConfig.h"
#import "UVSubdomain.h"
#import "UVNewTicketViewController.h"
#import "UVSuggestionListViewController.h"
#import "UVSignInViewController.h"
#import "UVStreamPoller.h"
#import <QuartzCore/QuartzCore.h>

#define UV_WELCOME_VIEW_ROW_FEEDBACK 0
#define UV_WELCOME_VIEW_ROW_SUPPORT 1

@implementation UVWelcomeViewController

@synthesize forum = _forum;

- (NSString *)backButtonTitle {
	return NSLocalizedStringFromTable(@"Welcome", @"UserVoice", nil);
}

#pragma mark ===== table cells =====

- (void)initCellForForum:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = NSLocalizedStringFromTable(@"Give feedback", @"UserVoice", nil);
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.minimumFontSize = 8.0;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)initCellForSupport:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {    
    cell.textLabel.text = NSLocalizedStringFromTable(@"Contact support", @"UserVoice", nil);
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.minimumFontSize = 8.0;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"";
	BOOL selectable = YES;

	UITableViewCellStyle style = UITableViewCellStyleDefault;	
	if (indexPath.row == UV_WELCOME_VIEW_ROW_FEEDBACK) {
		identifier = @"Forum";
	} else if (indexPath.row == UV_WELCOME_VIEW_ROW_SUPPORT) {		
		identifier = @"Support";
    }
	
	return [self createCellForIdentifier:identifier
							   tableView:theTableView
							   indexPath:indexPath
								   style:style
							  selectable:selectable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([UVSession currentSession].clientConfig.ticketsEnabled)
        return 2;
    return 1;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	switch (indexPath.row) {
        case UV_WELCOME_VIEW_ROW_FEEDBACK: {
            UVSuggestionListViewController *next = [[UVSuggestionListViewController alloc] initWithForum:self.forum];
            [self.navigationController pushViewController:next animated:YES];            
            [next release];
			break;
		}
        case UV_WELCOME_VIEW_ROW_SUPPORT: {
            UVNewTicketViewController *next = [[UVNewTicketViewController alloc] init];
            [self.navigationController pushViewController:next animated:YES];
            [next release];
			break;
		}
		default:
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedStringFromTable(@"Feedback & Support", @"UserVoice", nil);
}

#pragma mark ===== Basic View Methods =====

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	[self.navigationItem setHidesBackButton:YES animated:NO];
	
	CGRect frame = [self contentFrame];
	tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
	tableView.dataSource = self;
	tableView.delegate = self;
	tableView.sectionFooterHeight = 0.0;
	tableView.sectionHeaderHeight = 0.0;
    tableView.backgroundColor = [UVStyleSheet backgroundColor];
	tableView.tableFooterView = [UVFooterView footerViewForController:self];
	self.view = tableView;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];		
	
	self.forum = [UVSession currentSession].clientConfig.forum;		
	if ([self needsReload]) {
		NSLog(@"WelcomeView needs reload");
		
		[(UVFooterView *)tableView.tableFooterView reloadFooter];
	}

	[tableView reloadData];
    
    UVFooterView *footer = (UVFooterView *) self.tableView.tableFooterView;
    [footer reloadFooter];
}

- (void)dealloc {
    self.forum = nil;
    self.tableView = nil;
    [super dealloc];
}

@end
