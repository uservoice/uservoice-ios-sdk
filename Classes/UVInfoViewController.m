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
	[self loadView];
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

- (void)initCellForAbout:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath 
{
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, (screenWidth-40), 180)];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = UITextAlignmentLeft;
	label.lineBreakMode = UILineBreakModeWordWrap;	
	label.numberOfLines = 30;
	label.font = [UIFont systemFontOfSize:14];
	label.text = [UVSession currentSession].info.about_body;		
	label.textColor = [UVStyleSheet tableViewHeaderColor];
	
	[cell.contentView addSubview:label];
	[label release];
}

- (void)initCellForMotivation:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath 
{
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, (screenWidth-40), 150)];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = UITextAlignmentLeft;
	label.lineBreakMode = UILineBreakModeWordWrap;
	label.numberOfLines = 30;
	label.font = [UIFont systemFontOfSize:14];
	label.text = [UVSession currentSession].info.motivation_body;		
	label.textColor = [UVStyleSheet tableViewHeaderColor];
	
	[cell.contentView addSubview:label];
	[label release];
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
	if (indexPath.section == UV_INFO_SECTION_ABOUT) {
		return 200;
	} else {
		return 170;
	}
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
	//theTableView.backgroundColor = [UIColor clearColor];
    theTableView.backgroundColor = [UVStyleSheet lightBgColor];
	
	self.tableView = theTableView;
	[theTableView release];
	
	self.view = tableView;
	
	//[self addGradientBackground];	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.tableView = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
