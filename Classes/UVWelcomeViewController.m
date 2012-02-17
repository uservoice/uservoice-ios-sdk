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

#define UV_FORUM_LIST_SECTION_FORUMS 0
#define UV_FORUM_LIST_SECTION_SUPPORT 1

@implementation UVWelcomeViewController

@synthesize forum = _forum;

- (NSString *)backButtonTitle {
	return @"Welcome";
}

#pragma mark ===== UIAlertViewDelegate Methods =====

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertView.firstOtherButtonIndex) {
		NSString *url = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",
						 [UVSession currentSession].clientConfig.itunesApplicationId];
		
		NSLog(@"Attempting to open iTunes page: %@", url);
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
}

#pragma mark ===== table cells =====

- (void)initCellForForum:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [_forum prompt];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (CGFloat)heightForViewWithHeader:(NSString *)header subheader:(NSString *)subheader 
{
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	
	if (subheader) {
		CGSize subSize = [subheader sizeWithFont:[UIFont systemFontOfSize:14]
							   constrainedToSize:CGSizeMake((screenWidth - 40), 9999)
								   lineBreakMode:UILineBreakModeWordWrap];
		return subSize.height + 35 + 5 + 5; // (subheader + header + padding between/bottom)
		
	} else if (header) {
		return 35 + 5; // header + padding bottom only
	}
	
	return 10;
}

- (void)initCellForSupport:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {    
    cell.textLabel.text = [NSString stringWithFormat:@"Contact %@", [UVSession currentSession].clientConfig.subdomain.name];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)initCellForSpacer:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	
	UIView *bg = [[UILabel alloc] initWithFrame:CGRectMake(-10, -10, screenWidth, 11)];		
	bg.backgroundColor = [UVStyleSheet backgroundColor];
	[cell.contentView addSubview:bg];
	[bg release];
}

- (UIView *)viewWithHeader:(NSString *)header subheader:(NSString *)subheader {
	CGFloat height = [self heightForViewWithHeader:header subheader:subheader];
	
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
    CGFloat margin = ((screenWidth > 480) ? 45 : 10) + 10;
	
	UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, height)] autorelease];
	headerView.backgroundColor = [UVStyleSheet backgroundColor];
	
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(margin, 5, (screenWidth - 2 * margin), 35)];
	title.text = header;
	title.font = [UIFont boldSystemFontOfSize:18];
	title.backgroundColor = [UIColor clearColor];
	title.textColor = [UVStyleSheet tableViewHeaderColor];
	[headerView addSubview:title];
	[title release];
	
	if (subheader) {
		UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(margin, 33, (screenWidth - 2 * margin), height - (33 + 5))];
		subtitle.text = subheader;
		subtitle.lineBreakMode = UILineBreakModeWordWrap;
		subtitle.numberOfLines = 0;
		subtitle.font = [UIFont systemFontOfSize:14];
		subtitle.backgroundColor = [UIColor clearColor];
		subtitle.textColor = [UVStyleSheet tableViewHeaderColor];
		[headerView addSubview:subtitle];
		[subtitle release];
	}
	
	return headerView;
}

- (NSString *)headerTextForSection:(NSInteger)section {
	if (section == 0) {
		return @"Give Feedback";
		
	} else {
		return [UVSession currentSession].clientConfig.ticketsEnabled ? @"Contact Support" : nil;
	}
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"";
	BOOL selectable = YES;

	UITableViewCellStyle style = UITableViewCellStyleDefault;	
	if (indexPath.section == UV_FORUM_LIST_SECTION_FORUMS) {
		identifier = @"Forum";
	} else if (indexPath.section == UV_FORUM_LIST_SECTION_SUPPORT) {		
		if ([UVSession currentSession].clientConfig.ticketsEnabled) {
			identifier = @"Support";
		} else {
			identifier = @"Spacer";
            selectable = NO;
		}
    }
	
	return [self createCellForIdentifier:identifier
							   tableView:theTableView
							   indexPath:indexPath
								   style:style
							  selectable:selectable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	switch (indexPath.section) {
        case UV_FORUM_LIST_SECTION_FORUMS: {
            UVSuggestionListViewController *next = [[UVSuggestionListViewController alloc] initWithForum:self.forum];
            [self.navigationController pushViewController:next animated:YES];            
            [next release];
			break;
		}
        case UV_FORUM_LIST_SECTION_SUPPORT: {
            UVNewTicketViewController *next = [[UVNewTicketViewController alloc] init];
            [self.navigationController pushViewController:next animated:YES];
            [next release];
			break;
		}
		default:
			break;
	}
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == UV_FORUM_LIST_SECTION_FORUMS) {
		return 45;
		
	} else if (indexPath.section == UV_FORUM_LIST_SECTION_SUPPORT) {
		return [UVSession currentSession].clientConfig.ticketsEnabled ? 45 : 0.0;
    }
	return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return [self heightForViewWithHeader:[self headerTextForSection:section]
							   subheader:nil];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return [self viewWithHeader:[self headerTextForSection:section]
					  subheader:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 0.0;
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
