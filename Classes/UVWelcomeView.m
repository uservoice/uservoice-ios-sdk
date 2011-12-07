//
//  UVWelcomeView.m
//  UserVoice
//
//  Created by Scott Rutherford on 01/07/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVWelcomeView.h"
#import "UVSuggestionListViewController.h"
#import "UVNewMessageViewController.h"
#import "UVForum.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVFooterView.h"
#import "UVStyleSheet.h"
#import "UVQuestion.h"
#import "UVAnswer.h"
#import "UVSignInViewController.h"
#import "UVTaskBar.h"
#import "UVSubdomain.h"
#import <QuartzCore/QuartzCore.h>

#define UV_FORUM_LIST_TAG_CELL_LABEL 1000
#define UV_FORUM_LIST_TAG_CELL_IMAGE 1001
#define UV_FORUM_LIST_TAG_CELL_QUESTION_SEGMENTS 1002
#define UV_FORUM_LIST_TAG_CELL_MSG_TAG 1003

#define UV_FORUM_LIST_SECTION_FORUMS 0
#define UV_FORUM_LIST_SECTION_SUPPORT 1
#define UV_FORUM_LIST_SECTION_QUESTIONS 2

@implementation UVWelcomeView

@synthesize forum = _forum, 
	question = _question, 
	questions = _questions, 
	controller = _controller,
	tableView = _tableView;

+ (UVWelcomeView *)welcomeViewForController:(UVBaseViewController *)controller {
	UVWelcomeView *welcomeView = [[[UVWelcomeView alloc] 
								   initWithFrame:CGRectMake(0, 0, 320, [UVWelcomeView heightForView])] autorelease];
	welcomeView.controller = controller;
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:welcomeView.bounds style:UITableViewStyleGrouped];
	theTableView.scrollEnabled = NO;
	theTableView.delegate = welcomeView;
	theTableView.dataSource = welcomeView;
	theTableView.sectionHeaderHeight = 10.0;
	theTableView.sectionFooterHeight = 0.0;
	
	welcomeView.tableView = theTableView;
	[welcomeView addSubview:theTableView];
	
	welcomeView.forum = [UVSession currentSession].clientConfig.forum;
	if ([UVSession currentSession].clientConfig.questionsEnabled) {
		welcomeView.questions = [UVSession currentSession].clientConfig.questions;
		welcomeView.question = [welcomeView.questions objectAtIndex:0];
	}
	
	if ([UVSession currentSession].user != nil) {
		// remove login warning and set active
		[[welcomeView.tableView viewWithTag:UV_FORUM_LIST_TAG_CELL_MSG_TAG] setHidden:YES];
		UISegmentedControl *segments = 
		(UISegmentedControl *)[welcomeView.tableView viewWithTag:UV_FORUM_LIST_TAG_CELL_QUESTION_SEGMENTS];
		[segments setEnabled:YES]; 
	}
	
	return welcomeView;
}

+ (CGFloat)heightForView {
	return 320;
}

- (void)questionSegmentChanged:(id)sender {
	UISegmentedControl *segments = (UISegmentedControl *)sender;
	[_controller showActivityIndicator];
	// still using single question hack of assigning a single current one
	[UVAnswer initWithQuestion:self.question andValue:(segments.selectedSegmentIndex + 1) andDelegate:self];
}

- (void)didCreateAnswer:(UVAnswer *)theAnswer {
	[_controller hideActivityIndicator];
	self.question.currentAnswer = theAnswer;
}

- (CGFloat)heightForViewWithHeader:(NSString *)header subheader:(NSString *)subheader {
	if (subheader) {
		CGSize subSize = [subheader sizeWithFont:[UIFont systemFontOfSize:14]
							   constrainedToSize:CGSizeMake(280, 9999)
								   lineBreakMode:UILineBreakModeWordWrap];
		return subSize.height + 30 + 5 + 5; // (subheader + header + padding between/bottom)
		
	} else if (header) {
		return 40 + 5; // header + padding bottom only

	}
	return 0;
}

- (UIView *)viewWithHeader:(NSString *)header subheader:(NSString *)subheader {
	CGFloat height = [self heightForViewWithHeader:header subheader:subheader];
	UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height)] autorelease];
	//headerView.backgroundColor = [UIColor clearColor];
	
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
		return NSLocalizedStringFromTable(@"Suggestions",@"UserVoice",nil);
		
	} else if (section == 1) {
		return NSLocalizedStringFromTable(@"Support",@"UserVoice",nil);
		
	} else {
		return NSLocalizedString(@"Rating", nil);
        
	}
}

- (NSString *)subHeaderTextForSection:(NSInteger)section {
	if (section <= 1) {
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
	
	// Prompt for app store review if the returned rating indicates this (driven by
	// server side logic based on rating value) and if we actually have an app id.
//	if (theRating.flashType && [theRating.flashType isEqualToString:@"app_store_rating"] &&
//		[UVSession currentSession].clientConfig.itunesApplicationId) {
//		
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rating"
//														message:theRating.flashMessage
//													   delegate:self
//											  cancelButtonTitle:@"Cancel"
//											  otherButtonTitles:@"OK", nil];
//		[alert show];
//		[alert release];
//	}
}

#pragma mark ===== UIAlertViewDelegate Methods =====

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertView.firstOtherButtonIndex) {
		NSString *url = [NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8",
						 [UVSession currentSession].clientConfig.itunesApplicationId];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
}

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
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)customizeCellForForum:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:UV_FORUM_LIST_TAG_CELL_LABEL];
	textLabel.text = [self.forum prompt];
	
	UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:UV_FORUM_LIST_TAG_CELL_IMAGE];
	imageView.hidden = !self.forum.isPrivate;
}

- (void)initCellForQuestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[_controller removeBackgroundFromCell:cell];	
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
		// label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont boldSystemFontOfSize:14];
		label.text = NSLocalizedStringFromTable(@"You will need to sign in to answer.",@"UserVoice",nil);		
		label.textColor = [UVStyleSheet darkRedColor];
		
		[cell.contentView addSubview:label];
		[label release];				
	}
}

- (void)customizeCellForQuestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UISegmentedControl *segments = (UISegmentedControl *)[cell.contentView 
														  viewWithTag:UV_FORUM_LIST_TAG_CELL_QUESTION_SEGMENTS];
	[self updateSegmentsValue:segments];
}

- (void)initCellForSupport:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {	
	cell.textLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Contact %@",@"UserVoice",nil)s, 
						   [UVSession currentSession].clientConfig.subdomain.name];
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}
	
#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"";
	BOOL selectable = YES;
	UITableViewCellStyle style = UITableViewCellStyleDefault;	
	if (indexPath.section == UV_FORUM_LIST_SECTION_FORUMS) {
		identifier = @"Forum";
		
	} else if (indexPath.section == UV_FORUM_LIST_SECTION_SUPPORT) {
		identifier = @"Support";
		
	} else if (indexPath.section == UV_FORUM_LIST_SECTION_QUESTIONS) {
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
	NSInteger sections = 1;
	if ([UVSession currentSession].clientConfig.questionsEnabled) {
		sections++;
	} 
	if ([UVSession currentSession].clientConfig.subdomain.messagesEnabled) {
		sections++;
	}
	return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	self.tableView.backgroundColor = [UIColor clearColor];
	return 1;
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section <= 1) {
		return 45;
	} else {
		return [UVSession currentSession].user==nil ? 80 : 60;
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
	return 0.0; //18.0;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//	return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 18)] autorelease];
//}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"Row selected");
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	switch (indexPath.section) {
		case UV_FORUM_LIST_SECTION_FORUMS: {			
			UVSuggestionListViewController *next = [[UVSuggestionListViewController alloc] initWithForum:self.forum];
			[_controller.navigationController pushViewController:next animated:YES];
			[next release];
			break;
		}
		case UV_FORUM_LIST_SECTION_QUESTIONS: {
			if ([UVSession currentSession].user==nil) {
				UVSignInViewController *next = [[UVSignInViewController alloc] init];
				[_controller.navigationController pushViewController:next animated:YES];
				[next release];
			}
			break;
		}
		case UV_FORUM_LIST_SECTION_SUPPORT: {
			UVNewMessageViewController *next = [[UVNewMessageViewController alloc] init];
			[_controller.navigationController pushViewController:next animated:YES];
			[next release];
			break;
		}
		default:
			break;
	}
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	_forum = nil;
	_question = nil;
}


- (void)dealloc {
    [super dealloc];
	[_questions release];
}

- (void)reloadView {
	[_tableView reloadData];
}

- (UITableViewCell *)createCellForIdentifier:(NSString *)identifier
								   tableView:(UITableView *)theTableView
								   indexPath:(NSIndexPath *)indexPath
									   style:(UITableViewCellStyle)style
								  selectable:(BOOL)selectable {
	
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier] autorelease];	
		cell.selectionStyle = selectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		
		SEL initCellSelector = NSSelectorFromString([NSString stringWithFormat:@"initCellFor%@:indexPath:", identifier]);
		if ([self respondsToSelector:initCellSelector]) {
			[self performSelector:initCellSelector withObject:cell withObject:indexPath];
		}
	}
		
	SEL customizeCellSelector = NSSelectorFromString([NSString stringWithFormat:@"customizeCellFor%@:indexPath:", identifier]);
	if ([self respondsToSelector:customizeCellSelector]) {
		[self performSelector:customizeCellSelector withObject:cell withObject:indexPath];
	}
	return cell;
}

@end
