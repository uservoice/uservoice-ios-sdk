//
//  NSString+UV_UIStringDrawing.h
//  UserVoice
//
//  Created by Bogdan Poplauschi on 14/05/14.
//  Copyright (c) 2014 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface NSString (UV_UIStringDrawing)

/**
 *  Method used to calculate sizeWithFont for both iOS7+later (`sizeWithAttributes:`) and iOS6+earlier(`sizeWithFont:`)
 *
 *  @param font the font for the calculus
 *
 *  @return the size result
 */
- (CGSize)UV_sizeWithFont:(UIFont *)font;

/**
 *  Method used to calculate sizeWithFont for both iOS7+later (`boundingRectWithSize:options:attributes:context:`)
 *    and iOS6+earlier(`sizeWithFont:constrainedToSize:lineBreakMode:`)
 *
 *  @param font the font for the calculus
 *
 *  @return the size result
 */
- (CGSize)UV_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
