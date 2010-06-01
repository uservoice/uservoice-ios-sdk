//
//  UVUserAvatarView.h
//  UserVoice
//
//  Created by Scott Rutherford on 17/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UVUserAvatarView : UIView {
	NSString *avatarUrl;
}

@property (nonatomic, retain) NSString *avatarUrl;

+ (CGFloat)heightForView;
+ (CGFloat)widthForView;

- (void)enableButton:(BOOL)enabled;

- (id)initWithOrigin:(CGPoint)origin avatarUrl:(NSString *)theAvatarUrl;

@end
