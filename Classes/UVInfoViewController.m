//
//  UVInfoViewController.m
//  UserVoice
//
//  Created by Scott Rutherford 05/26/10
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVInfoViewController.h"
#import "UVConfig.h"
#import "UVSession.h"
#import "UVInfo.h"
#import "UVStyleSheet.h"
#import "UVClientConfig.h"

#define UV_INFO_SECTION_ABOUT 0
#define UV_INFO_SECTION_MOTIVATION 1

@implementation UVInfoViewController

- (void)didRetrieveInfo:(UVInfo *)someInfo {
	[self hideActivityIndicator];
	[UVSession currentSession].info = someInfo;
	[tableView reloadData];
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"";
	UITableViewCellStyle style = UITableViewCellStyleDefault;
	
	if (indexPath.section == UV_INFO_SECTION_ABOUT) {
		identifier = @"About";
		
	} else if (indexPath.section >= UV_INFO_SECTION_MOTIVATION) {
		identifier = @"Motivation";
	}
	
	return [self createCellForIdentifier:identifier
							   tableView:tableView
							   indexPath:indexPath
								   style:style
							  selectable:NO];
}

- (NSInteger)labelHeightWithText:(NSString *)text {
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	CGFloat margin = ((screenWidth > 480) ? 45 : 10) + 10;
    return [text sizeWithFont:[UIFont systemFontOfSize:14]
            constrainedToSize:CGSizeMake(screenWidth - 2 * margin, 100000)
                lineBreakMode:UILineBreakModeWordWrap].height;
}

- (UILabel *)labelWithText:(NSString *)text {
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	CGFloat margin = ((screenWidth > 480) ? 45 : 10) + 10;
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, screenWidth - 2 * margin, [self labelHeightWithText:text])] autorelease];
	label.lineBreakMode = UILineBreakModeWordWrap;	
	label.numberOfLines = 0;
	label.font = [UIFont systemFontOfSize:14];
	label.text = text;
    // This color isn't configurable because the grouped table cell background color is not (currently) configurable.
    label.textColor = [UIColor colorWithRed:0.298 green:0.337 blue:0.424 alpha:1.0];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

- (void)customizeCellForAbout:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UILabel *label = [self labelWithText:[UVSession currentSession].info.about_body];
	[cell.contentView addSubview:label];
}

- (void)customizeCellForMotivation:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UILabel *label = [self labelWithText:[UVSession currentSession].info.motivation_body];
	[cell.contentView addSubview:label];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

#pragma mark ===== UITableViewDelegate Methods =====

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = (indexPath.section == UV_INFO_SECTION_ABOUT) ? [UVSession currentSession].info.about_body : [UVSession currentSession].info.motivation_body;
    return 20 + [self labelHeightWithText:text];
}

#pragma mark ===== Basic View Methods =====

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	// see if we already have the info object loaded
	if ([UVSession currentSession].info == nil) {
		[self showActivityIndicator];
 		[UVInfo getWithDelegate:self];
	}
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	self.navigationItem.title = @"UserVoice";
	
	CGRect frame = [self contentFrame];
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
	theTableView.dataSource = self;
	theTableView.delegate = self;
    theTableView.backgroundColor = [UVStyleSheet backgroundColor];
	
	self.tableView = theTableView;
	[theTableView release];
	
	self.view = tableView;
}

@end
