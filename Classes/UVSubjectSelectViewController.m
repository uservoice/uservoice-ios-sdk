//
//  UVSubjectSelectViewController.m
//  UserVoice
//
//  Created by Mirko Froehlich on 2/19/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVSubjectSelectViewController.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVSubject.h"
#import "UVSubdomain.h"
#import "UVNewMessageViewController.h"

@implementation UVSubjectSelectViewController

@synthesize subjects;
@synthesize selectedSubject;

- (id)initWithSelectedSubject:(UVSubject *)subject {
	if (self = [super init]) {
		self.subjects = [UVSession currentSession].clientConfig.subdomain.messageSubjects;
		self.selectedSubject = subject;
	}
	return self;
}

#pragma mark ===== table cells =====

- (void)customizeCellForSubject:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UVSubject *subject = (UVSubject *)[self.subjects objectAtIndex:indexPath.row];
	cell.textLabel.text = subject.text;
	if (self.selectedSubject && self.selectedSubject.subjectId == subject.subjectId) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self createCellForIdentifier:@"Subject"
							   tableView:tableView
							   indexPath:indexPath
								   style:UITableViewCellStyleDefault
							  selectable:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.subjects count];
}

#pragma mark ===== UITableViewDelegate Methods =====

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	UVSubject *subject = [self.subjects objectAtIndex:indexPath.row];
	
	// Update the previous view controller (the new message view)
	NSArray *viewControllers = [self.navigationController viewControllers];
	UVNewMessageViewController *prev = (UVNewMessageViewController *)[viewControllers objectAtIndex:[viewControllers count] - 2];
	prev.subject = subject;
	prev.needsReload = YES;
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ===== Basic View Methods =====

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	self.navigationItem.title = @"Subject";
	
	CGRect frame = [self contentFrame];
	UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
	tableView.dataSource = self;
	tableView.delegate = self;
	
	self.view = tableView;
	[tableView release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
