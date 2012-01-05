//
//  UVUserAvatarView.m
//  UserVoice
//
//  Created by Scott Rutherford on 17/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVUserAvatarView.h"
#import <QuartzCore/QuartzCore.h>
#import "UVStyleSheet.h"
#import "UVImageView.h"

#define UV_USER_AVATAR_TAG_ICON 200
#define UV_USER_AVATAR_TAG_BUTTON 201

@implementation UVUserAvatarView

@synthesize avatarUrl;

+ (CGFloat)heightForView {
	return 50.0;
}

+ (CGFloat)widthForView {
	return 50.0;
}

- (void)enableButton:(BOOL)enabled {
	UIButton *button = (UIButton *)[self viewWithTag:UV_USER_AVATAR_TAG_BUTTON];
	button.enabled = enabled;
}

- (void)iconButtonTapped {
	// edit image not implemented
//	UVProfileViewController *next = [[UVProfileViewController alloc] initWithUserId:self.userId name:self.name];
//	[self.controller.navigationController pushViewController:next animated:YES];
//	[next release];
}

- (void)addSubviews {
	// Add rounded corners around the whole view
	self.layer.cornerRadius = 5.0;
	self.layer.masksToBounds = YES;
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, 300, 50);
	button.tag = UV_USER_AVATAR_TAG_BUTTON;
	[button addTarget:self action:@selector(iconButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	
	// Avatar image
	UVImageView *avatarView = [[UVImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
	avatarView.URL  = self.avatarUrl;
	avatarView.tag = UV_USER_AVATAR_TAG_ICON;
	avatarView.defaultImage = [UIImage imageNamed:@"uv_default_avatar.png"];
    avatarView.backgroundColor = [UIColor whiteColor];
	avatarView.userInteractionEnabled = NO;
	[button addSubview:avatarView];
	[avatarView release];
	[self addSubview:button];
}

- (id)initWithOrigin:(CGPoint)origin
		   avatarUrl:(NSString *)theAvatarUrl {
	CGRect theFrame = CGRectMake(origin.x, origin.y, [UVUserAvatarView widthForView], [UVUserAvatarView heightForView]);
	if (self = [super initWithFrame:theFrame]) {
		self.avatarUrl = theAvatarUrl;
		
		[self addSubviews];
	}
	return self;
}

- (void)dealloc {
    self.avatarUrl = nil;
    [super dealloc];
}

@end
