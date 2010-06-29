//
//  UVSearchResultsViewController.m
//  UserVoice
//
//  Created by Mirko Froehlich on 11/16/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVSearchResultsViewController.h"
#import "UVSession.h"
#import "UVSuggestion.h"
#import "UVForum.h"
#import "UVSuggestionDetailsViewController.h"
#import "UVProfileViewController.h"
#import "UVNewSuggestionViewController.h"
#import "UVStyleSheet.h"
#import "UVUser.h"
#import "Three20/Three20.h"

#define UV_SEARCH_RESULTS_TAG_CELL_ADD_PREFIX 100
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_QUERY 101
#define UV_SEARCH_RESULTS_TAG_CELL_ADD_SUFFIX 102

@implementation UVSearchResultsViewController

@synthesize forum;
@synthesize query;
@synthesize textField;

- (id)initWithForum:(UVForum *)theForum {
	if (self = [super init]) {
		self.forum = theForum;
	}
	return self;
}

- (void)cancelButtonTapped {
	[self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)numSuggestionsVisible {
	return showAllSuggestions ? [self.suggestions count] : MIN([self.suggestions count], 3);
}

- (BOOL)hasMoreSuggestions {
	return !showAllSuggestions && [self.suggestions count] > 3;
}

// Overridden to populate suggestions based on search results.
- (void)populateSuggestions {
	if (self.query) {
		self.suggestions = [NSMutableArray arrayWithCapacity:10];
		[self showActivityIndicator];
		[UVSuggestion searchWithForum:self.forum query:self.query delegate:self];
	}
}

- (void)didRetrieveSuggestions:(NSArray *)theSuggestions {
	[self hideActivityIndicator];
	if ([theSuggestions count] > 0) {
		[self.suggestions addObjectsFromArray:theSuggestions];
		showAllSuggestions = NO;
	}
	
	[self.tableView reloadData];
}

#pragma mark ===== UITextFieldDelegate Methods =====

- (void)textFieldDidEndEditing:(UITextField *)theTextField {
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	self.query = theTextField.text;
	[textField resignFirstResponder];

	// Trigger new search, but stay on this view instead of pushing a new one
	[self populateSuggestions];

	return YES;
}

#pragma mark ===== table cells =====

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
	label.text = self.query;
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

	NSString *text = [NSString stringWithFormat:@"Add \"%@\"", self.query];
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
	label.text = self.query;
	size = [label.text sizeWithFont:font forWidth:maxWidth lineBreakMode:UILineBreakModeTailTruncation];
	label.frame = CGRectMake(prevEndX, 26, size.width, 20);
	
	// Suffix: "
	prevEndX = label.frame.origin.x + label.frame.size.width;
	label = (UILabel *)[cell.contentView viewWithTag:UV_SEARCH_RESULTS_TAG_CELL_ADD_SUFFIX];
	label.frame = CGRectMake(prevEndX + 3, 26, 10, 20);
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier;
	UITableViewCellStyle style = UITableViewCellStyleDefault;
	
	if (indexPath.row < [self numSuggestionsVisible]) {
		identifier = @"Suggestion";
	} else if (indexPath.row == [self numSuggestionsVisible] && [self hasMoreSuggestions]) {
		identifier = @"Load";
	} else {
		identifier = @"Add";
	}
	
	return [self createCellForIdentifier:identifier
							   tableView:theTableView
							   indexPath:indexPath
								   style:style
							  selectable:YES];
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (self.suggestions) {
		if ([self hasMoreSuggestions]) {
			return 5; // 3 suggestions + "load more" + "add suggestion"
		} else {
			return [self.suggestions count] + 1; // up to 3 suggestions + "add sugestion"
		}
	} else {
		return 0;
	}
}

#pragma mark ===== UITableViewDelegate Methods =====

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 71;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.row < [self numSuggestionsVisible]) {
		UVSuggestion *suggestion = [suggestions objectAtIndex:indexPath.row];
		UVSuggestionDetailsViewController *next = [[UVSuggestionDetailsViewController alloc] init];
		next.suggestion = suggestion;
		[self.navigationController pushViewController:next animated:YES];
		[next release];
	} else if (indexPath.row == [self numSuggestionsVisible] && [self hasMoreSuggestions]) {
		showAllSuggestions = YES;
		[self.tableView reloadData];
	} else {
		UVNewSuggestionViewController *next = [[UVNewSuggestionViewController alloc] initWithForum:self.forum title:self.query];
		[self.navigationController pushViewController:next animated:YES];
		[next release];
	}
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
	// Hide the nav bar. We're going to add a combined pseudo nav bar and text field below.
	self.navigationController.navigationBarHidden = YES;

	[super loadView];

	CGRect frame = [self contentFrameWithNavBar:NO];
	UIView *contentView = [[UIView alloc] initWithFrame:frame];
	
	TTView *textBar = [[TTView alloc] initWithFrame:CGRectMake(0, 0, 320, 84)];
	textBar.style = [TTSolidFillStyle styleWithColor:TTSTYLEVAR(navigationBarTintColor) next:nil];

	// Simulate the UINavigationBar look by having a solid background and adding a reflective
	// style to the top part only.
	TTView *textBarTop = [[TTView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	textBarTop.style = [TTReflectiveFillStyle styleWithColor:TTSTYLEVAR(navigationBarTintColor) next:nil];
	[textBar addSubview:textBarTop];
	[textBarTop release];

	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 180, 24)];
	title.text = [self.forum prompt];
	title.font = [UIFont boldSystemFontOfSize:13];
	title.textColor = [UIColor colorWithRed:0.227 green:0.267 blue:0.314 alpha:1.0];
	title.backgroundColor = [UIColor clearColor];
	title.textAlignment = UITextAlignmentCenter;
	[textBar addSubview:title];
	[title release];
	
	TTButton *cancelButton = [TTButton buttonWithStyle:@"toolbarButton:" title:@"Cancel"];
	cancelButton.frame = CGRectMake(255, 5, 60, 33);
	[cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[textBar addSubview:cancelButton];
	
	UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 44, 310, 31)];
	theTextField.delegate = self;
	theTextField.borderStyle = UITextBorderStyleRoundedRect;
	theTextField.autocorrectionType = UITextAutocorrectionTypeYes;
	theTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	theTextField.returnKeyType = UIReturnKeyDone;
	theTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	theTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	theTextField.placeholder = [self.forum example];
	[textBar addSubview:theTextField];
	self.textField = theTextField;
	[theTextField release];
	[contentView addSubview:textBar];

	CGRect tableFrame = CGRectMake(0, textBar.frame.size.height, 320, frame.size.height - textBar.frame.size.height);
	UITableView *theTableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
	theTableView.dataSource = self;
	theTableView.delegate = self;
	theTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	[self addShadowSeparatorToTableView:theTableView];
	
	// Add empty footer, to suppress blank cells (with separators) after actual content
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
	theTableView.tableFooterView = footer;
	[footer release];
	
	self.tableView = theTableView;
	[contentView addSubview:theTableView];
	[theTableView release];
	[textBar release];
	
	self.view = contentView;
	[contentView release];
}

- (void)viewWillAppear:(BOOL)animated {
	// Hide the navigation bar. We're doing this in loadView (so we can calculate
	// the correct frame), but need to do it here as well to account for popping
	// back from a child view.
	self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	// Immedately activate search bar the first time we enter this view
	if (!self.query) {
		[self.textField becomeFirstResponder];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	// Re-enable the navigation bar
	self.navigationController.navigationBarHidden = NO;
}

@end
