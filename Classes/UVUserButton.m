//
//  UVUserButton.m
//  UserVoice
//
//  Created by UserVoice on 2/23/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVUserButton.h"
#import "UVProfileViewController.h"
#import "UVBaseViewController.h"


@implementation UVUserButton

@synthesize userId;
@synthesize userName;
@synthesize controller;

- (void)navigateToUser {
	UIViewController *next = [[UVProfileViewController alloc] initWithUserId:self.userId name:self.userName];
	[controller.navigationController pushViewController:next animated:YES];
	[next release];
}

+ (UVUserButton *)buttonWithcontroller:(UVBaseViewController *)controller
								  font:(UIFont *)font
								 color:(UIColor *)color {
	UVUserButton *button = [UVUserButton buttonWithType:UIButtonTypeCustom];
	button.controller = controller;
	button.backgroundColor = [UIColor clearColor];
	button.titleLabel.font = font;
	button.showsTouchWhenHighlighted = YES;
	[button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[button setTitleColor:color forState:UIControlStateNormal];
	[button addTarget:button action:@selector(navigateToUser) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

+ (UVUserButton *)buttonWithUserId:(NSInteger)userId
							  name:(NSString *)userName
						controller:(UVBaseViewController *)controller
							origin:(CGPoint)origin
						  maxWidth:(CGFloat)maxWidth
							  font:(UIFont *)font
							 color:(UIColor *)color {
	UVUserButton *button = [self buttonWithcontroller:controller font:font color:color];
	[button updateWithUserId:userId name:userName origin:origin maxWidth:maxWidth];
	return button;
}


- (void)updateWithUserId:(NSInteger)theUserId
					name:(NSString *)theUserName
				  origin:(CGPoint)origin
				maxWidth:(CGFloat)maxWidth {
	CGSize titleSize = [theUserName sizeWithFont:self.titleLabel.font
										forWidth:maxWidth
								   lineBreakMode:UILineBreakModeTailTruncation];
	self.frame = CGRectMake(origin.x, origin.y, titleSize.width, titleSize.height);
	[self setTitle:theUserName forState:UIControlStateNormal];
	self.userId = theUserId;
	self.userName = theUserName;
}

- (void)dealloc {
    self.userName = nil;
    [super dealloc];
}

@end
