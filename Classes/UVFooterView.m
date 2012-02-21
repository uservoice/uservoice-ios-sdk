//
//  UVFooterView.m
//  UserVoice
//
//  Created by UserVoice on 1/12/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVFooterView.h"
#import "UVBaseViewController.h"
#import "UVUser.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVProfileViewController.h"
#import "UVSignInViewController.h"
#import "UVInfoViewController.h"
#import "UVNewTicketViewController.h"
#import "UVSuggestion.h"
#import "UVSubdomain.h"
#import "UVStyleSheet.h"
#import <QuartzCore/QuartzCore.h>

#define UV_FOOTER_TAG_NAME_VIEW 1
#define UV_FOOTER_TAG_NAME_LABEL 2
#define UV_FOOTER_TAG_NAME_ICON 3

@implementation UVFooterView

@synthesize controller;
@synthesize tableView;

- (void)infoButtonTapped {
	UVInfoViewController *next = [[UVInfoViewController alloc] init];
	[self.controller.navigationController pushViewController:next animated:YES];
	[next release];
}

+ (UVFooterView *)footerViewForController:(UVBaseViewController *)controller {
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	UVFooterView *footer = [[[UVFooterView alloc ]initWithFrame:CGRectMake(0, 0, screenWidth, 110)] autorelease];
	footer.controller = controller;
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:footer.bounds style:UITableViewStyleGrouped];
	theTableView.scrollEnabled = NO;
	theTableView.delegate = footer;
	theTableView.dataSource = footer;
	theTableView.sectionHeaderHeight = 10.0;
	theTableView.sectionFooterHeight = 8.0;		
	theTableView.backgroundColor = [UVStyleSheet backgroundColor];
    
    // Fix background color on iPad
    if ([theTableView respondsToSelector:@selector(setBackgroundView:)])
        [theTableView setBackgroundView:nil];
	
	UIView *tableFooter = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 25)] autorelease];
	UILabel *poweredBy = [[[UILabel alloc] initWithFrame:CGRectMake(30, 8, (screenWidth-80), 16)] autorelease];
	poweredBy.text = NSLocalizedStringFromTable(@"Feedback powered by UserVoice", @"UserVoice", nil);
	poweredBy.font = [UIFont systemFontOfSize:14.0];
	poweredBy.textColor = [UVStyleSheet tableViewHeaderColor];
	poweredBy.backgroundColor = [UIColor clearColor];
	poweredBy.textAlignment = UITextAlignmentCenter;
	[tableFooter addSubview:poweredBy];
    
    //TODO: make the info button light if the background color is dark
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
	infoButton.center = CGPointMake(screenWidth / 2 + 110, 14);
	[infoButton addTarget:footer action:@selector(infoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[tableFooter addSubview:infoButton];
	
	theTableView.tableFooterView = tableFooter;
	
	footer.tableView = theTableView;
	[footer addSubview:theTableView];
	[theTableView release];
	
	return footer;
}


- (void)reloadFooter {
	[self.tableView reloadData];
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
    CGFloat margin = (screenWidth > 480) ? 45 : 10;

	if ([UVSession currentSession].loggedIn) {
		cell.textLabel.text = NSLocalizedStringFromTable(@"My profile", @"UserVoice", nil);
		UIView *nameView = [[[UIView alloc] initWithFrame:CGRectMake(100, 13, (screenWidth - 130 - 2 * margin), 18)] autorelease];
		UILabel *nameLabel = [[[UILabel alloc] initWithFrame:nameView.bounds] autorelease];
		nameLabel.textColor = [UVStyleSheet signedInUserTextColor];
		nameLabel.textAlignment = UITextAlignmentRight;
		nameLabel.font = [UIFont systemFontOfSize:14.0];
		nameLabel.text = [[UVSession currentSession].user nameOrAnonymous];
        nameLabel.backgroundColor = [UIColor clearColor];
		[nameView addSubview:nameLabel];
		
		if ([[UVSession currentSession].user hasUnconfirmedEmail]) {
			// Shrink label to make space for the image
			CGRect labelFrame = nameLabel.frame;
			nameLabel.frame = CGRectMake(labelFrame.origin.x, labelFrame.origin.y, labelFrame.size.width - 23, labelFrame.size.height);

			UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_alert.png"]];
			icon.frame = CGRectMake(labelFrame.origin.x + labelFrame.size.width - 18, 0, 18, 18);
			[nameView addSubview:icon];
			[icon release];
		}
		[cell.contentView addSubview:nameView];
	} else {
		cell.textLabel.text = NSLocalizedStringFromTable(@"Sign in", @"UserVoice", nil);
		cell.textLabel.textAlignment = UITextAlignmentLeft;
//		cell.accessoryType = UITableViewCellAccessoryNone;
//		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}	
	return cell;	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {	
	return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

#pragma mark ===== UITableViewDelegate Methods =====

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	UIViewController *next = nil;

	if ([UVSession currentSession].loggedIn) {
		UVUser *user = [UVSession currentSession].user;			
		next = [[UVProfileViewController alloc] initWithUVUser:user];
	} else {
		next = [[UVSignInViewController alloc] init];
	}

	if (next) {
		[self.controller.navigationController pushViewController:next animated:YES];
		[next release];
	}
}

- (void)dealloc {
    self.tableView = nil;
    [super dealloc];
}

@end
