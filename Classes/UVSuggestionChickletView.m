//
//  UVSuggestionChickletView.m
//  UserVoice
//
//  Created by Mirko Froehlich on 1/15/10.
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
	UIView *statusColorView = [[UIView alloc] initWithFrame:CGRectMake(0, height - 30, width, 29)];
	statusColorView.tag = UV_CHICKLET_TAG_STATUS_COLOR;
	statusColorView.layer.cornerRadius = 5.0;
	[self addSubview:statusColorView];
	[statusColorView release];

	// Background image
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
	imageView.tag = UV_CHICKLET_TAG_IMAGE;
	imageView.opaque = NO;
	[self addSubview:imageView];
	[imageView release];
	
	// Number of votes
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(2, 7, width - 4, 18)];
	label.tag = UV_CHICKLET_TAG_VOTES_COUNT;
	label.font = [UIFont boldSystemFontOfSize:18];
	label.adjustsFontSizeToFitWidth = YES;
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor blackColor];
	label.backgroundColor = [UIColor clearColor];
	[self addSubview:label];
	[label release];
	
	// The word "votes"
	label = [[UILabel alloc] initWithFrame:CGRectMake(2, 27, width - 4, 10)];
	label.tag = UV_CHICKLET_TAG_VOTES_LABEL;
	label.font = [UIFont boldSystemFontOfSize:10];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor darkGrayColor];
	label.backgroundColor = [UIColor clearColor];
	[self addSubview:label];
	[label release];	
	
	// Status
	label = [[UILabel alloc] initWithFrame:CGRectMake(2, height - 14, width - 4, 10)];
	label.tag = UV_CHICKLET_TAG_STATUS;
	label.font = [UIFont systemFontOfSize:9];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor];
	[self addSubview:label];
	[label release];
}

- (id)initWithOrigin:(CGPoint)origin {
	CGRect theFrame = CGRectMake(origin.x, origin.y, [UVSuggestionChickletView widthForView], [UVSuggestionChickletView heightForView]);
	if (self = [super initWithFrame:theFrame]) {
		[self addSubviews];
	}
	return self;
}

- (NSString *)imageNameForStyle:(UVSuggestionChickletStyle)style {
	if (style == UVSuggestionChickletStyleEmpty)
	{
		return @"uv_vote_chicklet_empty.png";
	}
	else
	{
		return @"uv_vote_chicklet.png";
	}
}

- (void)updateWithSuggestion:(UVSuggestion *)suggestion style:(UVSuggestionChickletStyle)style {
	UIImageView *imageView = (UIImageView *)[self viewWithTag:UV_CHICKLET_TAG_IMAGE];
	NSString *imageName = [self imageNameForStyle:style];
	//NSLog(@"imageName: %@\n", imageName);
	imageView.image = [UIImage imageNamed:imageName];
	if (!suggestion.status)
		imageView.frame = CGRectMake(0, 0, 60, 44);
		
	UIView *statusColorView = [self viewWithTag:UV_CHICKLET_TAG_STATUS_COLOR];
	statusColorView.backgroundColor = suggestion.statusColor;
	
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	UILabel *label = (UILabel *)[self viewWithTag:UV_CHICKLET_TAG_VOTES_COUNT];
	label.text = [formatter stringFromNumber:[NSNumber numberWithInteger:suggestion.voteCount]];
	[formatter release];

	label = (UILabel *)[self viewWithTag:UV_CHICKLET_TAG_VOTES_LABEL];
	label.text = suggestion.voteCount == 1 ? @"vote" : @"votes";

	label = (UILabel *)[self viewWithTag:UV_CHICKLET_TAG_STATUS];
	label.text = suggestion.status == nil ? @"" : suggestion.status;
}

@end
