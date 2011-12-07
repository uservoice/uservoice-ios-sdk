//
//  UVCommentListViewController.m
//  UserVoice
//
//  Created by UserVoice on 11/10/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVCommentListViewController.h"
#import "UVComment.h"
#import "UVSuggestion.h"
#import "UVStyleSheet.h"
#import "UVProfileViewController.h"
#import "UVUserChickletView.h"
#import "UVCellViewWithIndex.h"
#import "UVUserButton.h"
#import "UVTextEditor.h"
#import "UVClientConfig.h"

#define UV_COMMENT_LIST_TAG_CELL_NAME 1
#define UV_COMMENT_LIST_TAG_CELL_DATE 2
#define UV_COMMENT_LIST_TAG_CELL_COMMENT 3
#define UV_COMMENT_LIST_TAG_CELL_CHICKLET 4
#define UV_COMMENT_LIST_TAG_CELL_BUTTON 5

#define COMMENTS_PAGE_SIZE 10

@implementation UVCommentListViewController

@synthesize suggestion;
@synthesize comments;
@synthesize commentToFlag;
@synthesize text;
@synthesize textEditor;
@synthesize prevLeftBarButton;
@synthesize prevRightBarButton;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion {
	if (self = [super init]) {
		self.suggestion = theSuggestion;
	}
	return self;
}

- (NSString *)backButtonTitle {
	return @"Comments";
}

- (void)retrieveMoreComments {
	NSInteger page = ([self.comments count] / 10) + 1;
	[self showActivityIndicator];
	[UVComment getWithSuggestion:self.suggestion page:page delegate:self];
}

- (void)didCreateComment:(UVComment *)comment {
	[self hideActivityIndicator];
	// Insert new comment at the beginning
	[self.comments insertObject:comment atIndex:0];
	[self.tableView reloadData];
	
	// Update comment count
	self.suggestion.commentsCount += 1;
	if (self.suggestion.commentsCount == 1) {
		self.navigationItem.title = NSLocalizedStringFromTable(@"1 Comment",@"UserVoice",nil);
	} else {
		self.navigationItem.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d Comments",@"UserVoice",nil), self.suggestion.commentsCount];
	}
	
	// Clear text editor
	self.textEditor.text = @"";
	// For some reason setting the text activates the editor and brings up the
	// keyboard, so we need to manually deactivate it.
	[self.textEditor resignFirstResponder];
}

- (void)didRetrieveComments:(NSArray *)theComments {
	[self hideActivityIndicator];
	if ([theComments count] > 0) {
		[self.comments addObjectsFromArray:theComments];
		if ([self.comments count] >= self.suggestion.commentsCount) {
			allCommentsRetrieved = YES;
		}
	} else {
		allCommentsRetrieved = YES;
	}
	[self.tableView reloadData];
}

- (CGSize)sizeForComment:(UVComment *)comment {
	CGFloat labelWidth = 210;
	return [comment.text sizeWithFont:[UIFont systemFontOfSize:13]
					constrainedToSize:CGSizeMake(labelWidth, 10000)
						lineBreakMode:UILineBreakModeWordWrap];
}

- (void)dismissTextEditor:(id)sender {
	[self.textEditor resignFirstResponder];
	[self.navigationItem setLeftBarButtonItem:self.prevLeftBarButton animated:YES];
	[self.navigationItem setRightBarButtonItem:self.prevRightBarButton animated:YES];
	editing = NO;
}

- (void)saveTextEditor:(id)sender {
	[self dismissTextEditor:sender];
	[self showActivityIndicator];
	[UVComment createWithSuggestion:self.suggestion text:self.text delegate:self];
}

- (void)promptForFlagWithIndex:(NSInteger)index {
	self.commentToFlag = [self.comments objectAtIndex:index];
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Flag Comment?", nil)
														delegate:self
											   cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
										  destructiveButtonTitle:NSLocalizedString(@"Flag as inappropriate", nil)
											   otherButtonTitles:nil];
	[action showInView:self.view];
	[action release];
}




- (void)didFlagComment:(UVComment *)theComment {
	[self hideActivityIndicator];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", nil)
													message:NSLocalizedString(@"You have successfully flagged this comment as inappropriate.", nil)
												   delegate:nil
										  cancelButtonTitle:nil
										  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alert show];
	[alert release];
}

#pragma mark ===== UIActionSheetDelegate Methods =====

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != actionSheet.cancelButtonIndex) {
		[self showActivityIndicator];
		[self.commentToFlag flag:@"inappropriate" suggestion:self.suggestion delegate:self];
	}
}

#pragma mark ===== UVTextEditorDelegate Methods =====

- (void) textEditorDidBeginEditing:(UVTextEditor *)theTextEditor 
{
	CGFloat screenWidth = [UVClientConfig getScreenWidth];

	// Change right bar button to Done and left to Cancel, as there's no built-in
	// way to dismiss the text editor's keyboard.
	UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																			  target:self
																			  action:@selector(saveTextEditor:)];
	UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																			    target:self
																			    action:@selector(dismissTextEditor:)];
	self.prevLeftBarButton = self.navigationItem.leftBarButtonItem;
	self.prevRightBarButton = self.navigationItem.rightBarButtonItem;
	[self.navigationItem setLeftBarButtonItem:cancelItem animated:YES];
	[self.navigationItem setRightBarButtonItem:saveItem animated:YES];
	[saveItem release];
	[cancelItem release];
	
	// Maximize header view to allow text editor to grow (leaving room for keyboard)
	[UIView beginAnimations:@"growHeader" context:nil];
	NSInteger height = self.view.bounds.size.height - 216;
	CGRect frame = CGRectMake(0, 0, screenWidth, height);
	UIView *textBar = (UIView *)self.tableView.tableHeaderView;
	textBar.frame = frame;
	textBar.backgroundColor = [UIColor whiteColor];
	theTextEditor.frame = frame;  // (may not actually need to change this, since bg is white)
	[UIView commitAnimations];
}

- (void)textEditorDidEndEditing:(UVTextEditor *)theTextEditor 
{
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	self.text = theTextEditor.text;
	
	// Minimize text editor and header
	[UIView beginAnimations:@"shrinkHeader" context:nil];
	theTextEditor.frame = CGRectMake(5, 0, (screenWidth-5), 40);
	UIView *textBar = (UIView *)self.tableView.tableHeaderView;
	textBar.frame = CGRectMake(0, 0, screenWidth, 40);
	theTextEditor.frame = CGRectMake(5, 0, (screenWidth-5), 40);
	[UIView commitAnimations];
}

- (BOOL)textEditorShouldEndEditing:(UVTextEditor *)theTextEditor {
	return YES;
}

#pragma mark ===== table cells =====

- (void)initCellForPrompt:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	cell.textLabel.text = NSLocalizedStringFromTable(@"Add Comment",@"UserVoice",nil);
	cell.textLabel.textColor = [UIColor blueColor];
	cell.textLabel.textAlignment = UITextAlignmentCenter;
}

- (void)initCellForComment:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	cell.backgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
	[self addHighlightToCell:cell];
	
	// Username
	UVUserButton *userButton = [UVUserButton buttonWithcontroller:self
															 font:[UIFont boldSystemFontOfSize:14]
															color:[UVStyleSheet tableViewHeaderColor]];
	userButton.tag = UV_COMMENT_LIST_TAG_CELL_NAME;
	[cell.contentView addSubview:userButton];

	// Date
	UILabel *label = [[UILabel alloc] init];
	label.tag = UV_COMMENT_LIST_TAG_CELL_DATE;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor lightGrayColor];
	label.font = [UIFont systemFontOfSize:14];
	[cell.contentView addSubview:label];
	[label release];
	
	// Comment Text
	label = [[UILabel alloc] init];
	label.tag = UV_COMMENT_LIST_TAG_CELL_COMMENT;
	label.lineBreakMode = UILineBreakModeWordWrap;
	label.numberOfLines = 0;
	label.font = [UIFont systemFontOfSize:13];
	label.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:label];
	[label release];

	// Chicklet
	UVUserChickletView *chicklet = [UVUserChickletView userChickletViewWithOrigin:CGPointMake(10, 10) controller:self admin:NO];
	chicklet.tag = UV_COMMENT_LIST_TAG_CELL_CHICKLET;
	[cell.contentView addSubview:chicklet];
	
	// TODO: despite the class name, this is now actually a UIView subclass, not a UIButton (let's change the class name later)
	UVCellViewWithIndex *cellView = [[[UVCellViewWithIndex alloc] init] autorelease];
	cellView.tag = UV_COMMENT_LIST_TAG_CELL_BUTTON;
	cellView.index = indexPath.row;
	cellView.frame = CGRectMake(290, 10, 20, 21);
	//[button addTarget:self action:@selector(promptForFlag:) forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:cellView];
}

- (void)customizeCellForComment:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UVComment *comment = [self.comments objectAtIndex:indexPath.row];

	BOOL darkZebra = indexPath.row % 2 == 0;
	cell.backgroundView.backgroundColor = [UVStyleSheet zebraBgColor:darkZebra];

	// Username + Date
	NSInteger days = ABS([comment.createdAt timeIntervalSinceNow]) / (60 * 60 * 24);
	NSString *daysAgo = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d days ago",@"UserVoice",nil), days];
	UVUserButton *userButton = (UVUserButton *)[cell.contentView viewWithTag:UV_COMMENT_LIST_TAG_CELL_NAME];
	UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:UV_COMMENT_LIST_TAG_CELL_DATE];
	CGSize dateSize = [daysAgo sizeWithFont:dateLabel.font forWidth:210 lineBreakMode:UILineBreakModeTailTruncation];
	[userButton updateWithUserId:comment.userId
							name:comment.userName
						  origin:CGPointMake(70, 10)
						maxWidth:(210 - dateSize.width)];
	dateLabel.frame = CGRectMake(70 + 5 + userButton.bounds.size.width, 10, dateSize.width, dateSize.height);
	dateLabel.text = daysAgo;

	// Comment Text
	CGSize size = [self sizeForComment:comment];
	UILabel *label = (UILabel *)[cell.contentView viewWithTag:UV_COMMENT_LIST_TAG_CELL_COMMENT];
	label.frame = CGRectMake(70, 28, 210, size.height);
	label.text = comment.text;

	// Chicklet
	UVUserChickletView *chicklet = (UVUserChickletView *)[cell.contentView viewWithTag:UV_COMMENT_LIST_TAG_CELL_CHICKLET];
	UVUserChickletStyle style = darkZebra ? UVUserChickletStyleDark : UVUserChickletStyleLight;
	[chicklet updateWithStyle:style userId:comment.userId name:comment.userName avatarUrl:comment.avatarUrl karmaScore:comment.karmaScore];	
}

- (void)initCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath 
{
	cell.backgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
	[self addHighlightToCell:cell];
	CGFloat screenWidth = [UVClientConfig getScreenWidth];

	// Can't use built-in textLabel, as this forces a white background
	UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, screenWidth, 16)];
	textLabel.text = NSLocalizedStringFromTable(@"Load more comments...",@"UserVoice",nil);
	textLabel.textColor = [UIColor darkGrayColor];
	textLabel.backgroundColor = [UIColor clearColor];
	textLabel.font = [UIFont systemFontOfSize:16];
	textLabel.textAlignment = UITextAlignmentCenter;
	[cell.contentView addSubview:textLabel];
	[textLabel release];
}

- (void)customizeCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UIColor *bgColor = indexPath.row % 2 == 0 ? [UVStyleSheet darkZebraBgColor] : [UVStyleSheet lightZebraBgColor];
	cell.backgroundView.backgroundColor = bgColor;
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier;
	UITableViewCellStyle style = UITableViewCellStyleDefault;
	BOOL selectable = YES;
	
	if (indexPath.row < [self.comments count]) {
		identifier = @"Comment";
		selectable = NO;
	} else {
		identifier = @"Load";
	}
	
	return [self createCellForIdentifier:identifier
							   tableView:theTableView
							   indexPath:indexPath
								   style:style
							  selectable:selectable];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.comments count] + (allCommentsRetrieved ? 0 : 1);
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [self.comments count]) {
		UVComment *comment = [self.comments objectAtIndex:indexPath.row];
		CGSize size = [self sizeForComment:comment];
		// Add some extra margin. Also need to ensure a certain minimum height, to 
		// ensure user chicklets fit.
		return MAX(size.height + 20 + 18, [UVUserChickletView heightForView] + 20);
	} else {
		return 71; // Load More
	}
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.row == [self.comments count])
	{
		// This is the last row in the table, so it's the "Load more comments" cell
		[self retrieveMoreComments];
	}
	else 
	{
		// For all other rows, prompt for flag
		[self promptForFlagWithIndex:indexPath.row];
	}	
}

#pragma mark ===== Basic View Methods =====

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	[super loadView];

	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	CGFloat screenHeight = [UVClientConfig getScreenHeight];
	
	if (self.suggestion.commentsCount == 1) {
		self.navigationItem.title = NSLocalizedStringFromTable(@"1 Comment",@"UserVoice",nil);
	} else {
		self.navigationItem.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d Comments",@"UserVoice",nil), self.suggestion.commentsCount];
	}

	CGRect frame = [self contentFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:frame];
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-44)];
	theTableView.dataSource = self;
	theTableView.delegate = self;	
    //theTableView.backgroundColor = [UIColor clearColor];
    theTableView.backgroundColor = [UVStyleSheet lightBgColor];
	
	[self addShadowSeparatorToTableView:theTableView];

	// Add text editor to table header
	UIView *textBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
	textBar.backgroundColor = [UIColor whiteColor];
	// TTSTYLE(commentTextBar)
	UVTextEditor *theTextEditor = [[UVTextEditor alloc] initWithFrame:CGRectMake(5, 0, (screenWidth-5), 40)];
	theTextEditor.delegate = self;
	theTextEditor.autocorrectionType = UITextAutocorrectionTypeYes;
	theTextEditor.minNumberOfLines = 1;
	theTextEditor.maxNumberOfLines = 8;
	theTextEditor.autoresizesToText = YES;
	theTextEditor.backgroundColor = [UIColor clearColor];
	//theTextEditor.style = TTSTYLE(commentTextBarTextField);
	theTextEditor.placeholder = NSLocalizedStringFromTable(@"Add a comment...",@"UserVoice",nil);
	[textBar addSubview:theTextEditor];
	self.textEditor = theTextEditor;
	[theTextEditor release];
	theTableView.tableHeaderView = textBar;
	[textBar release];

	// Add empty footer, to suppress blank cells (with separators) after actual content
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
	theTableView.tableFooterView = footer;
	[footer release];
	
	self.tableView = theTableView;
	[contentView addSubview:theTableView];
	[theTableView release];
	
	self.view = contentView;
	[contentView release];
	
	//[self addGradientBackground];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!self.comments) {
		allCommentsRetrieved = NO;
		self.comments = [NSMutableArray arrayWithCapacity:10];
		
		[self showActivityIndicator];
		[self retrieveMoreComments];
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
	self.textEditor = nil;
	self.prevLeftBarButton = nil;
	self.prevRightBarButton = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
