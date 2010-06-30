//
//  UVStyleSheet.m
//  UserVoice
//
//  Created by UserVoice on 10/28/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVStyleSheet.h"
#import "UVSuggestion.h"

@implementation UVStyleSheet

#pragma mark === Colors ===
// Used both inside and outside of styles

+ (UIColor *)veryDarkGrayColor {
	return [UIColor colorWithRed:0.102 green:0.102 blue:0.102 alpha:1.0];
}

+ (UIColor *)darkBgColor {
	return [UIColor colorWithRed:0.718 green:0.725 blue:0.729 alpha:1.0];
}

+ (UIColor *)lightBgColor {
	return [UIColor colorWithRed:0.902 green:0.902 blue:0.902 alpha:1.0];
}

+ (UIColor *)zebraBgColor:(BOOL)dark {
	return dark ? [self darkZebraBgColor] : [self lightZebraBgColor];
}

+ (UIColor *)darkZebraBgColor {
	return [UIColor colorWithRed:0.851 green:0.851 blue:0.851 alpha:1.0];
}

+ (UIColor *)lightZebraBgColor {
	return [UIColor colorWithRed:0.902 green:0.902 blue:0.902 alpha:1.0];
}

+ (UIColor *)topSeparatorColor {
	return [UIColor colorWithRed:0.953 green:0.953 blue:0.953 alpha:1.0];
}

+ (UIColor *)bottomSeparatorColor {
	return [UIColor colorWithRed:0.729 green:0.741 blue:0.745 alpha:1.0];
}

+ (UIColor *)tableViewHeaderColor {
	return [UIColor colorWithRed:0.298 green:0.337 blue:0.424 alpha:1.0];
}

+ (UIColor *)dimBlueColor {
	return [UIColor colorWithRed:0.451 green:0.529 blue:0.643 alpha:1.0];
}

+ (UIColor *)darkRedColor {
	return [UIColor colorWithRed:0.631 green:0.0 blue:0.2 alpha:1.0];
}

#pragma mark === text field styles ===

//- (TTStyle*)commentTextBar {
//	return
//    [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(237, 239, 241)
//										color2:RGBCOLOR(206, 208, 212) next:
//	 [TTFourBorderStyle styleWithTop:RGBCOLOR(187, 189, 190) right:nil bottom:RGBCOLOR(153, 153, 153) left:nil width:1 next:nil]];
//}
//
//- (TTStyle*)commentTextBarActive {
//	return [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:nil];
//}
//
//- (TTStyle*)commentTextBarTextField {
//	return 
//    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(3, 0, 2, 6) next:
//	 [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5.0] next:
//	  [TTInsetStyle styleWithInset:UIEdgeInsetsMake(1, 0, 1, 0) next:
//	   [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.4) blur:0 offset:CGSizeMake(0, 1) next:
//		[TTSolidFillStyle styleWithColor:TTSTYLEVAR(backgroundColor) next:
//		 [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.4) blur:3 offset:CGSizeMake(0, 2) next:
//		  [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.25) shadow:RGBACOLOR(0,0,0,0.4)
//										   width:1 lightSource:270 next:nil]]]]]]];
//}
//
//- (TTStyle*)commentTextBarTextFieldActive {
//	return [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:nil];
//}
//
//- (TTStyle*)suggestionTextField {
//	return 
//    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 0, 0) next:
//	 [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5.0] next:
//	  [TTInsetStyle styleWithInset:UIEdgeInsetsMake(1, 0, 1, 0) next:
//	   [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.4) blur:0 offset:CGSizeMake(0, 1) next:
//		[TTSolidFillStyle styleWithColor:TTSTYLEVAR(backgroundColor) next:
//		 [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.4) blur:3 offset:CGSizeMake(0, 2) next:
//		  [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.25) shadow:RGBACOLOR(0,0,0,0.4)
//										   width:1 lightSource:270 next:nil]]]]]]];
//}
//
//- (TTStyle*)messageTextField {
//	return TTSTYLE(suggestionTextField);
//}
//
#pragma mark === Suggestion Detail Styles ===

//- (TTStyle *)title {
//	return [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:14.0] color:[UIColor blackColor] next:nil];
//}
//
//- (TTStyle *)text {
//	return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:12.0] color:[UIColor blackColor] next:nil];
//}
//
//- (TTStyle *)meta {
//	return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:12.0] color:[UIColor blueColor] next:nil];
//}
//
//// Not used for now (see comment in [UVSuggestionDetailsViewController loadView])
//- (TTStyle *)voteCount {
//	return [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:16.0] color:[UIColor blackColor] textAlignment:UITextAlignmentCenter next:nil];
//}
//
//// Not used for now (see comment in [UVSuggestionDetailsViewController loadView])
//- (TTStyle *)voteText {
//	return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:12.0] color:[UIColor blackColor] textAlignment:UITextAlignmentCenter next:nil];
//}
//
//- (TTStyle *)statusHeading {
//	return [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:12.0] color:[UIColor blackColor] next:nil];
//}
//
//#pragma mark === Misc Styles ===
//
//- (TTStyle *)dimBlue {
//	return [TTTextStyle styleWithColor:[UVStyleSheet dimBlueColor] next:nil];
//}
//
//- (TTStyle *)suggestionTitle {
//	return [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:12.0] color:[UIColor blueColor] next:nil];
//}
//
//- (TTStyle *)userChickletLabel {
//	return [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:10] color:[UVStyleSheet dimBlueColor] textAlignment:UITextAlignmentCenter next:nil];
//}

@end
