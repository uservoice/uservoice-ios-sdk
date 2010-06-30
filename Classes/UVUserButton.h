//
//  UVUserButton.h
//  UserVoice
//
//  Created by UserVoice on 2/23/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UVBaseViewController;

@interface UVUserButton : UIButton {
	NSInteger userId;
	NSString *userName;
	UVBaseViewController *controller;
}

@property (assign) NSInteger userId;
@property (nonatomic, retain) NSString *userName;
@property (assign) UVBaseViewController *controller;

+ (UVUserButton *)buttonWithUserId:(NSInteger)userId
							  name:(NSString *)userName
						controller:(UVBaseViewController *)controller
							origin:(CGPoint)origin
						  maxWidth:(CGFloat)maxWidth
							  font:(UIFont *)font
							 color:(UIColor *)color;

+ (UVUserButton *)buttonWithcontroller:(UVBaseViewController *)controller
							  font:(UIFont *)font
							 color:(UIColor *)color;

- (void)updateWithUserId:(NSInteger)userId
					name:(NSString *)userName
				  origin:(CGPoint)origin
				maxWidth:(CGFloat)maxWidth;

@end
