//
//  UVSuggestionFooterView.m
//  UserVoice
//
//  Created by Scott Rutherford on 04/07/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVSuggestionFooterView.h"
#import "UVFooterView.h"
#import "UVStyleSheet.h"
#import "UVUserButton.h"
#import "UVClientConfig.h"

@implementation UVSuggestionFooterView

@synthesize suggestion = _suggestion;

+ (CGFloat)heightForFooter {
	return 160; // actual cells and padding + table footer
}

+ (UIView *)getHeaderView {
	return nil;
}

- (NSString *)postDateString {
	static NSDateFormatter* dateFormatter = nil;
	if (!dateFormatter) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MMMM dd, yyyy"];
	}
	return [dateFormatter stringFromDate:self.suggestion.createdAt];
}

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion andController:(UVBaseViewController *)theController 
{
	CGFloat screenWidth = [UVClientConfig getScreenWidth];
	if ((self = (UVSuggestionFooterView *)[UVSuggestionFooterView footerViewForController:controller])) {
		UIView *wrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 100)];
		
		UIView *bg = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 82)];		
		bg.backgroundColor = [UVStyleSheet lightBgColor];
		[wrapper addSubview:bg];
		[bg release];
		
		// Name label
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, 85, 16)];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor grayColor];
		label.textAlignment = UITextAlignmentRight;
		label.font = [UIFont boldSystemFontOfSize:13];
		label.text = NSLocalizedStringFromTable(@"Created by",@"UserVoice",nil);
		[wrapper addSubview:label];
		[label release];
		
		// Name
		UVUserButton *nameButton = [UVUserButton buttonWithUserId:_suggestion.creatorId
															 name:_suggestion.creatorName
													   controller:controller
														   origin:CGPointMake(95, 13)
														 maxWidth:205
															 font:[UIFont boldSystemFontOfSize:13]
															color:[UVStyleSheet dimBlueColor]];
		[self addSubview:nameButton];
		
		// Date label
		label = [[UILabel alloc] initWithFrame:CGRectMake(0, 43, 85, 13)];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor grayColor];
		label.textAlignment = UITextAlignmentRight;
		label.font = [UIFont boldSystemFontOfSize:13];
		label.text = NSLocalizedStringFromTable(@"Post date",@"UserVoice",nil);
		[wrapper addSubview:label];
		[label release];
		
		// Date
		label = [[UILabel alloc] initWithFrame:CGRectMake(95, 43, 205, 14)];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor blackColor];
		label.textAlignment = UITextAlignmentLeft;
		label.font = [UIFont systemFontOfSize:13];
		label.text = [controller postDateString];
		[wrapper addSubview:label];
		[label release];
		
		UIView *bottomShadow = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 10)] autorelease];
		UIImage *shadow = [UIImage imageNamed:@"dropshadow_bottom_30.png"];
		CGFloat widthScale = screenWidth / shadow.size.width; // horizontal scaling factor to expand shadow image
		UIImageView *shadowView = [[[UIImageView alloc] initWithImage:shadow] autorelease];
		shadowView.transform = CGAffineTransformMakeScale(widthScale, 1.0); // rescale the shadow
		shadowView.center = CGPointMake(screenWidth/2, shadowView.center.y); // recenter the upscaled shadow
		[bottomShadow addSubview:shadowView];	
		[wrapper addSubview:bottomShadow];
		
		self.tableView.tableHeaderView = wrapper;
		[wrapper release];
	}
	return [self retain];
}

@end
