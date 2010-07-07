//
//  UVUIColorAdditions.m
//  UserVoice
//
//  Created by UserVoice on 12/14/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVUIColorAdditions.h"


@implementation UIColor (UV_UIColor_Additions)

+ (UIColor *)colorWithRGBHex:(UInt32)hex {
	int r = (hex >> 16) & 0xFF;
	int g = (hex >> 8) & 0xFF;
	int b = (hex) & 0xFF;
	
	return [UIColor colorWithRed:r / 255.0f
						   green:g / 255.0f
							blue:b / 255.0f
						   alpha:1.0f];
}

// Returns a UIColor by scanning the string for a hex number and passing that to +[UIColor colorWithRGBHex:]
// Skips any leading whitespace and ignores any trailing characters
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
	if ([stringToConvert length] > 0 && [stringToConvert characterAtIndex:0]) {
		// Account for #rrggbb format (instead of 0xrrggbb or rrggbb)
		stringToConvert = [stringToConvert substringFromIndex:1];
	}
	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
	unsigned hexNum;
	if (![scanner scanHexInt:&hexNum]) return nil;
	return [UIColor colorWithRGBHex:hexNum];
}

@end
