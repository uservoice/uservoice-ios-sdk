//
//  UVStyleSheet.h
//  UserVoice
//
//  Created by UserVoice on 10/28/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIColor;

@interface UVStyleSheet : NSObject {

}

+ (void)setStyleSheet:(UVStyleSheet *)styleSheet;

// Convenience methods delegate to the current stylesheet
+ (UIColor *)zebraBgColor:(BOOL)dark;
+ (UIColor *)backgroundColor;
+ (UIColor *)darkZebraBgColor;
+ (UIColor *)lightZebraBgColor;
+ (UIColor *)topSeparatorColor;
+ (UIColor *)bottomSeparatorColor;
+ (UIColor *)tableViewHeaderColor;
+ (UIColor *)tableViewHeaderShadowColor;
+ (UIColor *)primaryTextColor;
+ (UIColor *)secondaryTextColor;
+ (UIColor *)signedInUserTextColor;
+ (UIColor *)labelTextColor;
+ (UIColor *)linkTextColor;
+ (UIColor *)alertTextColor;
+ (UIColor *)navigationBarTintColor;

/**
 * The background color for all table views, etc.
 *
 * Default: light gray.
 */
- (UIColor *)backgroundColor;

/**
 * The background color for darker table rows (suggestions & comments).
 *
 * Default: a darker gray
 */
- (UIColor *)darkZebraBgColor;

/**
 * The background color for lighter table rows (suggestions & comments).
 *
 * Default: a lighter gray
 */
- (UIColor *)lightZebraBgColor;

/**
 * Text color for section headings on the welcome view, as well as a few other labels.
 *
 * Default: blue-gray
 */
- (UIColor *)tableViewHeaderColor;

/**
 * Shadow color for section headings on the welcome view. You may change this to [UIColor clearColor] if you don't want a text shadow.
 *
 * Default: white
 */
- (UIColor *)tableViewHeaderShadowColor;

/**
 * Used for headings, etc.
 *
 * Default: very dark gray
 */
- (UIColor *)primaryTextColor;

/**
 * Used for sub-headings, etc.
 *
 * Default: dark gray
 */
- (UIColor *)secondaryTextColor;

/**
 * Used for the user's name in the footer when the user is signed in.
 *
 * Default: blue
 */
- (UIColor *)signedInUserTextColor;

/**
 * Used for property labels on the suggestion detail view.
 *
 * Default: gray
 */
- (UIColor *)labelTextColor;

/**
 * Used for tappable text
 *
 * Default: dim blue.
 */
- (UIColor *)linkTextColor;

/**
 * Used for certain messages to the user (e.g. needs to sign in to vote, no votes left).
 *
 * Default: dark red
 */
- (UIColor *)alertTextColor;

/**
 * Set as the tintColor for the navigation bar in the UserVoice popover.
 *
 * Default: nil (platform default blue).
 */
- (UIColor *)navigationBarTintColor;

@end
