//
//  UVSuggestionListViewController.m
//  UserVoice
//
//  Created by UserVoice on 10/22/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVSuggestionListViewController.h"
#import "UVClientConfig.h"
#import "UVSession.h"
#import "UVSuggestion.h"
#import "UVSuggestionDetailsViewController.h"
#import "UVNewSuggestionViewController.h"
#import "UVProfileViewController.h"
#import "UVInfoViewController.h"
#import "UVStyleSheet.h"
#import "UVUser.h"
#import "UVFooterView.h"
#import "UVTextEditor.h"
#import "UVBaseGroupedCell.h"
#import "UVCellViewWithIndex.h"
#import "UVStreamPoller.h"

#define SUGGESTIONS_PAGE_SIZE 10
#define UV_SEARCH_TEXTBAR 1
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_PREFIX 100
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_QUERY 101
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_SUFFIX 102
#define UV_BASE_GROUPED_CELL_BG 103
#define UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND 104

@implementation UVSuggestionListViewController

@synthesize forum = _forum;
@synthesize prevLeftBarButton = _prevLeftBarButton;
@synthesize textEditor = _textEditor;

- (id)initWithForum:(UVForum *)theForum {
	if ((self = [super init])) {
		if (theForum.currentTopic.suggestions) {
			self = [self initWithForum:theForum andSuggestions:theForum.currentTopic.suggestions];
			
		} else {
			self.forum = theForum;
		}	
		_searching = NO;
	}
	return self;
}

- (id)initWithForum:(UVForum *)theForum andSuggestions:(NSArray *)theSuggestions {
	if ((self = [super init])) {
		self.suggestions = [NSMutableArray arrayWithArray:theSuggestions];
		self.forum = theForum;
		_searching = NO;
	}
	return self;
}

- (NSString *)backButtonTitle {
	return @"Ideas";
}

- (void)retrieveMoreSuggestions {
	NSInteger page = ([self.suggestions count] / SUGGESTIONS_PAGE_SIZE) + 1;
	[self showActivityIndicator];
    //NSLog(@"retrieveMoreSuggestions: %@", self.forum);
	[UVSuggestion getWithForum:self.forum page:page delegate:self];
}

// Populates the suggestions. The default implementation retrieves the 10 most recent
// suggestions, but this can be overridden in subclasses (e.g. for profile idea view).
- (void)populateSuggestions {
	self.suggestions = [NSMutableArray arrayWithCapacity:10];
	[UVSession currentSession].clientConfig.forum.currentTopic.suggestions = [NSMutableArray arrayWithCapacity:10];
	[UVSession currentSession].clientConfig.forum.currentTopic.suggestionsNeedReload = NO;
	[self retrieveMoreSuggestions];
	
	// gonna check and start the stream timer here too
	if (![UVStreamPoller instance].timerIsRunning) {
		[[UVStreamPoller instance] startTimer];
		[UVStreamPoller instance].lastPollTime = [NSDate date];
	}
}

- (void)didRetrieveSuggestions:(NSArray *)theSuggestions {
	[self hideActivityIndicator];
	if ([theSuggestions count] > 0) {
		//NSLog(@"Retrieved Suggestions: %@", theSuggetions);
		[self.suggestions addObjectsFromArray:theSuggestions];
		//NSLog(@"Stored Suggestions: %@", self.suggestions);
	}

	[[UVSession currentSession].clientConfig.forum.currentTopic.suggestions addObjectsFromArray:theSuggestions];
	[self.tableView reloadData];
}

- (void)didSearchSuggestions:(NSArray *)theSuggestions {
	[self.suggestions removeAllObjects];
	[self hideActivityIndicator];	
	if ([theSuggestions count] > 0) {
		[self.suggestions addObjectsFromArray:theSuggestions];
	}
	
	[self.tableView reloadData];
}

- (BOOL)supportsSearch {
	return YES;
}

- (BOOL)supportsFooter {
	return YES;
}

- (void)addSuggestion:(UVCellViewWithIndex *)cellView {
	UVNewSuggestionViewController *next = [[UVNewSuggestionViewController alloc] initWithForum:self.forum 
																						 title:_textEditor.text];
	[self.navigationController pushViewController:next animated:YES];
	[next release];
	[self dismissTextEditor];
}

#pragma mark ===== UITableViewDataSource Methods =====

// Overridden from superclass. In this case the Extra cell is responsible for
// creating a new suggestion.
- (void)initCellForAdd:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	// getting the cell size
    CGRect contentRect = cell.contentView.bounds;
	UVCellViewWithIndex *cellView = [[UVCellViewWithIndex alloc] initWithIndex:indexPath.row andFrame:contentRect];	

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	UIFont *font = [UIFont boldSystemFontOfSize:18];
	UILabel *label = [[UILabel alloc] init];
	label.tag = UV_SEARCH_RESULTS_TAG_CELL_ADD_PREFIX;
	label.text = @"Add \"";
	label.font = font;
	label.textAlignment = UITextAlignmentLeft;
	label.textColor = [UIColor blackColor];
	label.backgroundColor = [UIColor clearColor];
	[cellView addSubview:label];
	[label release];
	
	label = [[UILabel alloc] init];
	label.tag = UV_SEARCH_RESULTS_TAG_CELL_ADD_QUERY;
	label.text = _textEditor.text;
	label.font = font;
	label.textAlignment = UITextAlignmentLeft;
	label.textColor = [UVStyleSheet dimBlueColor];
	label.backgroundColor = [UIColor clearColor];
	[cellView addSubview:label];
	[label release];
	
	label = [[UILabel alloc] init];
	label.tag = UV_SEARCH_RESULTS_TAG_CELL_ADD_SUFFIX;
	label.text = @"\"";
	label.font = font;
	label.textAlignment = UITextAlignmentLeft;
	label.textColor = [UIColor blackColor];
	label.backgroundColor = [UIColor clearColor];
	[cellView addSubview:label];
	[label release];
	
	[cell.contentView addSubview:cellView];
	[cellView release];
}

- (void)customizeCellForAdd:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath 
{
	UIColor *bgColor = indexPath.row % 2 == 0 ? [UVStyleSheet darkZebraBgColor] : [UVStyleSheet lightZebraBgColor];
	cell.backgroundView.backgroundColor = bgColor;
	
	UIFont *font = [UIFont boldSystemFontOfSize:18];
	NSString *text = [NSString stringWithFormat:@"Add \"%@\"", _textEditor.text];
	CGSize size = [text sizeWithFont:font forWidth:260 lineBreakMode:UILineBreakModeTailTruncation];
	CGFloat startX = 30.0 + ((260.0 - size.width) / 2.0);
	
	// Prefix: Add "
	UILabel *label = (UILabel *)[cell.contentView viewWithTag:UV_SEARCH_RESULTS_TAG_CELL_ADD_PREFIX];
	size = [label.text sizeWithFont:font forWidth:260 lineBreakMode:UILineBreakModeTailTruncation];
	label.frame = CGRectMake(startX, 26, size.width, 20);
	
	// Query
	NSInteger prevEndX = label.frame.origin.x + label.frame.size.width;
	CGFloat maxWidth = 260 - (size.width + 10);
	label = (UILabel *)[cell.contentView viewWithTag:UV_SEARCH_RESULTS_TAG_CELL_ADD_QUERY];
	label.text = _textEditor.text;
	label.textColor = [UVStyleSheet dimBlueColor];
	size = [label.text sizeWithFont:font forWidth:maxWidth lineBreakMode:UILineBreakModeTailTruncation];
	label.frame = CGRectMake(prevEndX, 26, size.width, 20);
	
	// Suffix: "
	prevEndX = label.frame.origin.x + label.frame.size.width;
	label = (UILabel *)[cell.contentView viewWithTag:UV_SEARCH_RESULTS_TAG_CELL_ADD_SUFFIX];
	label.frame = CGRectMake(prevEndX-1, 26, 10, 20);
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier;
	BOOL selectable = YES;
	UITableViewCellStyle style = UITableViewCellStyleDefault;
	NSInteger suggestionsCount = [UVSession currentSession].clientConfig.forum.currentTopic.suggestionsCount;
	NSLog(@"%d, %d, %d", indexPath.row, [self.suggestions count], suggestionsCount);
	
	if (indexPath.row < [self.suggestions count]) {
		identifier = @"Suggestion";
		
	} else if (!_searching && (indexPath.row == [self.suggestions count]) &&  (suggestionsCount > [self.suggestions count])) {
		identifier = @"Load";
		
	} else {
		identifier = @"Add";
	}		
	return [self createCellForIdentifier:identifier
							   tableView:theTableView
							   indexPath:indexPath
								   style:style
							  selectable:selectable];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	NSInteger loadedCount = [self.suggestions count];
	NSInteger suggestionsCount = [UVSession currentSession].clientConfig.forum.currentTopic.suggestionsCount;
	
	if (_searching) {
		NSLog(@"Adding extra row for 'add'");
		// One cell per suggestion + one for "add"
		rows = loadedCount + 1;
		
	} else {
		// One cell per suggestion + "Load More"
		rows = [self.suggestions count] + (loadedCount>=suggestionsCount || suggestionsCount<SUGGESTIONS_PAGE_SIZE ? 0 : 1);
	}
	return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Both for suggestions and Load More
	return 71;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger suggestionsCount = [UVSession currentSession].clientConfig.forum.currentTopic.suggestionsCount;
	if (!_searching && (indexPath.row == [self.suggestions count]) && (suggestionsCount > [self.suggestions count]))
	{
		// This is the last row in the table, so it's the "Load more ideas" cell
		[self retrieveMoreSuggestions];
	}
	else 
	{
		// For all other rows, push appropriate suggestion details
		[self pushSuggestionShowView:indexPath.row];
	}
}


- (void)setLeftBarButtonCancel {
	UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																			    target:self
																			    action:@selector(dismissTextEditor)];	
	[self.navigationItem setLeftBarButtonItem:cancelItem animated:YES];
	[cancelItem release];
}

- (void)setLeftBarButtonClear {
	UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			    target:self
																			    action:@selector(resetList)];
	[self.navigationItem setLeftBarButtonItem:clearItem animated:YES];
	[clearItem release];
}

- (void)setLeftBarButtonPrevious {
	[self.navigationItem setLeftBarButtonItem:self.prevLeftBarButton animated:YES];
}

- (void)resetList {
	_searching = NO;
	_textEditor.text = @"";

	[self.suggestions removeAllObjects];
	[self.suggestions addObjectsFromArray:[UVSession currentSession].clientConfig.forum.currentTopic.suggestions];
	[self.tableView reloadData];
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

- (void)dismissTextEditor {
	[self.textEditor resignFirstResponder];	
	[self resetList];
}

#pragma mark ===== UVTextEditorDelegate Methods =====

- (void)setCellsEnabled:(BOOL)enabled {
	// need to stop rows being selected
	for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];	
		UIButton *button = (UIButton *)[cell.contentView viewWithTag:UV_BASE_SUGGESTION_LIST_TAG_CELL_BACKGROUND];
		button.enabled = enabled;
	}
}

- (BOOL)textEditorShouldBeginEditing:(UVTextEditor *)theTextEditor {
	//NSLog(@"textEditorShouldBeginEditing");
	
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	
	UIView *headerView = (UIView *)self.tableView.tableHeaderView;	
	NSInteger height = self.view.bounds.size.height - 216;
	CGRect frame = CGRectMake(0, 10, screenWidth, height);
	UIView *textBar = [headerView viewWithTag:UV_SEARCH_TEXTBAR];
	
	// Maximize header view to allow text editor to grow (leaving room for keyboard) 216
	[UIView beginAnimations:@"growHeader" context:nil];
	//NSLog(@"setLeftBarButtonCancel");
	[self setLeftBarButtonCancel];	
	[self setCellsEnabled:NO];
	
	textBar.frame = frame;
	textBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];		
	frame = CGRectMake(0, 0, screenWidth, 40);
	theTextEditor.frame = frame;  // (may not actually need to change this, since bg is white)
	theTextEditor.backgroundColor = [UIColor whiteColor];	
	
	[UIView commitAnimations];
	return YES;
}

- (BOOL)textEditorShouldReturn:(UVTextEditor *)theTextEditor {
	NSLog(@"Check for: %@", self.textEditor.text);
	[self showActivityIndicator];
	[self.textEditor resignFirstResponder];
	_searching = YES;
	
	if (self.textEditor.text) {
		[UVSuggestion searchWithForum:self.forum query:self.textEditor.text delegate:self];
	}
	
	return NO;
}

- (void)textEditorDidEndEditing:(UVTextEditor *)theTextEditor {	
	//NSLog(@"textEditorDidEndEditing");
	
	// reset nav
	if (_textEditor.text) {
		//NSLog(@"setLeftBarButtonClear");		
		[self setLeftBarButtonClear];		
	}
	
	UIView *headerView = (UIView *)self.tableView.tableHeaderView;	
	UIView *textBar = [headerView viewWithTag:UV_SEARCH_TEXTBAR];
	
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	
	// Minimize text editor and header
	[UIView beginAnimations:@"shrinkHeader" context:nil];
	textBar.frame = CGRectMake(0, 10, screenWidth, 40);
	textBar.backgroundColor = [UIColor whiteColor];
	
	[self setCellsEnabled:YES];
	[UIView commitAnimations];	
}

- (BOOL)textEditorShouldEndEditing:(UVTextEditor *)theTextEditor {
	return YES;
}

#pragma mark ===== Basic View Methods =====

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];

	self.navigationItem.title = self.forum.currentTopic.prompt;

	CGRect frame = [self contentFrame]; // ??
	UIView *contentView = [[UIView alloc] initWithFrame:frame];
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	CGFloat screenHeight = [UVClientConfig getScreenHeight];
	
	// TODO: fix table initWithFrame here
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-44) style:UITableViewStylePlain];
	theTableView.dataSource = self;
	theTableView.delegate = self;
	theTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
	theTableView.sectionFooterHeight = 0.0;
	theTableView.sectionHeaderHeight = 0.0;
	
	[self addShadowSeparatorToTableView:theTableView];
	
	NSInteger headerHeight = [self supportsSearch] ? 50 : 10;
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, headerHeight)];  
	headerView.backgroundColor = [UIColor clearColor];
	
	UIImage *shadow = [UIImage imageNamed:@"dropshadow_top_20.png"];	
	CGFloat widthScale = screenWidth / shadow.size.width; // horizontal scaling factor to expand shadow image
	UIImageView *shadowView = [[UIImageView alloc] initWithImage:shadow];
	shadowView.transform = CGAffineTransformMakeScale(widthScale, 1.0); // rescale the shadow
	shadowView.center = CGPointMake(screenWidth/2, shadowView.center.y); // recenter the upscaled shadow
	[headerView addSubview:shadowView];	
	[shadowView release];

	if ([self supportsSearch]) {		
		// Add text editor to table header
		UIView *textBar = [[UIView alloc] initWithFrame:CGRectMake(0, 10, screenWidth, 40)];
		textBar.backgroundColor = [UIColor whiteColor];
		textBar.tag = UV_SEARCH_TEXTBAR;
		
		_textEditor = [[UVTextEditor alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
		_textEditor.delegate = self;
		_textEditor.autocorrectionType = UITextAutocorrectionTypeYes;
		_textEditor.minNumberOfLines = 1;
		_textEditor.maxNumberOfLines = 1;
		_textEditor.autoresizesToText = NO;
		
		[_textEditor setReturnKeyType:UIReturnKeyGo];
		_textEditor.enablesReturnKeyAutomatically = NO;		
		_textEditor.placeholder = [self.forum example];
		
		[textBar addSubview:_textEditor];		
		[headerView addSubview:textBar];
		[textBar release];
	}
	theTableView.tableHeaderView = headerView;
	
	if ([self supportsFooter]) {
		theTableView.tableFooterView = [UVFooterView altFooterViewForController:self];
		
	} else {
		UIView *bottomShadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 10)];
		UIImage *shadow = [UIImage imageNamed:@"dropshadow_bottom_30.png"];
		CGFloat widthScale = screenWidth / shadow.size.width; // horizontal scaling factor to expand shadow image
		UIImageView *shadowView = [[[UIImageView alloc] initWithImage:shadow] autorelease];
		shadowView.transform = CGAffineTransformMakeScale(widthScale, 1.0); // rescale the shadow
		shadowView.center = CGPointMake(screenWidth/2, shadowView.center.y); // recenter the upscaled shadow
		[bottomShadow addSubview:shadowView];	
		theTableView.tableFooterView = bottomShadow;
		//[bottomShadow release];
		//[shadowView release];
	}
	
	self.tableView = theTableView;
	[contentView addSubview:theTableView];
	[theTableView release];
	
	self.view = contentView;
	[contentView release];
}

- (void)reloadTableData {
	NSLog(@"UVSuggestionListViewController: reloadTableData");
	self.suggestions = [UVSession currentSession].clientConfig.forum.currentTopic.suggestions;
	
	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    if (self.forum) {
        NSLog(@"UVSuggestionListViewController: reloadSuggestions");
        if ([UVSession currentSession].clientConfig.forum.currentTopic.suggestionsNeedReload) {
            self.suggestions = nil;
        }
        
        if (!self.suggestions) {
            NSLog(@"UVSuggestionListViewController: populateSuggestions");
            [self populateSuggestions];
        }
        if ([self supportsFooter]) {
            // Reload footer view, in case the user has changed (logged in or unlinked)
            UVFooterView *footer = (UVFooterView *) self.tableView.tableFooterView;
            [footer reloadFooter];
        }
    }
    [self.tableView reloadData];
    
    NSLog(@"Adding observer");
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reloadTableData) 
                                                 name:@"TopicSuggestionsUpdated"
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	NSLog(@"Removing observer");
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:@"TopicSuggestionsUpdated" 
												  object:nil];
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
	if (_textEditor)
		[_textEditor release];
}


@end
