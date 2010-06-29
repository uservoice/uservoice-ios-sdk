//
//  UVWelcomeViewController.m
//  UserVoice
//
//  Created by Mirko Froehlich on 12/15/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVWelcomeViewController.h"
#import "UVSuggestionListViewController.h"
#import "UVForum.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVFooterView.h"
#import "UVStyleSheet.h"
#import "UVQuestion.h"
#import "UVAnswer.h"
#import "UVSignInViewController.h"

#define UV_FORUM_LIST_TAG_CELL_LABEL 1000
#define UV_FORUM_LIST_TAG_CELL_IMAGE 1001
#define UV_FORUM_LIST_TAG_CELL_QUESTION_SEGMENTS 1002
#define UV_FORUM_LIST_TAG_CELL_MSG_TAG 1003

#define UV_FORUM_LIST_SECTION_FORUMS 0
#define UV_FORUM_LIST_SECTION_QUESTIONS 1

@implementation UVWelcomeViewController

@synthesize forum;
@synthesize questions;
@synthesize question;
@synthesize tableView;

- (NSString *)backButtonTitle {
	return @"Welcome";
}

- (void)questionSegmentChanged:(id)sender {
	UISegmentedControl *segments = (UISegmentedControl *)sender;
	[self showActivityIndicator];
	// still using single question hack of assigning a single current one
	[UVAnswer initWithQuestion:self.question andValue:(segments.selectedSegmentIndex + 1) andDelegate:self];
}

- (void)didCreateAnswer:(UVAnswer *)theAnswer {
	[self hideActivityIndicator];
	self.question.currentAnswer = theAnswer;
}

- (CGFloat)heightForViewWithHeader:(NSString *)header subheader:(NSString *)subheader {
	if (subheader) {
		CGSize subSize = [subheader sizeWithFont:[UIFont systemFontOfSize:14]
							   constrainedToSize:CGSizeMake(280, 9999)
								   lineBreakMode:UILineBreakModeWordWrap];
		return subSize.height + 20 + 5 + 5; // (subheader + header + padding between/bottom)
	} else {
		return 20 + 5; // header + padding bottom only
	}
}

- (UIView *)viewWithHeader:(NSString *)header subheader:(NSString *)subheader {
	CGFloat height = [self heightForViewWithHeader:header subheader:subheader];
	UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height)] autorelease];
	headerView.backgroundColor = [UIColor clearColor];
	
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 20)];
	title.text = header;
	title.font = [UIFont boldSystemFontOfSize:18];
	title.backgroundColor = [UIColor clearColor];
	title.textColor = [UVStyleSheet tableViewHeaderColor];
	[headerView addSubview:title];
	[title release];
	
	if (subheader) {
		UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 23, 280, height - (23 + 5))];
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
		return self.forum.name;
	} else {
		return @"Rating";
	}
}

- (NSString *)subHeaderTextForSection:(NSInteger)section {
	if (section == 0) {
		return nil;
	} else {
		NSArray *qs = [UVSession currentSession].clientConfig.questions;
		UVQuestion *q = [qs objectAtIndex:0];
		return q.text;
	}
}

- (void)addQuestionCell:(UITableViewCell *)cell labelWithText:(NSString *)text alignment:(UITextAlignment)alignment {
	// Simply stack up all labels with the same frame. The alignment will take care of things.
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 49, 280, 15)];
	
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont systemFontOfSize:12];
	label.textColor = [UVStyleSheet tableViewHeaderColor];
	label.text = text;
	label.textAlignment = alignment;
	[cell.contentView addSubview:label];
	[label release];
}

- (void)updateSegmentsValue:(UISegmentedControl *)segments {
	if (self.question.currentAnswer && self.question.currentAnswer.value > 0) {
		// Answers are 1-5 (0 means none), indexes 0-4
		segments.selectedSegmentIndex = self.question.currentAnswer.value - 1;
	} else {
		segments.selectedSegmentIndex = UISegmentedControlNoSegment;
	}
}

#pragma mark ===== table cells =====

- (void)initCellForForum:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 250, 24)];
	label.lineBreakMode = UILineBreakModeTailTruncation;
	label.numberOfLines = 1;
	label.font = [UIFont boldSystemFontOfSize:16];
	label.tag = UV_FORUM_LIST_TAG_CELL_LABEL;
	[cell.contentView addSubview:label];
	[label release];
	
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(260, 15, 12, 12)];
	imageView.tag = UV_FORUM_LIST_TAG_CELL_IMAGE;
	imageView.image = [UIImage imageNamed:@"uv_lock.png"];
	[cell.contentView addSubview:imageView];
	[imageView release];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)customizeCellForForum:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:UV_FORUM_LIST_TAG_CELL_LABEL];
	textLabel.text = [self.forum prompt];
	
	UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:UV_FORUM_LIST_TAG_CELL_IMAGE];
	imageView.hidden = !self.forum.isPrivate;
}

- (void)initCellForQuestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	NSArray *items = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
	UISegmentedControl *segments = [[UISegmentedControl alloc] initWithItems:items];
	segments.tag = UV_FORUM_LIST_TAG_CELL_QUESTION_SEGMENTS;
	segments.frame = CGRectMake(0, 0, 300, 44);
	[self updateSegmentsValue:segments]; // necessary to avoid triggering an update when we set it in the customize method
	[segments addTarget:self action:@selector(questionSegmentChanged:) forControlEvents:UIControlEventValueChanged];\
	
    // disable unless user
	BOOL enabled = [UVSession currentSession].user != nil;
	[segments setEnabled:enabled];
		
	// add segments
	[cell.contentView addSubview:segments];
	[segments release];
	
	[self addQuestionCell:cell labelWithText:@"Unlikely" alignment:UITextAlignmentLeft];
	[self addQuestionCell:cell labelWithText:@"Maybe" alignment:UITextAlignmentCenter];
	[self addQuestionCell:cell labelWithText:@"Absolutely" alignment:UITextAlignmentRight];
		
	if (!enabled) {
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 300, 20)];
		label.tag = UV_FORUM_LIST_TAG_CELL_MSG_TAG;
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont boldSystemFontOfSize:14];
		label.text = @"You will need to sign in to answer.";		
		label.textColor = [UVStyleSheet darkRedColor];
		
		[cell.contentView addSubview:label];
		[label release];				
	}
}

- (void)customizeCellForQuestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UISegmentedControl *segments = (UISegmentedControl *)[cell.contentView viewWithTag:UV_FORUM_LIST_TAG_CELL_QUESTION_SEGMENTS];
	[self updateSegmentsValue:segments];
}

#pragma mark ===== UIAlertViewDelegate Methods =====

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertView.firstOtherButtonIndex) {
		//NSLog(@"Launching app store");
		NSString *url = [NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8",
						 [UVSession currentSession].clientConfig.itunesApplicationId];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"";
	BOOL selectable = YES;
	UITableViewCellStyle style = UITableViewCellStyleDefault;
	
	if (indexPath.section == UV_FORUM_LIST_SECTION_FORUMS) {
		identifier = @"Forum";

	} else if (indexPath.section >= UV_FORUM_LIST_SECTION_QUESTIONS) {
		identifier = @"Question";
		if ([UVSession currentSession].user != nil)
			selectable = NO;
	}
	
	return [self createCellForIdentifier:identifier
							   tableView:theTableView
							   indexPath:indexPath
								   style:style
							  selectable:selectable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// [tableView setBackgroundColor:[UIColor blackColor]];
	
	if ([UVSession currentSession].clientConfig.questionsEnabled) {
		return 2;
	} else {
		return 1;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 44;
	} else {
		return [UVSession currentSession].user==nil ? 70 : 50;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return [self heightForViewWithHeader:[self headerTextForSection:section]
							   subheader:[self subHeaderTextForSection:section]];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return [self viewWithHeader:[self headerTextForSection:section]
					  subheader:[self subHeaderTextForSection:section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 18.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 18)] autorelease];
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
		case UV_FORUM_LIST_SECTION_QUESTIONS: {
			if ([UVSession currentSession].user==nil) {
				UVSignInViewController *next = [[UVSignInViewController alloc] init];
				[self.navigationController pushViewController:next animated:YES];
				[next release];
			}
			break;
		}
		default:
			break;
	}
}

#pragma mark ===== Basic View Methods =====

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];

	// Remove Back button, as we want to treat the forum list as the top level
	// view, rather than going back to the root view.
	[self.navigationItem setHidesBackButton:YES animated:NO];

	CGRect frame = [self contentFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:frame];
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStyleGrouped];
	theTableView.dataSource = self;
	theTableView.delegate = self;
	theTableView.backgroundColor = [UIColor clearColor];
	
	NSString *welcomeText = [UVSession currentSession].clientConfig.welcome;
	CGSize welcomeSize = [welcomeText sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(280, 9999) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, welcomeSize.width, welcomeSize.height)];
	welcomeLabel.lineBreakMode = UILineBreakModeWordWrap;
	welcomeLabel.numberOfLines = 0;
	welcomeLabel.font = [UIFont systemFontOfSize:14];
	welcomeLabel.backgroundColor = [UIColor clearColor];
	welcomeLabel.textColor = [UVStyleSheet tableViewHeaderColor];
	welcomeLabel.text = welcomeText;
	UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, welcomeSize.height + 40)];
	[tableHeaderView addSubview:welcomeLabel];
	theTableView.tableHeaderView = tableHeaderView;
	[tableHeaderView release];
	[welcomeLabel release];
	
	theTableView.tableFooterView = [UVFooterView footerViewForController:self];
	
	self.tableView = theTableView;
	[contentView addSubview:theTableView];
	[theTableView release];
	
	self.view = contentView;
	[contentView release];
	
	[self addGradientBackground];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	// It's important that we initialize the forums based on the session config here.
	// This way, if the user logs in under a different profile later, the proper list
	// of forums is reflected in the view.
	// (not strictly necessary any more, now that we are only showing a single forum)
	self.forum = [UVSession currentSession].clientConfig.forum;
	if ([UVSession currentSession].clientConfig.questionsEnabled) {
		self.questions = [UVSession currentSession].clientConfig.questions;
		self.question = [self.questions objectAtIndex:0];
	}
	if ([UVSession currentSession].user != nil) {
		// remove login warning and set active
		[[self.view viewWithTag:UV_FORUM_LIST_TAG_CELL_MSG_TAG] setHidden:YES];
		UISegmentedControl *segments = (UISegmentedControl *)[self.view viewWithTag:UV_FORUM_LIST_TAG_CELL_QUESTION_SEGMENTS];
		[segments setEnabled:YES]; 
	}
	[self.tableView reloadData];
	
	// Reload footer view, in case the user has changed (logged in or unlinked)
	UVFooterView *footer = (UVFooterView *) self.tableView.tableFooterView;
	[footer reloadFooter];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.forum = nil;
	self.question = nil;
}


- (void)dealloc {
    [super dealloc];
	[questions release];
}


// Prompt for app store review if the returned rating indicates this (driven by
// server side logic based on rating value) and if we actually have an app id.
//	if (theRating.flashType &&
//		[theRating.flashType isEqualToString:@"app_store_rating"] &&
//		[UVSession currentSession].clientConfig.itunesApplicationId) {
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rating"
//														message:theRating.flashMessage
//													   delegate:self
//											  cancelButtonTitle:@"Cancel"
//											  otherButtonTitles:@"OK", nil];
//		[alert show];
//		[alert release];
//	}

@end
