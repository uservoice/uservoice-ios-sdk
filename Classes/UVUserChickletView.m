//
//  UVUserChickletView.m
//  UserVoice
//
//  Created by UserVoice on 1/22/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVUserChickletView.h"
#import "UVStyleSheet.h"
#import "UVProfileViewController.h"
#import "UVImageView.h"

#define UV_USER_CHICKLET_TAG_BG_IMAGE 201
#define UV_USER_CHICKLET_TAG_AVATAR_IMAGE 202
#define UV_USER_CHICKLET_TAG_LABEL 203
#define UV_USER_CHICKLET_TAG_ICON 204
#define UV_USER_CHICKLET_TAG_BUTTON 205

@implementation UVUserChickletView

@synthesize controller;
@synthesize userId;
@synthesize name;
@synthesize avatarUrl;
@synthesize admin;
@synthesize karmaScore;
@synthesize style;

+ (CGFloat)heightForView {
	return 68.0;
}

+ (CGFloat)widthForView {
	return 50.0;
}

+ (UVUserChickletView *)userChickletViewWithOrigin:(CGPoint)origin
										controller:(UVBaseViewController *)theController
											 style:(UVUserChickletStyle)theStyle
											userId:(NSInteger)theUserId
											  name:(NSString *)theName
										 avatarUrl:(NSString *)theAvatarUrl
											 admin:(BOOL)isAdmin
										karmaScore:(NSInteger)theKarmaScore {
	return [[[UVUserChickletView alloc] initWithOrigin:origin
											controller:theController
												 style:theStyle
												userId:theUserId
												  name:theName
											 avatarUrl:theAvatarUrl
												 admin:isAdmin
											karmaScore:theKarmaScore] autorelease];
}

+ (UVUserChickletView *)userChickletViewWithOrigin:(CGPoint)origin
										controller:(UVBaseViewController *)theController
											 admin:(BOOL)isAdmin {
	return [[[UVUserChickletView alloc] initWithOrigin:origin
											controller:theController
												 style:UVUserChickletStyleDark
												userId:0
												  name:nil
											 avatarUrl:nil
												 admin:isAdmin
											karmaScore:0] autorelease];
}

- (NSString *)labelText {
	if (self.admin) {
		return NSLocalizedStringFromTable(@"admin", @"UserVoice", nil);
	} else {
		return [[NSNumber numberWithInteger:self.karmaScore] stringValue];
	}
}

- (void)updateLabel {
	CGFloat height = self.bounds.size.height;
	CGFloat width = self.bounds.size.width;

	UILabel *label = (UILabel *)[self viewWithTag:UV_USER_CHICKLET_TAG_LABEL];
	label.text = [self labelText];

	CGFloat availableWidth = width - 4;
	if (admin) {
		// No icon => Use the whole label size
		label.frame = CGRectMake(2, height - 14, availableWidth, 10);
	} else {
		// Figure out text size and account for image
		CGSize textSize = [label.text sizeWithFont:[UIFont boldSystemFontOfSize:10] forWidth:availableWidth lineBreakMode:UILineBreakModeTailTruncation];
		UIImageView *icon = (UIImageView *)[self viewWithTag:UV_USER_CHICKLET_TAG_ICON];
		CGSize iconSize = icon.image.size;
		CGFloat totalWidth = textSize.width + iconSize.width + 3;
		CGFloat leftMargin = (availableWidth - totalWidth) / 2.0;
		icon.frame = CGRectMake(2 + leftMargin, height - 14, iconSize.width, iconSize.height);
		label.frame = CGRectMake(2 + leftMargin + iconSize.width + 3, height - 14, textSize.width, 10);
	}
}

- (NSString *)imageName {
	switch (self.style) {
		case UVUserChickletStyleLight:
			return @"uv_user_chicklet_light.png";
		case UVUserChickletStyleDark:
			return @"uv_user_chicklet_dark.png";
		default:
			return @"uv_user_chicklet_detail.png";
	}
}

- (void)updateWithStyle:(UVUserChickletStyle)theStyle userId:(NSInteger)theUserId name:(NSString *)theName avatarUrl:(NSString *)theAvatarUrl karmaScore:(NSInteger)theKarmaScore {
	self.style = theStyle;
	self.userId = theUserId;
	self.name = theName;
	
	UIImageView *imageView = (UIImageView *)[self viewWithTag:UV_USER_CHICKLET_TAG_BG_IMAGE];
	imageView.image = [UIImage imageNamed:[self imageName]];
	
	[self updateWithAvatarUrl:theAvatarUrl karmaScore:theKarmaScore];
}

- (void)updateWithAvatarUrl:(NSString *)theAvatarUrl karmaScore:(NSInteger)theKarmaScore {
	self.avatarUrl = theAvatarUrl;
	self.karmaScore = theKarmaScore;
	
	UVImageView *imageView = (UVImageView *)[self viewWithTag:UV_USER_CHICKLET_TAG_AVATAR_IMAGE];
	imageView.URL = theAvatarUrl;

	[self updateLabel];
}

- (void)enableButton:(BOOL)enabled {
	UIButton *button = (UIButton *)[self viewWithTag:UV_USER_CHICKLET_TAG_BUTTON];
	button.enabled = enabled;
}

- (void)buttonTapped {
	UVProfileViewController *next = [[UVProfileViewController alloc] initWithUserId:self.userId name:self.name];
	[self.controller.navigationController pushViewController:next animated:YES];
	[next release];
}

- (void)addSubviews {
	// Add rounded corners around the whole view
	self.layer.cornerRadius = 5.0;
	self.layer.masksToBounds = YES;

	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.tag = UV_USER_CHICKLET_TAG_BUTTON;
	button.frame = self.bounds;
	[button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
	
	// Background image
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
	imageView.tag = UV_USER_CHICKLET_TAG_BG_IMAGE;
	imageView.opaque = NO;
	imageView.image = [UIImage imageNamed:[self imageName]];
	[button addSubview:imageView];
	[imageView release];

	// Avatar image	
	UVImageView *avatarView = [[UVImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
	avatarView.tag = UV_USER_CHICKLET_TAG_AVATAR_IMAGE;
	avatarView.defaultImage = [UIImage imageNamed:@"uv_default_avatar.png"];
	avatarView.URL  = self.avatarUrl;
    avatarView.backgroundColor = [UIColor whiteColor];
	avatarView.userInteractionEnabled = NO;
	[button addSubview:avatarView];
	[avatarView release];	

	// Score label
	UILabel *label = [[UILabel alloc] init]; // will set frame later
	label.tag = UV_USER_CHICKLET_TAG_LABEL;
	label.font = [UIFont boldSystemFontOfSize:10];
	label.textAlignment = UITextAlignmentCenter;
    // This color isn't configurable because it is overlayed on the chicklet image.
    label.textColor = [UIColor colorWithRed:0.298 green:0.337 blue:0.424 alpha:1.0];
	label.backgroundColor = [UIColor clearColor];
	[button addSubview:label];
	[label release];

	// Score image
	if (!self.admin) {
		UIImageView *scoreImage = [[UIImageView alloc] init]; // will set frame later
		scoreImage.tag = UV_USER_CHICKLET_TAG_ICON;
		scoreImage.image = [UIImage imageNamed:@"uv_karma_star.png"];
		[button addSubview:scoreImage];
		[scoreImage release];
	}

	[self addSubview:button];
	
	[self updateLabel];
}

- (id)initWithOrigin:(CGPoint)origin
		  controller:(UVBaseViewController *)theController
			   style:(UVUserChickletStyle)theStyle
			  userId:(NSInteger)theUserId
				name:(NSString *)theName
		   avatarUrl:(NSString *)theAvatarUrl
			   admin:(BOOL)isAdmin
		  karmaScore:(NSInteger)theKarmaScore {
	CGRect theFrame = CGRectMake(origin.x, origin.y, [UVUserChickletView widthForView], [UVUserChickletView heightForView]);
	if (self = [super initWithFrame:theFrame]) {
		self.controller = theController;
		self.userId = theUserId;
		self.name = theName;
		self.avatarUrl = theAvatarUrl;
		self.admin = isAdmin;
		self.karmaScore = theKarmaScore;
		self.style = theStyle;
		
		[self addSubviews];
	}
	return self;
}

- (void)dealloc {
    self.name = nil;
    self.avatarUrl = nil;
    [super dealloc];
}

@end
