//
//  NSString+Base64.h
//  UserVoice
//
//  Created by Austin Taylor on 5/23/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Base64)

- (NSData *)decodeBase64EncodedString;
- (NSString *)base64EncodedString;

@end
