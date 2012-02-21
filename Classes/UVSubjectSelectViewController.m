//
//  UVSubjectSelectViewController.m
//  UserVoice
//
//  Created by UserVoice on 6/9/11.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import "UVSubjectSelectViewController.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVCustomField.h"
#import "UVSubdomain.h"
#import "UVNewTicketViewController.h"

@implementation UVSubjectSelectViewController

@synthesize subjects;
@synthesize selectedSubject;

- (id)initWithSelectedSubject:(UVCustomField *)subject {
	if (self = [super init]) {
		self.subjects = [UVSession currentSession].clientConfig.customFields;
		self.selectedSubject = subject;
		NSLog(@"subjects: %@", self.subjects);
	}
	return self;
}

#pragma mark ===== table cells =====

- (void)customizeCellForSubject:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UVCustomField *subject = (UVCustomField *)[self.subjects objectAtIndex:indexPath.row];
	cell.textLabel.text = subject.name;
	NSLog(@"name: %@", subject.name);
//	if (self.selectedSubject && self.selectedSubject.subjectId == subject.subjectId) {
//		cell.accessoryType = UITableViewCellAccessoryCheckmark;
//	} else {
//		cell.accessoryType = UITableViewCellAccessoryNone;
//	}
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self createCellForIdentifier:@"Subject"
							   tableView:theTableView
							   indexPath:indexPath
								   style:UITableViewCellStyleDefault
							  selectable:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.subjects count];
}

#pragma mark ===== UITableViewDelegate Methods =====

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	
//	UVCustomField *subject = [self.subjects objectAtIndex:indexPath.row];
//	
//	// Update the previous view controller (the new message view)
//	NSArray *viewControllers = [self.navigationController viewControllers];
//	UVNewTicketViewController *prev = (UVNewTicketViewController *)[viewControllers objectAtIndex:[viewControllers count] - 2];
//	prev.subject = subject;
//	prev.needsReload = YES;
//	
//	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ===== Basic View Methods =====

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	self.navigationItem.title = NSLocalizedStringFromTable(@"Subject", @"UserVoice", nil);
	
	CGRect frame = [self contentFrame];
	UITableView *theTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
	theTableView.dataSource = self;
	theTableView.delegate = self;
	
	self.view = theTableView;
	[theTableView release];
}

- (void)dealloc {
	self.subjects = nil;
	self.selectedSubject = nil;
    [super dealloc];
}

@end
