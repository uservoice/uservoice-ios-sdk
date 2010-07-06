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

#define SUGGESTIONS_PAGE_SIZE 10
#define UV_SEARCH_TEXTBAR 1
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_PREFIX 100
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_QUERY 101
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_SUFFIX 102
#define UV_BASE_GROUPED_CELL_BG 103

@implementation UVSuggestionListViewController

@synthesize forum, prevLeftBarButton;
@synthesize textEditor = _textEditor;

- (id)initWithForum:(UVForum *)theForum {
	if (self = [super init]) {
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
	if (self = [super init]) {
		self.suggestions = [NSMutableArray arrayWithArray:theSuggestions];
		self.forum = theForum;
		_searching = NO;
	}
	return self;
}

- (NSString *)backButtonTitle {
	return @"Ideas";
}

- (BOOL)isLoading {
	return self.suggestions == nil || ([self.suggestions count] == 0 && !_allSuggestionsRetrieved);
}

- (void)retrieveMoreSuggestions {
	NSInteger page = ([self.suggestions count] / SUGGESTIONS_PAGE_SIZE) + 1;
	[self showActivityIndicator];
	[UVSuggestion getWithForum:self.forum page:page delegate:self];
}

// Populates the suggestions. The default implementation retrieves the 10 most recent
// suggestions, but this can be overridden in subclasses (e.g. for profile idea view).
- (void)populateSuggestions {
	_allSuggestionsRetrieved = NO;
	self.suggestions = [NSMutableArray arrayWithCapacity:10];
	[UVSession currentSession].clientConfig.forum.currentTopic.suggestions = [NSMutableArray arrayWithCapacity:10];
	[self retrieveMoreSuggestions];
}

- (void)didRetrieveSuggestions:(NSArray *)theSuggestions {
	[self hideActivityIndicator];
	if ([theSuggestions count] > 0) {
		[self.suggestions addObjectsFromArray:theSuggestions];
	}
	
	if ([theSuggestions count] < 10) {
		_allSuggestionsRetrieved = YES;
	}
	[[UVSession currentSession].clientConfig.forum.currentTopic.suggestions  addObjectsFromArray:theSuggestions];
	[self.tableView reloadData];
}

- (void)didSearchSuggestions:(NSArray *)theSuggestions {
	[self.suggestions removeAllObjects];
	[self hideActivityIndicator];	
	if ([theSuggestions count] > 0) {
		[self.suggestions addObjectsFromArray:theSuggestions];
	}
	
	if ([theSuggestions count] < 10) {
		_allSuggestionsRetrieved = YES;
	}	
	[self.tableView reloadData];
}

- (BOOL)supportsSearch {
	return YES;
}

- (BOOL)supportsFooter {
	return YES;
}

#pragma mark ===== UITableViewDataSource Methods =====

// Overridden from superclass. In this case the Extra cell is responsible for
// creating a new suggestion.
- (void)initCellForAdd:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
	cell.backgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
	[self addHighlightToCell:cell];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	UIFont *font = [UIFont boldSystemFontOfSize:18];
	UILabel *label = [[UILabel alloc] init];
	label.tag = UV_SEARCH_RESULTS_TAG_CELL_ADD_PREFIX;
	label.text = @"Add \"";
	label.font = font;
	label.textAlignment = UITextAlignmentLeft;
	label.textColor = [UIColor blackColor];
	label.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:label];
	[label release];
	
	label = [[UILabel alloc] init];
	label.tag = UV_SEARCH_RESULTS_TAG_CELL_ADD_QUERY;
	label.text = _textEditor.text;
	label.font = font;
	label.textAlignment = UITextAlignmentLeft;
	label.textColor = [UVStyleSheet dimBlueColor];
	label.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:label];
	[label release];
	
	label = [[UILabel alloc] init];
	label.tag = UV_SEARCH_RESULTS_TAG_CELL_ADD_SUFFIX;
	label.text = @"\"";
	label.font = font;
	label.textAlignment = UITextAlignmentLeft;
	label.textColor = [UIColor blackColor];
	label.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:label];
	[label release];
}

- (void)customizeCellForAdd:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
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
	size = [label.text sizeWithFont:font forWidth:maxWidth lineBreakMode:UILineBreakModeTailTruncation];
	label.frame = CGRectMake(prevEndX, 26, size.width, 20);
	
	// Suffix: "
	prevEndX = label.frame.origin.x + label.frame.size.width;
	label = (UILabel *)[cell.contentView viewWithTag:UV_SEARCH_RESULTS_TAG_CELL_ADD_SUFFIX];
	label.frame = CGRectMake(prevEndX + 3, 26, 10, 20);
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier;
	BOOL selectable = YES;
	UITableViewCellStyle style = UITableViewCellStyleDefault;
	
	if (indexPath.row < [self.suggestions count]) {
		identifier = @"Suggestion";
		
	} else if (indexPath.row == [self.suggestions count] && !_allSuggestionsRetrieved) {
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
	
	if (_searching) {
		// One cell per suggestion + "Load More" + one for "add"
		rows += [self.suggestions count] + (_allSuggestionsRetrieved ? 1 : 2);
		
	} else if (![self isLoading]) {
		// One cell per suggestion + "Load More"
		rows += [self.suggestions count] + (_allSuggestionsRetrieved ? 0 : 1);
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

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

//- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	UVBaseGroupedCell *cell = (UVBaseGroupedCell *)[theTableView cellForRowAtIndexPath:indexPath];
//	UIView *bg = [cell.contentView viewWithTag:UV_BASE_GROUPED_CELL_BG];
//	bg.backgroundColor = [UIColor blueColor];
//	
//	if (indexPath.row < [self.suggestions count]) {
//		UVSuggestion *suggestion = [suggestions objectAtIndex:indexPath.row];
//		UVSuggestionDetailsViewController *next = [[UVSuggestionDetailsViewController alloc] init];
//		next.suggestion = suggestion;
//		[self.navigationController pushViewController:next animated:YES];
//		[next release];
//		
//	} else if (indexPath.row == [self.suggestions count] && !_allSuggestionsRetrieved) {
//		[self retrieveMoreSuggestions];
//		
//	} else {
//		UVNewSuggestionViewController *next = [[UVNewSuggestionViewController alloc] initWithForum:self.forum 
//																							 title:_textEditor.text];
//		[self.navigationController pushViewController:next animated:YES];
//		[next release];
//	}
//	//[theTableView deselectRowAtIndexPath:indexPath animated:YES];
//}

- (void)setLeftBarButtonCancel {
	UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																			    target:self
																			    action:@selector(dismissTextEditor)];
	self.prevLeftBarButton = self.navigationItem.leftBarButtonItem;
	[self.navigationItem setLeftBarButtonItem:cancelItem animated:YES];
	[cancelItem release];
}

- (void)setLeftBarButtonClear {
	UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			    target:self
																			    action:@selector(resetList)];
	[self.navigationItem setLeftBarButtonItem:cancelItem animated:YES];
	[cancelItem release];
}

- (void)setLeftBarButtonPrevious {
	[self.navigationItem setLeftBarButtonItem:self.prevLeftBarButton animated:YES];
}

- (void)resetList {
	_searching = NO;
	_textEditor.text = @"";

	[self.suggestions removeAllObjects];
	[self.suggestions addObjectsFromArray:[UVSession currentSession].clientConfig.forum.currentTopic.suggestions];
	if ([self.suggestions count] < 10) {
		_allSuggestionsRetrieved = YES;
	}	
	[self.tableView reloadData];
	[self setLeftBarButtonPrevious];
}

- (void)dismissTextEditor {
	[self.textEditor resignFirstResponder];	
	[self resetList];
}

#pragma mark ===== UVTextEditorDelegate Methods =====

- (BOOL)textEditorShouldBeginEditing:(UVTextEditor *)theTextEditor {
	UIView *headerView = (UIView *)self.tableView.tableHeaderView;	
	NSInteger height = self.view.bounds.size.height - 216;
	CGRect frame = CGRectMake(0, 10, 320, height);
	UIView *textBar = [headerView viewWithTag:UV_SEARCH_TEXTBAR];
	
	// Maximize header view to allow text editor to grow (leaving room for keyboard) 216
	[UIView beginAnimations:@"growHeader" context:nil];	
	textBar.frame = frame;
	textBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
	
	[self setLeftBarButtonCancel];
	
	frame = CGRectMake(0, 0, 320, 40);
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
	// reset nav
	if (_textEditor.text) {
		[self setLeftBarButtonClear];		
	} else {
		[self setLeftBarButtonPrevious];
	}
	
	UIView *headerView = (UIView *)self.tableView.tableHeaderView;	
	UIView *textBar = [headerView viewWithTag:UV_SEARCH_TEXTBAR];
	
	// Minimize text editor and header
	[UIView beginAnimations:@"shrinkHeader" context:nil];
	textBar.frame = CGRectMake(0, 10, 320, 40);
	textBar.backgroundColor = [UIColor whiteColor];
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

	CGRect frame = [self contentFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:frame];
	
	UITableView *theTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStyleGrouped];
	theTableView.dataSource = self;
	theTableView.delegate = self;
	theTableView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
	theTableView.sectionFooterHeight = 0.0;
	theTableView.sectionHeaderHeight = 0.0;
	//theTableView.allowsSelection = NO;
	
	[self addShadowSeparatorToTableView:theTableView];
	
	NSInteger headerHeight = [self supportsSearch] ? 50 : 10;
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, headerHeight)];  
	headerView.backgroundColor = [UIColor clearColor];
	
	UIImage *shadow = [UIImage imageNamed:@"dropshadow_top_20.png"];	
	UIImageView *shadowView = [[UIImageView alloc] initWithImage:shadow];
	[headerView addSubview:shadowView];	

	if ([self supportsSearch]) {		
		// Add text editor to table header
		UIView *textBar = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 320, 40)];
		textBar.backgroundColor = [UIColor whiteColor];
		textBar.tag = UV_SEARCH_TEXTBAR;
		
		_textEditor = [[UVTextEditor alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		_textEditor.delegate = self;
		_textEditor.autocorrectionType = UITextAutocorrectionTypeYes;
		_textEditor.minNumberOfLines = 1;
		_textEditor.maxNumberOfLines = 1;
		_textEditor.autoresizesToText = NO;
		//_textEditor.backgroundColor = [UIColor clearColor];
		[_textEditor setReturnKeyType:UIReturnKeyGo];
		_textEditor.enablesReturnKeyAutomatically = NO;		
		_textEditor.placeholder = [self.forum example];
		
		[textBar addSubview:_textEditor];		
		[headerView addSubview:textBar];
		[textBar release];
	}
	theTableView.tableHeaderView = headerView;
	
	if ([self supportsFooter]) {
		theTableView.tableFooterView = [UVFooterView footerViewForController:self];
		
	} else {
		UIView *bottomShadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
		UIImage *shadow = [UIImage imageNamed:@"dropshadow_bottom_30.png"];
		UIImageView *shadowView = [[UIImageView alloc] initWithImage:shadow];
		[bottomShadow addSubview:shadowView];	
		theTableView.tableFooterView = bottomShadow;
		[shadow release];
		[shadowView release];
		[bottomShadow release];
	}
	
	self.tableView = theTableView;
	[contentView addSubview:theTableView];
	[theTableView release];
	
	self.view = contentView;
	[contentView release];
	
	//[self addGradientBackground];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!self.suggestions) {
		[self populateSuggestions];
	}
	
	if ([self supportsFooter]) {
		// Reload footer view, in case the user has changed (logged in or unlinked)
		UVFooterView *footer = (UVFooterView *) self.tableView.tableFooterView;
		[footer reloadFooter];
	}
	[self.tableView reloadData];
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
