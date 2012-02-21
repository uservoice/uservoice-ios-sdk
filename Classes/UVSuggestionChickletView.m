//
//  UVSuggestionChickletView.m
//  UserVoice
//
//  Created by UserVoice on 1/15/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVSuggestionChickletView.h"
#import "UVSuggestion.h"

#define UV_CHICKLET_TAG_IMAGE 1
#define UV_CHICKLET_TAG_VOTES_COUNT 2
#define UV_CHICKLET_TAG_VOTES_LABEL 3
#define UV_CHICKLET_TAG_STATUS 4
#define UV_CHICKLET_TAG_STATUS_COLOR 5

@implementation UVSuggestionChickletView

@synthesize statusColorLayer, backgroundImageView, voteNumLabel, voteLabel, statusLabel;

+ (CGFloat)heightForView {
	return 61.0;
}

+ (CGFloat)widthForView {
	return 60.0;
}

+ (UVSuggestionChickletView *)suggestionChickletViewWithOrigin:(CGPoint)origin {
	return [[[UVSuggestionChickletView alloc] initWithOrigin:origin] autorelease];
}

- (void)addSubviews {
	CGFloat height = self.bounds.size.height;
	CGFloat width = self.bounds.size.width;
	
	// Status Color
	// (Don't actually need exact height of 30, just want to exclude transparent top corners)
    // We use a CALayer rather than a UIView so that it won't get hidden on selection of the table cell.
    self.statusColorLayer = [CALayer layer];
    statusColorLayer.frame = CGRectMake(0, height - 30, width, 29);
    statusColorLayer.cornerRadius = 6.0;
    [self.layer addSublayer:statusColorLayer];

	// Background image
	backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
	backgroundImageView.tag = UV_CHICKLET_TAG_IMAGE;
	backgroundImageView.opaque = NO;
	[self addSubview:backgroundImageView];
	
	// Number of votes
	voteNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 7, width - 4, 18)];
	voteNumLabel.tag = UV_CHICKLET_TAG_VOTES_COUNT;
	voteNumLabel.font = [UIFont boldSystemFontOfSize:18];
	voteNumLabel.adjustsFontSizeToFitWidth = YES;
	voteNumLabel.textAlignment = UITextAlignmentCenter;
	voteNumLabel.textColor = [UIColor blackColor];
	voteNumLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:voteNumLabel];
	
	// The word "votes"
	voteLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 27, width - 4, 10)];
	voteLabel.tag = UV_CHICKLET_TAG_VOTES_LABEL;
	voteLabel.font = [UIFont boldSystemFontOfSize:10];
	voteLabel.textAlignment = UITextAlignmentCenter;
	voteLabel.textColor = [UIColor darkGrayColor];
	voteLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:voteLabel];
	
	// Status
	statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, height - 14, width - 4, 10)];
	statusLabel.tag = UV_CHICKLET_TAG_STATUS;
	statusLabel.font = [UIFont systemFontOfSize:9];
	statusLabel.textAlignment = UITextAlignmentCenter;
	statusLabel.textColor = [UIColor whiteColor];
	statusLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:statusLabel];
}

- (id)initWithOrigin:(CGPoint)origin {
	CGRect theFrame = CGRectMake(origin.x, origin.y, [UVSuggestionChickletView widthForView], [UVSuggestionChickletView heightForView]);
	if (self = [super initWithFrame:theFrame]) {
		[self addSubviews];
	}
	return self;
}

- (NSString *)imageNameForStyle:(UVSuggestionChickletStyle)style {
	if (style == UVSuggestionChickletStyleEmpty) {
		return @"uv_vote_chicklet_empty.png";
	} else {
		return @"uv_vote_chicklet.png";
	}
}

- (void)updateWithSuggestion:(UVSuggestion *)suggestion style:(UVSuggestionChickletStyle)style {
	//UIImageView *imageView = (UIImageView *)[self viewWithTag:UV_CHICKLET_TAG_IMAGE];
	NSString *imageName = suggestion.status ? @"uv_vote_chicklet.png" : @"uv_vote_chicklet_empty.png";
	//NSLog(@"imageName: %@\n", imageName);
	backgroundImageView.image = [UIImage imageNamed:imageName];
	if (!suggestion.status)
		backgroundImageView.frame = CGRectMake(0, 0, 60, 44);
	else
		backgroundImageView.frame = CGRectMake(0, 0, 60, 60);

    statusColorLayer.backgroundColor = [suggestion.statusColor CGColor];
	
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	//UILabel *label = (UILabel *)[self viewWithTag:UV_CHICKLET_TAG_VOTES_COUNT];
	voteNumLabel.text = [formatter stringFromNumber:[NSNumber numberWithInteger:suggestion.voteCount]];
	[formatter release];

	//label = (UILabel *)[self viewWithTag:UV_CHICKLET_TAG_VOTES_LABEL];
	voteLabel.text = suggestion.voteCount == 1 ? NSLocalizedStringFromTable(@"vote", @"UserVoice", nil) : NSLocalizedStringFromTable(@"votes", @"UserVoice", nil);

	//label = (UILabel *)[self viewWithTag:UV_CHICKLET_TAG_STATUS];
	statusLabel.text = suggestion.status == nil ? @"" : suggestion.status;
}

- (void)dealloc {
    self.statusColorLayer = nil;
	self.backgroundImageView = nil;	
	self.voteNumLabel = nil;
	self.voteLabel = nil;
	self.statusLabel = nil;
    [super dealloc];
}

@end
