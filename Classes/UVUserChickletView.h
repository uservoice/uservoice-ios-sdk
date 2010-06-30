//
//  UVUserChickletView.h
//  UserVoice
//
//  Created by UserVoice on 1/22/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UVBaseViewController;

typedef enum {
	UVUserChickletStyleLight,
	UVUserChickletStyleDark,
	UVUserChickletStyleDetail,
} UVUserChickletStyle;

@interface UVUserChickletView : UIView {
	NSInteger userId;
	NSString *name;
	NSString *avatarUrl;
	BOOL admin;
	NSInteger karmaScore;
	UVUserChickletStyle style;
	UVBaseViewController *controller;
}

@property (assign) NSInteger userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *avatarUrl;
@property (assign) BOOL admin;
@property (assign) NSInteger karmaScore;
@property (assign) UVUserChickletStyle style;
@property (assign) UVBaseViewController *controller;

+ (CGFloat)heightForView;
+ (CGFloat)widthForView;
+ (UVUserChickletView *)userChickletViewWithOrigin:(CGPoint)origin
										controller:(UVBaseViewController *)theController
											 style:(UVUserChickletStyle)style
											userId:(NSInteger)theUserId
											  name:(NSString *)theName
										 avatarUrl:(NSString *)theAvatarUrl
											 admin:(BOOL)isAdmin
										karmaScore:(NSInteger)theKarmaScore;

// Use this factory method if the values aren't known yet (e.g. when initializing
// a new table cell).
+ (UVUserChickletView *)userChickletViewWithOrigin:(CGPoint)origin
										controller:(UVBaseViewController *)theController
											 admin:(BOOL)isAdmin;

- (void)updateWithAvatarUrl:(NSString *)theAvatarUrl karmaScore:(NSInteger)theKarmaScore;
- (void)updateWithStyle:(UVUserChickletStyle)theStyle userId:(NSInteger)theUserId name:(NSString *)theName avatarUrl:(NSString *)theAvatarUrl karmaScore:(NSInteger)theKarmaScore;

- (void)enableButton:(BOOL)enabled;

- (id)initWithOrigin:(CGPoint)origin
		  controller:(UVBaseViewController *)theController
			   style:(UVUserChickletStyle)style
			  userId:(NSInteger)theUserId
				name:(NSString *)theName
		   avatarUrl:(NSString *)theAvatarUrl
			   admin:(BOOL)isAdmin
		  karmaScore:(NSInteger)theKarmaScore;

@end
