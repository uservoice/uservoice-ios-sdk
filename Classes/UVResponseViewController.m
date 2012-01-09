//
//  UVResponseViewController.m
//  UserVoice
//
//  Created by UserVoice on 11/10/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVResponseViewController.h"
#import "UVSuggestion.h"
#import "UVStyleSheet.h"
#import "UVProfileViewController.h"
#import "UVUserChickletView.h"
#import "UVUserButton.h"

#define UV_RESPONSE_SECTION_TEXT 0
#define UV_RESPONSE_SECTION_USER 1

@implementation UVResponseViewController

@synthesize suggestion;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion {
	if (self = [super init]) {
		self.suggestion = theSuggestion;
	}
	return self;
}

// Calculates the height of the text.
- (CGSize)textSize {
	// Probably doesn't matter, but we might want to cache this since we call it twice.
	return [self.suggestion.responseText
			sizeWithFont:[UIFont systemFontOfSize:13]
			constrainedToSize:CGSizeMake(240, 10000)
			lineBreakMode:UILineBreakModeWordWrap];
}

#pragma mark ===== Basic View Methods =====

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	self.navigationItem.title = self.suggestion.status;
	
	CGRect frame = [self contentFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:frame];

	UIView *statusLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 8)];
    statusLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	statusLine.backgroundColor = self.suggestion.statusColor;
	[contentView addSubview:statusLine];
	[statusLine release];
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 8, frame.size.width, contentView.bounds.size.height - 8)];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    scrollView.backgroundColor = [UVStyleSheet backgroundColor];

	// User Chicklet
	UVUserChickletView *chicklet = [UVUserChickletView userChickletViewWithOrigin:CGPointMake(10, 10)
																	   controller:self
																			style:UVUserChickletStyleDetail
																		   userId:self.suggestion.responseUserId
																			 name:self.suggestion.responseUserName
																		avatarUrl:self.suggestion.responseUserAvatarUrl
																			admin:YES
																	   karmaScore:0];
	[scrollView addSubview:chicklet];
	
	// User name
	UVUserButton *nameButton = [UVUserButton buttonWithUserId:self.suggestion.responseUserId
														 name:self.suggestion.responseUserName
												   controller:self
													   origin:CGPointMake(70, 10)
													 maxWidth:240
														 font:[UIFont boldSystemFontOfSize:13]
														color:[UVStyleSheet tableViewHeaderColor]];
	[scrollView addSubview:nameButton];
	
	UILabel *body = [[UILabel alloc] initWithFrame:CGRectMake(70, 28, 240, [self textSize].height)];
	body.text = self.suggestion.responseText;
	body.font = [UIFont systemFontOfSize:13];
	body.lineBreakMode = UILineBreakModeWordWrap;
	body.numberOfLines = 0;
    body.textColor = [UVStyleSheet primaryTextColor];
	body.backgroundColor = [UIColor clearColor];
	[scrollView addSubview:body];
	[body release];
	
	scrollView.contentSize = CGSizeMake(frame.size.width, body.bounds.size.height + 28);
	
	[contentView addSubview:scrollView];
	[scrollView release];
	self.view = contentView;
	[contentView release];
}

- (void)dealloc {
	self.suggestion = nil;
    [super dealloc];
}

@end
