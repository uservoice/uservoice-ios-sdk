//
//  UVStyleSheet.h
//  UserVoice
//
//  Created by Mirko Froehlich on 10/28/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIColor;

@interface UVStyleSheet : NSObject {

}

+ (UIColor *)veryDarkGrayColor;

+ (UIColor *)darkBgColor;
+ (UIColor *)lightBgColor;

+ (UIColor *)zebraBgColor:(BOOL)dark;
+ (UIColor *)darkZebraBgColor;
+ (UIColor *)lightZebraBgColor;

+ (UIColor *)topSeparatorColor;
+ (UIColor *)bottomSeparatorColor;

+ (UIColor *)tableViewHeaderColor;

+ (UIColor *)dimBlueColor;
+ (UIColor *)darkRedColor;

@end
