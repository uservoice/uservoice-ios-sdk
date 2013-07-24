//
//  UVUtils.m
//  UserVoice
//
//  Created by Austin Taylor on 4/29/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVUtils.h"
#import "UVJSON.h"
#import "UVStyleSheet.h"

@implementation UVUtils

+ (NSString *)toQueryString:(NSDictionary *)dict {
    if (dict == nil)
        return nil;
    NSMutableArray *pairs = [[[NSMutableArray alloc] init] autorelease];
    for (id key in [dict allKeys]) {
        id value = [dict objectForKey:key];
        if ([value isKindOfClass:[NSArray class]]) {
            for (id val in value) {
                [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [self URLEncode:val]]];
            }
        } else {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [self URLEncode:value]]];
        }
    }
    return [pairs componentsJoinedByString:@"&"];
}

+ (NSString *)URLEncode:(NSString *)str {
    if (str == nil)
        return nil;
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)str,
                                                                           NULL, CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
    [result autorelease];
    return result;
}

+ (NSString *)URLDecode:(NSString *)str {
    if (str == nil)
        return nil;
    NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                           (CFStringRef)str,
                                                                                           CFSTR(""),
                                                                                           kCFStringEncodingUTF8);
    [result autorelease];
    return result;
}

+ (NSString *)decodeHTMLEntities:(NSString *)str {
    if (str == nil)
        return nil;
    // TODO: Replace this with something more efficient/complete
    NSMutableString *string = [NSMutableString stringWithString:str];
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

+ (NSString *)encodeJSON:(id)obj {
    if (obj == nil)
        return nil;
    UVJsonWriter *jsonWriter = [UVJsonWriter new];
    NSString *json = [jsonWriter stringWithObject:obj];
    if (!json)
        NSLog(@"+encodeJSON failed. Error trace is: %@", [jsonWriter errorTrace]);
    [jsonWriter release];
    return json;
}

+ (UIColor *)parseHexColor:(NSString *)str {
    if (str == nil)
        return nil;
    if ([str length] > 0 && [str characterAtIndex:0] == '#') {
        str = [str substringFromIndex:1];
    }
    NSScanner *scanner = [NSScanner scannerWithString:str];
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

+ (NSData *)decode64:(NSString *)string {
	if (string == nil)
		return nil;
	if ([string length] == 0)
		return [NSData data];
	
	static char *decodingTable = NULL;
	if (decodingTable == NULL)
	{
		decodingTable = malloc(256);
		if (decodingTable == NULL)
			return nil;
		memset(decodingTable, CHAR_MAX, 256);
		NSUInteger i;
		for (i = 0; i < 64; i++)
			decodingTable[(short)encodingTable[i]] = i;
	}
	
	const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
	if (characters == NULL)     //  Not an ASCII string!
		return nil;
	char *bytes = malloc((([string length] + 3) / 4) * 3);
	if (bytes == NULL)
		return nil;
	NSUInteger length = 0;
    
	NSUInteger i = 0;
	while (YES)
	{
		char buffer[4];
		short bufferLength;
		for (bufferLength = 0; bufferLength < 4; i++)
		{
			if (characters[i] == '\0')
				break;
			if (isspace(characters[i]) || characters[i] == '=')
				continue;
			buffer[bufferLength] = decodingTable[(short)characters[i]];
			if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
			{
				free(bytes);
				return nil;
			}
		}
		
		if (bufferLength == 0)
			break;
		if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
		{
			free(bytes);
			return nil;
		}
		
		//  Decode the characters in the buffer to bytes.
		bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
		if (bufferLength > 2)
			bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
		if (bufferLength > 3)
			bytes[length++] = (buffer[2] << 6) | buffer[3];
	}
	
	realloc(bytes, length);
	return [NSData dataWithBytesNoCopy:bytes length:length];
}

+ (NSString *)encodeData64:(NSData *)data {
    if (data == nil)
        return nil;
	if ([data length] == 0)
		return @"";
    
    char *characters = malloc((([data length] + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < [data length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [data length])
			buffer[bufferLength++] = ((char *)[data bytes])[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';
	}
	
	NSString *str = [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

+ (NSString *)encode64:(NSString *)data {
    return [self encodeData64:[data dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (BOOL)isConnectionError:(NSError *)error {
    return ([error domain] == NSURLErrorDomain) && (
        [error code] == -1001 ||
        [error code] == -1004 ||
        [error code] == -1009);
}

+ (BOOL)isUVRecordInvalid:(NSError *)error {
    return [[error domain] isEqualToString:@"uservoice"] && [[[error userInfo] objectForKey:@"type"] isEqualToString:@"record_invalid"];
}

+ (BOOL)isUVRecordInvalid:(NSError *)error forField:(NSString *)field withMessage:(NSString *)message {
    if (![UVUtils isUVRecordInvalid:error])
        return NO;

    NSString *errorStr = [[error userInfo] objectForKey:field];
    if (!errorStr)
        return NO;
    return [errorStr rangeOfString:message].location != NSNotFound;
}

+ (BOOL)isAuthError:(NSError *)error {
    return [error code] == 401;
}

+ (BOOL)isNotFoundError:(NSError *)error {
    return [error code] == 404;
}

+ (NSRegularExpression *)patternForQuery:(NSString *)query {
    NSRegularExpression *termPattern = [NSRegularExpression regularExpressionWithPattern:@"\\b\\w+\\b" options:0 error:nil];
    NSMutableString *pattern = [NSMutableString stringWithString:@"\\b("];
    __block NSString *lastTerm = nil;
    [termPattern enumerateMatchesInString:query options:0 range:NSMakeRange(0, [query length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        if (lastTerm) {
            [pattern appendString:lastTerm];
            [pattern appendString:@"|"];
        }
        lastTerm = [query substringWithRange:[match range]];
    }];
    if (lastTerm) {
        [pattern appendString:lastTerm];
        [pattern appendString:@")"];
        return [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    } else {
        return nil;
    }
}

+ (void)applyStylesheetToNavigationController:(UINavigationController *)navigationController {
    navigationController.navigationBar.tintColor = [UVStyleSheet navigationBarTintColor];
    [navigationController.navigationBar setBackgroundImage:[UVStyleSheet navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    NSMutableDictionary *navbarTitleTextAttributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSValue valueWithUIOffset:UIOffsetMake(0, -1)], UITextAttributeTextShadowOffset, nil] autorelease];
    if ([UVStyleSheet navigationBarTextColor]) {
        [navbarTitleTextAttributes setObject:[UVStyleSheet navigationBarTextColor] forKey:UITextAttributeTextColor];
    }
    if ([UVStyleSheet navigationBarTextShadowColor]) {
        [navbarTitleTextAttributes setObject:[UVStyleSheet navigationBarTextShadowColor] forKey:UITextAttributeTextShadowColor];
    }
    [navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
}

@end
