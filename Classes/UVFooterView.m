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
#import "UVTaskBar.h"
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

+ (CGFloat)heightForFooter {
	return 110; // actual cells and padding + table footer
}

+ (UIView *)getHeaderView 
{
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	UIView *bottomShadow = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 10)] autorelease];
	UIImage *shadow = [UIImage imageNamed:@"dropshadow_bottom_30.png"];
	CGFloat widthScale = screenWidth / shadow.size.width; // horizontal scaling factor to expand shadow image
	UIImageView *shadowView = [[[UIImageView alloc] initWithImage:shadow] autorelease];
	shadowView.transform = CGAffineTransformMakeScale(widthScale, 1.0); // rescale the shadow
	shadowView.center = CGPointMake(screenWidth/2, shadowView.center.y); // recenter the upscaled shadow
	[bottomShadow addSubview:shadowView];	
	return bottomShadow;
}

+ (UVFooterView *)footerViewForController:(UVBaseViewController *)controller 
{
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	UVFooterView *footer = [[[UVFooterView alloc ]initWithFrame:CGRectMake(0, 0, screenWidth, [UVFooterView heightForFooter])] autorelease];
	footer.controller = controller;
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:footer.bounds style:UITableViewStyleGrouped];
	theTableView.scrollEnabled = NO;
	theTableView.delegate = footer;
	theTableView.dataSource = footer;
	theTableView.sectionHeaderHeight = 10.0;
	theTableView.sectionFooterHeight = 8.0;		
	theTableView.tableHeaderView = [self getHeaderView];
    theTableView.backgroundColor = [UVStyleSheet lightBgColor];
		
	UIView *tableFooter = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 25)] autorelease];
	UILabel *poweredBy = [[[UILabel alloc] initWithFrame:CGRectMake(30, 10, (screenWidth - 80), 14)] autorelease];
	poweredBy.text = NSLocalizedString(@"Feedback powered by UserVoice", @"Feedback powered by UserVoice");
	poweredBy.font = [UIFont systemFontOfSize:14.0];
	poweredBy.textColor = [UIColor colorWithRed:0.278 green:0.341 blue:0.435 alpha:1.0];
	poweredBy.backgroundColor = [UVStyleSheet lightBgColor];
	poweredBy.textAlignment = UITextAlignmentCenter;
	[tableFooter addSubview:poweredBy];
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
	infoButton.center = CGPointMake((screenWidth - 50), 14);
	[infoButton addTarget:footer action:@selector(infoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[tableFooter addSubview:infoButton];
	
	theTableView.tableFooterView = tableFooter;
	
	footer.tableView = theTableView;
	[footer addSubview:theTableView];
	[theTableView release];
	
	return footer;
}

+ (UVFooterView *)altFooterViewForController:(UVBaseViewController *)controller 
{
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	UVFooterView *footer = [[[UVFooterView alloc ]initWithFrame:CGRectMake(0, 0, screenWidth, [UVFooterView heightForFooter])] autorelease];
	footer.controller = controller;
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:footer.bounds style:UITableViewStyleGrouped];
	theTableView.scrollEnabled = NO;
	theTableView.delegate = footer;
	theTableView.dataSource = footer;
	theTableView.sectionHeaderHeight = 14.0;
	theTableView.sectionFooterHeight = 8.0;		
	theTableView.tableHeaderView = [self getHeaderView];
	theTableView.backgroundColor = [UVStyleSheet lightBgColor];
    //[UVStyleSheet lightZebraBgColor];
	
	UIView *tableFooter = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 25)] autorelease];
	UILabel *poweredBy = [[[UILabel alloc] initWithFrame:CGRectMake(30, 10, (screenWidth-80), 14)] autorelease];
	poweredBy.text = NSLocalizedString(@"Feedback powered by UserVoice", @"Feedback powered by UserVoice");
	poweredBy.font = [UIFont systemFontOfSize:14.0];
	poweredBy.textColor = [UIColor colorWithRed:0.278 green:0.341 blue:0.435 alpha:1.0];
	poweredBy.backgroundColor = [UIColor clearColor];
	poweredBy.textAlignment = UITextAlignmentCenter;
	[tableFooter addSubview:poweredBy];
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
	infoButton.center = CGPointMake((screenWidth-50), 14);
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

	if ([UVSession currentSession].loggedIn) {
		cell.textLabel.text = @"My profile";
		UIView *nameView = [[[UIView alloc] initWithFrame:CGRectMake(100, 13, (screenWidth-150), 18)] autorelease];
		UILabel *nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 2, (screenWidth-150), 14)] autorelease];
		nameLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
		nameLabel.textAlignment = UITextAlignmentRight;
		nameLabel.font = [UIFont systemFontOfSize:14.0];
		nameLabel.text = [[UVSession currentSession].user nameOrAnonymous];
		[nameView addSubview:nameLabel];
		
		if ([[UVSession currentSession].user hasUnconfirmedEmail]) {
			UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_alert.png"]];
			icon.frame = CGRectMake(156, 0, 18, 18);
			[nameView addSubview:icon];
			[icon release];
			
			// Shrink label to make space for the image
			CGRect labelFrame = nameLabel.frame;
			nameLabel.frame = CGRectMake(labelFrame.origin.x, labelFrame.origin.y, labelFrame.size.width - 23, labelFrame.size.height);
		}
		[cell.contentView addSubview:nameView];
	} else {
		cell.textLabel.text = NSLocalizedString(@"Sign in", @"Sign in");
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

@end
