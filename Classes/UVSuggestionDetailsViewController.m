//
//  UVSuggestionDetailsViewController.m
//  UserVoice
//
//  Created by UserVoice on 10/29/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVSuggestionDetailsViewController.h"
#import "UVCommentListViewController.h"
#import "UVProfileViewController.h"
#import "UVStyleSheet.h"
#import "UVSession.h"
#import "UVSuggestion.h"
#import "UVResponseViewController.h"
#import "UVSuggestionChickletView.h"
#import "UVFooterView.h"
#import "UVUserButton.h"
#import "UVUser.h"
#import "UVClientConfig.h"
#import "UVSignInViewController.h"

#define CHICKLET_TAG 1001
#define VOTE_SEGMENTS_TAG 1002
#define VOTE_LABEL_TAG 1003
#define NO_VOTE_LABEL_TAG 1004

#define UV_SUGGESTION_DETAILS_SECTION_HEADER 5
#define UV_SUGGESTION_DETAILS_SECTION_VOTE 0
#define UV_SUGGESTION_DETAILS_SECTION_BODY 1
#define UV_SUGGESTION_DETAILS_SECTION_COMMENTS 2
#define UV_SUGGESTION_DETAILS_SECTION_CREATOR 3

@implementation UVSuggestionDetailsViewController

@synthesize suggestion, innerTableView;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion {
	if (self = [super init]) {
		self.suggestion = theSuggestion;
	}
	return self;
}
	
- (NSString *)backButtonTitle {
	return @"Idea";
}

- (void)voteSegmentChanged:(id)sender {
	UISegmentedControl *segments = (UISegmentedControl *)sender;
	if (segments.selectedSegmentIndex != self.suggestion.votesFor) {		
		[self showActivityIndicator];
		// no longer supported so remove from supportedSuggestions
		// also should decrement counters
		if (segments.selectedSegmentIndex == 0) {
			NSInteger index = 0;
			NSInteger suggestionIndex = 0;
			for (UVSuggestion *aSuggestion in [UVSession currentSession].user.supportedSuggestions) {
				if (aSuggestion.suggestionId == self.suggestion.suggestionId)
					suggestionIndex = index;					
				index++;
			}
			[[UVSession currentSession].user.supportedSuggestions removeObjectAtIndex:suggestionIndex];
			[UVSession currentSession].user.supportedSuggestionsCount -= 1;
			
		} else if (self.suggestion.votesFor == 0) {
			// add if not there
			[[UVSession currentSession].user.supportedSuggestions addObject:self.suggestion];
			[UVSession currentSession].user.supportedSuggestionsCount += 1;
		}
		
		self.suggestion.votesFor = segments.selectedSegmentIndex;
		[self.suggestion vote:segments.selectedSegmentIndex delegate:self];
	}
}

- (void)didVoteForSuggestion:(UVSuggestion *)theSuggestion {		
	NSLog(@"Voted for suggestion: %@", theSuggestion);
	
	[UVSession currentSession].clientConfig.forum.currentTopic.votesRemaining = theSuggestion.votesRemaining;
	[UVSession currentSession].clientConfig.forum.currentTopic.suggestionsNeedReload = YES;
	self.suggestion = theSuggestion;
	
	[self.innerTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] 
					   withRowAnimation:UITableViewRowAnimationFade];
	UVSuggestionChickletView *chicklet = (UVSuggestionChickletView *)[self.view viewWithTag:CHICKLET_TAG];
	
	if (self.suggestion.status) {
		[chicklet updateWithSuggestion:self.suggestion style:UVSuggestionChickletStyleDetail];
	} else {
		[chicklet updateWithSuggestion:self.suggestion style:UVSuggestionChickletStyleEmpty];
	}
	[self hideActivityIndicator];
}

- (void)promptForFlag {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flag Idea?"
													message:@"Are you sure you want to flag this idea as inappropriate?"
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"Flag", nil];
	[alert show];
	[alert release];
}

- (void)didFlagSuggestion:(UVSuggestion *)theSuggestion {
	[self hideActivityIndicator];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
													message:@"You have successfully flagged this idea as inappropriate."
												   delegate:nil
										  cancelButtonTitle:nil
										  otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}

// Calculates the height of the text.
- (CGSize)textSize {
	// Probably doesn't matter, but we might want to cache this since we call it twice.
	return [self.suggestion.text
			sizeWithFont:[UIFont systemFontOfSize:13]
			constrainedToSize:CGSizeMake(300, 10000)
			lineBreakMode:UILineBreakModeWordWrap];
}

// Calculates the height of the title.
- (CGSize)titleSize {
	// Probably doesn't matter, but we might want to cache this since we call it twice.
	return [self.suggestion.title
			sizeWithFont:[UIFont boldSystemFontOfSize:18]
			constrainedToSize:CGSizeMake(235, 10000)
			lineBreakMode:UILineBreakModeWordWrap];
}

- (void)setVoteLabelTextAndColorForLabel:(UILabel *)label {
	NSInteger votesRemaining = [UVSession currentSession].clientConfig.forum.currentTopic.votesRemaining;
	[self setVoteLabelTextAndColorForVotesRemaining:votesRemaining label:label];
}

- (NSString *)postDateString {
	static NSDateFormatter* dateFormatter = nil;
	if (!dateFormatter) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MMMM dd, yyyy"];
	}
	return [dateFormatter stringFromDate:self.suggestion.createdAt];
}

#pragma mark ===== UIAlertViewDelegate Methods =====

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != alertView.cancelButtonIndex) {
		[self showActivityIndicator];
		[self.suggestion flag:@"inappropriate" delegate:self];
	}
}

#pragma mark ===== table cells =====

- (void)initCellForVote:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UIView *bg = [[UILabel alloc] initWithFrame:CGRectMake(-10, 0, 320, 72)];		
	bg.backgroundColor = [UVStyleSheet lightBgColor];
	[cell.contentView addSubview:bg];
	[bg release];
	
	if ([suggestion.status isEqualToString:@"completed"]) {
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 44)];
		label.tag = NO_VOTE_LABEL_TAG;
		label.numberOfLines = 2;
		label.opaque = YES;
		label.backgroundColor = [UVStyleSheet lightBgColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:14];
		label.text = [NSString stringWithFormat:
					  @"Voting for this suggestion is now closed and your %d %@ been returned to you",
					  self.suggestion.votesFor,
					  self.suggestion.votesFor == 1 ? @"vote has" : @"votes have"];
		label.textColor = [UVStyleSheet dimBlueColor];
		[cell.contentView addSubview:label];
		[label release];
		
	} else {
		NSArray *items = [NSArray arrayWithObjects:@"0 votes", @"1 vote", @"2 votes", @"3 votes", nil];
		UISegmentedControl *segments = [[UISegmentedControl alloc] initWithItems:items];
		segments.tag = VOTE_SEGMENTS_TAG;
		segments.frame = CGRectMake(0, 0, 300, 44);
		[segments addTarget:self action:@selector(voteSegmentChanged:) forControlEvents:UIControlEventValueChanged];
		UILabel *label;
		if ([UVSession currentSession].user != nil) {
			label = [[UILabel alloc] initWithFrame:CGRectMake(0, 49, 300, 14)];
		} else {
			[segments setEnabled:NO];
			label = [[UILabel alloc] initWithFrame:CGRectMake(0, 49, 300, 17)];
		}
		[cell.contentView addSubview:segments];
		[segments release];
		
		label.opaque = YES;
		label.backgroundColor = [UVStyleSheet lightBgColor];
		label.tag = VOTE_LABEL_TAG;
		label.numberOfLines = 0;
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:12];
		[cell.contentView addSubview:label];
		[label release];
	}
}

- (void)customizeCellForVote:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	if ([UVSession currentSession].user != nil) {
		UISegmentedControl *segments = (UISegmentedControl *)[cell.contentView viewWithTag:VOTE_SEGMENTS_TAG];
		segments.selectedSegmentIndex = self.suggestion.votesFor;
		NSInteger votesRemaining = [UVSession currentSession].clientConfig.forum.currentTopic.votesRemaining;
		for (int i = 0; i < segments.numberOfSegments; i++) {
			NSInteger votesNeeded = i - self.suggestion.votesFor;
			BOOL enabled = votesNeeded <= votesRemaining;
			[segments setEnabled:enabled forSegmentAtIndex:i];
		}
		
		UILabel *label = (UILabel *)[cell.contentView viewWithTag:VOTE_LABEL_TAG];
		if (label) 
			[self setVoteLabelTextAndColorForLabel:label];
	}
}

- (void)initCellForBody:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];
	NSInteger height = [self textSize].height > 0 ? [self textSize].height + 10 : 0;
	
	UIView *bg = [[UILabel alloc] initWithFrame:CGRectMake(-10, 0, 320, height)];		
	bg.backgroundColor = [UVStyleSheet lightBgColor];
	[cell.contentView addSubview:bg];
	[bg release];

	// The default margins are too large for the body, so we're using our own label.
	UILabel *body = [[[UILabel alloc] initWithFrame:CGRectMake(0, -3, 300, [self textSize].height)] autorelease];
	body.text = self.suggestion.text;
	body.font = [UIFont systemFontOfSize:13];
	body.lineBreakMode = UILineBreakModeWordWrap;
	body.numberOfLines = 0;
	body.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:body];
}

- (void)customizeCellForStatus:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	NSString *status = suggestion.status ? suggestion.status : @"N/A";
	cell.textLabel.text = [NSString stringWithFormat:@"Status: %@", [status capitalizedString]];
	//cell.textLabel.textColor = self.suggestion.statusColor;
	
	if (self.suggestion.responseText) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
}

- (void)customizeCellForComments:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	cell.textLabel.text = [NSString stringWithFormat:(self.suggestion.commentsCount == 1 ? @"%d Comment" : @"%d Comments"), self.suggestion.commentsCount];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
}

- (void)customizeCellForFlag:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	cell.textLabel.text = @"Flag as inappropriate";
}

- (void)initCellForCreator:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];
	
	
	UIView *bg = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 75)];		
	bg.backgroundColor = [UVStyleSheet lightBgColor];
	[cell.contentView addSubview:bg];
	[bg release];
	
	// Name label
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, 85, 16)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor grayColor];
	label.textAlignment = UITextAlignmentRight;
	label.font = [UIFont boldSystemFontOfSize:13];
	label.text = @"Created by";
	[cell.contentView addSubview:label];
	[label release];

	// Name
	UVUserButton *nameButton = [UVUserButton buttonWithUserId:self.suggestion.creatorId
														 name:self.suggestion.creatorName
												   controller:self
													   origin:CGPointMake(95, 13)
													 maxWidth:205
														 font:[UIFont boldSystemFontOfSize:13]
														color:[UVStyleSheet dimBlueColor]];
	[cell.contentView addSubview:nameButton];
	
	// Date label
	label = [[UILabel alloc] initWithFrame:CGRectMake(0, 43, 85, 13)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor grayColor];
	label.textAlignment = UITextAlignmentRight;
	label.font = [UIFont boldSystemFontOfSize:13];
	label.text = @"Post date";
	[cell.contentView addSubview:label];
	[label release];

	// Date
	label = [[UILabel alloc] initWithFrame:CGRectMake(95, 43, 205, 14)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor blackColor];
	label.textAlignment = UITextAlignmentLeft;
	label.font = [UIFont systemFontOfSize:13];
	label.text = [self postDateString];
	[cell.contentView addSubview:label];
	[label release];
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"";
	BOOL selectable = YES;
	
	switch (indexPath.section) {
		case UV_SUGGESTION_DETAILS_SECTION_VOTE:
			identifier = @"Vote";
			if ([UVSession currentSession].user!=nil)
				selectable = NO;
			break;
		case UV_SUGGESTION_DETAILS_SECTION_BODY:
			identifier = @"Body";			
			selectable = NO;
			break;
		case UV_SUGGESTION_DETAILS_SECTION_COMMENTS:
			switch (indexPath.row) {
				case 0:
					identifier = @"Status";
					break;
				case 1:
					identifier = @"Comments";
					break;
				case 2:
					identifier = @"Flag";
					break;
			}
			break;
		case UV_SUGGESTION_DETAILS_SECTION_CREATOR:
			identifier = @"Creator";
			selectable = NO;
			break;
	}

	return [self createCellForIdentifier:identifier
							   tableView:theTableView
							   indexPath:indexPath
								   style:UITableViewCellStyleDefault
							  selectable:selectable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case UV_SUGGESTION_DETAILS_SECTION_COMMENTS:
			return 3;
			break;
		default:
			return 1;
	}
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case UV_SUGGESTION_DETAILS_SECTION_VOTE:
			return 73;
			break;
		case UV_SUGGESTION_DETAILS_SECTION_BODY:
			return [self textSize].height > 0 ? [self textSize].height + 10 : 0;
			break;
		case UV_SUGGESTION_DETAILS_SECTION_CREATOR:
			return 71;
			break;
		default:
			return 44;
	}
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIViewController *next = nil;

	switch (indexPath.section) {
		case UV_SUGGESTION_DETAILS_SECTION_VOTE: {
			if ([UVSession currentSession].user==nil) {
				UVSignInViewController *next = [[UVSignInViewController alloc] init];
				[self.navigationController pushViewController:next animated:YES];
				[next release];
			}
			break;
		}
		case UV_SUGGESTION_DETAILS_SECTION_COMMENTS: {
			switch (indexPath.row) {
				case 0: // status
					if (self.suggestion.responseText) {
						next = [[UVResponseViewController alloc] initWithSuggestion:self.suggestion];
					}
					break;
				case 1: // comments
					next = [[UVCommentListViewController alloc] initWithSuggestion:self.suggestion];
					break;
				case 2: // flag
					[self promptForFlag];
					break;
			}
			break;
		}
		default:
			break;
	}
	
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (next) {
		[self.navigationController pushViewController:next animated:YES];
		[next release];
	}
}

#pragma mark ===== Basic View Methods =====

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];

	self.navigationItem.title = self.suggestion.title;
	
	CGRect frame = [self contentFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:frame];
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStyleGrouped];
	theTableView.sectionHeaderHeight = 0.0;
	theTableView.sectionFooterHeight = 0.0;
	theTableView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
	
	NSInteger height = MAX([self titleSize].height + 347, 383);
	height += [self textSize].height > 0 ? [self textSize].height + 10 : 0;
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];  
	headerView.backgroundColor = [UIColor clearColor];
	
	UIImage *shadow = [UIImage imageNamed:@"dropshadow_top_20.png"];	
	UIImageView *shadowView = [[UIImageView alloc] initWithImage:shadow];
	[headerView addSubview:shadowView];	
	[shadowView release];
	
	UIView *bg = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, height)];		
	bg.backgroundColor = [UVStyleSheet lightBgColor];
	[headerView addSubview:bg];
	[bg release];
	
	// Votes
	UVSuggestionChickletView *chicklet = [UVSuggestionChickletView suggestionChickletViewWithOrigin:CGPointMake(10, 20)];
	chicklet.tag = CHICKLET_TAG;
	[headerView addSubview:chicklet];
	
	// Title
	CGSize titleSize = [self titleSize];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(75, 20, titleSize.width, titleSize.height)];
	label.text = self.suggestion.title;
	label.font = [UIFont boldSystemFontOfSize:18.0];
	label.textAlignment = UITextAlignmentLeft;
	label.numberOfLines = 0;
	label.backgroundColor = [UIColor clearColor];
	[headerView addSubview:label];
	[label release];
	
	// Category
	label = [[UILabel alloc] initWithFrame:CGRectMake(75, titleSize.height + 30, titleSize.width, 11)];
	label.lineBreakMode = UILineBreakModeTailTruncation;
	label.numberOfLines = 1;
	label.font = [UIFont boldSystemFontOfSize:11];
	label.textColor = [UIColor darkGrayColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = self.suggestion.categoryString;
	[label sizeToFit];
	[headerView addSubview:label];
	[label release];
	NSInteger yOffset = MAX([self titleSize].height + 55, 90);
	UITableView *theInnerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, yOffset, 320, MAX([self titleSize].height + 273, 313)) 
																  style:UITableViewStyleGrouped];
	theInnerTableView.dataSource = self;
	theInnerTableView.delegate = self;
	theInnerTableView.sectionHeaderHeight = 0.0;
	theInnerTableView.sectionFooterHeight = 3.0;
	theInnerTableView.backgroundColor = [UVStyleSheet lightBgColor];
	self.innerTableView = theInnerTableView;
	[headerView addSubview:theInnerTableView];
	
	theTableView.tableHeaderView = headerView;
	theTableView.tableFooterView = [UVFooterView footerViewForController:self];
	
	[contentView addSubview:theTableView];
	
	self.tableView = theTableView;
	[theTableView release];

	self.view = contentView;
	[contentView release];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
	[self.innerTableView reloadData];
	
	UVSuggestionChickletView *chicklet = (UVSuggestionChickletView *)[self.view viewWithTag:CHICKLET_TAG];
	if (self.suggestion.status) {
		[chicklet updateWithSuggestion:self.suggestion style:UVSuggestionChickletStyleDetail];
	} else {
		[chicklet updateWithSuggestion:self.suggestion style:UVSuggestionChickletStyleEmpty];
	}
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
