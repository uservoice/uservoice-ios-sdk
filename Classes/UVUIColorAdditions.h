//
//  UVUIColorAdditions.h
//  UserVoice
//
//  Created by UserVoice on 12/14/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


// Several UIColor extensions
// Adapted from <http://github.com/ars/uicolor-utilities>
@interface UIColor (UV_UIColor_Additions)

+ (UIColor *)colorWithRGBHex:(UInt32)hex;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

@end
