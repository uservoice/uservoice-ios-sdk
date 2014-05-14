//
//  NSString+UV_UIStringDrawing.m
//  UserVoice
//
//  Created by Bogdan Poplauschi on 14/05/14.
//  Copyright (c) 2014 UserVoice Inc. All rights reserved.
//

#import "NSString+UV_UIStringDrawing.h"

@implementation NSString (UV_UIStringDrawing)

- (CGSize)UV_sizeWithFont:(UIFont *)font {
    CGSize sizeWithFont = CGSizeZero;
    
    if ([self respondsToSelector:@selector(sizeWithAttributes:)]) {
        sizeWithFont = [self sizeWithAttributes:@{NSFontAttributeName: font}];
    } else {
        // this means we are running on a system older than iOS7, since `sizeWithAttributes:` was added in iOS7.
        // so we need to use `sizeWithFont:`
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        sizeWithFont = [self sizeWithFont:font];
        #pragma clang diagnostic pop
    }
    
    return sizeWithFont;
}

- (CGSize)UV_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    CGSize sizeWithFont = CGSizeZero;
    
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = lineBreakMode;
        
        NSDictionary * attributes = @{NSFontAttributeName : font,
                                      NSParagraphStyleAttributeName : [paragraphStyle copy]};
        
        sizeWithFont = [self boundingRectWithSize:size
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:attributes
                                          context:nil].size;
    } else {
        // this means we are running on a system older than iOS7, since `sizeWithAttributes:` was added in iOS7.
        // so we need to use `sizeWithFont:`
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        sizeWithFont = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
        #pragma clang diagnostic pop
    }
    
    return sizeWithFont;
}

@end
