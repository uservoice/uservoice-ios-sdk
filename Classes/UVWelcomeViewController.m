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
#import "UVQuestion.h"
#import "UVAnswer.h"
#import "UVNewMessageViewController.h"
#import "UVSuggestionListViewController.h"
#import "UVSignInViewController.h"
#import "UVStreamPoller.h"
#import <QuartzCore/QuartzCore.h>

#define UV_FORUM_LIST_TAG_CELL_LABEL 1000
#define UV_FORUM_LIST_TAG_CELL_IMAGE 1001
#define UV_FORUM_LIST_TAG_CELL_QUESTION_SEGMENTS 1002
#define UV_FORUM_LIST_TAG_CELL_MSG_TAG 1003

#define UV_FORUM_LIST_SECTION_FORUMS 0
#define UV_FORUM_LIST_SECTION_SUPPORT 1
#define UV_FORUM_LIST_SECTION_QUESTIONS 2

@implementation UVWelcomeViewController

@synthesize forum = _forum, 
	question = _question, 
	questions = _questions, 
	tableView = _tableView;

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
	
	// Prompt for app store review if the returned rating indicates this (driven by
	// server side logic based on rating value) and if we actually have an app id.
	if (theAnswer.value >= 4 && [UVSession currentSession].clientConfig.itunesApplicationId) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rating"
														message:@"Would you like to add your rating to the iTunes store?"
													   delegate:self
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
	}
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

- (void)pushNewMessageView {
	UVNewMessageViewController *next = [[UVNewMessageViewController alloc] init];
	[self.navigationController pushViewController:next animated:YES];
	[next release];
}

- (void)pushForumView {
	UVSuggestionListViewController *next = [[UVSuggestionListViewController alloc] initWithForum:self.forum];
	[self.navigationController pushViewController:next animated:YES];
	
	[next release];
}

#pragma mark ===== table cells =====

- (void)initCellForForum:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
	UIView *bg = [[UILabel alloc] initWithFrame:CGRectMake(-10, -10, 320, 55)];		
	bg.backgroundColor = [UVStyleSheet lightBgColor];
	[cell.contentView addSubview:bg];
	[bg release];
	
	UIButton *myButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	myButton.tag = UV_FORUM_LIST_TAG_CELL_LABEL;
    myButton.frame = CGRectMake(0, 0, 300, 44); // position in the parent view and set the size of the button
    [myButton setTitle:[_forum prompt] forState:UIControlStateNormal];
    [myButton addTarget:self action:@selector(pushForumView) forControlEvents:UIControlEventTouchUpInside];
	[myButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[myButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];	
	
	UIEdgeInsets insets = UIEdgeInsetsMake(0,10,0,0);
	myButton.titleEdgeInsets = insets;	
	myButton.titleLabel.font = [UIFont boldSystemFontOfSize: 16];
	myButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
	myButton.titleLabel.numberOfLines = 1;
		
    [cell.contentView addSubview:myButton];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)customizeCellForForum:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UIButton *myButton = (UIButton *)[cell.contentView viewWithTag:UV_FORUM_LIST_TAG_CELL_LABEL];
    [myButton setTitle:[_forum prompt] forState:UIControlStateNormal];
}

- (CGFloat)heightForViewWithHeader:(NSString *)header subheader:(NSString *)subheader {
	if (subheader) {
		CGSize subSize = [subheader sizeWithFont:[UIFont systemFontOfSize:14]
							   constrainedToSize:CGSizeMake(280, 9999)
								   lineBreakMode:UILineBreakModeWordWrap];
		return subSize.height + 35 + 5 + 5; // (subheader + header + padding between/bottom)
		
	} else if (header) {
		return 35 + 5; // header + padding bottom only
	}
	
	return 10;
}

- (void)initCellForSupport:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UIView *bg = [[UILabel alloc] initWithFrame:CGRectMake(-10, -10, 320, 55)];		
	bg.backgroundColor = [UVStyleSheet lightBgColor];
	[cell.contentView addSubview:bg];
	[bg release];
		
	UIButton *myButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    myButton.frame = CGRectMake(0, 0, 300, 44);
    [myButton addTarget:self action:@selector(pushNewMessageView) forControlEvents:UIControlEventTouchUpInside];
	[myButton setTitle:[NSString stringWithFormat:@"Contact %@", [UVSession currentSession].clientConfig.subdomain.name]
			  forState:UIControlStateNormal];
	[myButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[myButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];	
	
	UIEdgeInsets insets = UIEdgeInsetsMake (0,10,0,0);
	myButton.titleEdgeInsets = insets;	
	myButton.titleLabel.font = [UIFont boldSystemFontOfSize: 16];
	myButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
	myButton.titleLabel.numberOfLines = 1;

    [cell.contentView addSubview:myButton];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

- (void)initCellForQuestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UIView *bg = [[UILabel alloc] initWithFrame:CGRectMake(-10, -10, 320, 80)];		
	bg.backgroundColor = [UVStyleSheet lightBgColor];
	[cell.contentView addSubview:bg];
	[bg release];
	
	NSArray *items = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
	UISegmentedControl *segments = [[UISegmentedControl alloc] initWithItems:items];
	segments.tag = UV_FORUM_LIST_TAG_CELL_QUESTION_SEGMENTS;
	segments.frame = CGRectMake(0, 0, 300, 44);
	[self updateSegmentsValue:segments]; // necessary to avoid triggering an update when we set it in the customize method
	[segments addTarget:self action:@selector(questionSegmentChanged:) forControlEvents:UIControlEventValueChanged];
	// add segments
	[cell.contentView addSubview:segments];
	[segments release];
}

- (void)customizeCellForQuestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	// disable unless user
	BOOL enabled = [UVSession currentSession].user != nil;
	UISegmentedControl *segments = (UISegmentedControl *)[cell.contentView viewWithTag:UV_FORUM_LIST_TAG_CELL_QUESTION_SEGMENTS];
	[segments setEnabled:enabled];	
	
	if (enabled) {
		[[cell.contentView viewWithTag:UV_FORUM_LIST_TAG_CELL_MSG_TAG] setHidden:YES];
		[self addQuestionCell:cell labelWithText:@"Unlikely" alignment:UITextAlignmentLeft];
		[self addQuestionCell:cell labelWithText:@"Maybe" alignment:UITextAlignmentCenter];
		[self addQuestionCell:cell labelWithText:@"Absolutely" alignment:UITextAlignmentRight];
		
	} else {		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 46, 300, 20)];
		label.tag = UV_FORUM_LIST_TAG_CELL_MSG_TAG;
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont boldSystemFontOfSize:12];
		label.text = @"You will need to sign in to answer.";	
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UVStyleSheet darkRedColor];
		
		[cell.contentView addSubview:label];
		[label release];				
	}
}

- (void)initCellForSpacer:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UIView *bg = [[UILabel alloc] initWithFrame:CGRectMake(-10, -10, 320, 11)];		
	bg.backgroundColor = [UVStyleSheet lightBgColor];
	[cell.contentView addSubview:bg];
	[bg release];
}

- (UIView *)viewWithHeader:(NSString *)header subheader:(NSString *)subheader {
	CGFloat height = [self heightForViewWithHeader:header subheader:subheader];
	UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height)] autorelease];
	headerView.backgroundColor = [UVStyleSheet lightBgColor];
	
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 280, 35)];
	title.text = header;
	title.font = [UIFont boldSystemFontOfSize:18];
	title.backgroundColor = [UIColor clearColor];
	title.textColor = [UVStyleSheet tableViewHeaderColor];
	[headerView addSubview:title];
	[title release];
	
	if (subheader) {
		UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 33, 280, height - (33 + 5))];
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
		return @"Suggestions";
		
	} else if (section == 1) {
		return [UVSession currentSession].clientConfig.subdomain.messagesEnabled ? @"Support" : nil;
		
	} else {
		return [UVSession currentSession].clientConfig.questionsEnabled ? @"Rating" : nil;
	}
}

- (NSString *)subHeaderTextForSection:(NSInteger)section {	
	if (section <= UV_FORUM_LIST_SECTION_SUPPORT) {
		return nil;
		
	} else {
		NSArray *qs = [UVSession currentSession].clientConfig.questions;
		UVQuestion *q = [qs objectAtIndex:0];
		return [UVSession currentSession].clientConfig.questionsEnabled ? q.text : nil;
	}
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"";
	BOOL selectable = NO;

	UITableViewCellStyle style = UITableViewCellStyleDefault;	
	if (indexPath.section == UV_FORUM_LIST_SECTION_FORUMS) {
		identifier = @"Forum";
		
	} else if (indexPath.section == UV_FORUM_LIST_SECTION_SUPPORT) {		
		if ([UVSession currentSession].clientConfig.subdomain.messagesEnabled) {
			identifier = @"Support";
			
		} else {
			identifier = @"Spacer";
		}
		
	} else if (indexPath.section == UV_FORUM_LIST_SECTION_QUESTIONS) {
		if ([UVSession currentSession].clientConfig.questionsEnabled) {
		
			identifier = @"Question";
			if ([UVSession currentSession].user == nil)
				selectable = YES;
			
		} else {
			identifier = @"Spacer";
		}
	}
	
	return [self createCellForIdentifier:identifier
							   tableView:theTableView
							   indexPath:indexPath
								   style:style
							  selectable:selectable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	switch (indexPath.section) {
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

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == UV_FORUM_LIST_SECTION_FORUMS) {
		return 45;
		
	} else if (indexPath.section == UV_FORUM_LIST_SECTION_SUPPORT) {
		return [UVSession currentSession].clientConfig.subdomain.messagesEnabled ? 45 : 0.0;
		
	} else if (indexPath.section == UV_FORUM_LIST_SECTION_QUESTIONS) {
		return [UVSession currentSession].clientConfig.questionsEnabled ? 70 : 0.0;
	}
	return 0.0;
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
	return 0.0;
}

#pragma mark ===== Basic View Methods =====

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	[self.navigationItem setHidesBackButton:YES animated:NO];
	
	CGRect frame = [self contentFrame];	
	_tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
	_tableView.sectionFooterHeight = 0.0;
	_tableView.sectionHeaderHeight = 0.0;
	
	UIView *topShadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];  
	UIImage *shadow = [UIImage imageNamed:@"dropshadow_top_20.png"];
	
	UIImageView *shadowView = [[UIImageView alloc] initWithImage:shadow];
	[topShadow addSubview:shadowView];	
	_tableView.tableHeaderView = shadowView;
	
	[shadowView release];
	[topShadow release];

	_tableView.tableFooterView = [UVFooterView footerViewForController:self];			
	self.view = _tableView;	
	
	if ([UVSession currentSession].clientConfig.questionsEnabled) {
		_questions = [UVSession currentSession].clientConfig.questions;
		_question = [_questions objectAtIndex:0];		
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];		
	
	_forum = [UVSession currentSession].clientConfig.forum;		
	if ([self needsReload]) {
		NSLog(@"WelcomeView needs reload");
		
		UISegmentedControl *segments = 
			(UISegmentedControl *)[_tableView viewWithTag:UV_FORUM_LIST_TAG_CELL_QUESTION_SEGMENTS];
		
		[(UVFooterView *)_tableView.tableFooterView reloadFooter];
		[self updateSegmentsValue:segments];
	}

	[_tableView reloadData];
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
