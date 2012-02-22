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
#import "UVUserButton.h"
#import "UVUser.h"
#import "UVClientConfig.h"
#import "UVSignInViewController.h"

#define CHICKLET_TAG 1001
#define VOTE_SEGMENTS_TAG 1002
#define VOTE_LABEL_TAG 1003
#define NO_VOTE_LABEL_TAG 1004
#define LOGIN_TAG 1005

#define UV_SUGGESTION_DETAILS_SECTION_VOTE 0
#define UV_SUGGESTION_DETAILS_SECTION_BODY 1
#define UV_SUGGESTION_DETAILS_SECTION_COMMENTS 2
#define UV_SUGGESTION_DETAILS_SECTION_CREATOR 3
#define UV_SUGGESTION_DETAILS_SECTION_HEADER 5

@implementation UVSuggestionDetailsViewController

@synthesize suggestion;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion {
	if ((self = [super init])) {
		self.suggestion = theSuggestion;
	}
	return self;
}
	
- (NSString *)backButtonTitle {
	return NSLocalizedStringFromTable(@"Idea", @"UserVoice", nil);
}

- (void)voteSegmentChanged:(id)sender {
	UISegmentedControl *segments = (UISegmentedControl *)sender;
    if ([UVSession currentSession].user != nil) {
        if (segments.selectedSegmentIndex != self.suggestion.votesFor) {		
            [self showActivityIndicator];

            // Inform the user model
            if (segments.selectedSegmentIndex == 0 && self.suggestion.votesFor > 0) {
                [[UVSession currentSession].user didWithdrawSupportForSuggestion:self.suggestion];			
            } else if (self.suggestion.votesFor == 0) {
                [[UVSession currentSession].user didSupportSuggestion:self.suggestion];			
            }

            self.suggestion.votesFor = segments.selectedSegmentIndex;
            [self.suggestion vote:segments.selectedSegmentIndex delegate:self];
        }
    } else {
        segments.selectedSegmentIndex = -1;
        [self promptUserToSignIn];
    }
}

- (void)didVoteForSuggestion:(UVSuggestion *)theSuggestion {		
	NSLog(@"Voted for suggestion: %@", theSuggestion);
	
	[UVSession currentSession].clientConfig.forum.currentTopic.votesRemaining = theSuggestion.votesRemaining;
	[UVSession currentSession].clientConfig.forum.currentTopic.suggestionsNeedReload = YES;
	self.suggestion = theSuggestion;
	
	UVSuggestionChickletView *chicklet = (UVSuggestionChickletView *)[self.view viewWithTag:CHICKLET_TAG];
	
	if (self.suggestion.status) {
		[chicklet updateWithSuggestion:self.suggestion style:UVSuggestionChickletStyleDetail];
	} else {
		[chicklet updateWithSuggestion:self.suggestion style:UVSuggestionChickletStyleEmpty];
	}
    
    UILabel *votesLabel = (UILabel *)[self.view viewWithTag:VOTE_LABEL_TAG];
    [self setVoteLabelTextAndColorForLabel:votesLabel];
	[self hideActivityIndicator];
}

- (void)promptForFlag {
	[[[[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Flag Idea?", @"UserVoice", nil)
                                 message:NSLocalizedStringFromTable(@"Are you sure you want to flag this idea as inappropriate?", @"UserVoice", nil)
                                delegate:self
                       cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                       otherButtonTitles:NSLocalizedStringFromTable(@"Flag", @"UserVoice", nil), nil] autorelease] show];
}

- (void)didFlagSuggestion:(UVSuggestion *)theSuggestion {
	[self hideActivityIndicator];
    [self alertSuccess:NSLocalizedStringFromTable(@"You have successfully flagged this idea as inappropriate.", @"UserVoice", nil)];
}

// Calculates the height of the text.
- (CGSize)textSize {
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	// Probably doesn't matter, but we might want to cache this since we call it twice.
	return [self.suggestion.text
			sizeWithFont:[UIFont systemFontOfSize:13]
			constrainedToSize:CGSizeMake((screenWidth-20), 10000)
			lineBreakMode:UILineBreakModeWordWrap];
}

// Calculates the height of the title.
- (CGSize)titleSize {
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	// Probably doesn't matter, but we might want to cache this since we call it twice.
	return [self.suggestion.title
			sizeWithFont:[UIFont boldSystemFontOfSize:18]
			constrainedToSize:CGSizeMake((screenWidth-85), 10000)
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
    CGFloat screenWidth = [UVClientConfig getScreenWidth];
    CGFloat margin = screenWidth > 480 ? 45 : 10;

	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UIView *bg = [[UILabel alloc] initWithFrame:CGRectMake(-margin, 0, screenWidth, 72)];		
	bg.backgroundColor = [UVStyleSheet backgroundColor];
	[cell.contentView addSubview:bg];
	[bg release];
	
	if ([suggestion.status isEqualToString:@"completed"]) {
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, screenWidth - 2 * margin, 44)];
		label.tag = NO_VOTE_LABEL_TAG;
		label.numberOfLines = 2;
		label.opaque = YES;
		label.backgroundColor = [UVStyleSheet backgroundColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:14];
		label.text = [NSString stringWithFormat:
					  NSLocalizedStringFromTable(@"Voting for this suggestion is now closed and your %d %@ been returned to you", @"UserVoice", nil),
					  self.suggestion.votesFor,
					  self.suggestion.votesFor == 1 ? NSLocalizedStringFromTable(@"vote has", @"UserVoice", nil) : NSLocalizedStringFromTable(@"votes have", @"UserVoice", nil)];
		label.textColor = [UVStyleSheet linkTextColor];
		[cell.contentView addSubview:label];
		[label release];
		
	} else {
		NSArray *items = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"0 votes", @"UserVoice", nil), NSLocalizedStringFromTable(@"1 vote", @"UserVoice", nil), NSLocalizedStringFromTable(@"2 votes", @"UserVoice", nil), NSLocalizedStringFromTable(@"3 votes", @"UserVoice", nil), nil];
		UISegmentedControl *segments = [[UISegmentedControl alloc] initWithItems:items];
		segments.tag = VOTE_SEGMENTS_TAG;
		segments.frame = CGRectMake(0, 0, screenWidth - 2 * margin, 44);
		[segments addTarget:self action:@selector(voteSegmentChanged:) forControlEvents:UIControlEventValueChanged];
		[cell.contentView addSubview:segments];
		[segments release];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 49, screenWidth - 2 * margin, 17)];
		label.opaque = YES;
		label.backgroundColor = [UVStyleSheet backgroundColor];
		label.tag = VOTE_LABEL_TAG;
		label.numberOfLines = 0;
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:12];
		[cell.contentView addSubview:label];
		[label release];
	}
}

- (void)customizeCellForVote:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UISegmentedControl *segments = (UISegmentedControl *)[cell.contentView viewWithTag:VOTE_SEGMENTS_TAG];
	if ([UVSession currentSession].user != nil) {
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
	} else {
		UILabel *label = (UILabel *)[cell.contentView viewWithTag:VOTE_LABEL_TAG];
        [label setHidden:YES];
    }
}

- (void)initCellForBody:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];
    
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
    CGFloat margin = screenWidth > 480 ? 45 : 10;
	NSInteger height = [self textSize].height > 0 ? [self textSize].height + 10 : 0;
	
	UIView *bg = [[UILabel alloc] initWithFrame:CGRectMake(-margin, 0, screenWidth, height)];		
	bg.backgroundColor = [UVStyleSheet backgroundColor];
	[cell.contentView addSubview:bg];
	[bg release];

	// The default margins are too large for the body, so we're using our own label.
	UILabel *body = [[[UILabel alloc] initWithFrame:CGRectMake(0, -3, screenWidth - 2 * margin, [self textSize].height)] autorelease];
	body.text = self.suggestion.text;
	body.font = [UIFont systemFontOfSize:13];
	body.lineBreakMode = UILineBreakModeWordWrap;
	body.numberOfLines = 0;
    body.textColor = [UVStyleSheet primaryTextColor];
	body.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:body];
}

- (void)customizeCellForStatus:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	NSString *status = suggestion.status ? suggestion.status : @"N/A";
	cell.textLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Status: %@", @"UserVoice", nil), [status capitalizedString]];
	
	if (self.suggestion.responseText) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
}

- (void)customizeCellForComments:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	cell.textLabel.text = [NSString stringWithFormat:(self.suggestion.commentsCount == 1 ? NSLocalizedStringFromTable(@"%d Comment", @"UserVoice", nil) : NSLocalizedStringFromTable(@"%d Comments", @"UserVoice", nil)), self.suggestion.commentsCount];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
}

- (void)customizeCellForFlag:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	cell.textLabel.text = NSLocalizedStringFromTable(@"Flag as inappropriate", @"UserVoice", nil);
}

- (void)initCellForCreator:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self removeBackgroundFromCell:cell];
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	
	UIView *bg = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (screenWidth-20), 75)];		
	bg.backgroundColor = [UVStyleSheet backgroundColor];
	[cell.contentView addSubview:bg];
	[bg release];
	
	// Name label
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, 100, 16)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UVStyleSheet labelTextColor];
	label.textAlignment = UITextAlignmentRight;
	label.font = [UIFont boldSystemFontOfSize:13];
	label.text = NSLocalizedStringFromTable(@"Created by", @"UserVoice", nil);
	[cell.contentView addSubview:label];
	[label release];

	// Name
	UVUserButton *nameButton = [UVUserButton buttonWithUserId:self.suggestion.creatorId
														 name:self.suggestion.creatorName
												   controller:self
													   origin:CGPointMake(110, 13)
													 maxWidth:205
														 font:[UIFont boldSystemFontOfSize:13]
														color:[UVStyleSheet linkTextColor]];
	[cell.contentView addSubview:nameButton];
	
	// Date label
	label = [[UILabel alloc] initWithFrame:CGRectMake(0, 43, 100, 13)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UVStyleSheet labelTextColor];
	label.textAlignment = UITextAlignmentRight;
	label.font = [UIFont boldSystemFontOfSize:13];
	label.text = NSLocalizedStringFromTable(@"Post date", @"UserVoice", nil);
	[cell.contentView addSubview:label];
	[label release];

	// Date
	label = [[UILabel alloc] initWithFrame:CGRectMake(110, 43, 205, 14)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UVStyleSheet primaryTextColor];
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
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	CGFloat screenHeight = [UVClientConfig getScreenHeight];
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-44) 
                                                             style:UITableViewStyleGrouped];
	theTableView.sectionHeaderHeight = 0.0;
	theTableView.sectionFooterHeight = 0.0;
    theTableView.dataSource = self;
    theTableView.delegate = self;
    theTableView.backgroundColor = [UVStyleSheet backgroundColor];
	
	NSInteger height = MAX([self titleSize].height + 50, 90);
    //	height += [self textSize].height > 0 ? [self textSize].height : 0;
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, height)];  
	headerView.backgroundColor = [UIColor clearColor];
	
	UIView *bg = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, height)];		
	bg.backgroundColor = [UVStyleSheet backgroundColor];
	[headerView addSubview:bg];
	[bg release];
	
    BOOL iPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    CGFloat marginLeft = iPad ? 45 : 10;
    CGFloat marginTop = 20;
	// Votes
	UVSuggestionChickletView *chicklet = [UVSuggestionChickletView suggestionChickletViewWithOrigin:CGPointMake(marginLeft, marginTop)];
	chicklet.tag = CHICKLET_TAG;
	[headerView addSubview:chicklet];
	
	// Title
	CGSize titleSize = [self titleSize];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(marginLeft + (iPad ? 75 : 65), marginTop, titleSize.width, titleSize.height)];
	label.text = self.suggestion.title;
	label.font = [UIFont boldSystemFontOfSize:18.0];
	label.textAlignment = UITextAlignmentLeft;
	label.numberOfLines = 0;
    label.textColor = [UVStyleSheet primaryTextColor];
	label.backgroundColor = [UIColor clearColor];
	[headerView addSubview:label];
	[label release];
	
	// Category
	label = [[UILabel alloc] initWithFrame:CGRectMake(marginLeft + (iPad ? 75 : 65), titleSize.height + marginTop + 10, titleSize.width, 11)];
	label.lineBreakMode = UILineBreakModeTailTruncation;
	label.numberOfLines = 1;
	label.font = [UIFont boldSystemFontOfSize:11];
	label.textColor = [UVStyleSheet secondaryTextColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = self.suggestion.categoryString;
	[label sizeToFit];
	[headerView addSubview:label];
	[label release];
    	
	theTableView.tableHeaderView = headerView;
    [headerView release];
		
	self.tableView = theTableView;
	self.view = theTableView;
    [theTableView release];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
	
	UVSuggestionChickletView *chicklet = (UVSuggestionChickletView *)[self.view viewWithTag:CHICKLET_TAG];
	if (self.suggestion.status) {
		[chicklet updateWithSuggestion:self.suggestion style:UVSuggestionChickletStyleDetail];
	} else {
		[chicklet updateWithSuggestion:self.suggestion style:UVSuggestionChickletStyleEmpty];
	}
    [super viewWillAppear:animated];
}

- (void)dealloc {
    self.suggestion = nil;
    [super dealloc];
}

@end
