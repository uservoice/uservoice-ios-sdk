//
//  UVUtils.h
//  UserVoice
//
//  Created by Austin Taylor on 4/29/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UVUtils : NSObject

+ (NSString *)toQueryString:(NSDictionary *)dict;
+ (NSString *)URLEncode:(NSString *)str;
+ (NSString *)URLDecode:(NSString *)str;
+ (NSString *)decodeHTMLEntities:(NSString *)str;
+ (NSString *)encodeJSON:(id)obj;
+ (NSData *)decode64:(NSString *)string;
+ (NSString *)encodeData64:(NSData *)data;
+ (NSString *)encode64:(NSString *)data;
+ (UIColor *)parseHexColor:(NSString *)str;

+ (BOOL)isConnectionError:(NSError *)error;
+ (BOOL)isUVRecordInvalid:(NSError *)error;
+ (BOOL)isUVRecordInvalid:(NSError *)error forField:(NSString *)field withMessage:(NSString *)message;
+ (BOOL)isAuthError:(NSError *)error;
+ (BOOL)isNotFoundError:(NSError *)error;

+ (void)applyStylesheetToNavigationController:(UINavigationController *)navigationController;
+ (NSString *)formatInteger:(NSInteger)number;
+ (NSString *)colorToCSS:(UIColor *)color;
+ (void)configureView:(UIView *)superview subviews:(NSDictionary *)viewsDict constraints:(NSArray *)constraintStrings finalCondition:(BOOL)includeFinalConstraint finalConstraint:(NSString *)finalConstraint;
+ (void)configureView:(UIView *)superview subviews:(NSDictionary *)viewsDict constraints:(NSArray *)constraintStrings;

@end
