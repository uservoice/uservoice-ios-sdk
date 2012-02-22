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
#import "UVSession.h"

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
@synthesize textEditor;
@synthesize prevLeftBarButton;
@synthesize prevRightBarButton;
@synthesize textBar;
@synthesize headerView;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion {
	if (self = [super init]) {
		self.suggestion = theSuggestion;
	}
	return self;
}

- (NSString *)backButtonTitle {
	return NSLocalizedStringFromTable(@"Comments", @"UserVoice", nil);
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
    	self.navigationItem.title = NSLocalizedStringFromTable(@"1 Comment", @"UserVoice", nil);
    } else {
    	self.navigationItem.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d Comments", @"UserVoice", nil), self.suggestion.commentsCount];
    }
    [self.textEditor setText:@""];
    
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
    [textEditor setText:@""];
    [textEditor performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0];
}

- (void)saveTextEditor:(id)sender {
    NSString *text = self.textEditor.text;

    [self dismissTextEditor:sender];
    [self showActivityIndicator];
    [UVComment createWithSuggestion:self.suggestion text:text delegate:self];
}

- (void)promptForFlagWithIndex:(NSInteger)index {
    self.commentToFlag = [self.comments objectAtIndex:index];
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"Flag Comment?", @"UserVoice", nil)
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                          destructiveButtonTitle:NSLocalizedStringFromTable(@"Flag as inappropriate", @"UserVoice", nil)
                                               otherButtonTitles:nil];
    [action showInView:self.view];
    [action release];
}

- (void)didFlagComment:(UVComment *)theComment {
    [self hideActivityIndicator];
    [self alertSuccess:NSLocalizedStringFromTable(@"You have successfully flagged this comment as inappropriate.", @"UserVoice", nil)];
}

#pragma mark ===== UIActionSheetDelegate Methods =====

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self showActivityIndicator];
        [self.commentToFlag flag:@"inappropriate" suggestion:self.suggestion delegate:self];
    }
}

#pragma mark ===== UITextFieldDelegate Methods =====

- (void)textFieldDidBeginEditing:(UITextField *)textField {
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
	
    textBar.hidden = NO;
    [textEditor performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];

	// Maximize header view to allow text editor to grow (leaving room for keyboard)
    // TODO: Technically, kbHeight is 0 the first time we do this, so it would probably make sense
    // to move the whole animation part to keyboardDidShow: or something. Doesn't look bad, though.
	NSInteger height = self.view.bounds.size.height - kbHeight;
    [UIView animateWithDuration:0.2
                     animations:^{ textBar.frame = CGRectMake(0, 0, screenWidth, height); }];
}

#pragma mark ===== UVTextEditorDelegate Methods =====

- (void)textEditorDidEndEditing:(UVTextEditor *)theTextEditor {
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
    [self.navigationItem setLeftBarButtonItem:self.prevLeftBarButton animated:YES];
	[self.navigationItem setRightBarButtonItem:self.prevRightBarButton animated:YES];

	// Minimize text editor and header
    [UIView animateWithDuration:0.2
                     animations:^{ textBar.frame = CGRectMake(0, 0, screenWidth, 40); }
                     completion:^(BOOL finished){ textBar.hidden = YES; }];
}

- (BOOL)textEditorShouldEndEditing:(UVTextEditor *)theTextEditor {
	return YES;
}

#pragma mark ===== table cells =====

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
	label.textColor = [UVStyleSheet secondaryTextColor];
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
    label.textColor = [UVStyleSheet primaryTextColor];
	[cell.contentView addSubview:label];
	[label release];

	// Chicklet
	UVUserChickletView *chicklet = [UVUserChickletView userChickletViewWithOrigin:CGPointMake(10, 10) controller:self admin:NO];
	chicklet.tag = UV_COMMENT_LIST_TAG_CELL_CHICKLET;
	[cell.contentView addSubview:chicklet];
	
	UVCellViewWithIndex *cellView = [[[UVCellViewWithIndex alloc] init] autorelease];
	cellView.tag = UV_COMMENT_LIST_TAG_CELL_BUTTON;
	cellView.index = indexPath.row;
	cellView.frame = CGRectMake(290, 10, 20, 21);
	[cell.contentView addSubview:cellView];
}

- (void)customizeCellForComment:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	UVComment *comment = [self.comments objectAtIndex:indexPath.row];

	BOOL darkZebra = indexPath.row % 2 == 0;
	cell.backgroundView.backgroundColor = [UVStyleSheet zebraBgColor:darkZebra];

	// Username + Date
	NSInteger days = ABS([comment.createdAt timeIntervalSinceNow]) / (60 * 60 * 24);
	NSString *daysAgo = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d days ago", @"UserVoice", nil), days];
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

- (void)initCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	cell.backgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
	[self addHighlightToCell:cell];
	CGFloat screenWidth = [UVClientConfig getScreenWidth];

	// Can't use built-in textLabel, as this forces a white background
	UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, screenWidth, 20)];
	textLabel.text = NSLocalizedStringFromTable(@"Load more comments...", @"UserVoice", nil);
	textLabel.textColor = [UVStyleSheet primaryTextColor];
	textLabel.backgroundColor = [UIColor clearColor];
	textLabel.font = [UIFont systemFontOfSize:16];
	textLabel.textAlignment = UITextAlignmentCenter;
	[cell.contentView addSubview:textLabel];
	[textLabel release];
}

- (void)customizeCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	cell.backgroundView.backgroundColor = [UVStyleSheet zebraBgColor:(indexPath.row % 2 == 0)];
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

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        CGFloat screenWidth = [UVClientConfig getScreenWidth];
        if ([UVSession currentSession].user==nil) {        
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, screenWidth, 40);
            NSString *buttonTitle = NSLocalizedStringFromTable(@"Please sign in here to comment.", @"UserVoice", nil);
            [button setTitle:buttonTitle forState:UIControlStateNormal];
            [button setTitleColor:[UVStyleSheet alertTextColor] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor whiteColor];
            button.showsTouchWhenHighlighted = YES;
            button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            [button addTarget:self action:@selector(promptUserToSignIn) forControlEvents:UIControlEventTouchUpInside];
            return button;
            
        } else {
            // Add text editor to table header
            if (headerView == nil) {
                self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)] autorelease];
                headerView.backgroundColor = [UIColor whiteColor];
                UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(14, 9, (screenWidth-14), 26)] autorelease];
                textField.placeholder = NSLocalizedStringFromTable(@"Add a comment...", @"UserVoice", nil);
                textField.delegate = self;
                [headerView addSubview:textField];
            }
            return headerView;
        }
    } else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 40;
    } else {
        return 0;
    }
}

#pragma mark ===== Basic View Methods =====

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];

	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	CGRect frame = [self contentFrame];
	if (self.suggestion.commentsCount == 1) {
		self.navigationItem.title = NSLocalizedStringFromTable(@"1 Comment", @"UserVoice", nil);
	} else {
		self.navigationItem.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d Comments", @"UserVoice", nil), self.suggestion.commentsCount];
	}
    UIView *contentView = [[[UIView alloc] initWithFrame:frame] autorelease];
	UITableView *theTableView = [[[UITableView alloc] initWithFrame:contentView.bounds] autorelease];
	theTableView.dataSource = self;
	theTableView.delegate = self;
    [theTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    theTableView.backgroundColor = [UVStyleSheet backgroundColor];
	
	[self addShadowSeparatorToTableView:theTableView];

	// Add empty footer, to suppress blank cells (with separators) after actual content
	UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)] autorelease];
	theTableView.tableFooterView = footer;
    
    [contentView addSubview:theTableView];
    
    
    self.textBar = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)] autorelease];
    textBar.hidden = YES;
    textBar.backgroundColor = [UIColor whiteColor];
    self.textEditor = [[[UVTextEditor alloc] initWithFrame:CGRectMake(5, 0, (screenWidth-5), 40)] autorelease];
    textEditor.delegate = self;
    textEditor.autocorrectionType = UITextAutocorrectionTypeYes;
    textEditor.minNumberOfLines = 1;
    if (UIDeviceOrientationIsLandscape([UVClientConfig getOrientation]))
        textEditor.maxNumberOfLines = 4;
    else
        textEditor.maxNumberOfLines = 8;
    textEditor.autoresizesToText = YES;
    textEditor.backgroundColor = [UIColor clearColor];
    textEditor.placeholder = NSLocalizedStringFromTable(@"Add a comment...", @"UserVoice", nil);
    [textBar addSubview:textEditor];

    [contentView addSubview:textBar];
	
	self.tableView = theTableView;
    self.view = contentView;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    [self.tableView reloadData];
    	
	if (!self.comments) {
		allCommentsRetrieved = NO;
		self.comments = [NSMutableArray arrayWithCapacity:10];
		
		[self showActivityIndicator];
		[self retrieveMoreComments];
	}
}

- (void)dealloc {
    self.suggestion = nil;
    self.comments = nil;
    self.commentToFlag = nil;
    self.textEditor = nil;
    self.prevLeftBarButton = nil;
    self.prevRightBarButton = nil;
    self.textBar = nil;
    self.headerView = nil;
    [super dealloc];
}


@end
