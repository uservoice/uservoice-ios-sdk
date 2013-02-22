//
//  NSString+HTMLEntities.m
//  UserVoice
//
//  Created by Austin Taylor on 12/29/11.
//  Copyright (c) 2011 UserVoice Inc. All rights reserved.
//

#import "NSString+HTMLEntities.h"

@implementation NSString (HTMLEntities)

- (NSString *)stringByDecodingHTMLEntities {
    // TODO: Replace this with something more efficient/complete
    NSMutableString *string = [NSMutableString stringWithString:self];
    [string replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&apos;" withString:@"'"  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&amp;"  withString:@"&"  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&lt;"   withString:@"<"  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&gt;"   withString:@">"  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&#34;" withString:@"\""  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&#39;" withString:@"'"  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&#38;" withString:@"&"  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&#60;" withString:@"<"  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&#62;" withString:@">"  options:0 range:NSMakeRange(0, [string length])];
    return string;
}

@end
